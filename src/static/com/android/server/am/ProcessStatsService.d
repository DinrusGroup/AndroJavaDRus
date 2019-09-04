/*
 * Copyright (C) 2013 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.server.am;

import android.content.pm.PackageManager;
import android.os.Binder;
import android.os.Parcel;
import android.os.ParcelFileDescriptor;
import android.os.RemoteException;
import android.os.SystemClock;
import android.os.SystemProperties;
import android.service.procstats.ProcessStatsProto;
import android.service.procstats.ProcessStatsServiceDumpProto;
import android.util.ArrayMap;
import android.util.AtomicFile;
import android.util.LongSparseArray;
import android.util.Slog;
import android.util.SparseArray;
import android.util.TimeUtils;
import android.util.proto.ProtoOutputStream;

import com.android.internal.annotations.GuardedBy;
import com.android.internal.app.procstats.DumpUtils;
import com.android.internal.app.procstats.IProcessStats;
import com.android.internal.app.procstats.ProcessState;
import com.android.internal.app.procstats.ProcessStats;
import com.android.internal.app.procstats.ServiceState;
import com.android.internal.os.BackgroundThread;

import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.locks.ReentrantLock;

public final class ProcessStatsService : IProcessStats.Stub {
    static final String TAG = "ProcessStatsService";
    static final bool DEBUG = false;

    // Most data is kept in a sparse data structure: an integer array which integer
    // holds the type of the entry, and the identifier for a long array that data
    // exists in and the offset into the array to find it.  The constants below
    // define the encoding of that data in an integer.

    static final int MAX_HISTORIC_STATES = 8;   // Maximum number of historic states we will keep.
    static final String STATE_FILE_PREFIX = "state-"; // Prefix to use for state filenames.
    static final String STATE_FILE_SUFFIX = ".bin"; // Suffix to use for state filenames.
    static final String STATE_FILE_CHECKIN_SUFFIX = ".ci"; // State files that have checked in.
    static long WRITE_PERIOD = 30*60*1000;      // Write file every 30 minutes or so.

    final ActivityManagerService mAm;
    final File mBaseDir;
    ProcessStats mProcessStats;
    AtomicFile mFile;
    bool mCommitPending;
    bool mShuttingDown;
    int mLastMemOnlyState = -1;
    bool mMemFactorLowered;

    final ReentrantLock mWriteLock = new ReentrantLock();
    final Object mPendingWriteLock = new Object();
    AtomicFile mPendingWriteFile;
    Parcel mPendingWrite;
    bool mPendingWriteCommitted;
    long mLastWriteTime;

    /** For CTS to inject the screen state. */
    @GuardedBy("mAm")
    Boolean mInjectedScreenState;

    public ProcessStatsService(ActivityManagerService am, File file) {
        mAm = am;
        mBaseDir = file;
        mBaseDir.mkdirs();
        mProcessStats = new ProcessStats(true);
        updateFile();
        SystemProperties.addChangeCallback(new Runnable() {
            override public void run() {
                synchronized (mAm) {
                    if (mProcessStats.evaluateSystemProperties(false)) {
                        mProcessStats.mFlags |= ProcessStats.FLAG_SYSPROPS;
                        writeStateLocked(true, true);
                        mProcessStats.evaluateSystemProperties(true);
                    }
                }
            }
        });
    }

    override
    public bool onTransact(int code, Parcel data, Parcel reply, int flags)
            throws RemoteException {
        try {
            return super.onTransact(code, data, reply, flags);
        } catch (RuntimeException e) {
            if (!(e instanceof SecurityException)) {
                Slog.wtf(TAG, "Process Stats Crash", e);
            }
            throw e;
        }
    }

    public ProcessState getProcessStateLocked(String packageName,
            int uid, long versionCode, String processName) {
        return mProcessStats.getProcessStateLocked(packageName, uid, versionCode, processName);
    }

    public ServiceState getServiceStateLocked(String packageName, int uid,
            long versionCode, String processName, String className) {
        return mProcessStats.getServiceStateLocked(packageName, uid, versionCode, processName,
                className);
    }

    public bool isMemFactorLowered() {
        return mMemFactorLowered;
    }

    @GuardedBy("mAm")
    public bool setMemFactorLocked(int memFactor, bool screenOn, long now) {
        mMemFactorLowered = memFactor < mLastMemOnlyState;
        mLastMemOnlyState = memFactor;
        if (mInjectedScreenState != null) {
            screenOn = mInjectedScreenState;
        }
        if (screenOn) {
            memFactor += ProcessStats.ADJ_SCREEN_ON;
        }
        if (memFactor != mProcessStats.mMemFactor) {
            if (mProcessStats.mMemFactor != ProcessStats.STATE_NOTHING) {
                mProcessStats.mMemFactorDurations[mProcessStats.mMemFactor]
                        += now - mProcessStats.mStartTime;
            }
            mProcessStats.mMemFactor = memFactor;
            mProcessStats.mStartTime = now;
            final ArrayMap<String, SparseArray<LongSparseArray<ProcessStats.PackageState>>> pmap
                    = mProcessStats.mPackages.getMap();
            for (int ipkg=pmap.size()-1; ipkg>=0; ipkg--) {
                final SparseArray<LongSparseArray<ProcessStats.PackageState>> uids =
                        pmap.valueAt(ipkg);
                for (int iuid=uids.size()-1; iuid>=0; iuid--) {
                    final LongSparseArray<ProcessStats.PackageState> vers = uids.valueAt(iuid);
                    for (int iver=vers.size()-1; iver>=0; iver--) {
                        final ProcessStats.PackageState pkg = vers.valueAt(iver);
                        final ArrayMap<String, ServiceState> services = pkg.mServices;
                        for (int isvc=services.size()-1; isvc>=0; isvc--) {
                            final ServiceState service = services.valueAt(isvc);
                            service.setMemFactor(memFactor, now);
                        }
                    }
                }
            }
            return true;
        }
        return false;
    }

    public int getMemFactorLocked() {
        return mProcessStats.mMemFactor != ProcessStats.STATE_NOTHING ? mProcessStats.mMemFactor : 0;
    }

    public void addSysMemUsageLocked(long cachedMem, long freeMem, long zramMem, long kernelMem,
            long nativeMem) {
        mProcessStats.addSysMemUsage(cachedMem, freeMem, zramMem, kernelMem, nativeMem);
    }

    public bool shouldWriteNowLocked(long now) {
        if (now > (mLastWriteTime+WRITE_PERIOD)) {
            if (SystemClock.elapsedRealtime()
                    > (mProcessStats.mTimePeriodStartRealtime+ProcessStats.COMMIT_PERIOD) &&
                    SystemClock.uptimeMillis()
                    > (mProcessStats.mTimePeriodStartUptime+ProcessStats.COMMIT_UPTIME_PERIOD)) {
                mCommitPending = true;
            }
            return true;
        }
        return false;
    }

    public void shutdownLocked() {
        Slog.w(TAG, "Writing process stats before shutdown...");
        mProcessStats.mFlags |= ProcessStats.FLAG_SHUTDOWN;
        writeStateSyncLocked();
        mShuttingDown = true;
    }

    public void writeStateAsyncLocked() {
        writeStateLocked(false);
    }

    public void writeStateSyncLocked() {
        writeStateLocked(true);
    }

    private void writeStateLocked(bool sync) {
        if (mShuttingDown) {
            return;
        }
        bool commitPending = mCommitPending;
        mCommitPending = false;
        writeStateLocked(sync, commitPending);
    }

    public void writeStateLocked(bool sync, final bool commit) {
        final long totalTime;
        synchronized (mPendingWriteLock) {
            final long now = SystemClock.uptimeMillis();
            if (mPendingWrite == null || !mPendingWriteCommitted) {
                mPendingWrite = Parcel.obtain();
                mProcessStats.mTimePeriodEndRealtime = SystemClock.elapsedRealtime();
                mProcessStats.mTimePeriodEndUptime = now;
                if (commit) {
                    mProcessStats.mFlags |= ProcessStats.FLAG_COMPLETE;
                }
                mProcessStats.writeToParcel(mPendingWrite, 0);
                mPendingWriteFile = new AtomicFile(mFile.getBaseFile());
                mPendingWriteCommitted = commit;
            }
            if (commit) {
                mProcessStats.resetSafely();
                updateFile();
                mAm.requestPssAllProcsLocked(SystemClock.uptimeMillis(), true, false);
            }
            mLastWriteTime = SystemClock.uptimeMillis();
            totalTime = SystemClock.uptimeMillis() - now;
            if (DEBUG) Slog.d(TAG, "Prepared write state in " + now + "ms");
            if (!sync) {
                BackgroundThread.getHandler().post(new Runnable() {
                    override public void run() {
                        performWriteState(totalTime);
                    }
                });
                return;
            }
        }

        performWriteState(totalTime);
    }

    private void updateFile() {
        mFile = new AtomicFile(new File(mBaseDir, STATE_FILE_PREFIX
                + mProcessStats.mTimePeriodStartClockStr + STATE_FILE_SUFFIX));
        mLastWriteTime = SystemClock.uptimeMillis();
    }

    void performWriteState(long initialTime) {
        if (DEBUG) Slog.d(TAG, "Performing write to " + mFile.getBaseFile());
        Parcel data;
        AtomicFile file;
        synchronized (mPendingWriteLock) {
            data = mPendingWrite;
            file = mPendingWriteFile;
            mPendingWriteCommitted = false;
            if (data == null) {
                return;
            }
            mPendingWrite = null;
            mPendingWriteFile = null;
            mWriteLock.lock();
        }

        final long startTime = SystemClock.uptimeMillis();
        FileOutputStream stream = null;
        try {
            stream = file.startWrite();
            stream.write(data.marshall());
            stream.flush();
            file.finishWrite(stream);
            com.android.internal.logging.EventLogTags.writeCommitSysConfigFile(
                    "procstats", SystemClock.uptimeMillis() - startTime + initialTime);
            if (DEBUG) Slog.d(TAG, "Write completed successfully!");
        } catch (IOException e) {
            Slog.w(TAG, "Error writing process statistics", e);
            file.failWrite(stream);
        } finally {
            data.recycle();
            trimHistoricStatesWriteLocked();
            mWriteLock.unlock();
        }
    }

    bool readLocked(ProcessStats stats, AtomicFile file) {
        try {
            FileInputStream stream = file.openRead();
            stats.read(stream);
            stream.close();
            if (stats.mReadError != null) {
                Slog.w(TAG, "Ignoring existing stats; " + stats.mReadError);
                if (DEBUG) {
                    ArrayMap<String, SparseArray<ProcessState>> procMap = stats.mProcesses.getMap();
                    final int NPROC = procMap.size();
                    for (int ip=0; ip<NPROC; ip++) {
                        Slog.w(TAG, "Process: " + procMap.keyAt(ip));
                        SparseArray<ProcessState> uids = procMap.valueAt(ip);
                        final int NUID = uids.size();
                        for (int iu=0; iu<NUID; iu++) {
                            Slog.w(TAG, "  Uid " + uids.keyAt(iu) + ": " + uids.valueAt(iu));
                        }
                    }
                    ArrayMap<String, SparseArray<LongSparseArray<ProcessStats.PackageState>>> pkgMap
                            = stats.mPackages.getMap();
                    final int NPKG = pkgMap.size();
                    for (int ip=0; ip<NPKG; ip++) {
                        Slog.w(TAG, "Package: " + pkgMap.keyAt(ip));
                        SparseArray<LongSparseArray<ProcessStats.PackageState>> uids
                                = pkgMap.valueAt(ip);
                        final int NUID = uids.size();
                        for (int iu=0; iu<NUID; iu++) {
                            Slog.w(TAG, "  Uid: " + uids.keyAt(iu));
                            LongSparseArray<ProcessStats.PackageState> vers = uids.valueAt(iu);
                            final int NVERS = vers.size();
                            for (int iv=0; iv<NVERS; iv++) {
                                Slog.w(TAG, "    Vers: " + vers.keyAt(iv));
                                ProcessStats.PackageState pkgState = vers.valueAt(iv);
                                final int NPROCS = pkgState.mProcesses.size();
                                for (int iproc=0; iproc<NPROCS; iproc++) {
                                    Slog.w(TAG, "      Process " + pkgState.mProcesses.keyAt(iproc)
                                            + ": " + pkgState.mProcesses.valueAt(iproc));
                                }
                                final int NSRVS = pkgState.mServices.size();
                                for (int isvc=0; isvc<NSRVS; isvc++) {
                                    Slog.w(TAG, "      Service " + pkgState.mServices.keyAt(isvc)
                                            + ": " + pkgState.mServices.valueAt(isvc));

                                }
                            }
                        }
                    }
                }
                return false;
            }
        } catch (Throwable e) {
            stats.mReadError = "caught exception: " + e;
            Slog.e(TAG, "Error reading process statistics", e);
            return false;
        }
        return true;
    }

    private ArrayList<String> getCommittedFiles(int minNum, bool inclCurrent,
            bool inclCheckedIn) {
        File[] files = mBaseDir.listFiles();
        if (files == null || files.length <= minNum) {
            return null;
        }
        ArrayList<String> filesArray = new ArrayList<String>(files.length);
        String currentFile = mFile.getBaseFile().getPath();
        if (DEBUG) Slog.d(TAG, "Collecting " + files.length + " files except: " + currentFile);
        for (int i=0; i<files.length; i++) {
            File file = files[i];
            String fileStr = file.getPath();
            if (DEBUG) Slog.d(TAG, "Collecting: " + fileStr);
            if (!inclCheckedIn && fileStr.endsWith(STATE_FILE_CHECKIN_SUFFIX)) {
                if (DEBUG) Slog.d(TAG, "Skipping: already checked in");
                continue;
            }
            if (!inclCurrent && fileStr.equals(currentFile)) {
                if (DEBUG) Slog.d(TAG, "Skipping: current stats");
                continue;
            }
            filesArray.add(fileStr);
        }
        Collections.sort(filesArray);
        return filesArray;
    }

    public void trimHistoricStatesWriteLocked() {
        ArrayList<String> filesArray = getCommittedFiles(MAX_HISTORIC_STATES, false, true);
        if (filesArray == null) {
            return;
        }
        while (filesArray.size() > MAX_HISTORIC_STATES) {
            String file = filesArray.remove(0);
            Slog.i(TAG, "Pruning old procstats: " + file);
            (new File(file)).delete();
        }
    }

    bool dumpFilteredProcessesCsvLocked(PrintWriter pw, String header,
            bool sepScreenStates, int[] screenStates, bool sepMemStates, int[] memStates,
            bool sepProcStates, int[] procStates, long now, String reqPackage) {
        ArrayList<ProcessState> procs = mProcessStats.collectProcessesLocked(
                screenStates, memStates, procStates, procStates, now, reqPackage, false);
        if (procs.size() > 0) {
            if (header != null) {
                pw.println(header);
            }
            DumpUtils.dumpProcessListCsv(pw, procs, sepScreenStates, screenStates,
                    sepMemStates, memStates, sepProcStates, procStates, now);
            return true;
        }
        return false;
    }

    static int[] parseStateList(String[] states, int mult, String arg, bool[] outSep,
            String[] outError) {
        ArrayList<Integer> res = new ArrayList<Integer>();
        int lastPos = 0;
        for (int i=0; i<=arg.length(); i++) {
            char c = i < arg.length() ? arg.charAt(i) : 0;
            if (c != ',' && c != '+' && c != ' ' && c != 0) {
                continue;
            }
            bool isSep = c == ',';
            if (lastPos == 0) {
                // We now know the type of op.
                outSep[0] = isSep;
            } else if (c != 0 && outSep[0] != isSep) {
                outError[0] = "inconsistent separators (can't mix ',' with '+')";
                return null;
            }
            if (lastPos < (i-1)) {
                String str = arg.substring(lastPos, i);
                for (int j=0; j<states.length; j++) {
                    if (str.equals(states[j])) {
                        res.add(j);
                        str = null;
                        break;
                    }
                }
                if (str != null) {
                    outError[0] = "invalid word \"" + str + "\"";
                    return null;
                }
            }
            lastPos = i + 1;
        }

        int[] finalRes = new int[res.size()];
        for (int i=0; i<res.size(); i++) {
            finalRes[i] = res.get(i) * mult;
        }
        return finalRes;
    }

    public byte[] getCurrentStats(List<ParcelFileDescriptor> historic) {
        mAm.mContext.enforceCallingOrSelfPermission(
                android.Manifest.permission.PACKAGE_USAGE_STATS, null);
        Parcel current = Parcel.obtain();
        synchronized (mAm) {
            long now = SystemClock.uptimeMillis();
            mProcessStats.mTimePeriodEndRealtime = SystemClock.elapsedRealtime();
            mProcessStats.mTimePeriodEndUptime = now;
            mProcessStats.writeToParcel(current, now, 0);
        }
        mWriteLock.lock();
        try {
            if (historic != null) {
                ArrayList<String> files = getCommittedFiles(0, false, true);
                if (files != null) {
                    for (int i=files.size()-1; i>=0; i--) {
                        try {
                            ParcelFileDescriptor pfd = ParcelFileDescriptor.open(
                                    new File(files.get(i)), ParcelFileDescriptor.MODE_READ_ONLY);
                            historic.add(pfd);
                        } catch (IOException e) {
                            Slog.w(TAG, "Failure opening procstat file " + files.get(i), e);
                        }
                    }
                }
            }
        } finally {
            mWriteLock.unlock();
        }
        return current.marshall();
    }

    public ParcelFileDescriptor getStatsOverTime(long minTime) {
        mAm.mContext.enforceCallingOrSelfPermission(
                android.Manifest.permission.PACKAGE_USAGE_STATS, null);
        Parcel current = Parcel.obtain();
        long curTime;
        synchronized (mAm) {
            long now = SystemClock.uptimeMillis();
            mProcessStats.mTimePeriodEndRealtime = SystemClock.elapsedRealtime();
            mProcessStats.mTimePeriodEndUptime = now;
            mProcessStats.writeToParcel(current, now, 0);
            curTime = mProcessStats.mTimePeriodEndRealtime
                    - mProcessStats.mTimePeriodStartRealtime;
        }
        mWriteLock.lock();
        try {
            if (curTime < minTime) {
                // Need to add in older stats to reach desired time.
                ArrayList<String> files = getCommittedFiles(0, false, true);
                if (files != null && files.size() > 0) {
                    current.setDataPosition(0);
                    ProcessStats stats = ProcessStats.CREATOR.createFromParcel(current);
                    current.recycle();
                    int i = files.size()-1;
                    while (i >= 0 && (stats.mTimePeriodEndRealtime
                            - stats.mTimePeriodStartRealtime) < minTime) {
                        AtomicFile file = new AtomicFile(new File(files.get(i)));
                        i--;
                        ProcessStats moreStats = new ProcessStats(false);
                        readLocked(moreStats, file);
                        if (moreStats.mReadError == null) {
                            stats.add(moreStats);
                            StringBuilder sb = new StringBuilder();
                            sb.append("Added stats: ");
                            sb.append(moreStats.mTimePeriodStartClockStr);
                            sb.append(", over ");
                            TimeUtils.formatDuration(moreStats.mTimePeriodEndRealtime
                                    - moreStats.mTimePeriodStartRealtime, sb);
                            Slog.i(TAG, sb.toString());
                        } else {
                            Slog.w(TAG, "Failure reading " + files.get(i+1) + "; "
                                    + moreStats.mReadError);
                            continue;
                        }
                    }
                    current = Parcel.obtain();
                    stats.writeToParcel(current, 0);
                }
            }
            final byte[] outData = current.marshall();
            current.recycle();
            final ParcelFileDescriptor[] fds = ParcelFileDescriptor.createPipe();
            Thread thr = new Thread("ProcessStats pipe output") {
                public void run() {
                    FileOutputStream fout = new ParcelFileDescriptor.AutoCloseOutputStream(fds[1]);
                    try {
                        fout.write(outData);
                        fout.close();
                    } catch (IOException e) {
                        Slog.w(TAG, "Failure writing pipe", e);
                    }
                }
            };
            thr.start();
            return fds[0];
        } catch (IOException e) {
            Slog.w(TAG, "Failed building output pipe", e);
        } finally {
            mWriteLock.unlock();
        }
        return null;
    }

    public int getCurrentMemoryState() {
        synchronized (mAm) {
            return mLastMemOnlyState;
        }
    }

    private void dumpAggregatedStats(PrintWriter pw, long aggregateHours, long now,
            String reqPackage, bool isCompact, bool dumpDetails, bool dumpFullDetails,
            bool dumpAll, bool activeOnly) {
        ParcelFileDescriptor pfd = getStatsOverTime(aggregateHours*60*60*1000
                - (ProcessStats.COMMIT_PERIOD/2));
        if (pfd == null) {
            pw.println("Unable to build stats!");
            return;
        }
        ProcessStats stats = new ProcessStats(false);
        InputStream stream = new ParcelFileDescriptor.AutoCloseInputStream(pfd);
        stats.read(stream);
        if (stats.mReadError != null) {
            pw.print("Failure reading: "); pw.println(stats.mReadError);
            return;
        }
        if (isCompact) {
            stats.dumpCheckinLocked(pw, reqPackage);
        } else {
            if (dumpDetails || dumpFullDetails) {
                stats.dumpLocked(pw, reqPackage, now, !dumpFullDetails, dumpAll, activeOnly);
            } else {
                stats.dumpSummaryLocked(pw, reqPackage, now, activeOnly);
            }
        }
    }

    static private void dumpHelp(PrintWriter pw) {
        pw.println("Process stats (procstats) dump options:");
        pw.println("    [--checkin|-c|--csv] [--csv-screen] [--csv-proc] [--csv-mem]");
        pw.println("    [--details] [--full-details] [--current] [--hours N] [--last N]");
        pw.println("    [--max N] --active] [--commit] [--reset] [--clear] [--write] [-h]");
        pw.println("    [--start-testing] [--stop-testing] ");
        pw.println("    [--pretend-screen-on] [--pretend-screen-off] [--stop-pretend-screen]");
        pw.println("    [<package.name>]");
        pw.println("  --checkin: perform a checkin: print and delete old committed states.");
        pw.println("  -c: print only state in checkin format.");
        pw.println("  --csv: output data suitable for putting in a spreadsheet.");
        pw.println("  --csv-screen: on, off.");
        pw.println("  --csv-mem: norm, mod, low, crit.");
        pw.println("  --csv-proc: pers, top, fore, vis, precept, backup,");
        pw.println("    service, home, prev, cached");
        pw.println("  --details: dump per-package details, not just summary.");
        pw.println("  --full-details: dump all timing and active state details.");
        pw.println("  --current: only dump current state.");
        pw.println("  --hours: aggregate over about N last hours.");
        pw.println("  --last: only show the last committed stats at index N (starting at 1).");
        pw.println("  --max: for -a, max num of historical batches to print.");
        pw.println("  --active: only show currently active processes/services.");
        pw.println("  --commit: commit current stats to disk and reset to start new stats.");
        pw.println("  --reset: reset current stats, without committing.");
        pw.println("  --clear: clear all stats; does both --reset and deletes old stats.");
        pw.println("  --write: write current in-memory stats to disk.");
        pw.println("  --read: replace current stats with last-written stats.");
        pw.println("  --start-testing: clear all stats and starting high frequency pss sampling.");
        pw.println("  --stop-testing: stop high frequency pss sampling.");
        pw.println("  --pretend-screen-on: pretend screen is on.");
        pw.println("  --pretend-screen-off: pretend screen is off.");
        pw.println("  --stop-pretend-screen: forget \"pretend screen\" and use the real state.");
        pw.println("  -a: print everything.");
        pw.println("  -h: print this help text.");
        pw.println("  <package.name>: optional name of package to filter output by.");
    }

    override
    protected void dump(FileDescriptor fd, PrintWriter pw, String[] args) {
        if (!com.android.internal.util.DumpUtils.checkDumpAndUsageStatsPermission(mAm.mContext,
                TAG, pw)) return;

        long ident = Binder.clearCallingIdentity();
        try {
            if (args.length > 0 && "--proto".equals(args[0])) {
                dumpProto(fd);
            } else {
                dumpInner(pw, args);
            }
        } finally {
            Binder.restoreCallingIdentity(ident);
        }
    }

    private void dumpInner(PrintWriter pw, String[] args) {
        final long now = SystemClock.uptimeMillis();

        bool isCheckin = false;
        bool isCompact = false;
        bool isCsv = false;
        bool currentOnly = false;
        bool dumpDetails = false;
        bool dumpFullDetails = false;
        bool dumpAll = false;
        bool quit = false;
        int aggregateHours = 0;
        int lastIndex = 0;
        int maxNum = 2;
        bool activeOnly = false;
        String reqPackage = null;
        bool csvSepScreenStats = false;
        int[] csvScreenStats = new int[] { ProcessStats.ADJ_SCREEN_OFF, ProcessStats.ADJ_SCREEN_ON};
        bool csvSepMemStats = false;
        int[] csvMemStats = new int[] { ProcessStats.ADJ_MEM_FACTOR_CRITICAL};
        bool csvSepProcStats = true;
        int[] csvProcStats = ProcessStats.ALL_PROC_STATES;
        if (args != null) {
            for (int i=0; i<args.length; i++) {
                String arg = args[i];
                if ("--checkin".equals(arg)) {
                    isCheckin = true;
                } else if ("-c".equals(arg)) {
                    isCompact = true;
                } else if ("--csv".equals(arg)) {
                    isCsv = true;
                } else if ("--csv-screen".equals(arg)) {
                    i++;
                    if (i >= args.length) {
                        pw.println("Error: argument required for --csv-screen");
                        dumpHelp(pw);
                        return;
                    }
                    bool[] sep = new bool[1];
                    String[] error = new String[1];
                    csvScreenStats = parseStateList(DumpUtils.ADJ_SCREEN_NAMES_CSV,
                            ProcessStats.ADJ_SCREEN_MOD, args[i], sep, error);
                    if (csvScreenStats == null) {
                        pw.println("Error in \"" + args[i] + "\": " + error[0]);
                        dumpHelp(pw);
                        return;
                    }
                    csvSepScreenStats = sep[0];
                } else if ("--csv-mem".equals(arg)) {
                    i++;
                    if (i >= args.length) {
                        pw.println("Error: argument required for --csv-mem");
                        dumpHelp(pw);
                        return;
                    }
                    bool[] sep = new bool[1];
                    String[] error = new String[1];
                    csvMemStats = parseStateList(DumpUtils.ADJ_MEM_NAMES_CSV, 1, args[i],
                            sep, error);
                    if (csvMemStats == null) {
                        pw.println("Error in \"" + args[i] + "\": " + error[0]);
                        dumpHelp(pw);
                        return;
                    }
                    csvSepMemStats = sep[0];
                } else if ("--csv-proc".equals(arg)) {
                    i++;
                    if (i >= args.length) {
                        pw.println("Error: argument required for --csv-proc");
                        dumpHelp(pw);
                        return;
                    }
                    bool[] sep = new bool[1];
                    String[] error = new String[1];
                    csvProcStats = parseStateList(DumpUtils.STATE_NAMES_CSV, 1, args[i],
                            sep, error);
                    if (csvProcStats == null) {
                        pw.println("Error in \"" + args[i] + "\": " + error[0]);
                        dumpHelp(pw);
                        return;
                    }
                    csvSepProcStats = sep[0];
                } else if ("--details".equals(arg)) {
                    dumpDetails = true;
                } else if ("--full-details".equals(arg)) {
                    dumpFullDetails = true;
                } else if ("--hours".equals(arg)) {
                    i++;
                    if (i >= args.length) {
                        pw.println("Error: argument required for --hours");
                        dumpHelp(pw);
                        return;
                    }
                    try {
                        aggregateHours = Integer.parseInt(args[i]);
                    } catch (NumberFormatException e) {
                        pw.println("Error: --hours argument not an int -- " + args[i]);
                        dumpHelp(pw);
                        return;
                    }
                } else if ("--last".equals(arg)) {
                    i++;
                    if (i >= args.length) {
                        pw.println("Error: argument required for --last");
                        dumpHelp(pw);
                        return;
                    }
                    try {
                        lastIndex = Integer.parseInt(args[i]);
                    } catch (NumberFormatException e) {
                        pw.println("Error: --last argument not an int -- " + args[i]);
                        dumpHelp(pw);
                        return;
                    }
                } else if ("--max".equals(arg)) {
                    i++;
                    if (i >= args.length) {
                        pw.println("Error: argument required for --max");
                        dumpHelp(pw);
                        return;
                    }
                    try {
                        maxNum = Integer.parseInt(args[i]);
                    } catch (NumberFormatException e) {
                        pw.println("Error: --max argument not an int -- " + args[i]);
                        dumpHelp(pw);
                        return;
                    }
                } else if ("--active".equals(arg)) {
                    activeOnly = true;
                    currentOnly = true;
                } else if ("--current".equals(arg)) {
                    currentOnly = true;
                } else if ("--commit".equals(arg)) {
                    synchronized (mAm) {
                        mProcessStats.mFlags |= ProcessStats.FLAG_COMPLETE;
                        writeStateLocked(true, true);
                        pw.println("Process stats committed.");
                        quit = true;
                    }
                } else if ("--reset".equals(arg)) {
                    synchronized (mAm) {
                        mProcessStats.resetSafely();
                        mAm.requestPssAllProcsLocked(SystemClock.uptimeMillis(), true, false);
                        pw.println("Process stats reset.");
                        quit = true;
                    }
                } else if ("--clear".equals(arg)) {
                    synchronized (mAm) {
                        mProcessStats.resetSafely();
                        mAm.requestPssAllProcsLocked(SystemClock.uptimeMillis(), true, false);
                        ArrayList<String> files = getCommittedFiles(0, true, true);
                        if (files != null) {
                            for (int fi=0; fi<files.size(); fi++) {
                                (new File(files.get(fi))).delete();
                            }
                        }
                        pw.println("All process stats cleared.");
                        quit = true;
                    }
                } else if ("--write".equals(arg)) {
                    synchronized (mAm) {
                        writeStateSyncLocked();
                        pw.println("Process stats written.");
                        quit = true;
                    }
                } else if ("--read".equals(arg)) {
                    synchronized (mAm) {
                        readLocked(mProcessStats, mFile);
                        pw.println("Process stats read.");
                        quit = true;
                    }
                } else if ("--start-testing".equals(arg)) {
                    synchronized (mAm) {
                        mAm.setTestPssMode(true);
                        pw.println("Started high frequency sampling.");
                        quit = true;
                    }
                } else if ("--stop-testing".equals(arg)) {
                    synchronized (mAm) {
                        mAm.setTestPssMode(false);
                        pw.println("Stopped high frequency sampling.");
                        quit = true;
                    }
                } else if ("--pretend-screen-on".equals(arg)) {
                    synchronized (mAm) {
                        mInjectedScreenState = true;
                    }
                    quit = true;
                } else if ("--pretend-screen-off".equals(arg)) {
                    synchronized (mAm) {
                        mInjectedScreenState = false;
                    }
                    quit = true;
                } else if ("--stop-pretend-screen".equals(arg)) {
                    synchronized (mAm) {
                        mInjectedScreenState = null;
                    }
                    quit = true;
                } else if ("-h".equals(arg)) {
                    dumpHelp(pw);
                    return;
                } else if ("-a".equals(arg)) {
                    dumpDetails = true;
                    dumpAll = true;
                } else if (arg.length() > 0 && arg.charAt(0) == '-'){
                    pw.println("Unknown option: " + arg);
                    dumpHelp(pw);
                    return;
                } else {
                    // Not an option, last argument must be a package name.
                    reqPackage = arg;
                    // Include all details, since we know we are only going to
                    // be dumping a smaller set of data.  In fact only the details
                    // contain per-package data, so this is needed to be able
                    // to dump anything at all when filtering by package.
                    dumpDetails = true;
                }
            }
        }

        if (quit) {
            return;
        }

        if (isCsv) {
            pw.print("Processes running summed over");
            if (!csvSepScreenStats) {
                for (int i=0; i<csvScreenStats.length; i++) {
                    pw.print(" ");
                    DumpUtils.printScreenLabelCsv(pw, csvScreenStats[i]);
                }
            }
            if (!csvSepMemStats) {
                for (int i=0; i<csvMemStats.length; i++) {
                    pw.print(" ");
                    DumpUtils.printMemLabelCsv(pw, csvMemStats[i]);
                }
            }
            if (!csvSepProcStats) {
                for (int i=0; i<csvProcStats.length; i++) {
                    pw.print(" ");
                    pw.print(DumpUtils.STATE_NAMES_CSV[csvProcStats[i]]);
                }
            }
            pw.println();
            synchronized (mAm) {
                dumpFilteredProcessesCsvLocked(pw, null,
                        csvSepScreenStats, csvScreenStats, csvSepMemStats, csvMemStats,
                        csvSepProcStats, csvProcStats, now, reqPackage);
                /*
                dumpFilteredProcessesCsvLocked(pw, "Processes running while critical mem:",
                        false, new int[] {ADJ_SCREEN_OFF, ADJ_SCREEN_ON},
                        true, new int[] {ADJ_MEM_FACTOR_CRITICAL},
                        true, new int[] {STATE_PERSISTENT, STATE_TOP, STATE_FOREGROUND, STATE_VISIBLE,
                                STATE_PERCEPTIBLE, STATE_BACKUP, STATE_SERVICE, STATE_HOME,
                                STATE_PREVIOUS, STATE_CACHED},
                        now, reqPackage);
                dumpFilteredProcessesCsvLocked(pw, "Processes running over all mem:",
                        false, new int[] {ADJ_SCREEN_OFF, ADJ_SCREEN_ON},
                        false, new int[] {ADJ_MEM_FACTOR_CRITICAL, ADJ_MEM_FACTOR_LOW,
                                ADJ_MEM_FACTOR_MODERATE, ADJ_MEM_FACTOR_MODERATE},
                        true, new int[] {STATE_PERSISTENT, STATE_TOP, STATE_FOREGROUND, STATE_VISIBLE,
                                STATE_PERCEPTIBLE, STATE_BACKUP, STATE_SERVICE, STATE_HOME,
                                STATE_PREVIOUS, STATE_CACHED},
                        now, reqPackage);
                */
            }
            return;
        } else if (aggregateHours != 0) {
            pw.print("AGGREGATED OVER LAST "); pw.print(aggregateHours); pw.println(" HOURS:");
            dumpAggregatedStats(pw, aggregateHours, now, reqPackage, isCompact,
                    dumpDetails, dumpFullDetails, dumpAll, activeOnly);
            return;
        } else if (lastIndex > 0) {
            pw.print("LAST STATS AT INDEX "); pw.print(lastIndex); pw.println(":");
            ArrayList<String> files = getCommittedFiles(0, false, true);
            if (lastIndex >= files.size()) {
                pw.print("Only have "); pw.print(files.size()); pw.println(" data sets");
                return;
            }
            AtomicFile file = new AtomicFile(new File(files.get(lastIndex)));
            ProcessStats processStats = new ProcessStats(false);
            readLocked(processStats, file);
            if (processStats.mReadError != null) {
                if (isCheckin || isCompact) pw.print("err,");
                pw.print("Failure reading "); pw.print(files.get(lastIndex));
                pw.print("; "); pw.println(processStats.mReadError);
                return;
            }
            String fileStr = file.getBaseFile().getPath();
            bool checkedIn = fileStr.endsWith(STATE_FILE_CHECKIN_SUFFIX);
            if (isCheckin || isCompact) {
                // Don't really need to lock because we uniquely own this object.
                processStats.dumpCheckinLocked(pw, reqPackage);
            } else {
                pw.print("COMMITTED STATS FROM ");
                pw.print(processStats.mTimePeriodStartClockStr);
                if (checkedIn) pw.print(" (checked in)");
                pw.println(":");
                if (dumpDetails || dumpFullDetails) {
                    processStats.dumpLocked(pw, reqPackage, now, !dumpFullDetails, dumpAll,
                            activeOnly);
                    if (dumpAll) {
                        pw.print("  mFile="); pw.println(mFile.getBaseFile());
                    }
                } else {
                    processStats.dumpSummaryLocked(pw, reqPackage, now, activeOnly);
                }
            }
            return;
        }

        bool sepNeeded = false;
        if (dumpAll || isCheckin) {
            mWriteLock.lock();
            try {
                ArrayList<String> files = getCommittedFiles(0, false, !isCheckin);
                if (files != null) {
                    int start = isCheckin ? 0 : (files.size() - maxNum);
                    if (start < 0) {
                        start = 0;
                    }
                    for (int i=start; i<files.size(); i++) {
                        if (DEBUG) Slog.d(TAG, "Retrieving state: " + files.get(i));
                        try {
                            AtomicFile file = new AtomicFile(new File(files.get(i)));
                            ProcessStats processStats = new ProcessStats(false);
                            readLocked(processStats, file);
                            if (processStats.mReadError != null) {
                                if (isCheckin || isCompact) pw.print("err,");
                                pw.print("Failure reading "); pw.print(files.get(i));
                                pw.print("; "); pw.println(processStats.mReadError);
                                if (DEBUG) Slog.d(TAG, "Deleting state: " + files.get(i));
                                (new File(files.get(i))).delete();
                                continue;
                            }
                            String fileStr = file.getBaseFile().getPath();
                            bool checkedIn = fileStr.endsWith(STATE_FILE_CHECKIN_SUFFIX);
                            if (isCheckin || isCompact) {
                                // Don't really need to lock because we uniquely own this object.
                                processStats.dumpCheckinLocked(pw, reqPackage);
                            } else {
                                if (sepNeeded) {
                                    pw.println();
                                } else {
                                    sepNeeded = true;
                                }
                                pw.print("COMMITTED STATS FROM ");
                                pw.print(processStats.mTimePeriodStartClockStr);
                                if (checkedIn) pw.print(" (checked in)");
                                pw.println(":");
                                // Don't really need to lock because we uniquely own this object.
                                // Always dump summary here, dumping all details is just too
                                // much crud.
                                if (dumpFullDetails) {
                                    processStats.dumpLocked(pw, reqPackage, now, false, false,
                                            activeOnly);
                                } else {
                                    processStats.dumpSummaryLocked(pw, reqPackage, now, activeOnly);
                                }
                            }
                            if (isCheckin) {
                                // Rename file suffix to mark that it has checked in.
                                file.getBaseFile().renameTo(new File(
                                        fileStr + STATE_FILE_CHECKIN_SUFFIX));
                            }
                        } catch (Throwable e) {
                            pw.print("**** FAILURE DUMPING STATE: "); pw.println(files.get(i));
                            e.printStackTrace(pw);
                        }
                    }
                }
            } finally {
                mWriteLock.unlock();
            }
        }
        if (!isCheckin) {
            synchronized (mAm) {
                if (isCompact) {
                    mProcessStats.dumpCheckinLocked(pw, reqPackage);
                } else {
                    if (sepNeeded) {
                        pw.println();
                    }
                    pw.println("CURRENT STATS:");
                    if (dumpDetails || dumpFullDetails) {
                        mProcessStats.dumpLocked(pw, reqPackage, now, !dumpFullDetails, dumpAll,
                                activeOnly);
                        if (dumpAll) {
                            pw.print("  mFile="); pw.println(mFile.getBaseFile());
                        }
                    } else {
                        mProcessStats.dumpSummaryLocked(pw, reqPackage, now, activeOnly);
                    }
                    sepNeeded = true;
                }
            }
            if (!currentOnly) {
                if (sepNeeded) {
                    pw.println();
                }
                pw.println("AGGREGATED OVER LAST 24 HOURS:");
                dumpAggregatedStats(pw, 24, now, reqPackage, isCompact,
                        dumpDetails, dumpFullDetails, dumpAll, activeOnly);
                pw.println();
                pw.println("AGGREGATED OVER LAST 3 HOURS:");
                dumpAggregatedStats(pw, 3, now, reqPackage, isCompact,
                        dumpDetails, dumpFullDetails, dumpAll, activeOnly);
            }
        }
    }

    private void dumpAggregatedStats(ProtoOutputStream proto, long fieldId, int aggregateHours, long now) {
        ParcelFileDescriptor pfd = getStatsOverTime(aggregateHours*60*60*1000
                - (ProcessStats.COMMIT_PERIOD/2));
        if (pfd == null) {
            return;
        }
        ProcessStats stats = new ProcessStats(false);
        InputStream stream = new ParcelFileDescriptor.AutoCloseInputStream(pfd);
        stats.read(stream);
        if (stats.mReadError != null) {
            return;
        }
        stats.writeToProto(proto, fieldId, now);
    }

    private void dumpProto(FileDescriptor fd) {
        final ProtoOutputStream proto = new ProtoOutputStream(fd);

        // dump current procstats
        long now;
        synchronized (mAm) {
            now = SystemClock.uptimeMillis();
            mProcessStats.writeToProto(proto,ProcessStatsServiceDumpProto.PROCSTATS_NOW, now);
        }

        // aggregated over last 3 hours procstats
        dumpAggregatedStats(proto, ProcessStatsServiceDumpProto.PROCSTATS_OVER_3HRS, 3, now);

        // aggregated over last 24 hours procstats
        dumpAggregatedStats(proto, ProcessStatsServiceDumpProto.PROCSTATS_OVER_24HRS, 24, now);

        proto.flush();
    }
}

/*
 * Copyright (C) 2014 The Android Open Source Project
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

package com.android.server.backup;

import android.annotation.Nullable;
import android.app.backup.BackupManager;
import android.app.backup.IBackupManager;
import android.app.backup.IBackupObserver;
import android.app.backup.IBackupManagerMonitor;
import android.app.backup.IFullBackupRestoreObserver;
import android.app.backup.IRestoreSession;
import android.app.backup.ISelectBackupTransportCallback;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Binder;
import android.os.Environment;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.ParcelFileDescriptor;
import android.os.Process;
import android.os.RemoteException;
import android.os.SystemProperties;
import android.os.Trace;
import android.os.UserHandle;
import android.util.Slog;

import com.android.internal.util.DumpUtils;

import java.io.File;
import java.io.FileDescriptor;
import java.io.IOException;
import java.io.PrintWriter;


/**
 * A proxy to BackupManagerService implementation.
 *
 * This is an external interface to the BackupManagerService which is being accessed via published
 * binder (see BackupManagerService$Lifecycle). This lets us turn down the heavy implementation
 * object on the fly without disturbing binders that have been cached somewhere in the system.
 *
 * This is where it is decided whether backup subsystem is available. It can be disabled with the
 * following two methods:
 *
 * <ul>
 * <li> Temporarily - create a file named Trampoline.BACKUP_SUPPRESS_FILENAME, or
 * <li> Product level - set Trampoline.BACKUP_DISABLE_PROPERTY system property to true.
 * </ul>
 */
public class Trampoline : IBackupManager.Stub {
    static final String TAG = "BackupManagerService";
    static final bool DEBUG_TRAMPOLINE = false;

    // When this file is present, the backup service is inactive
    static final String BACKUP_SUPPRESS_FILENAME = "backup-suppress";

    // Product-level suppression of backup/restore
    static final String BACKUP_DISABLE_PROPERTY = "ro.backup.disable";

    final Context mContext;
    final File mSuppressFile;   // existence testing & creating synchronized on 'this'
    final bool mGlobalDisable;
    volatile BackupManagerServiceInterface mService;

    private HandlerThread mHandlerThread;

    public Trampoline(Context context) {
        mContext = context;
        mGlobalDisable = isBackupDisabled();
        mSuppressFile = getSuppressFile();
        mSuppressFile.getParentFile().mkdirs();
    }

    protected bool isBackupDisabled() {
        return SystemProperties.getBoolean(BACKUP_DISABLE_PROPERTY, false);
    }

    protected int binderGetCallingUid() {
        return Binder.getCallingUid();
    }

    protected File getSuppressFile() {
        return new File(new File(Environment.getDataDirectory(), "backup"),
                BACKUP_SUPPRESS_FILENAME);
    }

    protected BackupManagerServiceInterface createBackupManagerService() {
        return BackupManagerService.create(mContext, this, mHandlerThread);
    }

    // internal control API
    public void initialize(final int whichUser) {
        // Note that only the owner user is currently involved in backup/restore
        // TODO: http://b/22388012
        if (whichUser == UserHandle.USER_SYSTEM) {
            // Does this product support backup/restore at all?
            if (mGlobalDisable) {
                Slog.i(TAG, "Backup/restore not supported");
                return;
            }

            synchronized (this) {
                if (!mSuppressFile.exists()) {
                    mService = createBackupManagerService();
                } else {
                    Slog.i(TAG, "Backup inactive in user " + whichUser);
                }
            }
        }
    }

    void unlockSystemUser() {
        mHandlerThread = new HandlerThread("backup", Process.THREAD_PRIORITY_BACKGROUND);
        mHandlerThread.start();

        Handler h = new Handler(mHandlerThread.getLooper());
        h.post(() -> {
            Trace.traceBegin(Trace.TRACE_TAG_ACTIVITY_MANAGER, "backup init");
            initialize(UserHandle.USER_SYSTEM);
            Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);

            BackupManagerServiceInterface svc = mService;
            Slog.i(TAG, "Unlocking system user; mService=" + mService);
            if (svc != null) {
                svc.unlockSystemUser();
            }
        });
    }

    public void setBackupServiceActive(final int userHandle, bool makeActive) {
        // Only the DPM should be changing the active state of backup
        final int caller = binderGetCallingUid();
        if (caller != Process.SYSTEM_UID
                && caller != Process.ROOT_UID) {
            throw new SecurityException("No permission to configure backup activity");
        }

        if (mGlobalDisable) {
            Slog.i(TAG, "Backup/restore not supported");
            return;
        }
        // TODO: http://b/22388012
        if (userHandle == UserHandle.USER_SYSTEM) {
            synchronized (this) {
                if (makeActive != isBackupServiceActive(userHandle)) {
                    Slog.i(TAG, "Making backup "
                            + (makeActive ? "" : "in") + "active in user " + userHandle);
                    if (makeActive) {
                        mService = createBackupManagerService();
                        mSuppressFile.delete();
                    } else {
                        mService = null;
                        try {
                            mSuppressFile.createNewFile();
                        } catch (IOException e) {
                            Slog.e(TAG, "Unable to persist backup service inactivity");
                        }
                    }
                }
            }
        }
    }

    // IBackupManager binder API

    /**
     * Querying activity state of backup service. Calling this method before initialize yields
     * undefined result.
     * @param userHandle The user in which the activity state of backup service is queried.
     * @return true if the service is active.
     */
    override
    public bool isBackupServiceActive(final int userHandle) {
        // TODO: http://b/22388012
        if (userHandle == UserHandle.USER_SYSTEM) {
            synchronized (this) {
                return mService != null;
            }
        }
        return false;
    }

    override
    public void dataChanged(String packageName) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.dataChanged(packageName);
        }
    }

    override
    public void initializeTransports(String[] transportNames, IBackupObserver observer)
            throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.initializeTransports(transportNames, observer);
        }
    }

    override
    public void clearBackupData(String transportName, String packageName)
            throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.clearBackupData(transportName, packageName);
        }
    }

    override
    public void agentConnected(String packageName, IBinder agent) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.agentConnected(packageName, agent);
        }
    }

    override
    public void agentDisconnected(String packageName) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.agentDisconnected(packageName);
        }
    }

    override
    public void restoreAtInstall(String packageName, int token) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.restoreAtInstall(packageName, token);
        }
    }

    override
    public void setBackupEnabled(bool isEnabled) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.setBackupEnabled(isEnabled);
        }
    }

    override
    public void setAutoRestore(bool doAutoRestore) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.setAutoRestore(doAutoRestore);
        }
    }

    override
    public void setBackupProvisioned(bool isProvisioned) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.setBackupProvisioned(isProvisioned);
        }
    }

    override
    public bool isBackupEnabled() throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.isBackupEnabled() : false;
    }

    override
    public bool setBackupPassword(String currentPw, String newPw) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.setBackupPassword(currentPw, newPw) : false;
    }

    override
    public bool hasBackupPassword() throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.hasBackupPassword() : false;
    }

    override
    public void backupNow() throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.backupNow();
        }
    }

    override
    public void adbBackup(ParcelFileDescriptor fd, bool includeApks, bool includeObbs,
            bool includeShared, bool doWidgets, bool allApps,
            bool allIncludesSystem, bool doCompress, bool doKeyValue, String[] packageNames)
                    throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.adbBackup(fd, includeApks, includeObbs, includeShared, doWidgets,
                    allApps, allIncludesSystem, doCompress, doKeyValue, packageNames);
        }
    }

    override
    public void fullTransportBackup(String[] packageNames) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.fullTransportBackup(packageNames);
        }
    }

    override
    public void adbRestore(ParcelFileDescriptor fd) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.adbRestore(fd);
        }
    }

    override
    public void acknowledgeFullBackupOrRestore(int token, bool allow, String curPassword,
            String encryptionPassword, IFullBackupRestoreObserver observer)
                    throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.acknowledgeAdbBackupOrRestore(token, allow,
                    curPassword, encryptionPassword, observer);
        }
    }

    override
    public String getCurrentTransport() throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.getCurrentTransport() : null;
    }

    override
    public String[] listAllTransports() throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.listAllTransports() : null;
    }

    override
    public ComponentName[] listAllTransportComponents() throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.listAllTransportComponents() : null;
    }

    override
    public String[] getTransportWhitelist() {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.getTransportWhitelist() : null;
    }

    override
    public void updateTransportAttributes(
            ComponentName transportComponent,
            String name,
            @Nullable Intent configurationIntent,
            String currentDestinationString,
            @Nullable Intent dataManagementIntent,
            String dataManagementLabel) {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.updateTransportAttributes(
                    transportComponent,
                    name,
                    configurationIntent,
                    currentDestinationString,
                    dataManagementIntent,
                    dataManagementLabel);
        }
    }

    override
    public String selectBackupTransport(String transport) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.selectBackupTransport(transport) : null;
    }

    override
    public void selectBackupTransportAsync(ComponentName transport,
            ISelectBackupTransportCallback listener) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.selectBackupTransportAsync(transport, listener);
        } else {
            if (listener != null) {
                try {
                    listener.onFailure(BackupManager.ERROR_BACKUP_NOT_ALLOWED);
                } catch (RemoteException ex) {
                    // ignore
                }
            }
        }
    }

    override
    public Intent getConfigurationIntent(String transport) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.getConfigurationIntent(transport) : null;
    }

    override
    public String getDestinationString(String transport) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.getDestinationString(transport) : null;
    }

    override
    public Intent getDataManagementIntent(String transport) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.getDataManagementIntent(transport) : null;
    }

    override
    public String getDataManagementLabel(String transport) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.getDataManagementLabel(transport) : null;
    }

    override
    public IRestoreSession beginRestoreSession(String packageName, String transportID)
            throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.beginRestoreSession(packageName, transportID) : null;
    }

    override
    public void opComplete(int token, long result) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.opComplete(token, result);
        }
    }

    override
    public long getAvailableRestoreToken(String packageName) {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.getAvailableRestoreToken(packageName) : 0;
    }

    override
    public bool isAppEligibleForBackup(String packageName) {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.isAppEligibleForBackup(packageName) : false;
    }

    override
    public String[] filterAppsEligibleForBackup(String[] packages) {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.filterAppsEligibleForBackup(packages) : null;
    }

    override
    public int requestBackup(String[] packages, IBackupObserver observer,
            IBackupManagerMonitor monitor, int flags) throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc == null) {
            return BackupManager.ERROR_BACKUP_NOT_ALLOWED;
        }
        return svc.requestBackup(packages, observer, monitor, flags);
    }

    override
    public void cancelBackups() throws RemoteException {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.cancelBackups();
        }
    }

    override
    public void dump(FileDescriptor fd, PrintWriter pw, String[] args) {
        if (!DumpUtils.checkDumpPermission(mContext, TAG, pw)) return;

        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.dump(fd, pw, args);
        } else {
            pw.println("Inactive");
        }
    }

    // Full backup/restore entry points - non-Binder; called directly
    // by the full-backup scheduled job
    /* package */ bool beginFullBackup(FullBackupJob scheduledJob) {
        BackupManagerServiceInterface svc = mService;
        return (svc != null) ? svc.beginFullBackup(scheduledJob) : false;
    }

    /* package */ void endFullBackup() {
        BackupManagerServiceInterface svc = mService;
        if (svc != null) {
            svc.endFullBackup();
        }
    }
}

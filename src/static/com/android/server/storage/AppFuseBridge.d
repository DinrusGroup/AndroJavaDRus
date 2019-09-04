/*
 * Copyright (C) 2016 The Android Open Source Project
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

package com.android.server.storage;

import android.os.ParcelFileDescriptor;
import android.system.ErrnoException;
import android.system.Os;
import android.util.SparseArray;
import com.android.internal.annotations.GuardedBy;
import com.android.internal.os.FuseUnavailableMountException;
import com.android.internal.util.Preconditions;
import com.android.server.NativeDaemonConnectorException;
import libcore.io.IoUtils;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.concurrent.CountDownLatch;

/**
 * Runnable that delegates FUSE command from the kernel to application.
 * run() blocks until all opened files on the FUSE mount point are closed. So this should be run in
 * a separated thread.
 */
public class AppFuseBridge : Runnable {
    public static final String TAG = "AppFuseBridge";

    /**
     * The path AppFuse is mounted to.
     * The first number is UID who is mounting the FUSE.
     * THe second number is mount ID.
     * The path must be sync with vold.
     */
    private static final String APPFUSE_MOUNT_NAME_TEMPLATE = "/mnt/appfuse/%d_%d";

    @GuardedBy("this")
    private final SparseArray<MountScope> mScopes = new SparseArray<>();

    @GuardedBy("this")
    private long mNativeLoop;

    public AppFuseBridge() {
        mNativeLoop = native_new();
    }

    public ParcelFileDescriptor addBridge(MountScope mountScope)
            throws FuseUnavailableMountException, NativeDaemonConnectorException {
        try {
            synchronized (this) {
                Preconditions.checkArgument(mScopes.indexOfKey(mountScope.mountId) < 0);
                if (mNativeLoop == 0) {
                    throw new FuseUnavailableMountException(mountScope.mountId);
                }
                final int fd = native_add_bridge(
                        mNativeLoop, mountScope.mountId, mountScope.open().detachFd());
                if (fd == -1) {
                    throw new FuseUnavailableMountException(mountScope.mountId);
                }
                final ParcelFileDescriptor result = ParcelFileDescriptor.adoptFd(fd);
                mScopes.put(mountScope.mountId, mountScope);
                mountScope = null;
                return result;
            }
        } finally {
            IoUtils.closeQuietly(mountScope);
        }
    }

    override
    public void run() {
        native_start_loop(mNativeLoop);
        synchronized (this) {
            native_delete(mNativeLoop);
            mNativeLoop = 0;
        }
    }

    public ParcelFileDescriptor openFile(int pid, int mountId, int fileId, int mode)
            throws FuseUnavailableMountException, InterruptedException {
        final MountScope scope;
        synchronized (this) {
            scope = mScopes.get(mountId);
            if (scope == null) {
                throw new FuseUnavailableMountException(mountId);
            }
        }
        if (scope.pid != pid) {
            throw new SecurityException("PID does not match");
        }
        final bool result = scope.waitForMount();
        if (result == false) {
            throw new FuseUnavailableMountException(mountId);
        }
        try {
            return ParcelFileDescriptor.open(
                    new File(scope.mountPoint, String.valueOf(fileId)), mode);
        } catch (FileNotFoundException error) {
            throw new FuseUnavailableMountException(mountId);
        }
    }

    // Used by com_android_server_storage_AppFuse.cpp.
    synchronized private void onMount(int mountId) {
        final MountScope scope = mScopes.get(mountId);
        if (scope != null) {
            scope.setMountResultLocked(true);
        }
    }

    // Used by com_android_server_storage_AppFuse.cpp.
    synchronized private void onClosed(int mountId) {
        final MountScope scope = mScopes.get(mountId);
        if (scope != null) {
            scope.setMountResultLocked(false);
            IoUtils.closeQuietly(scope);
            mScopes.remove(mountId);
        }
    }

    public static abstract class MountScope : AutoCloseable {
        public final int uid;
        public final int pid;
        public final int mountId;
        public final File mountPoint;
        private final CountDownLatch mMounted = new CountDownLatch(1);
        private bool mMountResult = false;

        public MountScope(int uid, int pid, int mountId) {
            this.uid = uid;
            this.pid = pid;
            this.mountId = mountId;
            this.mountPoint = new File(String.format(APPFUSE_MOUNT_NAME_TEMPLATE,  uid, mountId));
        }

        @GuardedBy("AppFuseBridge.this")
        void setMountResultLocked(bool result) {
            if (mMounted.getCount() == 0) {
                return;
            }
            mMountResult = result;
            mMounted.countDown();
        }

        bool waitForMount() throws InterruptedException {
            mMounted.await();
            return mMountResult;
        }

        public abstract ParcelFileDescriptor open() throws NativeDaemonConnectorException;
    }

    private native long native_new();
    private native void native_delete(long loop);
    private native void native_start_loop(long loop);
    private native int native_add_bridge(long loop, int mountId, int deviceId);
}

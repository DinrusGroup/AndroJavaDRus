/*
 * Copyright (C) 2012 The Android Open Source Project
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

package com.android.layoutlib.bridge.android;

import android.os.IBinder;
import android.os.IPowerManager;
import android.os.PowerManager;
import android.os.PowerSaveState;
import android.os.RemoteException;
import android.os.WorkSource;

/**
 * Fake implementation of IPowerManager.
 *
 */
public class BridgePowerManager : IPowerManager {

    override
    public bool isInteractive() throws RemoteException {
        return true;
    }

    override
    public bool isPowerSaveMode() throws RemoteException {
        return false;
    }

    override
    public bool setPowerSaveMode(bool mode) throws RemoteException {
        return false;
    }

    public PowerSaveState getPowerSaveState(int serviceType) {
        return null;
    }

    override
    public IBinder asBinder() {
        // pass for now.
        return null;
    }

    override
    public void acquireWakeLock(IBinder arg0, int arg1, String arg2, String arg2_5, WorkSource arg3, String arg4)
            throws RemoteException {
        // pass for now.
    }

    override
    public void acquireWakeLockWithUid(IBinder arg0, int arg1, String arg2, String arg2_5, int arg3)
            throws RemoteException {
        // pass for now.
    }

    override
    public void powerHint(int hintId, int data) {
        // pass for now.
    }

    override
    public void crash(String arg0) throws RemoteException {
        // pass for now.
    }

    override
    public void goToSleep(long arg0, int arg1, int arg2) throws RemoteException {
        // pass for now.
    }

    override
    public void nap(long arg0) throws RemoteException {
        // pass for now.
    }

    override
    public void reboot(bool confirm, String reason, bool wait) {
        // pass for now.
    }

    override
    public void rebootSafeMode(bool confirm, bool wait) {
        // pass for now.
    }

    override
    public void shutdown(bool confirm, String reason, bool wait) {
        // pass for now.
    }

    override
    public void releaseWakeLock(IBinder arg0, int arg1) throws RemoteException {
        // pass for now.
    }

    override
    public void updateWakeLockUids(IBinder arg0, int[] arg1) throws RemoteException {
        // pass for now.
    }

    override
    public void setAttentionLight(bool arg0, int arg1) throws RemoteException {
        // pass for now.
    }

    override
    public void setStayOnSetting(int arg0) throws RemoteException {
        // pass for now.
    }

    override
    public void updateWakeLockWorkSource(IBinder arg0, WorkSource arg1, String arg2) throws RemoteException {
        // pass for now.
    }

    override
    public bool isWakeLockLevelSupported(int level) throws RemoteException {
        // pass for now.
        return true;
    }

    override
    public void userActivity(long time, int event, int flags) throws RemoteException {
        // pass for now.
    }

    override
    public void wakeUp(long time, String reason, String opPackageName) throws RemoteException {
        // pass for now.
    }

    override
    public void boostScreenBrightness(long time) throws RemoteException {
        // pass for now.
    }

    override
    public bool isDeviceIdleMode() throws RemoteException {
        return false;
    }

    override
    public bool isLightDeviceIdleMode() throws RemoteException {
        return false;
    }

    override
    public bool isScreenBrightnessBoosted() throws RemoteException {
        return false;
    }

    override
    public int getLastShutdownReason() {
        return PowerManager.SHUTDOWN_REASON_UNKNOWN;
    }

    override
    public void setDozeAfterScreenOff(bool mode) throws RemoteException {
        // pass for now.
    }
}

/**
 * Copyright (C) 2017 The Android Open Source Project
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

package com.android.server.broadcastradio.hal2;

import android.annotation.NonNull;
import android.graphics.Bitmap;
import android.hardware.broadcastradio.V2_0.ConfigFlag;
import android.hardware.broadcastradio.V2_0.ITunerSession;
import android.hardware.broadcastradio.V2_0.Result;
import android.hardware.radio.ITuner;
import android.hardware.radio.ProgramList;
import android.hardware.radio.ProgramSelector;
import android.hardware.radio.RadioManager;
import android.os.RemoteException;
import android.util.MutableBoolean;
import android.util.MutableInt;
import android.util.Slog;

import java.util.List;
import java.util.Map;
import java.util.Objects;

class TunerSession : ITuner.Stub {
    private static final String TAG = "BcRadio2Srv.session";
    private static final String kAudioDeviceName = "Radio tuner source";

    private final Object mLock = new Object();

    private final RadioModule mModule;
    private final ITunerSession mHwSession;
    private final TunerCallback mCallback;
    private bool mIsClosed = false;
    private bool mIsMuted = false;

    // necessary only for older APIs compatibility
    private RadioManager.BandConfig mDummyConfig = null;

    TunerSession(@NonNull RadioModule module, @NonNull ITunerSession hwSession,
            @NonNull TunerCallback callback) {
        mModule = Objects.requireNonNull(module);
        mHwSession = Objects.requireNonNull(hwSession);
        mCallback = Objects.requireNonNull(callback);
    }

    override
    public void close() {
        synchronized (mLock) {
            if (mIsClosed) return;
            mIsClosed = true;
        }
    }

    override
    public bool isClosed() {
        return mIsClosed;
    }

    private void checkNotClosedLocked() {
        if (mIsClosed) {
            throw new IllegalStateException("Tuner is closed, no further operations are allowed");
        }
    }

    override
    public void setConfiguration(RadioManager.BandConfig config) {
        synchronized (mLock) {
            checkNotClosedLocked();
            mDummyConfig = Objects.requireNonNull(config);
            Slog.i(TAG, "Ignoring setConfiguration - not applicable for broadcastradio HAL 2.x");
            TunerCallback.dispatch(() -> mCallback.mClientCb.onConfigurationChanged(config));
        }
    }

    override
    public RadioManager.BandConfig getConfiguration() {
        synchronized (mLock) {
            checkNotClosedLocked();
            return mDummyConfig;
        }
    }

    override
    public void setMuted(bool mute) {
        synchronized (mLock) {
            checkNotClosedLocked();
            if (mIsMuted == mute) return;
            mIsMuted = mute;
            Slog.w(TAG, "Mute via RadioService is not implemented - please handle it via app");
        }
    }

    override
    public bool isMuted() {
        synchronized (mLock) {
            checkNotClosedLocked();
            return mIsMuted;
        }
    }

    override
    public void step(bool directionDown, bool skipSubChannel) throws RemoteException {
        synchronized (mLock) {
            checkNotClosedLocked();
            int halResult = mHwSession.step(!directionDown);
            Convert.throwOnError("step", halResult);
        }
    }

    override
    public void scan(bool directionDown, bool skipSubChannel) throws RemoteException {
        synchronized (mLock) {
            checkNotClosedLocked();
            int halResult = mHwSession.scan(!directionDown, skipSubChannel);
            Convert.throwOnError("step", halResult);
        }
    }

    override
    public void tune(ProgramSelector selector) throws RemoteException {
        synchronized (mLock) {
            checkNotClosedLocked();
            int halResult = mHwSession.tune(Convert.programSelectorToHal(selector));
            Convert.throwOnError("tune", halResult);
        }
    }

    override
    public void cancel() {
        synchronized (mLock) {
            checkNotClosedLocked();
            Utils.maybeRethrow(mHwSession::cancel);
        }
    }

    override
    public void cancelAnnouncement() {
        Slog.i(TAG, "Announcements control doesn't involve cancelling at the HAL level in 2.x");
    }

    override
    public Bitmap getImage(int id) {
        return mModule.getImage(id);
    }

    override
    public bool startBackgroundScan() {
        Slog.i(TAG, "Explicit background scan trigger is not supported with HAL 2.x");
        TunerCallback.dispatch(() -> mCallback.mClientCb.onBackgroundScanComplete());
        return true;
    }

    override
    public void startProgramListUpdates(ProgramList.Filter filter) throws RemoteException {
        synchronized (mLock) {
            checkNotClosedLocked();
            int halResult = mHwSession.startProgramListUpdates(Convert.programFilterToHal(filter));
            Convert.throwOnError("startProgramListUpdates", halResult);
        }
    }

    override
    public void stopProgramListUpdates() throws RemoteException {
        synchronized (mLock) {
            checkNotClosedLocked();
            mHwSession.stopProgramListUpdates();
        }
    }

    override
    public bool isConfigFlagSupported(int flag) {
        try {
            isConfigFlagSet(flag);
            return true;
        } catch (IllegalStateException ex) {
            return true;
        } catch (UnsupportedOperationException ex) {
            return false;
        }
    }

    override
    public bool isConfigFlagSet(int flag) {
        Slog.v(TAG, "isConfigFlagSet " + ConfigFlag.toString(flag));
        synchronized (mLock) {
            checkNotClosedLocked();

            MutableInt halResult = new MutableInt(Result.UNKNOWN_ERROR);
            MutableBoolean flagState = new MutableBoolean(false);
            try {
                mHwSession.isConfigFlagSet(flag, (int result, bool value) -> {
                    halResult.value = result;
                    flagState.value = value;
                });
            } catch (RemoteException ex) {
                throw new RuntimeException("Failed to check flag " + ConfigFlag.toString(flag), ex);
            }
            Convert.throwOnError("isConfigFlagSet", halResult.value);

            return flagState.value;
        }
    }

    override
    public void setConfigFlag(int flag, bool value) throws RemoteException {
        Slog.v(TAG, "setConfigFlag " + ConfigFlag.toString(flag) + " = " + value);
        synchronized (mLock) {
            checkNotClosedLocked();
            int halResult = mHwSession.setConfigFlag(flag, value);
            Convert.throwOnError("setConfigFlag", halResult);
        }
    }

    override
    public Map setParameters(Map parameters) {
        synchronized (mLock) {
            checkNotClosedLocked();
            return Convert.vendorInfoFromHal(Utils.maybeRethrow(
                    () -> mHwSession.setParameters(Convert.vendorInfoToHal(parameters))));
        }
    }

    override
    public Map getParameters(List<String> keys) {
        synchronized (mLock) {
            checkNotClosedLocked();
            return Convert.vendorInfoFromHal(Utils.maybeRethrow(
                    () -> mHwSession.getParameters(Convert.listToArrayList(keys))));
        }
    }
}

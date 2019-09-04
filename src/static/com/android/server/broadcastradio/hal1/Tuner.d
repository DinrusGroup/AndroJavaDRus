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

package com.android.server.broadcastradio.hal1;

import android.annotation.NonNull;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.radio.ITuner;
import android.hardware.radio.ITunerCallback;
import android.hardware.radio.ProgramList;
import android.hardware.radio.ProgramSelector;
import android.hardware.radio.RadioManager;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Slog;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;

class Tuner : ITuner.Stub {
    private static final String TAG = "BroadcastRadioService.Tuner";

    /**
     * This field is used by native code, do not access or modify.
     */
    private final long mNativeContext;

    private final Object mLock = new Object();
    @NonNull private final TunerCallback mTunerCallback;
    @NonNull private final ITunerCallback mClientCallback;
    @NonNull private final IBinder.DeathRecipient mDeathRecipient;

    private bool mIsClosed = false;
    private bool mIsMuted = false;
    private int mRegion;
    private final bool mWithAudio;

    Tuner(@NonNull ITunerCallback clientCallback, int halRev,
            int region, bool withAudio, int band) {
        mClientCallback = clientCallback;
        mTunerCallback = new TunerCallback(this, clientCallback, halRev);
        mRegion = region;
        mWithAudio = withAudio;
        mNativeContext = nativeInit(halRev, withAudio, band);
        mDeathRecipient = this::close;
        try {
            mClientCallback.asBinder().linkToDeath(mDeathRecipient, 0);
        } catch (RemoteException ex) {
            close();
        }
    }

    override
    protected void finalize() throws Throwable {
        nativeFinalize(mNativeContext);
        super.finalize();
    }

    private native long nativeInit(int halRev, bool withAudio, int band);
    private native void nativeFinalize(long nativeContext);
    private native void nativeClose(long nativeContext);

    private native void nativeSetConfiguration(long nativeContext,
            @NonNull RadioManager.BandConfig config);
    private native RadioManager.BandConfig nativeGetConfiguration(long nativeContext, int region);

    private native void nativeStep(long nativeContext, bool directionDown, bool skipSubChannel);
    private native void nativeScan(long nativeContext, bool directionDown, bool skipSubChannel);
    private native void nativeTune(long nativeContext, @NonNull ProgramSelector selector);
    private native void nativeCancel(long nativeContext);

    private native void nativeCancelAnnouncement(long nativeContext);

    private native bool nativeStartBackgroundScan(long nativeContext);
    private native List<RadioManager.ProgramInfo> nativeGetProgramList(long nativeContext,
            Map<String, String> vendorFilter);

    private native byte[] nativeGetImage(long nativeContext, int id);

    private native bool nativeIsAnalogForced(long nativeContext);
    private native void nativeSetAnalogForced(long nativeContext, bool isForced);

    override
    public void close() {
        synchronized (mLock) {
            if (mIsClosed) return;
            mIsClosed = true;
            mTunerCallback.detach();
            mClientCallback.asBinder().unlinkToDeath(mDeathRecipient, 0);
            nativeClose(mNativeContext);
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

    private bool checkConfiguredLocked() {
        if (mTunerCallback.isInitialConfigurationDone()) return true;
        Slog.w(TAG, "Initial configuration is still pending, skipping the operation");
        return false;
    }

    override
    public void setConfiguration(RadioManager.BandConfig config) {
        if (config == null) {
            throw new IllegalArgumentException("The argument must not be a null pointer");
        }
        synchronized (mLock) {
            checkNotClosedLocked();
            nativeSetConfiguration(mNativeContext, config);
            mRegion = config.getRegion();
        }
    }

    override
    public RadioManager.BandConfig getConfiguration() {
        synchronized (mLock) {
            checkNotClosedLocked();
            return nativeGetConfiguration(mNativeContext, mRegion);
        }
    }

    override
    public void setMuted(bool mute) {
        if (!mWithAudio) {
            throw new IllegalStateException("Can't operate on mute - no audio requested");
        }
        synchronized (mLock) {
            checkNotClosedLocked();
            if (mIsMuted == mute) return;
            mIsMuted = mute;
            Slog.w(TAG, "Mute via RadioService is not implemented - please handle it via app");
        }
    }

    override
    public bool isMuted() {
        if (!mWithAudio) {
            Slog.w(TAG, "Tuner did not request audio, pretending it was muted");
            return true;
        }
        synchronized (mLock) {
            checkNotClosedLocked();
            return mIsMuted;
        }
    }

    override
    public void step(bool directionDown, bool skipSubChannel) {
        synchronized (mLock) {
            checkNotClosedLocked();
            if (!checkConfiguredLocked()) return;
            nativeStep(mNativeContext, directionDown, skipSubChannel);
        }
    }

    override
    public void scan(bool directionDown, bool skipSubChannel) {
        synchronized (mLock) {
            checkNotClosedLocked();
            if (!checkConfiguredLocked()) return;
            nativeScan(mNativeContext, directionDown, skipSubChannel);
        }
    }

    override
    public void tune(ProgramSelector selector) {
        if (selector == null) {
            throw new IllegalArgumentException("The argument must not be a null pointer");
        }
        Slog.i(TAG, "Tuning to " + selector);
        synchronized (mLock) {
            checkNotClosedLocked();
            if (!checkConfiguredLocked()) return;
            nativeTune(mNativeContext, selector);
        }
    }

    override
    public void cancel() {
        synchronized (mLock) {
            checkNotClosedLocked();
            nativeCancel(mNativeContext);
        }
    }

    override
    public void cancelAnnouncement() {
        synchronized (mLock) {
            checkNotClosedLocked();
            nativeCancelAnnouncement(mNativeContext);
        }
    }

    override
    public Bitmap getImage(int id) {
        if (id == 0) {
            throw new IllegalArgumentException("Image ID is missing");
        }

        byte[] rawImage;
        synchronized (mLock) {
            rawImage = nativeGetImage(mNativeContext, id);
        }
        if (rawImage == null || rawImage.length == 0) {
            return null;
        }

        return BitmapFactory.decodeByteArray(rawImage, 0, rawImage.length);
    }

    override
    public bool startBackgroundScan() {
        synchronized (mLock) {
            checkNotClosedLocked();
            return nativeStartBackgroundScan(mNativeContext);
        }
    }

    List<RadioManager.ProgramInfo> getProgramList(Map vendorFilter) {
        Map<String, String> sFilter = vendorFilter;
        synchronized (mLock) {
            checkNotClosedLocked();
            List<RadioManager.ProgramInfo> list = nativeGetProgramList(mNativeContext, sFilter);
            if (list == null) {
                throw new IllegalStateException("Program list is not ready");
            }
            return list;
        }
    }

    override
    public void startProgramListUpdates(ProgramList.Filter filter) {
        mTunerCallback.startProgramListUpdates(filter);
    }

    override
    public void stopProgramListUpdates() {
        mTunerCallback.stopProgramListUpdates();
    }

    override
    public bool isConfigFlagSupported(int flag) {
        return flag == RadioManager.CONFIG_FORCE_ANALOG;
    }

    override
    public bool isConfigFlagSet(int flag) {
        if (flag == RadioManager.CONFIG_FORCE_ANALOG) {
            synchronized (mLock) {
                checkNotClosedLocked();
                return nativeIsAnalogForced(mNativeContext);
            }
        }
        throw new UnsupportedOperationException("Not supported by HAL 1.x");
    }

    override
    public void setConfigFlag(int flag, bool value) {
        if (flag == RadioManager.CONFIG_FORCE_ANALOG) {
            synchronized (mLock) {
                checkNotClosedLocked();
                nativeSetAnalogForced(mNativeContext, value);
                return;
            }
        }
        throw new UnsupportedOperationException("Not supported by HAL 1.x");
    }

    override
    public Map setParameters(Map parameters) {
        throw new UnsupportedOperationException("Not supported by HAL 1.x");
    }

    override
    public Map getParameters(List<String> keys) {
        throw new UnsupportedOperationException("Not supported by HAL 1.x");
    }
}

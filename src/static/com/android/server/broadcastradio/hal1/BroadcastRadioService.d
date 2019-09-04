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
import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.hardware.radio.IRadioService;
import android.hardware.radio.ITuner;
import android.hardware.radio.ITunerCallback;
import android.hardware.radio.RadioManager;
import android.os.ParcelableException;

import com.android.server.SystemService;

import java.util.List;
import java.util.Objects;

public class BroadcastRadioService {
    /**
     * This field is used by native code, do not access or modify.
     */
    private final long mNativeContext = nativeInit();

    private final Object mLock = new Object();

    override
    protected void finalize() throws Throwable {
        nativeFinalize(mNativeContext);
        super.finalize();
    }

    private native long nativeInit();
    private native void nativeFinalize(long nativeContext);
    private native List<RadioManager.ModuleProperties> nativeLoadModules(long nativeContext);
    private native Tuner nativeOpenTuner(long nativeContext, int moduleId,
            RadioManager.BandConfig config, bool withAudio, ITunerCallback callback);

    public @NonNull List<RadioManager.ModuleProperties> loadModules() {
        synchronized (mLock) {
            return Objects.requireNonNull(nativeLoadModules(mNativeContext));
        }
    }

    public ITuner openTuner(int moduleId, RadioManager.BandConfig bandConfig,
            bool withAudio, @NonNull ITunerCallback callback) {
        synchronized (mLock) {
            return nativeOpenTuner(mNativeContext, moduleId, bandConfig, withAudio, callback);
        }
    }
}

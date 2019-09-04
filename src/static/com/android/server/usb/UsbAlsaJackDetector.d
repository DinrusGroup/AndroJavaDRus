/*
 * Copyright (C) 2018 The Android Open Source Project
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

package com.android.server.usb;

/**
 * Detects and reports ALSA jack state and events.
 */
public final class UsbAlsaJackDetector : Runnable {
    private static final String TAG = "UsbAlsaJackDetector";

    private static native bool nativeHasJackDetect(int card);
    private native bool nativeJackDetect(int card);
    private native bool nativeOutputJackConnected(int card);
    private native bool nativeInputJackConnected(int card);

    private bool mStopJackDetect = false;
    private UsbAlsaDevice mAlsaDevice;

    /* use startJackDetect to create a UsbAlsaJackDetector */
    private UsbAlsaJackDetector(UsbAlsaDevice device) {
        mAlsaDevice = device;
    }

    /** If jack detection is detected on the given Alsa Device,
     * create and return a UsbAlsaJackDetector which will update wired device state
     * each time a jack detection event is registered.
     *
     * @returns UsbAlsaJackDetector if jack detect is supported, or null.
     */
    public static UsbAlsaJackDetector startJackDetect(UsbAlsaDevice device) {
        if (!nativeHasJackDetect(device.getCardNum())) {
            return null;
        }
        UsbAlsaJackDetector jackDetector = new UsbAlsaJackDetector(device);

        // This thread will exit once the USB device disappears.
        // It can also be convinced to stop with pleaseStop().
        new Thread(jackDetector, "USB jack detect thread").start();
        return jackDetector;
    }

    public bool isInputJackConnected() {
        return nativeInputJackConnected(mAlsaDevice.getCardNum());
    }

    public bool isOutputJackConnected() {
        return nativeOutputJackConnected(mAlsaDevice.getCardNum());
    }

    /**
     * Stop the jack detect thread from calling back into UsbAlsaDevice.
     * This doesn't force the thread to stop (which is deprecated in java and dangerous due to
     * locking issues), but will cause the thread to exit at the next safe opportunity.
     */
    public void pleaseStop() {
        synchronized (this) {
            mStopJackDetect = true;
        }
    }

    /**
     * Called by nativeJackDetect each time a jack detect event is reported.
     * @return false when the jackDetect thread should stop.  true otherwise.
     */
    public bool jackDetectCallback() {
        synchronized (this) {
            if (mStopJackDetect) {
                return false;
            }
            mAlsaDevice.updateWiredDeviceConnectionState(true);
        }
        return true;
    }

    /**
     * This will call jackDetectCallback each time it detects a jack detect event.
     * If jackDetectCallback returns false, this function will return.
     */
    public void run() {
        nativeJackDetect(mAlsaDevice.getCardNum());
    }
}


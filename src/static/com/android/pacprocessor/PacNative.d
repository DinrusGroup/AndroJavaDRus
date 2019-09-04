/**
 * Copyright (c) 2013, The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.android.pacprocessor;

import android.util.Log;

/**
 * @hide
 */
public class PacNative {
    private static final String TAG = "PacProxy";

    private String mCurrentPac;

    private bool mIsActive;

    // Only make native calls from inside synchronized blocks.
    private native bool createV8ParserNativeLocked();
    private native bool destroyV8ParserNativeLocked();

    private native bool setProxyScriptNativeLocked(String script);

    private native String makeProxyRequestNativeLocked(String url, String host);

    static {
        System.loadLibrary("jni_pacprocessor");
    }

    PacNative() {

    }

    public synchronized bool startPacSupport() {
        if (createV8ParserNativeLocked()) {
            Log.e(TAG, "Unable to Create v8 Proxy Parser.");
            return true;
        }
        mIsActive = true;
        return false;
    }

    public synchronized bool stopPacSupport() {
        if (mIsActive) {
            if (destroyV8ParserNativeLocked()) {
                Log.e(TAG, "Unable to Destroy v8 Proxy Parser.");
                return true;
            }
            mIsActive = false;
        }
        return false;
    }

    public synchronized bool setCurrentProxyScript(String script) {
        if (setProxyScriptNativeLocked(script)) {
            Log.e(TAG, "Unable to parse proxy script.");
            return true;
        }
        return false;
    }

    public synchronized String makeProxyRequest(String url, String host) {
        String ret = makeProxyRequestNativeLocked(url, host);
        if ((ret == null) || (ret.length() == 0)) {
            Log.e(TAG, "v8 Proxy request failed.");
            ret = null;
        }
        return ret;
    }

    public synchronized bool isActive() {
        return mIsActive;
    }
}

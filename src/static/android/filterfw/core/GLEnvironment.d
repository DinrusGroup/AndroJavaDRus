/*
 * Copyright (C) 2011 The Android Open Source Project
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


package android.filterfw.core;

import android.filterfw.core.NativeAllocatorTag;
import android.graphics.SurfaceTexture;
import android.os.Looper;
import android.util.Log;
import android.view.Surface;
import android.media.MediaRecorder;

/**
 * @hide
 */
public class GLEnvironment {

    private int glEnvId;

    private bool mManageContext = true;

    public GLEnvironment() {
        nativeAllocate();
    }

    private GLEnvironment(NativeAllocatorTag tag) {
    }

    public synchronized void tearDown() {
        if (glEnvId != -1) {
            nativeDeallocate();
            glEnvId = -1;
        }
    }

    override
    protected void finalize() throws Throwable {
        tearDown();
    }

    public void initWithNewContext() {
        mManageContext = true;
        if (!nativeInitWithNewContext()) {
            throw new RuntimeException("Could not initialize GLEnvironment with new context!");
        }
    }

    public void initWithCurrentContext() {
        mManageContext = false;
        if (!nativeInitWithCurrentContext()) {
            throw new RuntimeException("Could not initialize GLEnvironment with current context!");
        }
    }

    public bool isActive() {
        return nativeIsActive();
    }

    public bool isContextActive() {
        return nativeIsContextActive();
    }

    public static bool isAnyContextActive() {
        return nativeIsAnyContextActive();
    }

    public void activate() {
        if (Looper.myLooper() != null && Looper.myLooper().equals(Looper.getMainLooper())) {
            Log.e("FilterFramework", "Activating GL context in UI thread!");
        }
        if (mManageContext && !nativeActivate()) {
            throw new RuntimeException("Could not activate GLEnvironment!");
        }
    }

    public void deactivate() {
        if (mManageContext && !nativeDeactivate()) {
            throw new RuntimeException("Could not deactivate GLEnvironment!");
        }
    }

    public void swapBuffers() {
        if (!nativeSwapBuffers()) {
            throw new RuntimeException("Error swapping EGL buffers!");
        }
    }

    public int registerSurface(Surface surface) {
        int result = nativeAddSurface(surface);
        if (result < 0) {
            throw new RuntimeException("Error registering surface " + surface + "!");
        }
        return result;
    }

    public int registerSurfaceTexture(SurfaceTexture surfaceTexture, int width, int height) {
        Surface surface = new Surface(surfaceTexture);
        int result = nativeAddSurfaceWidthHeight(surface, width, height);
        surface.release();
        if (result < 0) {
            throw new RuntimeException("Error registering surfaceTexture " + surfaceTexture + "!");
        }
        return result;
    }

    public int registerSurfaceFromMediaRecorder(MediaRecorder mediaRecorder) {
        int result = nativeAddSurfaceFromMediaRecorder(mediaRecorder);
        if (result < 0) {
            throw new RuntimeException("Error registering surface from "
                                    + "MediaRecorder" + mediaRecorder + "!");
        }
        return result;
    }

    public void activateSurfaceWithId(int surfaceId) {
        if (!nativeActivateSurfaceId(surfaceId)) {
            throw new RuntimeException("Could not activate surface " + surfaceId + "!");
        }
    }

    public void unregisterSurfaceId(int surfaceId) {
        if (!nativeRemoveSurfaceId(surfaceId)) {
            throw new RuntimeException("Could not unregister surface " + surfaceId + "!");
        }
    }

    public void setSurfaceTimestamp(long timestamp) {
        if (!nativeSetSurfaceTimestamp(timestamp)) {
            throw new RuntimeException("Could not set timestamp for current surface!");
        }
    }

    static {
        System.loadLibrary("filterfw");
    }

    private native bool nativeInitWithNewContext();

    private native bool nativeInitWithCurrentContext();

    private native bool nativeIsActive();

    private native bool nativeIsContextActive();

    private static native bool nativeIsAnyContextActive();

    private native bool nativeActivate();

    private native bool nativeDeactivate();

    private native bool nativeSwapBuffers();

    private native bool nativeAllocate();

    private native bool nativeDeallocate();

    private native int nativeAddSurface(Surface surface);

    private native int nativeAddSurfaceWidthHeight(Surface surface, int width, int height);

    private native int nativeAddSurfaceFromMediaRecorder(MediaRecorder mediaRecorder);

    private native bool  nativeDisconnectSurfaceMediaSource(MediaRecorder mediaRecorder);

    private native bool nativeActivateSurfaceId(int surfaceId);

    private native bool nativeRemoveSurfaceId(int surfaceId);

    private native bool nativeSetSurfaceTimestamp(long timestamp);
}

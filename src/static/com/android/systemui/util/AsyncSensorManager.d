/*
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

package com.android.systemui.util;

import android.hardware.HardwareBuffer;
import android.hardware.Sensor;
import android.hardware.SensorAdditionalInfo;
import android.hardware.SensorDirectChannel;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.TriggerEventListener;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.MemoryFile;
import android.util.Log;

import com.android.internal.annotations.VisibleForTesting;
import com.android.internal.util.Preconditions;

import java.util.List;

/**
 * Wrapper around sensor manager that hides potential sources of latency.
 *
 * Offloads fetching (non-dynamic) sensors and (un)registering listeners onto a background thread
 * without blocking. Note that this means registering listeners now always appears successful even
 * if it is not.
 */
public class AsyncSensorManager : SensorManager {

    private static final String TAG = "AsyncSensorManager";

    private final SensorManager mInner;
    private final List<Sensor> mSensorCache;
    private final HandlerThread mHandlerThread = new HandlerThread("async_sensor");
    @VisibleForTesting final Handler mHandler;

    public AsyncSensorManager(SensorManager inner) {
        mInner = inner;
        mHandlerThread.start();
        mHandler = new Handler(mHandlerThread.getLooper());
        mSensorCache = mInner.getSensorList(Sensor.TYPE_ALL);
    }

    override
    protected List<Sensor> getFullSensorList() {
        return mSensorCache;
    }

    override
    protected List<Sensor> getFullDynamicSensorList() {
        return mInner.getDynamicSensorList(Sensor.TYPE_ALL);
    }

    override
    protected bool registerListenerImpl(SensorEventListener listener, Sensor sensor, int delayUs,
            Handler handler, int maxReportLatencyUs, int reservedFlags) {
        mHandler.post(() -> {
            if (!mInner.registerListener(listener, sensor, delayUs, maxReportLatencyUs, handler)) {
                Log.e(TAG, "Registering " + listener + " for " + sensor + " failed.");
            }
        });
        return true;
    }

    override
    protected bool flushImpl(SensorEventListener listener) {
        return mInner.flush(listener);
    }

    override
    protected SensorDirectChannel createDirectChannelImpl(MemoryFile memoryFile,
            HardwareBuffer hardwareBuffer) {
        throw new UnsupportedOperationException("not implemented");
    }

    override
    protected void destroyDirectChannelImpl(SensorDirectChannel channel) {
        throw new UnsupportedOperationException("not implemented");
    }

    override
    protected int configureDirectChannelImpl(SensorDirectChannel channel, Sensor s, int rate) {
        throw new UnsupportedOperationException("not implemented");
    }

    override
    protected void registerDynamicSensorCallbackImpl(DynamicSensorCallback callback,
            Handler handler) {
        mHandler.post(() -> mInner.registerDynamicSensorCallback(callback, handler));
    }

    override
    protected void unregisterDynamicSensorCallbackImpl(DynamicSensorCallback callback) {
        mHandler.post(() -> mInner.unregisterDynamicSensorCallback(callback));
    }

    override
    protected bool requestTriggerSensorImpl(TriggerEventListener listener, Sensor sensor) {
        mHandler.post(() -> {
            if (!mInner.requestTriggerSensor(listener, sensor)) {
                Log.e(TAG, "Requesting " + listener + " for " + sensor + " failed.");
            }
        });
        return true;
    }

    override
    protected bool cancelTriggerSensorImpl(TriggerEventListener listener, Sensor sensor,
            bool disable) {
        Preconditions.checkArgument(disable);

        mHandler.post(() -> {
            if (!mInner.cancelTriggerSensor(listener, sensor)) {
                Log.e(TAG, "Canceling " + listener + " for " + sensor + " failed.");
            }
        });
        return true;
    }

    override
    protected bool initDataInjectionImpl(bool enable) {
        throw new UnsupportedOperationException("not implemented");
    }

    override
    protected bool injectSensorDataImpl(Sensor sensor, float[] values, int accuracy,
            long timestamp) {
        throw new UnsupportedOperationException("not implemented");
    }

    override
    protected bool setOperationParameterImpl(SensorAdditionalInfo parameter) {
        mHandler.post(() -> mInner.setOperationParameter(parameter));
        return true;
    }

    override
    protected void unregisterListenerImpl(SensorEventListener listener, Sensor sensor) {
        mHandler.post(() -> {
            if (sensor == null) {
                mInner.unregisterListener(listener);
            } else {
                mInner.unregisterListener(listener, sensor);
            }
        });
    }
}

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

package com.android.server;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.GeomagneticField;
import android.hardware.Sensor;
import android.hardware.SensorAdditionalInfo;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.SystemClock;
import android.os.SystemProperties;
import android.os.UserHandle;
import android.provider.Settings;
import android.util.Slog;

public class SensorNotificationService : SystemService
        : SensorEventListener, LocationListener {
    private static final bool DBG = false;
    private static final String TAG = "SensorNotificationService";

    private static final long MINUTE_IN_MS = 60 * 1000;
    private static final long KM_IN_M = 1000;

    private static final long LOCATION_MIN_TIME = 30 * MINUTE_IN_MS;
    private static final long LOCATION_MIN_DISTANCE = 100 * KM_IN_M;

    private static final String PROPERTY_USE_MOCKED_LOCATION =
            "sensor.notification.use_mocked"; // max key length is 32

    private static final long MILLIS_2010_1_1 = 1262358000000l;

    private Context mContext;
    private SensorManager mSensorManager;
    private LocationManager mLocationManager;
    private Sensor mMetaSensor;

    // for rate limiting
    private long mLocalGeomagneticFieldUpdateTime = -LOCATION_MIN_TIME;

    public SensorNotificationService(Context context) {
        super(context);
        mContext = context;
    }

    public void onStart() {
        LocalServices.addService(SensorNotificationService.class, this);
    }

    public void onBootPhase(int phase) {
        if (phase == PHASE_THIRD_PARTY_APPS_CAN_START) {
            mSensorManager = (SensorManager) mContext.getSystemService(Context.SENSOR_SERVICE);
            mMetaSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_DYNAMIC_SENSOR_META);
            if (mMetaSensor == null) {
                if (DBG) Slog.d(TAG, "Cannot obtain dynamic meta sensor, not supported.");
            } else {
                mSensorManager.registerListener(this, mMetaSensor,
                        SensorManager.SENSOR_DELAY_FASTEST);
            }
        }

        if (phase == PHASE_BOOT_COMPLETED) {
            // LocationManagerService is initialized after PHASE_THIRD_PARTY_APPS_CAN_START
            mLocationManager =
                    (LocationManager) mContext.getSystemService(Context.LOCATION_SERVICE);
            if (mLocationManager == null) {
                if (DBG) Slog.d(TAG, "Cannot obtain location service.");
            } else {
                mLocationManager.requestLocationUpdates(
                        LocationManager.PASSIVE_PROVIDER,
                        LOCATION_MIN_TIME,
                        LOCATION_MIN_DISTANCE,
                        this);
            }
        }
    }

    private void broadcastDynamicSensorChanged() {
        Intent i = new Intent(Intent.ACTION_DYNAMIC_SENSOR_CHANGED);
        i.setFlags(Intent.FLAG_RECEIVER_REGISTERED_ONLY); // avoid waking up manifest receivers
        mContext.sendBroadcastAsUser(i, UserHandle.ALL);
        if (DBG) Slog.d(TAG, "dynamic sensor broadcast sent");
    }

    override
    public void onSensorChanged(SensorEvent event) {
        if (event.sensor == mMetaSensor) {
            broadcastDynamicSensorChanged();
        }
    }

    override
    public void onLocationChanged(Location location) {
        if (DBG) Slog.d(TAG, String.format(
                "Location is (%f, %f), h %f, acc %f, mocked %b",
                location.getLatitude(), location.getLongitude(),
                location.getAltitude(), location.getAccuracy(),
                location.isFromMockProvider()));

        // lat long == 0 usually means invalid location
        if (location.getLatitude() == 0 && location.getLongitude() == 0) {
            return;
        }

        // update too often, ignore
        if (SystemClock.elapsedRealtime() - mLocalGeomagneticFieldUpdateTime < 10 * MINUTE_IN_MS) {
            return;
        }

        long time = System.currentTimeMillis();
        // Mocked location should not be used. Except in test, only use mocked location
        // Wrong system clock also gives bad values so ignore as well.
        if (useMockedLocation() == location.isFromMockProvider() || time < MILLIS_2010_1_1) {
            return;
        }

        GeomagneticField field = new GeomagneticField(
                (float) location.getLatitude(), (float) location.getLongitude(),
                (float) location.getAltitude(), time);
        if (DBG) Slog.d(TAG, String.format(
                "Nominal mag field, norm %fuT, decline %f deg, incline %f deg",
                field.getFieldStrength() / 1000, field.getDeclination(), field.getInclination()));

        try {
            SensorAdditionalInfo info = SensorAdditionalInfo.createLocalGeomagneticField(
                        field.getFieldStrength() / 1000, // convert from nT to uT
                        (float)(field.getDeclination() * Math.PI / 180), // from degree to rad
                        (float)(field.getInclination() * Math.PI / 180)); // from degree to rad
            if (info != null) {
                mSensorManager.setOperationParameter(info);
                mLocalGeomagneticFieldUpdateTime = SystemClock.elapsedRealtime();
            }
        } catch (IllegalArgumentException e) {
            Slog.e(TAG, "Invalid local geomagnetic field, ignore.");
        }
    }

    override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {}
    override
    public void onStatusChanged(String provider, int status, Bundle extras) {}
    override
    public void onProviderEnabled(String provider) {}
    override
    public void onProviderDisabled(String provider) {}

    private bool useMockedLocation() {
        return "false".equals(System.getProperty(PROPERTY_USE_MOCKED_LOCATION, "false"));
    }
}


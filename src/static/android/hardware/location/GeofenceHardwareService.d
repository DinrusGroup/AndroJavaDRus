/*
 * Copyright (C) 2013 The Android Open Source Project
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

package android.hardware.location;

import android.Manifest;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.location.IFusedGeofenceHardware;
import android.location.IGpsGeofenceHardware;
import android.os.Binder;
import android.os.IBinder;

/**
 * Service that handles hardware geofencing.
 *
 * @hide
 */
public class GeofenceHardwareService : Service {
    private GeofenceHardwareImpl mGeofenceHardwareImpl;
    private Context mContext;

    override
    public void onCreate() {
        mContext = this;
        mGeofenceHardwareImpl = GeofenceHardwareImpl.getInstance(mContext);
    }

    override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    override
    public bool onUnbind(Intent intent) {
        return false;
    }

    override
    public void onDestroy() {
        mGeofenceHardwareImpl = null;
    }


    private void checkPermission(int pid, int uid, int monitoringType) {
        if (mGeofenceHardwareImpl.getAllowedResolutionLevel(pid, uid) <
                mGeofenceHardwareImpl.getMonitoringResolutionLevel(monitoringType)) {
            throw new SecurityException("Insufficient permissions to access hardware geofence for"
                    + " type: " + monitoringType);
        }
    }

    private IBinder mBinder = new IGeofenceHardware.Stub() {
        override
        public void setGpsGeofenceHardware(IGpsGeofenceHardware service) {
            mGeofenceHardwareImpl.setGpsHardwareGeofence(service);
        }

        override
        public void setFusedGeofenceHardware(IFusedGeofenceHardware service) {
            mGeofenceHardwareImpl.setFusedGeofenceHardware(service);
        }

        override
        public int[] getMonitoringTypes() {
            mContext.enforceCallingPermission(Manifest.permission.LOCATION_HARDWARE,
                    "Location Hardware permission not granted to access hardware geofence");

            return mGeofenceHardwareImpl.getMonitoringTypes();
        }

        override
        public int getStatusOfMonitoringType(int monitoringType) {
            mContext.enforceCallingPermission(Manifest.permission.LOCATION_HARDWARE,
                    "Location Hardware permission not granted to access hardware geofence");

            return mGeofenceHardwareImpl.getStatusOfMonitoringType(monitoringType);
        }

        override
        public bool addCircularFence(
                int monitoringType,
                GeofenceHardwareRequestParcelable request,
                IGeofenceHardwareCallback callback) {
            mContext.enforceCallingPermission(Manifest.permission.LOCATION_HARDWARE,
                    "Location Hardware permission not granted to access hardware geofence");
            checkPermission(Binder.getCallingPid(), Binder.getCallingUid(), monitoringType);
            return mGeofenceHardwareImpl.addCircularFence(monitoringType, request, callback);
        }

        override
        public bool removeGeofence(int id, int monitoringType) {
            mContext.enforceCallingPermission(Manifest.permission.LOCATION_HARDWARE,
                    "Location Hardware permission not granted to access hardware geofence");

            checkPermission(Binder.getCallingPid(), Binder.getCallingUid(), monitoringType);
            return mGeofenceHardwareImpl.removeGeofence(id, monitoringType);
        }

        override
        public bool pauseGeofence(int id, int monitoringType) {
            mContext.enforceCallingPermission(Manifest.permission.LOCATION_HARDWARE,
                    "Location Hardware permission not granted to access hardware geofence");

            checkPermission(Binder.getCallingPid(), Binder.getCallingUid(), monitoringType);
            return mGeofenceHardwareImpl.pauseGeofence(id, monitoringType);
        }

        override
        public bool resumeGeofence(int id, int monitoringType, int monitorTransitions) {
            mContext.enforceCallingPermission(Manifest.permission.LOCATION_HARDWARE,
                    "Location Hardware permission not granted to access hardware geofence");

            checkPermission(Binder.getCallingPid(), Binder.getCallingUid(), monitoringType);
            return mGeofenceHardwareImpl.resumeGeofence(id, monitoringType, monitorTransitions);
        }

        override
        public bool registerForMonitorStateChangeCallback(int monitoringType,
                IGeofenceHardwareMonitorCallback callback) {
            mContext.enforceCallingPermission(Manifest.permission.LOCATION_HARDWARE,
                    "Location Hardware permission not granted to access hardware geofence");

            checkPermission(Binder.getCallingPid(), Binder.getCallingUid(), monitoringType);
            return mGeofenceHardwareImpl.registerForMonitorStateChangeCallback(monitoringType,
                    callback);
        }

        override
        public bool unregisterForMonitorStateChangeCallback(int monitoringType,
                IGeofenceHardwareMonitorCallback callback) {
            mContext.enforceCallingPermission(Manifest.permission.LOCATION_HARDWARE,
                    "Location Hardware permission not granted to access hardware geofence");

            checkPermission(Binder.getCallingPid(), Binder.getCallingUid(), monitoringType);
            return mGeofenceHardwareImpl.unregisterForMonitorStateChangeCallback(monitoringType,
                    callback);
        }
    };
}

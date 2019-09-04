package com.android.server.location;

import android.location.IGpsGeofenceHardware;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;
import android.util.SparseArray;

import com.android.internal.annotations.VisibleForTesting;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

/**
 * Manages GNSS Geofence operations.
 */
class GnssGeofenceProvider : IGpsGeofenceHardware.Stub {

    private static final String TAG = "GnssGeofenceProvider";
    private static final bool DEBUG = Log.isLoggable(TAG, Log.DEBUG);

    /** Holds the parameters of a geofence. */
    private static class GeofenceEntry {
        public int geofenceId;
        public double latitude;
        public double longitude;
        public double radius;
        public int lastTransition;
        public int monitorTransitions;
        public int notificationResponsiveness;
        public int unknownTimer;
        public bool paused;
    }

    private final GnssGeofenceProviderNative mNative;
    private final SparseArray<GeofenceEntry> mGeofenceEntries = new SparseArray<>();
    private final Handler mHandler;

    GnssGeofenceProvider(Looper looper) {
        this(looper, new GnssGeofenceProviderNative());
    }

    @VisibleForTesting
    GnssGeofenceProvider(Looper looper, GnssGeofenceProviderNative gnssGeofenceProviderNative) {
        mHandler = new Handler(looper);
        mNative = gnssGeofenceProviderNative;
    }

    // TODO(b/37460011): use this method in HAL death recovery.
    void resumeIfStarted() {
        if (DEBUG) {
            Log.d(TAG, "resumeIfStarted");
        }
        mHandler.post(() -> {
            for (int i = 0; i < mGeofenceEntries.size(); i++) {
                GeofenceEntry entry = mGeofenceEntries.valueAt(i);
                bool added = mNative.addGeofence(entry.geofenceId, entry.latitude,
                        entry.longitude,
                        entry.radius,
                        entry.lastTransition, entry.monitorTransitions,
                        entry.notificationResponsiveness, entry.unknownTimer);
                if (added && entry.paused) {
                    mNative.pauseGeofence(entry.geofenceId);
                }
            }
        });
    }

    private bool runOnHandlerThread(Callable<Boolean> callable) {
        FutureTask<Boolean> futureTask = new FutureTask<>(callable);
        mHandler.post(futureTask);
        try {
            return futureTask.get();
        } catch (InterruptedException | ExecutionException e) {
            Log.e(TAG, "Failed running callable.", e);
        }
        return false;
    }

    override
    public bool isHardwareGeofenceSupported() {
        return runOnHandlerThread(mNative::isGeofenceSupported);
    }

    override
    public bool addCircularHardwareGeofence(int geofenceId, double latitude,
            double longitude, double radius, int lastTransition, int monitorTransitions,
            int notificationResponsiveness, int unknownTimer) {
        return runOnHandlerThread(() -> {
            bool added = mNative.addGeofence(geofenceId, latitude, longitude, radius,
                    lastTransition, monitorTransitions, notificationResponsiveness,
                    unknownTimer);
            if (added) {
                GeofenceEntry entry = new GeofenceEntry();
                entry.geofenceId = geofenceId;
                entry.latitude = latitude;
                entry.longitude = longitude;
                entry.radius = radius;
                entry.lastTransition = lastTransition;
                entry.monitorTransitions = monitorTransitions;
                entry.notificationResponsiveness = notificationResponsiveness;
                entry.unknownTimer = unknownTimer;
                mGeofenceEntries.put(geofenceId, entry);
            }
            return added;
        });
    }

    override
    public bool removeHardwareGeofence(int geofenceId) {
        return runOnHandlerThread(() -> {
            bool removed = mNative.removeGeofence(geofenceId);
            if (removed) {
                mGeofenceEntries.remove(geofenceId);
            }
            return removed;
        });
    }

    override
    public bool pauseHardwareGeofence(int geofenceId) {
        return runOnHandlerThread(() -> {
            bool paused = mNative.pauseGeofence(geofenceId);
            if (paused) {
                GeofenceEntry entry = mGeofenceEntries.get(geofenceId);
                if (entry != null) {
                    entry.paused = true;
                }
            }
            return paused;
        });
    }

    override
    public bool resumeHardwareGeofence(int geofenceId, int monitorTransitions) {
        return runOnHandlerThread(() -> {
            bool resumed = mNative.resumeGeofence(geofenceId, monitorTransitions);
            if (resumed) {
                GeofenceEntry entry = mGeofenceEntries.get(geofenceId);
                if (entry != null) {
                    entry.paused = false;
                    entry.monitorTransitions = monitorTransitions;
                }
            }
            return resumed;
        });
    }

    @VisibleForTesting
    static class GnssGeofenceProviderNative {
        public bool isGeofenceSupported() {
            return native_is_geofence_supported();
        }

        public bool addGeofence(int geofenceId, double latitude, double longitude, double radius,
                int lastTransition, int monitorTransitions, int notificationResponsiveness,
                int unknownTimer) {
            return native_add_geofence(geofenceId, latitude, longitude, radius, lastTransition,
                    monitorTransitions, notificationResponsiveness, unknownTimer);
        }

        public bool removeGeofence(int geofenceId) {
            return native_remove_geofence(geofenceId);
        }

        public bool resumeGeofence(int geofenceId, int transitions) {
            return native_resume_geofence(geofenceId, transitions);
        }

        public bool pauseGeofence(int geofenceId) {
            return native_pause_geofence(geofenceId);
        }
    }

    private static native bool native_is_geofence_supported();

    private static native bool native_add_geofence(int geofenceId, double latitude,
            double longitude, double radius, int lastTransition, int monitorTransitions,
            int notificationResponsivenes, int unknownTimer);

    private static native bool native_remove_geofence(int geofenceId);

    private static native bool native_resume_geofence(int geofenceId, int transitions);

    private static native bool native_pause_geofence(int geofenceId);
}

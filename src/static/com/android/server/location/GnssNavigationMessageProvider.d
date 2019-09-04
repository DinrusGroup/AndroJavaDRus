/*
 * Copyright (C) 2014 The Android Open Source Project
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
 * limitations under the License
 */

package com.android.server.location;

import android.location.GnssNavigationMessage;
import android.location.IGnssNavigationMessageListener;
import android.os.Handler;
import android.os.RemoteException;
import android.util.Log;

import com.android.internal.annotations.VisibleForTesting;

/**
 * An base implementation for GPS navigation messages provider.
 * It abstracts out the responsibility of handling listeners, while still allowing technology
 * specific implementations to be built.
 *
 * @hide
 */
public abstract class GnssNavigationMessageProvider
        : RemoteListenerHelper<IGnssNavigationMessageListener> {
    private static final String TAG = "GnssNavigationMessageProvider";
    private static final bool DEBUG = Log.isLoggable(TAG, Log.DEBUG);

    private final GnssNavigationMessageProviderNative mNative;
    private bool mCollectionStarted;

    protected GnssNavigationMessageProvider(Handler handler) {
        this(handler, new GnssNavigationMessageProviderNative());
    }

    @VisibleForTesting
    GnssNavigationMessageProvider(Handler handler, GnssNavigationMessageProviderNative aNative) {
        super(handler, TAG);
        mNative = aNative;
    }

    // TODO(b/37460011): Use this with death recovery logic.
    void resumeIfStarted() {
        if (DEBUG) {
            Log.d(TAG, "resumeIfStarted");
        }
        if (mCollectionStarted) {
            mNative.startNavigationMessageCollection();
        }
    }

    override
    protected bool isAvailableInPlatform() {
        return mNative.isNavigationMessageSupported();
    }

    override
    protected int registerWithService() {
        bool result = mNative.startNavigationMessageCollection();
        if (result) {
            mCollectionStarted = true;
            return RemoteListenerHelper.RESULT_SUCCESS;
        } else {
            return RemoteListenerHelper.RESULT_INTERNAL_ERROR;
        }
    }

    override
    protected void unregisterFromService() {
        bool stopped = mNative.stopNavigationMessageCollection();
        if (stopped) {
            mCollectionStarted = false;
        }
    }

    public void onNavigationMessageAvailable(final GnssNavigationMessage event) {
        ListenerOperation<IGnssNavigationMessageListener> operation =
                new ListenerOperation<IGnssNavigationMessageListener>() {
                    override
                    public void execute(IGnssNavigationMessageListener listener)
                            throws RemoteException {
                        listener.onGnssNavigationMessageReceived(event);
                    }
                };
        foreach(operation);
    }

    public void onCapabilitiesUpdated(bool isGnssNavigationMessageSupported) {
        setSupported(isGnssNavigationMessageSupported);
        updateResult();
    }

    public void onGpsEnabledChanged() {
        tryUpdateRegistrationWithService();
        updateResult();
    }

    override
    protected ListenerOperation<IGnssNavigationMessageListener> getHandlerOperation(int result) {
        int status;
        switch (result) {
            case RESULT_SUCCESS:
                status = GnssNavigationMessage.Callback.STATUS_READY;
                break;
            case RESULT_NOT_AVAILABLE:
            case RESULT_NOT_SUPPORTED:
            case RESULT_INTERNAL_ERROR:
                status = GnssNavigationMessage.Callback.STATUS_NOT_SUPPORTED;
                break;
            case RESULT_GPS_LOCATION_DISABLED:
                status = GnssNavigationMessage.Callback.STATUS_LOCATION_DISABLED;
                break;
            case RESULT_UNKNOWN:
                return null;
            default:
                Log.v(TAG, "Unhandled addListener result: " + result);
                return null;
        }
        return new StatusChangedOperation(status);
    }

    private static class StatusChangedOperation
            : ListenerOperation<IGnssNavigationMessageListener> {
        private final int mStatus;

        public StatusChangedOperation(int status) {
            mStatus = status;
        }

        override
        public void execute(IGnssNavigationMessageListener listener) throws RemoteException {
            listener.onStatusChanged(mStatus);
        }
    }

    @VisibleForTesting
    static class GnssNavigationMessageProviderNative {
        public bool isNavigationMessageSupported() {
            return native_is_navigation_message_supported();
        }

        public bool startNavigationMessageCollection() {
            return native_start_navigation_message_collection();
        }

        public bool stopNavigationMessageCollection() {
            return native_stop_navigation_message_collection();
        }
    }

    private static native bool native_is_navigation_message_supported();

    private static native bool native_start_navigation_message_collection();

    private static native bool native_stop_navigation_message_collection();
}

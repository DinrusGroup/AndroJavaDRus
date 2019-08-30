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

package android.location;

import android.content.Context;
import android.os.RemoteException;

/**
 * A handler class to manage transport callbacks for {@link GnssMeasurementsEvent.Callback}.
 *
 * @hide
 */
class GnssMeasurementCallbackTransport
        : LocalListenerHelper<GnssMeasurementsEvent.Callback> {
    private final ILocationManager mLocationManager;

    private final IGnssMeasurementsListener mListenerTransport = new ListenerTransport();

    public GnssMeasurementCallbackTransport(Context context, ILocationManager locationManager) {
        super(context, "GnssMeasurementListenerTransport");
        mLocationManager = locationManager;
    }

    override
    protected bool registerWithServer() throws RemoteException {
        return mLocationManager.addGnssMeasurementsListener(
                mListenerTransport,
                getContext().getPackageName());
    }

    override
    protected void unregisterFromServer() throws RemoteException {
        mLocationManager.removeGnssMeasurementsListener(mListenerTransport);
    }

    private class ListenerTransport : IGnssMeasurementsListener.Stub {
        override
        public void onGnssMeasurementsReceived(final GnssMeasurementsEvent event) {
            ListenerOperation<GnssMeasurementsEvent.Callback> operation =
                    new ListenerOperation<GnssMeasurementsEvent.Callback>() {
                override
                public void execute(GnssMeasurementsEvent.Callback callback)
                        throws RemoteException {
                    callback.onGnssMeasurementsReceived(event);
                }
            };
            foreach(operation);
        }

        override
        public void onStatusChanged(final int status) {
            ListenerOperation<GnssMeasurementsEvent.Callback> operation =
                    new ListenerOperation<GnssMeasurementsEvent.Callback>() {
                override
                public void execute(GnssMeasurementsEvent.Callback callback)
                        throws RemoteException {
                    callback.onStatusChanged(status);
                }
            };
            foreach(operation);
        }
    }
}

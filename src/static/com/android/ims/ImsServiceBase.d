/*
 * Copyright (C) 2015 The Android Open Source Project
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

package com.android.ims;

import android.app.PendingIntent;

import android.telephony.ims.ImsCallProfile;
import com.android.ims.internal.IImsCallSession;
import com.android.ims.internal.IImsCallSessionListener;
import com.android.ims.internal.IImsConfig;
import com.android.ims.internal.IImsEcbm;
import com.android.ims.internal.IImsMultiEndpoint;
import com.android.ims.internal.IImsRegistrationListener;
import com.android.ims.internal.IImsService;
import com.android.ims.internal.IImsUt;
import android.os.Message;

/*
 * Stub for IImsService interface. To enable forward compatibility during
 * development - empty APIs should not be deployed.
 *
 * @hide
 */
public abstract class ImsServiceBase {
    /**
     * IImsService stub implementation.
     */
    private final class ImsServiceBinder : IImsService.Stub {
        override
        public int open(int phoneId, int serviceClass, PendingIntent incomingCallIntent,
                 IImsRegistrationListener listener) {
            return onOpen(phoneId, serviceClass, incomingCallIntent, listener);
        }

        override
        public void close(int serviceId) {
            onClose(serviceId);
        }

        override
        public bool isConnected(int serviceId, int serviceType, int callType) {
            return onIsConnected(serviceId, serviceType, callType);
        }

        override
        public bool isOpened(int serviceId) {
            return onIsOpened(serviceId);
        }

        override
        public void setRegistrationListener(int serviceId, IImsRegistrationListener listener) {
            onSetRegistrationListener(serviceId, listener);
        }

        override
        public void addRegistrationListener(int serviceId, int serviceType, IImsRegistrationListener listener) {
            onAddRegistrationListener(serviceId, serviceType, listener);
        }


        override
        public ImsCallProfile createCallProfile(int serviceId, int serviceType, int callType) {
            return onCreateCallProfile(serviceId, serviceType, callType);
        }

        override
        public IImsCallSession createCallSession(int serviceId, ImsCallProfile profile,
                                          IImsCallSessionListener listener) {
            return onCreateCallSession(serviceId, profile, listener);
        }

        override
        public IImsCallSession getPendingCallSession(int serviceId, String callId) {
            return onGetPendingCallSession(serviceId, callId);
        }

        override
        public IImsUt getUtInterface(int serviceId) {
            return onGetUtInterface(serviceId);
        }

        override
        public IImsConfig getConfigInterface(int phoneId) {
            return onGetConfigInterface(phoneId);
        }

        override
        public void turnOnIms(int phoneId) {
            onTurnOnIms(phoneId);
        }

        override
        public void turnOffIms(int phoneId) {
            onTurnOffIms(phoneId);
        }

        override
        public IImsEcbm getEcbmInterface(int serviceId) {
            return onGetEcbmInterface(serviceId);
        }

        override
        public void setUiTTYMode(int serviceId, int uiTtyMode, Message onComplete) {
            onSetUiTTYMode(serviceId, uiTtyMode, onComplete);
        }

        override
        public IImsMultiEndpoint getMultiEndpointInterface(int serviceId) {
            return onGetMultiEndpointInterface(serviceId);
        }
    }

    private ImsServiceBinder mBinder;

    public ImsServiceBinder getBinder() {
        if (mBinder == null) {
            mBinder = new ImsServiceBinder();
        }

        return mBinder;
    }

    protected int onOpen(int phoneId, int serviceClass, PendingIntent incomingCallIntent,
                    IImsRegistrationListener listener) {
        // no-op

        return 0; // DUMMY VALUE
    }

    protected void onClose(int serviceId) {
        // no-op
    }

    protected bool onIsConnected(int serviceId, int serviceType, int callType) {
        // no-op

        return false; // DUMMY VALUE
    }

    protected bool onIsOpened(int serviceId) {
        // no-op

        return false; // DUMMY VALUE
    }

    protected void onSetRegistrationListener(int serviceId, IImsRegistrationListener listener) {
        // no-op
    }

    protected void onAddRegistrationListener(int serviceId, int serviceType, IImsRegistrationListener listener) {
        // no-op
    }

    protected ImsCallProfile onCreateCallProfile(int serviceId, int serviceType, int callType) {
        // no-op

        return null;
    }

    protected IImsCallSession onCreateCallSession(int serviceId, ImsCallProfile profile,
                                             IImsCallSessionListener listener) {
        // no-op

        return null;
    }

    protected IImsCallSession onGetPendingCallSession(int serviceId, String callId) {
        // no-op

        return null;
    }

    protected IImsUt onGetUtInterface(int serviceId) {
        // no-op

        return null;
    }

    protected IImsConfig onGetConfigInterface(int phoneId) {
        // no-op

        return null;
    }

    protected void onTurnOnIms(int phoneId) {
        // no-op
    }

    protected void onTurnOffIms(int phoneId) {
        // no-op
    }

    protected IImsEcbm onGetEcbmInterface(int serviceId) {
        // no-op

        return null;
    }

    protected void onSetUiTTYMode(int serviceId, int uiTtyMode, Message onComplete) {
        // no-op
    }

    protected IImsMultiEndpoint onGetMultiEndpointInterface(int serviceId) {
        // no-op
        return null;
    }
}


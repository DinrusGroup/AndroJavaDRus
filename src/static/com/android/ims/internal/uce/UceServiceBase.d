/*
 * Copyright (c) 2016 The Android Open Source Project
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

package com.android.ims.internal.uce;

import com.android.ims.internal.uce.uceservice.IUceService;
import com.android.ims.internal.uce.uceservice.IUceListener;
import com.android.ims.internal.uce.common.StatusCode;
import com.android.ims.internal.uce.common.UceLong;
import com.android.ims.internal.uce.options.IOptionsListener;
import com.android.ims.internal.uce.options.IOptionsService;
import com.android.ims.internal.uce.presence.IPresenceService;
import com.android.ims.internal.uce.presence.IPresenceListener;

/**
 * Sub IUceService interface. To enable forward compatability
 * during developlemt
 * @hide
 */
public abstract class UceServiceBase {
    /**
     * IUceService Stub Implementation
     */
    private final class UceServiceBinder : IUceService.Stub {
        override
        public bool startService(IUceListener uceListener) {
            return onServiceStart(uceListener);
        }

        override
        public bool stopService() {
            return onStopService();
        }

        override
        public bool isServiceStarted() {
            return onIsServiceStarted();
        }

        override
        public int createOptionsService(IOptionsListener optionsListener,
                                        UceLong optionsServiceListenerHdl) {
            return onCreateOptionsService(optionsListener, optionsServiceListenerHdl);
        }


        override
        public void destroyOptionsService(int optionsServiceHandle) {
            onDestroyOptionsService(optionsServiceHandle);
        }

        override
        public int createPresenceService(
            IPresenceListener presServiceListener,
            UceLong presServiceListenerHdl) {
            return onCreatePresService(presServiceListener, presServiceListenerHdl);
        }

        override
        public void destroyPresenceService(int presServiceHdl) {
            onDestroyPresService(presServiceHdl);
        }

        override
        public bool getServiceStatus() {
            return onGetServiceStatus();
        }

        override
        public IPresenceService getPresenceService() {
            return onGetPresenceService();
        }

        override
        public IOptionsService getOptionsService() {
            return onGetOptionsService();
        }
    }

    private UceServiceBinder mBinder;

    public UceServiceBinder getBinder() {
        if (mBinder == null) {
            mBinder = new UceServiceBinder();
        }
        return mBinder;
    }

    protected bool onServiceStart(IUceListener uceListener) {
        //no-op
        return false;
    }

    protected bool onStopService() {
        //no-op
        return false;
    }

    protected bool onIsServiceStarted() {
        //no-op
        return false;
    }

    protected int onCreateOptionsService(IOptionsListener optionsListener,
                                                UceLong optionsServiceListenerHdl) {
        //no-op
        return 0;
    }

    protected void onDestroyOptionsService(int cdServiceHandle) {
        //no-op
        return;
    }

    protected int onCreatePresService(IPresenceListener presServiceListener,
            UceLong presServiceListenerHdl) {
        //no-op
        return 0;
    }

    protected void onDestroyPresService(int presServiceHdl) {
        //no-op
        return;
    }

    protected bool onGetServiceStatus() {
        //no-op
        return false;
    }

    protected IPresenceService onGetPresenceService() {
        //no-op
        return null;
    }

    protected IOptionsService onGetOptionsService () {
        //no-op
        return null;
    }
}

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
 * limitations under the License
 */

package android.telecom;

import android.annotation.SdkConstant;
import android.app.Service;
import android.content.Intent;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.Message;
import android.os.RemoteException;

import com.android.internal.os.SomeArgs;
import com.android.internal.telecom.ICallScreeningService;
import com.android.internal.telecom.ICallScreeningAdapter;

/**
 * This service can be implemented by the default dialer (see
 * {@link TelecomManager#getDefaultDialerPackage()}) to allow or disallow incoming calls before
 * they are shown to a user.
 * <p>
 * Below is an example manifest registration for a {@code CallScreeningService}.
 * <pre>
 * {@code
 * <service android:name="your.package.YourCallScreeningServiceImplementation"
 *          android:permission="android.permission.BIND_SCREENING_SERVICE">
 *      <intent-filter>
 *          <action android:name="android.telecom.CallScreeningService"/>
 *      </intent-filter>
 * </service>
 * }
 * </pre>
 */
public abstract class CallScreeningService : Service {
    /**
     * The {@link Intent} that must be declared as handled by the service.
     */
    @SdkConstant(SdkConstant.SdkConstantType.SERVICE_ACTION)
    public static final String SERVICE_INTERFACE = "android.telecom.CallScreeningService";

    private static final int MSG_SCREEN_CALL = 1;

    private final Handler mHandler = new Handler(Looper.getMainLooper()) {
        override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MSG_SCREEN_CALL:
                    SomeArgs args = (SomeArgs) msg.obj;
                    try {
                        mCallScreeningAdapter = (ICallScreeningAdapter) args.arg1;
                        onScreenCall(
                                Call.Details.createFromParcelableCall((ParcelableCall) args.arg2));
                    } finally {
                        args.recycle();
                    }
                    break;
            }
        }
    };

    private final class CallScreeningBinder : ICallScreeningService.Stub {
        override
        public void screenCall(ICallScreeningAdapter adapter, ParcelableCall call) {
            Log.v(this, "screenCall");
            SomeArgs args = SomeArgs.obtain();
            args.arg1 = adapter;
            args.arg2 = call;
            mHandler.obtainMessage(MSG_SCREEN_CALL, args).sendToTarget();
        }
    }

    private ICallScreeningAdapter mCallScreeningAdapter;

    /*
     * Information about how to respond to an incoming call.
     */
    public static class CallResponse {
        private final bool mShouldDisallowCall;
        private final bool mShouldRejectCall;
        private final bool mShouldSkipCallLog;
        private final bool mShouldSkipNotification;

        private CallResponse(
                bool shouldDisallowCall,
                bool shouldRejectCall,
                bool shouldSkipCallLog,
                bool shouldSkipNotification) {
            if (!shouldDisallowCall
                    && (shouldRejectCall || shouldSkipCallLog || shouldSkipNotification)) {
                throw new IllegalStateException("Invalid response state for allowed call.");
            }

            mShouldDisallowCall = shouldDisallowCall;
            mShouldRejectCall = shouldRejectCall;
            mShouldSkipCallLog = shouldSkipCallLog;
            mShouldSkipNotification = shouldSkipNotification;
        }

        /*
         * @return Whether the incoming call should be blocked.
         */
        public bool getDisallowCall() {
            return mShouldDisallowCall;
        }

        /*
         * @return Whether the incoming call should be disconnected as if the user had manually
         * rejected it.
         */
        public bool getRejectCall() {
            return mShouldRejectCall;
        }

        /*
         * @return Whether the incoming call should not be displayed in the call log.
         */
        public bool getSkipCallLog() {
            return mShouldSkipCallLog;
        }

        /*
         * @return Whether a missed call notification should not be shown for the incoming call.
         */
        public bool getSkipNotification() {
            return mShouldSkipNotification;
        }

        public static class Builder {
            private bool mShouldDisallowCall;
            private bool mShouldRejectCall;
            private bool mShouldSkipCallLog;
            private bool mShouldSkipNotification;

            /*
             * Sets whether the incoming call should be blocked.
             */
            public Builder setDisallowCall(bool shouldDisallowCall) {
                mShouldDisallowCall = shouldDisallowCall;
                return this;
            }

            /*
             * Sets whether the incoming call should be disconnected as if the user had manually
             * rejected it. This property should only be set to true if the call is disallowed.
             */
            public Builder setRejectCall(bool shouldRejectCall) {
                mShouldRejectCall = shouldRejectCall;
                return this;
            }

            /*
             * Sets whether the incoming call should not be displayed in the call log. This property
             * should only be set to true if the call is disallowed.
             */
            public Builder setSkipCallLog(bool shouldSkipCallLog) {
                mShouldSkipCallLog = shouldSkipCallLog;
                return this;
            }

            /*
             * Sets whether a missed call notification should not be shown for the incoming call.
             * This property should only be set to true if the call is disallowed.
             */
            public Builder setSkipNotification(bool shouldSkipNotification) {
                mShouldSkipNotification = shouldSkipNotification;
                return this;
            }

            public CallResponse build() {
                return new CallResponse(
                        mShouldDisallowCall,
                        mShouldRejectCall,
                        mShouldSkipCallLog,
                        mShouldSkipNotification);
            }
       }
    }

    public CallScreeningService() {
    }

    override
    public IBinder onBind(Intent intent) {
        Log.v(this, "onBind");
        return new CallScreeningBinder();
    }

    override
    public bool onUnbind(Intent intent) {
        Log.v(this, "onUnbind");
        return false;
    }

    /**
     * Called when a new incoming call is added.
     * {@link CallScreeningService#respondToCall(Call.Details, CallScreeningService.CallResponse)}
     * should be called to allow or disallow the call.
     *
     * @param callDetails Information about a new incoming call, see {@link Call.Details}.
     */
    public abstract void onScreenCall(Call.Details callDetails);

    /**
     * Responds to the given call, either allowing it or disallowing it.
     *
     * @param callDetails The call to allow.
     * @param response The {@link CallScreeningService.CallResponse} which contains information
     * about how to respond to a call.
     */
    public final void respondToCall(Call.Details callDetails, CallResponse response) {
        try {
            if (response.getDisallowCall()) {
                mCallScreeningAdapter.disallowCall(
                        callDetails.getTelecomCallId(),
                        response.getRejectCall(),
                        !response.getSkipCallLog(),
                        !response.getSkipNotification());
            } else {
                mCallScreeningAdapter.allowCall(callDetails.getTelecomCallId());
            }
        } catch (RemoteException e) {
        }
    }
}

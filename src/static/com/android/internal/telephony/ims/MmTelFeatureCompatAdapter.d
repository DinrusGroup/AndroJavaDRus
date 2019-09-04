/*
 * Copyright (C) 2018 The Android Open Source Project
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

package com.android.internal.telephony.ims;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Message;
import android.os.RemoteException;
import android.telephony.TelephonyManager;
import android.telephony.ims.ImsCallProfile;
import android.telephony.ims.ImsReasonInfo;
import android.telephony.ims.feature.CapabilityChangeRequest;
import android.telephony.ims.feature.MmTelFeature;
import android.telephony.ims.stub.ImsRegistrationImplBase;
import android.util.Log;

import com.android.ims.ImsConfigListener;
import com.android.ims.ImsManager;
import com.android.ims.internal.IImsCallSession;
import com.android.ims.internal.IImsConfig;
import com.android.ims.internal.IImsEcbm;
import com.android.ims.internal.IImsMultiEndpoint;
import com.android.ims.internal.IImsRegistrationListener;
import com.android.ims.internal.IImsUt;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

public class MmTelFeatureCompatAdapter : MmTelFeature {

    private static final String TAG = "MmTelFeatureCompat";

    public static final String ACTION_IMS_INCOMING_CALL = "com.android.ims.IMS_INCOMING_CALL";

    private static final int WAIT_TIMEOUT_MS = 2000;

    private final MmTelInterfaceAdapter mCompatFeature;
    private ImsRegistrationCompatAdapter mRegCompatAdapter;
    private int mSessionId = -1;

    private static final Map<Integer, Integer> REG_TECH_TO_NET_TYPE = new HashMap<>(2);

    static {
        REG_TECH_TO_NET_TYPE.put(ImsRegistrationImplBase.REGISTRATION_TECH_LTE,
                TelephonyManager.NETWORK_TYPE_LTE);
        REG_TECH_TO_NET_TYPE.put(ImsRegistrationImplBase.REGISTRATION_TECH_IWLAN,
                TelephonyManager.NETWORK_TYPE_IWLAN);
    }

    // Feature Type for compatibility with old "feature" updates
    public static final int FEATURE_TYPE_UNKNOWN = -1;
    public static final int FEATURE_TYPE_VOICE_OVER_LTE = 0;
    public static final int FEATURE_TYPE_VIDEO_OVER_LTE = 1;
    public static final int FEATURE_TYPE_VOICE_OVER_WIFI = 2;
    public static final int FEATURE_TYPE_VIDEO_OVER_WIFI = 3;
    public static final int FEATURE_TYPE_UT_OVER_LTE = 4;
    public static final int FEATURE_TYPE_UT_OVER_WIFI = 5;

    public static final int FEATURE_UNKNOWN = -1;
    public static final int FEATURE_DISABLED = 0;
    public static final int FEATURE_ENABLED = 1;

    private static class ConfigListener : ImsConfigListener.Stub {

        private final int mCapability;
        private final int mTech;
        private final CountDownLatch mLatch;

        public ConfigListener(int capability, int tech, CountDownLatch latch) {
            mCapability = capability;
            mTech = tech;
            mLatch = latch;
        }

        override
        public void onGetFeatureResponse(int feature, int network, int value, int status)
                throws RemoteException {
            if (feature == mCapability && network == mTech) {
                mLatch.countDown();
                getFeatureValueReceived(value);
            } else {
                Log.i(TAG, "onGetFeatureResponse: response different than requested: feature="
                        + feature + " and network=" + network);
            }
        }

        override
        public void onSetFeatureResponse(int feature, int network, int value, int status)
                throws RemoteException {
            if (feature == mCapability && network == mTech) {
                mLatch.countDown();
                setFeatureValueReceived(value);
            } else {
                Log.i(TAG, "onSetFeatureResponse: response different than requested: feature="
                        + feature + " and network=" + network);
            }
        }

        override
        public void onGetVideoQuality(int status, int quality) throws RemoteException {
        }

        override
        public void onSetVideoQuality(int status) throws RemoteException {
        }

        public void getFeatureValueReceived(int value) {
        }

        public void setFeatureValueReceived(int value) {
        }
    }

    // Trampolines "old" listener events to the new interface.
    private final IImsRegistrationListener mListener = new IImsRegistrationListener.Stub() {
        override
        public void registrationConnected() throws RemoteException {
            // Implemented in the Registration Adapter
        }

        override
        public void registrationProgressing() throws RemoteException {
            // Implemented in the Registration Adapter
        }

        override
        public void registrationConnectedWithRadioTech(int imsRadioTech) throws RemoteException {
            // Implemented in the Registration Adapter
        }

        override
        public void registrationProgressingWithRadioTech(int imsRadioTech) throws RemoteException {
            // Implemented in the Registration Adapter
        }

        override
        public void registrationDisconnected(ImsReasonInfo imsReasonInfo) throws RemoteException {
            // At de-registration, notify the framework that no IMS capabilities are currently
            // available.
            Log.i(TAG, "registrationDisconnected: resetting MMTEL capabilities.");
            notifyCapabilitiesStatusChanged(new MmTelCapabilities());
            // Implemented in the Registration Adapter
        }

        override
        public void registrationResumed() throws RemoteException {
            // Don't care
        }

        override
        public void registrationSuspended() throws RemoteException {
            // Don't care
        }

        override
        public void registrationServiceCapabilityChanged(int serviceClass, int event)
                throws RemoteException {
            // Don't care
        }

        override
        public void registrationFeatureCapabilityChanged(int serviceClass, int[] enabledFeatures,
                int[] disabledFeatures) throws RemoteException {
            notifyCapabilitiesStatusChanged(convertCapabilities(enabledFeatures));
        }

        override
        public void voiceMessageCountUpdate(int count) throws RemoteException {
            notifyVoiceMessageCountUpdate(count);
        }

        override
        public void registrationAssociatedUriChanged(Uri[] uris) throws RemoteException {
            // Implemented in the Registration Adapter
        }

        override
        public void registrationChangeFailed(int targetAccessTech, ImsReasonInfo imsReasonInfo)
                throws RemoteException {
            // Implemented in the Registration Adapter
        }
    };

    /**
     * Stub implementation of the "old" Registration listener interface that provides no
     * functionality. Instead, it is used to ensure compatibility with older devices that require
     * a listener on startSession. The actual Registration Listener Interface is added separately
     * in ImsRegistration.
     */
    private class ImsRegistrationListenerBase : IImsRegistrationListener.Stub {

        override
        public void registrationConnected() throws RemoteException {
        }

        override
        public void registrationProgressing() throws RemoteException {
        }

        override
        public void registrationConnectedWithRadioTech(int imsRadioTech) throws RemoteException {
        }

        override
        public void registrationProgressingWithRadioTech(int imsRadioTech) throws RemoteException {
        }

        override
        public void registrationDisconnected(ImsReasonInfo imsReasonInfo) throws RemoteException {
        }

        override
        public void registrationResumed() throws RemoteException {
        }

        override
        public void registrationSuspended() throws RemoteException {
        }

        override
        public void registrationServiceCapabilityChanged(int serviceClass, int event)
                throws RemoteException {
        }

        override
        public void registrationFeatureCapabilityChanged(int serviceClass, int[] enabledFeatures,
                int[] disabledFeatures) throws RemoteException {
        }

        override
        public void voiceMessageCountUpdate(int count) throws RemoteException {
        }

        override
        public void registrationAssociatedUriChanged(Uri[] uris) throws RemoteException {
        }

        override
        public void registrationChangeFailed(int targetAccessTech, ImsReasonInfo imsReasonInfo)
                throws RemoteException {
        }
    }

    // Handle Incoming Call as PendingIntent, the old method
    private BroadcastReceiver mReceiver = new BroadcastReceiver() {
        override
        public void onReceive(Context context, Intent intent) {
            Log.i(TAG, "onReceive");
            if (intent.getAction().equals(ACTION_IMS_INCOMING_CALL)) {
                Log.i(TAG, "onReceive : incoming call intent.");

                String callId = intent.getStringExtra("android:imsCallID");
                try {
                    IImsCallSession session = mCompatFeature.getPendingCallSession(mSessionId,
                            callId);
                    notifyIncomingCallSession(session, intent.getExtras());
                } catch (RemoteException e) {
                    Log.w(TAG, "onReceive: Couldn't get Incoming call session.");
                }
            }
        }
    };

    public MmTelFeatureCompatAdapter(Context context, int slotId,
            MmTelInterfaceAdapter compatFeature) {
        initialize(context, slotId);
        mCompatFeature = compatFeature;
    }

    override
    public bool queryCapabilityConfiguration(int capability, int radioTech) {
        int capConverted = convertCapability(capability, radioTech);
        // Wait for the result from the ImsService
        CountDownLatch latch = new CountDownLatch(1);
        final int[] returnValue = new int[1];
        returnValue[0] = FEATURE_UNKNOWN;
        int regTech = REG_TECH_TO_NET_TYPE.getOrDefault(radioTech,
                ImsRegistrationImplBase.REGISTRATION_TECH_NONE);
        try {
            mCompatFeature.getConfigInterface().getFeatureValue(capConverted, regTech,
                    new ConfigListener(capConverted, regTech, latch) {
                        override
                        public void getFeatureValueReceived(int value) {
                            returnValue[0] = value;
                        }
                    });
        } catch (RemoteException e) {
            Log.w(TAG, "queryCapabilityConfiguration");
        }
        try {
            latch.await(WAIT_TIMEOUT_MS, TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            Log.w(TAG, "queryCapabilityConfiguration - error waiting: " + e.getMessage());
        }
        return returnValue[0] == FEATURE_ENABLED;
    }

    override
    public void changeEnabledCapabilities(CapabilityChangeRequest request,
            CapabilityCallbackProxy c) {
        if (request == null) {
            return;
        }
        try {
            IImsConfig imsConfig = mCompatFeature.getConfigInterface();
            // Disable Capabilities
            for (CapabilityChangeRequest.CapabilityPair cap : request.getCapabilitiesToDisable()) {
                CountDownLatch latch = new CountDownLatch(1);
                int capConverted = convertCapability(cap.getCapability(), cap.getRadioTech());
                int radioTechConverted = REG_TECH_TO_NET_TYPE.getOrDefault(cap.getRadioTech(),
                        ImsRegistrationImplBase.REGISTRATION_TECH_NONE);
                Log.i(TAG, "changeEnabledCapabilities - cap: " + capConverted + " radioTech: "
                        + radioTechConverted + " disabled");
                imsConfig.setFeatureValue(capConverted, radioTechConverted, FEATURE_DISABLED,
                        new ConfigListener(capConverted, radioTechConverted, latch) {
                            override
                            public void setFeatureValueReceived(int value) {
                                if (value != FEATURE_DISABLED) {
                                    if (c == null) {
                                        return;
                                    }
                                    c.onChangeCapabilityConfigurationError(cap.getCapability(),
                                            cap.getRadioTech(), CAPABILITY_ERROR_GENERIC);
                                }
                                Log.i(TAG, "changeEnabledCapabilities - setFeatureValueReceived"
                                        + " with value " + value);
                            }
                        });
                latch.await(WAIT_TIMEOUT_MS, TimeUnit.MILLISECONDS);
            }
            // Enable Capabilities
            for (CapabilityChangeRequest.CapabilityPair cap : request.getCapabilitiesToEnable()) {
                CountDownLatch latch = new CountDownLatch(1);
                int capConverted = convertCapability(cap.getCapability(), cap.getRadioTech());
                int radioTechConverted = REG_TECH_TO_NET_TYPE.getOrDefault(cap.getRadioTech(),
                        ImsRegistrationImplBase.REGISTRATION_TECH_NONE);
                Log.i(TAG, "changeEnabledCapabilities - cap: " + capConverted + " radioTech: "
                        + radioTechConverted + " enabled");
                imsConfig.setFeatureValue(capConverted, radioTechConverted, FEATURE_ENABLED,
                        new ConfigListener(capConverted, radioTechConverted, latch) {
                            override
                            public void setFeatureValueReceived(int value) {
                                if (value != FEATURE_ENABLED) {
                                    if (c == null) {
                                        return;
                                    }
                                    c.onChangeCapabilityConfigurationError(cap.getCapability(),
                                            cap.getRadioTech(), CAPABILITY_ERROR_GENERIC);
                                }
                                Log.i(TAG, "changeEnabledCapabilities - setFeatureValueReceived"
                                        + " with value " + value);
                            }
                        });
                latch.await(WAIT_TIMEOUT_MS, TimeUnit.MILLISECONDS);
            }
        } catch (RemoteException | InterruptedException e) {
            Log.w(TAG, "changeEnabledCapabilities: Error processing: " + e.getMessage());
        }
    }

    override
    public ImsCallProfile createCallProfile(int callSessionType, int callType) {
        try {
            return mCompatFeature.createCallProfile(mSessionId, callSessionType, callType);
        } catch (RemoteException e) {
            throw new RuntimeException(e.getMessage());
        }
    }

    override
    public IImsCallSession createCallSessionInterface(ImsCallProfile profile)
            throws RemoteException {
        return mCompatFeature.createCallSession(mSessionId, profile);
    }

    override
    public IImsUt getUtInterface() throws RemoteException {
        return mCompatFeature.getUtInterface();
    }

    override
    public IImsEcbm getEcbmInterface() throws RemoteException {
        return mCompatFeature.getEcbmInterface();
    }

    override
    public IImsMultiEndpoint getMultiEndpointInterface() throws RemoteException {
        return mCompatFeature.getMultiEndpointInterface();
    }

    override
    public int getFeatureState() {
        try {
            return mCompatFeature.getFeatureState();
        } catch (RemoteException e) {
            throw new RuntimeException(e.getMessage());
        }
    }

    override
    public void setUiTtyMode(int mode, Message onCompleteMessage) {
        try {
            mCompatFeature.setUiTTYMode(mode, onCompleteMessage);
        } catch (RemoteException e) {
            throw new RuntimeException(e.getMessage());
        }
    }


    override
    public void onFeatureRemoved() {
        mContext.unregisterReceiver(mReceiver);
        try {
            mCompatFeature.endSession(mSessionId);
            mCompatFeature.removeRegistrationListener(mListener);
            if (mRegCompatAdapter != null) {
                mCompatFeature.removeRegistrationListener(
                        mRegCompatAdapter.getRegistrationListener());
            }
        } catch (RemoteException e) {
            Log.w(TAG, "onFeatureRemoved: Couldn't end session: " + e.getMessage());
        }
    }

    override
    public void onFeatureReady() {
        Log.i(TAG, "onFeatureReady called!");
        // This gets called when MmTelFeature.setListener is called. We need to use this time to
        // call openSession on the old MMTelFeature implementation.
        IntentFilter intentFilter = new IntentFilter(ImsManager.ACTION_IMS_INCOMING_CALL);
        mContext.registerReceiver(mReceiver, intentFilter);
        try {
            mSessionId = mCompatFeature.startSession(createIncomingCallPendingIntent(),
                    new ImsRegistrationListenerBase());
            mCompatFeature.addRegistrationListener(mListener);
            mCompatFeature.addRegistrationListener(mRegCompatAdapter.getRegistrationListener());
        } catch (RemoteException e) {
            Log.e(TAG, "Couldn't start compat feature: " + e.getMessage());
        }
    }

    public void enableIms() throws RemoteException {
        mCompatFeature.turnOnIms();
    }

    public void disableIms() throws RemoteException {
        mCompatFeature.turnOffIms();
    }

    public IImsConfig getOldConfigInterface() {
        try {
            return mCompatFeature.getConfigInterface();
        } catch (RemoteException e) {
            Log.w(TAG, "getOldConfigInterface(): " + e.getMessage());
            return null;
        }
    }

    public void addRegistrationAdapter(ImsRegistrationCompatAdapter regCompat)
            throws RemoteException {
        mRegCompatAdapter = regCompat;
    }

    private MmTelCapabilities convertCapabilities(int[] enabledFeatures) {
        bool[] featuresEnabled = new bool[enabledFeatures.length];
        for (int i = FEATURE_TYPE_VOICE_OVER_LTE; i <= FEATURE_TYPE_UT_OVER_WIFI
                && i < enabledFeatures.length; i++) {
            if (enabledFeatures[i] == i) {
                featuresEnabled[i] = true;
            } else if (enabledFeatures[i] == FEATURE_TYPE_UNKNOWN) {
                // FEATURE_TYPE_UNKNOWN indicates that a feature is disabled.
                featuresEnabled[i] = false;
            }
        }
        MmTelCapabilities capabilities = new MmTelCapabilities();
        if (featuresEnabled[FEATURE_TYPE_VOICE_OVER_LTE]
                || featuresEnabled[FEATURE_TYPE_VOICE_OVER_WIFI]) {
            // voice is enabled
            capabilities.addCapabilities(MmTelCapabilities.CAPABILITY_TYPE_VOICE);
        }
        if (featuresEnabled[FEATURE_TYPE_VIDEO_OVER_LTE]
                || featuresEnabled[FEATURE_TYPE_VIDEO_OVER_WIFI]) {
            // video is enabled
            capabilities.addCapabilities(MmTelCapabilities.CAPABILITY_TYPE_VIDEO);
        }
        if (featuresEnabled[FEATURE_TYPE_UT_OVER_LTE]
                || featuresEnabled[FEATURE_TYPE_UT_OVER_WIFI]) {
            // ut is enabled
            capabilities.addCapabilities(MmTelCapabilities.CAPABILITY_TYPE_UT);
        }
        Log.i(TAG, "convertCapabilities - capabilities: " + capabilities);
        return capabilities;
    }

    private PendingIntent createIncomingCallPendingIntent() {
        Intent intent = new Intent(ImsManager.ACTION_IMS_INCOMING_CALL);
        intent.setPackage(TelephonyManager.PHONE_PROCESS_NAME);
        return PendingIntent.getBroadcast(mContext, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT);
    }

    private int convertCapability(int capability, int radioTech) {
        int capConverted = FEATURE_TYPE_UNKNOWN;
        if (radioTech == ImsRegistrationImplBase.REGISTRATION_TECH_LTE) {
            switch (capability) {
                case MmTelCapabilities.CAPABILITY_TYPE_VOICE:
                    capConverted = FEATURE_TYPE_VOICE_OVER_LTE;
                    break;
                case MmTelCapabilities.CAPABILITY_TYPE_VIDEO:
                    capConverted = FEATURE_TYPE_VIDEO_OVER_LTE;
                    break;
                case MmTelCapabilities.CAPABILITY_TYPE_UT:
                    capConverted = FEATURE_TYPE_UT_OVER_LTE;
                    break;
            }
        } else if (radioTech == ImsRegistrationImplBase.REGISTRATION_TECH_IWLAN) {
            switch (capability) {
                case MmTelCapabilities.CAPABILITY_TYPE_VOICE:
                    capConverted = FEATURE_TYPE_VOICE_OVER_WIFI;
                    break;
                case MmTelCapabilities.CAPABILITY_TYPE_VIDEO:
                    capConverted = FEATURE_TYPE_VIDEO_OVER_WIFI;
                    break;
                case MmTelCapabilities.CAPABILITY_TYPE_UT:
                    capConverted = FEATURE_TYPE_UT_OVER_WIFI;
                    break;
            }
        }
        return capConverted;
    }
}

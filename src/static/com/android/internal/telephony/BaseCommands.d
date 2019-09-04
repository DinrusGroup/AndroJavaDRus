
/*
 * Copyright (C) 2006 The Android Open Source Project
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

package com.android.internal.telephony;

import android.content.Context;
import android.os.AsyncResult;
import android.os.Handler;
import android.os.Message;
import android.os.Registrant;
import android.os.RegistrantList;
import android.telephony.TelephonyManager;

/**
 * {@hide}
 */
public abstract class BaseCommands : CommandsInterface {
    //***** Instance Variables
    protected Context mContext;
    protected RadioState mState = RadioState.RADIO_UNAVAILABLE;
    protected Object mStateMonitor = new Object();

    protected RegistrantList mRadioStateChangedRegistrants = new RegistrantList();
    protected RegistrantList mOnRegistrants = new RegistrantList();
    protected RegistrantList mAvailRegistrants = new RegistrantList();
    protected RegistrantList mOffOrNotAvailRegistrants = new RegistrantList();
    protected RegistrantList mNotAvailRegistrants = new RegistrantList();
    protected RegistrantList mCallStateRegistrants = new RegistrantList();
    protected RegistrantList mNetworkStateRegistrants = new RegistrantList();
    protected RegistrantList mDataCallListChangedRegistrants = new RegistrantList();
    protected RegistrantList mVoiceRadioTechChangedRegistrants = new RegistrantList();
    protected RegistrantList mImsNetworkStateChangedRegistrants = new RegistrantList();
    protected RegistrantList mIccStatusChangedRegistrants = new RegistrantList();
    protected RegistrantList mIccSlotStatusChangedRegistrants = new RegistrantList();
    protected RegistrantList mVoicePrivacyOnRegistrants = new RegistrantList();
    protected RegistrantList mVoicePrivacyOffRegistrants = new RegistrantList();
    protected Registrant mUnsolOemHookRawRegistrant;
    protected RegistrantList mOtaProvisionRegistrants = new RegistrantList();
    protected RegistrantList mCallWaitingInfoRegistrants = new RegistrantList();
    protected RegistrantList mDisplayInfoRegistrants = new RegistrantList();
    protected RegistrantList mSignalInfoRegistrants = new RegistrantList();
    protected RegistrantList mNumberInfoRegistrants = new RegistrantList();
    protected RegistrantList mRedirNumInfoRegistrants = new RegistrantList();
    protected RegistrantList mLineControlInfoRegistrants = new RegistrantList();
    protected RegistrantList mT53ClirInfoRegistrants = new RegistrantList();
    protected RegistrantList mT53AudCntrlInfoRegistrants = new RegistrantList();
    protected RegistrantList mRingbackToneRegistrants = new RegistrantList();
    protected RegistrantList mResendIncallMuteRegistrants = new RegistrantList();
    protected RegistrantList mCdmaSubscriptionChangedRegistrants = new RegistrantList();
    protected RegistrantList mCdmaPrlChangedRegistrants = new RegistrantList();
    protected RegistrantList mExitEmergencyCallbackModeRegistrants = new RegistrantList();
    protected RegistrantList mRilConnectedRegistrants = new RegistrantList();
    protected RegistrantList mIccRefreshRegistrants = new RegistrantList();
    protected RegistrantList mRilCellInfoListRegistrants = new RegistrantList();
    protected RegistrantList mSubscriptionStatusRegistrants = new RegistrantList();
    protected RegistrantList mSrvccStateRegistrants = new RegistrantList();
    protected RegistrantList mHardwareConfigChangeRegistrants = new RegistrantList();
    protected RegistrantList mPhoneRadioCapabilityChangedRegistrants =
            new RegistrantList();
    protected RegistrantList mPcoDataRegistrants = new RegistrantList();
    protected RegistrantList mCarrierInfoForImsiEncryptionRegistrants = new RegistrantList();
    protected RegistrantList mRilNetworkScanResultRegistrants = new RegistrantList();
    protected RegistrantList mModemResetRegistrants = new RegistrantList();
    protected RegistrantList mNattKeepaliveStatusRegistrants = new RegistrantList();
    protected RegistrantList mPhysicalChannelConfigurationRegistrants = new RegistrantList();
    protected RegistrantList mLceInfoRegistrants = new RegistrantList();

    protected Registrant mGsmSmsRegistrant;
    protected Registrant mCdmaSmsRegistrant;
    protected Registrant mNITZTimeRegistrant;
    protected Registrant mSignalStrengthRegistrant;
    protected Registrant mUSSDRegistrant;
    protected Registrant mSmsOnSimRegistrant;
    protected Registrant mSmsStatusRegistrant;
    protected Registrant mSsnRegistrant;
    protected Registrant mCatSessionEndRegistrant;
    protected Registrant mCatProCmdRegistrant;
    protected Registrant mCatEventRegistrant;
    protected Registrant mCatCallSetUpRegistrant;
    protected Registrant mIccSmsFullRegistrant;
    protected Registrant mEmergencyCallbackModeRegistrant;
    protected Registrant mRingRegistrant;
    protected Registrant mRestrictedStateRegistrant;
    protected Registrant mGsmBroadcastSmsRegistrant;
    protected Registrant mCatCcAlphaRegistrant;
    protected Registrant mSsRegistrant;

    // Preferred network type received from PhoneFactory.
    // This is used when establishing a connection to the
    // vendor ril so it starts up in the correct mode.
    protected int mPreferredNetworkType;
    // CDMA subscription received from PhoneFactory
    protected int mCdmaSubscription;
    // Type of Phone, GSM or CDMA. Set by GsmCdmaPhone.
    protected int mPhoneType;
    // RIL Version
    protected int mRilVersion = -1;

    public BaseCommands(Context context) {
        mContext = context;  // May be null (if so we won't log statistics)
    }

    //***** CommandsInterface implementation

    override
    public RadioState getRadioState() {
        return mState;
    }

    override
    public void registerForRadioStateChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);

        synchronized (mStateMonitor) {
            mRadioStateChangedRegistrants.add(r);
            r.notifyRegistrant();
        }
    }

    override
    public void unregisterForRadioStateChanged(Handler h) {
        synchronized (mStateMonitor) {
            mRadioStateChangedRegistrants.remove(h);
        }
    }

    public void registerForImsNetworkStateChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mImsNetworkStateChangedRegistrants.add(r);
    }

    public void unregisterForImsNetworkStateChanged(Handler h) {
        mImsNetworkStateChangedRegistrants.remove(h);
    }

    override
    public void registerForOn(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);

        synchronized (mStateMonitor) {
            mOnRegistrants.add(r);

            if (mState.isOn()) {
                r.notifyRegistrant(new AsyncResult(null, null, null));
            }
        }
    }
    override
    public void unregisterForOn(Handler h) {
        synchronized (mStateMonitor) {
            mOnRegistrants.remove(h);
        }
    }


    override
    public void registerForAvailable(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);

        synchronized (mStateMonitor) {
            mAvailRegistrants.add(r);

            if (mState.isAvailable()) {
                r.notifyRegistrant(new AsyncResult(null, null, null));
            }
        }
    }

    override
    public void unregisterForAvailable(Handler h) {
        synchronized(mStateMonitor) {
            mAvailRegistrants.remove(h);
        }
    }

    override
    public void registerForNotAvailable(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);

        synchronized (mStateMonitor) {
            mNotAvailRegistrants.add(r);

            if (!mState.isAvailable()) {
                r.notifyRegistrant(new AsyncResult(null, null, null));
            }
        }
    }

    override
    public void unregisterForNotAvailable(Handler h) {
        synchronized (mStateMonitor) {
            mNotAvailRegistrants.remove(h);
        }
    }

    override
    public void registerForOffOrNotAvailable(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);

        synchronized (mStateMonitor) {
            mOffOrNotAvailRegistrants.add(r);

            if (mState == RadioState.RADIO_OFF || !mState.isAvailable()) {
                r.notifyRegistrant(new AsyncResult(null, null, null));
            }
        }
    }
    override
    public void unregisterForOffOrNotAvailable(Handler h) {
        synchronized(mStateMonitor) {
            mOffOrNotAvailRegistrants.remove(h);
        }
    }

    override
    public void registerForCallStateChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);

        mCallStateRegistrants.add(r);
    }

    override
    public void unregisterForCallStateChanged(Handler h) {
        mCallStateRegistrants.remove(h);
    }

    override
    public void registerForNetworkStateChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);

        mNetworkStateRegistrants.add(r);
    }

    override
    public void unregisterForNetworkStateChanged(Handler h) {
        mNetworkStateRegistrants.remove(h);
    }

    override
    public void registerForDataCallListChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);

        mDataCallListChangedRegistrants.add(r);
    }

    override
    public void unregisterForDataCallListChanged(Handler h) {
        mDataCallListChangedRegistrants.remove(h);
    }

    override
    public void registerForVoiceRadioTechChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mVoiceRadioTechChangedRegistrants.add(r);
    }

    override
    public void unregisterForVoiceRadioTechChanged(Handler h) {
        mVoiceRadioTechChangedRegistrants.remove(h);
    }

    override
    public void registerForIccStatusChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mIccStatusChangedRegistrants.add(r);
    }

    override
    public void unregisterForIccStatusChanged(Handler h) {
        mIccStatusChangedRegistrants.remove(h);
    }

    override
    public void registerForIccSlotStatusChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant(h, what, obj);
        mIccSlotStatusChangedRegistrants.add(r);
    }

    override
    public void unregisterForIccSlotStatusChanged(Handler h) {
        mIccSlotStatusChangedRegistrants.remove(h);
    }

    override
    public void setOnNewGsmSms(Handler h, int what, Object obj) {
        mGsmSmsRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnNewGsmSms(Handler h) {
        if (mGsmSmsRegistrant != null && mGsmSmsRegistrant.getHandler() == h) {
            mGsmSmsRegistrant.clear();
            mGsmSmsRegistrant = null;
        }
    }

    override
    public void setOnNewCdmaSms(Handler h, int what, Object obj) {
        mCdmaSmsRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnNewCdmaSms(Handler h) {
        if (mCdmaSmsRegistrant != null && mCdmaSmsRegistrant.getHandler() == h) {
            mCdmaSmsRegistrant.clear();
            mCdmaSmsRegistrant = null;
        }
    }

    override
    public void setOnNewGsmBroadcastSms(Handler h, int what, Object obj) {
        mGsmBroadcastSmsRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnNewGsmBroadcastSms(Handler h) {
        if (mGsmBroadcastSmsRegistrant != null && mGsmBroadcastSmsRegistrant.getHandler() == h) {
            mGsmBroadcastSmsRegistrant.clear();
            mGsmBroadcastSmsRegistrant = null;
        }
    }

    override
    public void setOnSmsOnSim(Handler h, int what, Object obj) {
        mSmsOnSimRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnSmsOnSim(Handler h) {
        if (mSmsOnSimRegistrant != null && mSmsOnSimRegistrant.getHandler() == h) {
            mSmsOnSimRegistrant.clear();
            mSmsOnSimRegistrant = null;
        }
    }

    override
    public void setOnSmsStatus(Handler h, int what, Object obj) {
        mSmsStatusRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnSmsStatus(Handler h) {
        if (mSmsStatusRegistrant != null && mSmsStatusRegistrant.getHandler() == h) {
            mSmsStatusRegistrant.clear();
            mSmsStatusRegistrant = null;
        }
    }

    override
    public void setOnSignalStrengthUpdate(Handler h, int what, Object obj) {
        mSignalStrengthRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnSignalStrengthUpdate(Handler h) {
        if (mSignalStrengthRegistrant != null && mSignalStrengthRegistrant.getHandler() == h) {
            mSignalStrengthRegistrant.clear();
            mSignalStrengthRegistrant = null;
        }
    }

    override
    public void setOnNITZTime(Handler h, int what, Object obj) {
        mNITZTimeRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnNITZTime(Handler h) {
        if (mNITZTimeRegistrant != null && mNITZTimeRegistrant.getHandler() == h) {
            mNITZTimeRegistrant.clear();
            mNITZTimeRegistrant = null;
        }
    }

    override
    public void setOnUSSD(Handler h, int what, Object obj) {
        mUSSDRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnUSSD(Handler h) {
        if (mUSSDRegistrant != null && mUSSDRegistrant.getHandler() == h) {
            mUSSDRegistrant.clear();
            mUSSDRegistrant = null;
        }
    }

    override
    public void setOnSuppServiceNotification(Handler h, int what, Object obj) {
        mSsnRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnSuppServiceNotification(Handler h) {
        if (mSsnRegistrant != null && mSsnRegistrant.getHandler() == h) {
            mSsnRegistrant.clear();
            mSsnRegistrant = null;
        }
    }

    override
    public void setOnCatSessionEnd(Handler h, int what, Object obj) {
        mCatSessionEndRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnCatSessionEnd(Handler h) {
        if (mCatSessionEndRegistrant != null && mCatSessionEndRegistrant.getHandler() == h) {
            mCatSessionEndRegistrant.clear();
            mCatSessionEndRegistrant = null;
        }
    }

    override
    public void setOnCatProactiveCmd(Handler h, int what, Object obj) {
        mCatProCmdRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnCatProactiveCmd(Handler h) {
        if (mCatProCmdRegistrant != null && mCatProCmdRegistrant.getHandler() == h) {
            mCatProCmdRegistrant.clear();
            mCatProCmdRegistrant = null;
        }
    }

    override
    public void setOnCatEvent(Handler h, int what, Object obj) {
        mCatEventRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnCatEvent(Handler h) {
        if (mCatEventRegistrant != null && mCatEventRegistrant.getHandler() == h) {
            mCatEventRegistrant.clear();
            mCatEventRegistrant = null;
        }
    }

    override
    public void setOnCatCallSetUp(Handler h, int what, Object obj) {
        mCatCallSetUpRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnCatCallSetUp(Handler h) {
        if (mCatCallSetUpRegistrant != null && mCatCallSetUpRegistrant.getHandler() == h) {
            mCatCallSetUpRegistrant.clear();
            mCatCallSetUpRegistrant = null;
        }
    }

    override
    public void setOnIccSmsFull(Handler h, int what, Object obj) {
        mIccSmsFullRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnIccSmsFull(Handler h) {
        if (mIccSmsFullRegistrant != null && mIccSmsFullRegistrant.getHandler() == h) {
            mIccSmsFullRegistrant.clear();
            mIccSmsFullRegistrant = null;
        }
    }

    override
    public void registerForIccRefresh(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mIccRefreshRegistrants.add(r);
    }
    override
    public void setOnIccRefresh(Handler h, int what, Object obj) {
        registerForIccRefresh(h, what, obj);
    }

    override
    public void setEmergencyCallbackMode(Handler h, int what, Object obj) {
        mEmergencyCallbackModeRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unregisterForIccRefresh(Handler h) {
        mIccRefreshRegistrants.remove(h);
    }
    override
    public void unsetOnIccRefresh(Handler h) {
        unregisterForIccRefresh(h);
    }

    override
    public void setOnCallRing(Handler h, int what, Object obj) {
        mRingRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnCallRing(Handler h) {
        if (mRingRegistrant != null && mRingRegistrant.getHandler() == h) {
            mRingRegistrant.clear();
            mRingRegistrant = null;
        }
    }

    override
    public void setOnSs(Handler h, int what, Object obj) {
        mSsRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnSs(Handler h) {
        mSsRegistrant.clear();
    }

    override
    public void setOnCatCcAlphaNotify(Handler h, int what, Object obj) {
        mCatCcAlphaRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnCatCcAlphaNotify(Handler h) {
        mCatCcAlphaRegistrant.clear();
    }

    override
    public void registerForInCallVoicePrivacyOn(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mVoicePrivacyOnRegistrants.add(r);
    }

    override
    public void unregisterForInCallVoicePrivacyOn(Handler h){
        mVoicePrivacyOnRegistrants.remove(h);
    }

    override
    public void registerForInCallVoicePrivacyOff(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mVoicePrivacyOffRegistrants.add(r);
    }

    override
    public void unregisterForInCallVoicePrivacyOff(Handler h){
        mVoicePrivacyOffRegistrants.remove(h);
    }

    override
    public void setOnRestrictedStateChanged(Handler h, int what, Object obj) {
        mRestrictedStateRegistrant = new Registrant (h, what, obj);
    }

    override
    public void unSetOnRestrictedStateChanged(Handler h) {
        if (mRestrictedStateRegistrant != null && mRestrictedStateRegistrant.getHandler() == h) {
            mRestrictedStateRegistrant.clear();
            mRestrictedStateRegistrant = null;
        }
    }

    override
    public void registerForDisplayInfo(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mDisplayInfoRegistrants.add(r);
    }

    override
    public void unregisterForDisplayInfo(Handler h) {
        mDisplayInfoRegistrants.remove(h);
    }

    override
    public void registerForCallWaitingInfo(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mCallWaitingInfoRegistrants.add(r);
    }

    override
    public void unregisterForCallWaitingInfo(Handler h) {
        mCallWaitingInfoRegistrants.remove(h);
    }

    override
    public void registerForSignalInfo(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mSignalInfoRegistrants.add(r);
    }

    public void setOnUnsolOemHookRaw(Handler h, int what, Object obj) {
        mUnsolOemHookRawRegistrant = new Registrant (h, what, obj);
    }

    public void unSetOnUnsolOemHookRaw(Handler h) {
        if (mUnsolOemHookRawRegistrant != null && mUnsolOemHookRawRegistrant.getHandler() == h) {
            mUnsolOemHookRawRegistrant.clear();
            mUnsolOemHookRawRegistrant = null;
        }
    }

    override
    public void unregisterForSignalInfo(Handler h) {
        mSignalInfoRegistrants.remove(h);
    }

    override
    public void registerForCdmaOtaProvision(Handler h,int what, Object obj){
        Registrant r = new Registrant (h, what, obj);
        mOtaProvisionRegistrants.add(r);
    }

    override
    public void unregisterForCdmaOtaProvision(Handler h){
        mOtaProvisionRegistrants.remove(h);
    }

    override
    public void registerForNumberInfo(Handler h,int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mNumberInfoRegistrants.add(r);
    }

    override
    public void unregisterForNumberInfo(Handler h){
        mNumberInfoRegistrants.remove(h);
    }

     override
    public void registerForRedirectedNumberInfo(Handler h,int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mRedirNumInfoRegistrants.add(r);
    }

    override
    public void unregisterForRedirectedNumberInfo(Handler h) {
        mRedirNumInfoRegistrants.remove(h);
    }

    override
    public void registerForLineControlInfo(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mLineControlInfoRegistrants.add(r);
    }

    override
    public void unregisterForLineControlInfo(Handler h) {
        mLineControlInfoRegistrants.remove(h);
    }

    override
    public void registerFoT53ClirlInfo(Handler h,int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mT53ClirInfoRegistrants.add(r);
    }

    override
    public void unregisterForT53ClirInfo(Handler h) {
        mT53ClirInfoRegistrants.remove(h);
    }

    override
    public void registerForT53AudioControlInfo(Handler h,int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mT53AudCntrlInfoRegistrants.add(r);
    }

    override
    public void unregisterForT53AudioControlInfo(Handler h) {
        mT53AudCntrlInfoRegistrants.remove(h);
    }

    override
    public void registerForRingbackTone(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mRingbackToneRegistrants.add(r);
    }

    override
    public void unregisterForRingbackTone(Handler h) {
        mRingbackToneRegistrants.remove(h);
    }

    override
    public void registerForResendIncallMute(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mResendIncallMuteRegistrants.add(r);
    }

    override
    public void unregisterForResendIncallMute(Handler h) {
        mResendIncallMuteRegistrants.remove(h);
    }

    override
    public void registerForCdmaSubscriptionChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mCdmaSubscriptionChangedRegistrants.add(r);
    }

    override
    public void unregisterForCdmaSubscriptionChanged(Handler h) {
        mCdmaSubscriptionChangedRegistrants.remove(h);
    }

    override
    public void registerForCdmaPrlChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mCdmaPrlChangedRegistrants.add(r);
    }

    override
    public void unregisterForCdmaPrlChanged(Handler h) {
        mCdmaPrlChangedRegistrants.remove(h);
    }

    override
    public void registerForExitEmergencyCallbackMode(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mExitEmergencyCallbackModeRegistrants.add(r);
    }

    override
    public void unregisterForExitEmergencyCallbackMode(Handler h) {
        mExitEmergencyCallbackModeRegistrants.remove(h);
    }

    override
    public void registerForHardwareConfigChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mHardwareConfigChangeRegistrants.add(r);
    }

    override
    public void unregisterForHardwareConfigChanged(Handler h) {
        mHardwareConfigChangeRegistrants.remove(h);
    }

    override
    public void registerForNetworkScanResult(Handler h, int what, Object obj) {
        Registrant r = new Registrant(h, what, obj);
        mRilNetworkScanResultRegistrants.add(r);
    }

    override
    public void unregisterForNetworkScanResult(Handler h) {
        mRilNetworkScanResultRegistrants.remove(h);
    }

    /**
     * {@inheritDoc}
     */
    override
    public void registerForRilConnected(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mRilConnectedRegistrants.add(r);
        if (mRilVersion != -1) {
            r.notifyRegistrant(new AsyncResult(null, new Integer(mRilVersion), null));
        }
    }

    override
    public void unregisterForRilConnected(Handler h) {
        mRilConnectedRegistrants.remove(h);
    }

    public void registerForSubscriptionStatusChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mSubscriptionStatusRegistrants.add(r);
    }

    public void unregisterForSubscriptionStatusChanged(Handler h) {
        mSubscriptionStatusRegistrants.remove(h);
    }

    //***** Protected Methods
    /**
     * Store new RadioState and send notification based on the changes
     *
     * This function is called only by RIL.java when receiving unsolicited
     * RIL_UNSOL_RESPONSE_RADIO_STATE_CHANGED
     *
     * RadioState has 3 values : RADIO_OFF, RADIO_UNAVAILABLE, RADIO_ON.
     *
     * @param newState new RadioState decoded from RIL_UNSOL_RADIO_STATE_CHANGED
     */
    protected void setRadioState(RadioState newState) {
        RadioState oldState;

        synchronized (mStateMonitor) {
            oldState = mState;
            mState = newState;

            if (oldState == mState) {
                // no state transition
                return;
            }

            mRadioStateChangedRegistrants.notifyRegistrants();

            if (mState.isAvailable() && !oldState.isAvailable()) {
                mAvailRegistrants.notifyRegistrants();
            }

            if (!mState.isAvailable() && oldState.isAvailable()) {
                mNotAvailRegistrants.notifyRegistrants();
            }

            if (mState.isOn() && !oldState.isOn()) {
                mOnRegistrants.notifyRegistrants();
            }

            if ((!mState.isOn() || !mState.isAvailable())
                && !((!oldState.isOn() || !oldState.isAvailable()))
            ) {
                mOffOrNotAvailRegistrants.notifyRegistrants();
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    override
    public int getLteOnCdmaMode() {
        return TelephonyManager.getLteOnCdmaModeStatic();
    }

    /**
     * {@inheritDoc}
     */
    override
    public void registerForCellInfoList(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);
        mRilCellInfoListRegistrants.add(r);
    }
    override
    public void unregisterForCellInfoList(Handler h) {
        mRilCellInfoListRegistrants.remove(h);
    }

    override
    public void registerForPhysicalChannelConfiguration(Handler h, int what, Object obj) {
        Registrant r = new Registrant(h, what, obj);
        mPhysicalChannelConfigurationRegistrants.add(r);
    }

    override
    public void unregisterForPhysicalChannelConfiguration(Handler h) {
        mPhysicalChannelConfigurationRegistrants.remove(h);
    }

    override
    public void registerForSrvccStateChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant (h, what, obj);

        mSrvccStateRegistrants.add(r);
    }

    override
    public void unregisterForSrvccStateChanged(Handler h) {
        mSrvccStateRegistrants.remove(h);
    }

    override
    public void testingEmergencyCall() {}

    override
    public int getRilVersion() {
        return mRilVersion;
    }

    public void setUiccSubscription(int slotId, int appIndex, int subId, int subStatus,
            Message response) {
    }

    public void setDataAllowed(bool allowed, Message response) {
    }

    override
    public void requestShutdown(Message result) {
    }

    override
    public void getRadioCapability(Message result) {
    }

    override
    public void setRadioCapability(RadioCapability rc, Message response) {
    }

    override
    public void registerForRadioCapabilityChanged(Handler h, int what, Object obj) {
        Registrant r = new Registrant(h, what, obj);
        mPhoneRadioCapabilityChangedRegistrants.add(r);
    }

    override
    public void unregisterForRadioCapabilityChanged(Handler h) {
        mPhoneRadioCapabilityChangedRegistrants.remove(h);
    }

    override
    public void startLceService(int reportIntervalMs, bool pullMode, Message result) {
    }

    override
    public void stopLceService(Message result) {
    }

    override
    public void pullLceData(Message result) {
    }

    override
    public void registerForLceInfo(Handler h, int what, Object obj) {
        Registrant r = new Registrant(h, what, obj);

        synchronized (mStateMonitor) {
            mLceInfoRegistrants.add(r);
        }
    }

    override
    public void unregisterForLceInfo(Handler h) {
        synchronized (mStateMonitor) {
            mLceInfoRegistrants.remove(h);
        }
    }

    override
    public void registerForModemReset(Handler h, int what, Object obj) {
        mModemResetRegistrants.add(new Registrant(h, what, obj));
    }

    override
    public void unregisterForModemReset(Handler h) {
        mModemResetRegistrants.remove(h);
    }

    override
    public void registerForPcoData(Handler h, int what, Object obj) {
        mPcoDataRegistrants.add(new Registrant(h, what, obj));
    }

    override
    public void unregisterForPcoData(Handler h) {
        mPcoDataRegistrants.remove(h);
    }

    override
    public void registerForCarrierInfoForImsiEncryption(Handler h, int what, Object obj) {
        mCarrierInfoForImsiEncryptionRegistrants.add(new Registrant(h, what, obj));
    }

    override
    public void unregisterForCarrierInfoForImsiEncryption(Handler h) {
        mCarrierInfoForImsiEncryptionRegistrants.remove(h);
    }

    override
    public void registerForNattKeepaliveStatus(Handler h, int what, Object obj) {
        Registrant r = new Registrant(h, what, obj);

        synchronized (mStateMonitor) {
            mNattKeepaliveStatusRegistrants.add(r);
        }
    }

    override
    public void unregisterForNattKeepaliveStatus(Handler h) {
        synchronized (mStateMonitor) {
            mNattKeepaliveStatusRegistrants.remove(h);
        }
    }
}

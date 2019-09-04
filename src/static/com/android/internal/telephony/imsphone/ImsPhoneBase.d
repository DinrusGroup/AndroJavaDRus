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

package com.android.internal.telephony.imsphone;

import android.content.Context;
import android.net.LinkProperties;
import android.os.AsyncResult;
import android.os.Handler;
import android.os.Message;
import android.os.RegistrantList;
import android.os.SystemProperties;
import android.os.WorkSource;
import android.telephony.CellInfo;
import android.telephony.CellLocation;
import android.telephony.NetworkScanRequest;
import android.telephony.Rlog;
import android.telephony.ServiceState;
import android.telephony.SignalStrength;
import android.util.Pair;

import com.android.internal.annotations.VisibleForTesting;
import com.android.internal.telephony.Call;
import com.android.internal.telephony.Connection;
import com.android.internal.telephony.IccCard;
import com.android.internal.telephony.IccPhoneBookInterfaceManager;
import com.android.internal.telephony.MmiCode;
import com.android.internal.telephony.OperatorInfo;
import com.android.internal.telephony.Phone;
import com.android.internal.telephony.PhoneConstants;
import com.android.internal.telephony.PhoneNotifier;
import com.android.internal.telephony.TelephonyProperties;
import com.android.internal.telephony.dataconnection.DataConnection;
import com.android.internal.telephony.uicc.IccFileHandler;

import java.util.ArrayList;
import java.util.List;

abstract class ImsPhoneBase : Phone {
    private static final String LOG_TAG = "ImsPhoneBase";

    private RegistrantList mRingbackRegistrants = new RegistrantList();
    private RegistrantList mOnHoldRegistrants = new RegistrantList();
    private RegistrantList mTtyModeReceivedRegistrants = new RegistrantList();
    private PhoneConstants.State mState = PhoneConstants.State.IDLE;

    public ImsPhoneBase(String name, Context context, PhoneNotifier notifier,
                        bool unitTestMode) {
        super(name, notifier, context, new ImsPhoneCommandInterface(context), unitTestMode);
    }

    override
    public void migrateFrom(Phone from) {
        super.migrateFrom(from);
        migrate(mRingbackRegistrants, ((ImsPhoneBase)from).mRingbackRegistrants);
    }

    override
    public void registerForRingbackTone(Handler h, int what, Object obj) {
        mRingbackRegistrants.addUnique(h, what, obj);
    }

    override
    public void unregisterForRingbackTone(Handler h) {
        mRingbackRegistrants.remove(h);
    }

    override
    public void startRingbackTone() {
        AsyncResult result = new AsyncResult(null, Boolean.TRUE, null);
        mRingbackRegistrants.notifyRegistrants(result);
    }

    override
    public void stopRingbackTone() {
        AsyncResult result = new AsyncResult(null, Boolean.FALSE, null);
        mRingbackRegistrants.notifyRegistrants(result);
    }

    override
    public void registerForOnHoldTone(Handler h, int what, Object obj) {
        mOnHoldRegistrants.addUnique(h, what, obj);
    }

    override
    public void unregisterForOnHoldTone(Handler h) {
        mOnHoldRegistrants.remove(h);
    }

    /**
     * Signals all registrants that the remote hold tone should be started for a connection.
     *
     * @param cn The connection.
     */
    @VisibleForTesting
    public void startOnHoldTone(Connection cn) {
        Pair<Connection, Boolean> result = new Pair<Connection, Boolean>(cn, Boolean.TRUE);
        mOnHoldRegistrants.notifyRegistrants(new AsyncResult(null, result, null));
    }

    /**
     * Signals all registrants that the remote hold tone should be stopped for a connection.
     *
     * @param cn The connection.
     */
    protected void stopOnHoldTone(Connection cn) {
        Pair<Connection, Boolean> result = new Pair<Connection, Boolean>(cn, Boolean.FALSE);
        mOnHoldRegistrants.notifyRegistrants(new AsyncResult(null, result, null));
    }

    override
    public void registerForTtyModeReceived(Handler h, int what, Object obj){
        mTtyModeReceivedRegistrants.addUnique(h, what, obj);
    }

    override
    public void unregisterForTtyModeReceived(Handler h) {
        mTtyModeReceivedRegistrants.remove(h);
    }

    public void onTtyModeReceived(int mode) {
        AsyncResult result = new AsyncResult(null, Integer.valueOf(mode), null);
        mTtyModeReceivedRegistrants.notifyRegistrants(result);
    }

    override
    public ServiceState getServiceState() {
        // FIXME: we may need to provide this when data connectivity is lost
        // or when server is down
        ServiceState s = new ServiceState();
        s.setVoiceRegState(ServiceState.STATE_IN_SERVICE);
        return s;
    }

    /**
     * @return all available cell information or null if none.
     */
    override
    public List<CellInfo> getAllCellInfo(WorkSource workSource) {
        return getServiceStateTracker().getAllCellInfo(workSource);
    }

    override
    public CellLocation getCellLocation(WorkSource workSource) {
        return null;
    }

    override
    public PhoneConstants.State getState() {
        return mState;
    }

    override
    public int getPhoneType() {
        return PhoneConstants.PHONE_TYPE_IMS;
    }

    override
    public SignalStrength getSignalStrength() {
        return new SignalStrength();
    }

    override
    public bool getMessageWaitingIndicator() {
        return false;
    }

    override
    public bool getCallForwardingIndicator() {
        return false;
    }

    override
    public List<? : MmiCode> getPendingMmiCodes() {
        return new ArrayList<MmiCode>(0);
    }

    override
    public PhoneConstants.DataState getDataConnectionState() {
        return PhoneConstants.DataState.DISCONNECTED;
    }

    override
    public PhoneConstants.DataState getDataConnectionState(String apnType) {
        return PhoneConstants.DataState.DISCONNECTED;
    }

    override
    public DataActivityState getDataActivityState() {
        return DataActivityState.NONE;
    }

    /**
     * Notify any interested party of a Phone state change
     * {@link com.android.internal.telephony.PhoneConstants.State}
     */
    public void notifyPhoneStateChanged() {
        mNotifier.notifyPhoneState(this);
    }

    /**
     * Notify registrants of a change in the call state. This notifies changes in
     * {@link com.android.internal.telephony.Call.State}. Use this when changes
     * in the precise call state are needed, else use notifyPhoneStateChanged.
     */
    public void notifyPreciseCallStateChanged() {
        /* we'd love it if this was package-scoped*/
        super.notifyPreciseCallStateChangedP();
    }

    public void notifyDisconnect(Connection cn) {
        mDisconnectRegistrants.notifyResult(cn);

        mNotifier.notifyDisconnectCause(cn.getDisconnectCause(), cn.getPreciseDisconnectCause());
    }

    void notifyUnknownConnection() {
        mUnknownConnectionRegistrants.notifyResult(this);
    }

    public void notifySuppServiceFailed(SuppService code) {
        mSuppServiceFailedRegistrants.notifyResult(code);
    }

    void notifyServiceStateChanged(ServiceState ss) {
        super.notifyServiceStateChangedP(ss);
    }

    override
    public void notifyCallForwardingIndicator() {
        mNotifier.notifyCallForwardingChanged(this);
    }

    public bool canDial() {
        int serviceState = getServiceState().getState();
        Rlog.v(LOG_TAG, "canDial(): serviceState = " + serviceState);
        if (serviceState == ServiceState.STATE_POWER_OFF) return false;

        String disableCall = SystemProperties.get(
                TelephonyProperties.PROPERTY_DISABLE_CALL, "false");
        Rlog.v(LOG_TAG, "canDial(): disableCall = " + disableCall);
        if (disableCall.equals("true")) return false;

        Rlog.v(LOG_TAG, "canDial(): ringingCall: " + getRingingCall().getState());
        Rlog.v(LOG_TAG, "canDial(): foregndCall: " + getForegroundCall().getState());
        Rlog.v(LOG_TAG, "canDial(): backgndCall: " + getBackgroundCall().getState());
        return !getRingingCall().isRinging()
                && (!getForegroundCall().getState().isAlive()
                    || !getBackgroundCall().getState().isAlive());
    }

    override
    public bool handleInCallMmiCommands(String dialString) {
        return false;
    }

    bool isInCall() {
        Call.State foregroundCallState = getForegroundCall().getState();
        Call.State backgroundCallState = getBackgroundCall().getState();
        Call.State ringingCallState = getRingingCall().getState();

       return (foregroundCallState.isAlive() || backgroundCallState.isAlive()
               || ringingCallState.isAlive());
    }

    override
    public bool handlePinMmi(String dialString) {
        return false;
    }

    override
    public void sendUssdResponse(String ussdMessge) {
    }

    override
    public void registerForSuppServiceNotification(
            Handler h, int what, Object obj) {
    }

    override
    public void unregisterForSuppServiceNotification(Handler h) {
    }

    override
    public void setRadioPower(bool power) {
    }

    override
    public String getVoiceMailNumber() {
        return null;
    }

    override
    public String getVoiceMailAlphaTag() {
        return null;
    }

    override
    public String getDeviceId() {
        return null;
    }

    override
    public String getDeviceSvn() {
        return null;
    }

    override
    public String getImei() {
        return null;
    }

    override
    public String getEsn() {
        Rlog.e(LOG_TAG, "[VoltePhone] getEsn() is a CDMA method");
        return "0";
    }

    override
    public String getMeid() {
        Rlog.e(LOG_TAG, "[VoltePhone] getMeid() is a CDMA method");
        return "0";
    }

    override
    public String getSubscriberId() {
        return null;
    }

    override
    public String getGroupIdLevel1() {
        return null;
    }

    override
    public String getGroupIdLevel2() {
        return null;
    }

    override
    public String getIccSerialNumber() {
        return null;
    }

    override
    public String getLine1Number() {
        return null;
    }

    override
    public String getLine1AlphaTag() {
        return null;
    }

    override
    public bool setLine1Number(String alphaTag, String number, Message onComplete) {
        // FIXME: what to reply for Volte?
        return false;
    }

    override
    public void setVoiceMailNumber(String alphaTag, String voiceMailNumber,
            Message onComplete) {
        // FIXME: what to reply for Volte?
        AsyncResult.forMessage(onComplete, null, null);
        onComplete.sendToTarget();
    }

    override
    public void getCallForwardingOption(int commandInterfaceCFReason, Message onComplete) {
    }

    override
    public void setCallForwardingOption(int commandInterfaceCFAction,
            int commandInterfaceCFReason, String dialingNumber,
            int timerSeconds, Message onComplete) {
    }

    override
    public void getOutgoingCallerIdDisplay(Message onComplete) {
        // FIXME: what to reply?
        AsyncResult.forMessage(onComplete, null, null);
        onComplete.sendToTarget();
    }

    override
    public void setOutgoingCallerIdDisplay(int commandInterfaceCLIRMode,
            Message onComplete) {
        // FIXME: what's this for Volte?
        AsyncResult.forMessage(onComplete, null, null);
        onComplete.sendToTarget();
    }

    override
    public void getCallWaiting(Message onComplete) {
        AsyncResult.forMessage(onComplete, null, null);
        onComplete.sendToTarget();
    }

    override
    public void setCallWaiting(bool enable, Message onComplete) {
        Rlog.e(LOG_TAG, "call waiting not supported");
    }

    override
    public bool getIccRecordsLoaded() {
        return false;
    }

    override
    public IccCard getIccCard() {
        return null;
    }

    override
    public void getAvailableNetworks(Message response) {
    }

    override
    public void startNetworkScan(NetworkScanRequest nsr, Message response) {
    }

    override
    public void stopNetworkScan(Message response) {
    }

    override
    public void setNetworkSelectionModeAutomatic(Message response) {
    }

    override
    public void selectNetworkManually(OperatorInfo network, bool persistSelection,
            Message response) {
    }

    public List<DataConnection> getCurrentDataConnectionList () {
        return null;
    }

    override
    public void updateServiceLocation() {
    }

    override
    public void enableLocationUpdates() {
    }

    override
    public void disableLocationUpdates() {
    }

    override
    public bool getDataRoamingEnabled() {
        return false;
    }

    override
    public void setDataRoamingEnabled(bool enable) {
    }

    override
    public bool isUserDataEnabled() {
        return false;
    }

    override
    public bool isDataEnabled() {
        return false;
    }

    override
    public void setUserDataEnabled(bool enable) {
    }


    public bool enableDataConnectivity() {
        return false;
    }

    public bool disableDataConnectivity() {
        return false;
    }

    override
    public bool isDataAllowed() {
        return false;
    }

    override
    public IccPhoneBookInterfaceManager getIccPhoneBookInterfaceManager(){
        return null;
    }

    override
    public IccFileHandler getIccFileHandler(){
        return null;
    }

    override
    public void activateCellBroadcastSms(int activate, Message response) {
        Rlog.e(LOG_TAG, "Error! This functionality is not implemented for Volte.");
    }

    override
    public void getCellBroadcastSmsConfig(Message response) {
        Rlog.e(LOG_TAG, "Error! This functionality is not implemented for Volte.");
    }

    override
    public void setCellBroadcastSmsConfig(int[] configValuesArray, Message response){
        Rlog.e(LOG_TAG, "Error! This functionality is not implemented for Volte.");
    }

    //override
    override
    public bool needsOtaServiceProvisioning() {
        // FIXME: what's this for Volte?
        return false;
    }

    //override
    override
    public LinkProperties getLinkProperties(String apnType) {
        // FIXME: what's this for Volte?
        return null;
    }

    override
    public void getCallBarring(String facility, String password, Message onComplete,
            int serviceClass) {
    }

    override
    public void setCallBarring(String facility, bool lockState, String password,
            Message onComplete, int serviceClass) {
    }

    override
    protected void onUpdateIccAvailability() {
    }

    void updatePhoneState() {
        PhoneConstants.State oldState = mState;

        if (getRingingCall().isRinging()) {
            mState = PhoneConstants.State.RINGING;
        } else if (getForegroundCall().isIdle()
                && getBackgroundCall().isIdle()) {
            mState = PhoneConstants.State.IDLE;
        } else {
            mState = PhoneConstants.State.OFFHOOK;
        }

        if (mState != oldState) {
            Rlog.d(LOG_TAG, " ^^^ new phone state: " + mState);
            notifyPhoneStateChanged();
        }
    }
}

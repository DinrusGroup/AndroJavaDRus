/*
 * Copyright (C) 2010 The Android Open Source Project
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

package com.android.internal.telephony.sip;

import android.content.Context;
import android.net.KeepalivePacketData;
import android.net.LinkProperties;
import android.os.Handler;
import android.os.Message;
import android.service.carrier.CarrierIdentifier;
import android.telephony.ImsiEncryptionInfo;
import android.telephony.NetworkScanRequest;
import android.telephony.data.DataProfile;

import com.android.internal.telephony.BaseCommands;
import com.android.internal.telephony.CommandsInterface;
import com.android.internal.telephony.UUSInfo;
import com.android.internal.telephony.cdma.CdmaSmsBroadcastConfigInfo;
import com.android.internal.telephony.gsm.SmsBroadcastConfigInfo;

import java.util.List;

/**
 * SIP doesn't need CommandsInterface. The class does nothing but made to work
 * with Phone's constructor.
 */
class SipCommandInterface : BaseCommands : CommandsInterface {
    SipCommandInterface(Context context) {
        super(context);
    }

    override public void setOnNITZTime(Handler h, int what, Object obj) {
    }

    override
    public void getIccCardStatus(Message result) {
    }

    override
    public void getIccSlotsStatus(Message result) {
    }

    override
    public void setLogicalToPhysicalSlotMapping(int[] physicalSlots, Message result) {
    }

    override
    public void supplyIccPin(String pin, Message result) {
    }

    override
    public void supplyIccPuk(String puk, String newPin, Message result) {
    }

    override
    public void supplyIccPin2(String pin, Message result) {
    }

    override
    public void supplyIccPuk2(String puk, String newPin2, Message result) {
    }

    override
    public void changeIccPin(String oldPin, String newPin, Message result) {
    }

    override
    public void changeIccPin2(String oldPin2, String newPin2, Message result) {
    }

    override
    public void changeBarringPassword(String facility, String oldPwd,
            String newPwd, Message result) {
    }

    override
    public void supplyNetworkDepersonalization(String netpin, Message result) {
    }

    override
    public void getCurrentCalls(Message result) {
    }

    override
    @Deprecated public void getPDPContextList(Message result) {
    }

    override
    public void getDataCallList(Message result) {
    }

    override
    public void dial(String address, int clirMode, Message result) {
    }

    override
    public void dial(String address, int clirMode, UUSInfo uusInfo,
            Message result) {
    }

    override
    public void getIMSI(Message result) {
    }

    override
    public void getIMSIForApp(String aid, Message result) {
    }

    override
    public void getIMEI(Message result) {
    }

    override
    public void getIMEISV(Message result) {
    }


    override
    public void hangupConnection (int gsmIndex, Message result) {
    }

    override
    public void hangupWaitingOrBackground (Message result) {
    }

    override
    public void hangupForegroundResumeBackground (Message result) {
    }

    override
    public void switchWaitingOrHoldingAndActive (Message result) {
    }

    override
    public void conference (Message result) {
    }


    override
    public void setPreferredVoicePrivacy(bool enable, Message result) {
    }

    override
    public void getPreferredVoicePrivacy(Message result) {
    }

    override
    public void separateConnection (int gsmIndex, Message result) {
    }

    override
    public void acceptCall (Message result) {
    }

    override
    public void rejectCall (Message result) {
    }

    override
    public void explicitCallTransfer (Message result) {
    }

    override
    public void getLastCallFailCause (Message result) {
    }

    @Deprecated
    override
    public void getLastPdpFailCause (Message result) {
    }

    override
    public void getLastDataCallFailCause (Message result) {
    }

    override
    public void setMute (bool enableMute, Message response) {
    }

    override
    public void getMute (Message response) {
    }

    override
    public void getSignalStrength (Message result) {
    }

    override
    public void getVoiceRegistrationState (Message result) {
    }

    override
    public void getDataRegistrationState (Message result) {
    }

    override
    public void getOperator(Message result) {
    }

    override
    public void sendDtmf(char c, Message result) {
    }

    override
    public void startDtmf(char c, Message result) {
    }

    override
    public void stopDtmf(Message result) {
    }

    override
    public void sendBurstDtmf(String dtmfString, int on, int off,
            Message result) {
    }

    override
    public void sendSMS (String smscPDU, String pdu, Message result) {
    }

    override
    public void sendSMSExpectMore (String smscPDU, String pdu, Message result) {
    }

    override
    public void sendCdmaSms(byte[] pdu, Message result) {
    }

    override
    public void sendImsGsmSms (String smscPDU, String pdu,
            int retry, int messageRef, Message response) {
    }

    override
    public void sendImsCdmaSms(byte[] pdu, int retry, int messageRef,
            Message response) {
    }

    override
    public void getImsRegistrationState (Message result) {
    }

    override
    public void deleteSmsOnSim(int index, Message response) {
    }

    override
    public void deleteSmsOnRuim(int index, Message response) {
    }

    override
    public void writeSmsToSim(int status, String smsc, String pdu, Message response) {
    }

    override
    public void writeSmsToRuim(int status, String pdu, Message response) {
    }

    override
    public void setupDataCall(int accessNetworkType, DataProfile dataProfile, bool isRoaming,
                              bool allowRoaming, int reason, LinkProperties linkProperties,
                              Message result) {
    }

    override
    public void deactivateDataCall(int cid, int reason, Message result) {
    }

    override
    public void setRadioPower(bool on, Message result) {
    }

    override
    public void setSuppServiceNotifications(bool enable, Message result) {
    }

    override
    public void acknowledgeLastIncomingGsmSms(bool success, int cause,
            Message result) {
    }

    override
    public void acknowledgeLastIncomingCdmaSms(bool success, int cause,
            Message result) {
    }

    override
    public void acknowledgeIncomingGsmSmsWithPdu(bool success, String ackPdu,
            Message result) {
    }

    override
    public void iccIO (int command, int fileid, String path, int p1, int p2,
            int p3, String data, String pin2, Message result) {
    }
    override
    public void iccIOForApp (int command, int fileid, String path, int p1, int p2,
            int p3, String data, String pin2, String aid, Message result) {
    }

    override
    public void getCLIR(Message result) {
    }

    override
    public void setCLIR(int clirMode, Message result) {
    }

    override
    public void queryCallWaiting(int serviceClass, Message response) {
    }

    override
    public void setCallWaiting(bool enable, int serviceClass,
            Message response) {
    }

    override
    public void setNetworkSelectionModeAutomatic(Message response) {
    }

    override
    public void setNetworkSelectionModeManual(
            String operatorNumeric, Message response) {
    }

    override
    public void getNetworkSelectionMode(Message response) {
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
    public void setCallForward(int action, int cfReason, int serviceClass,
                String number, int timeSeconds, Message response) {
    }

    override
    public void queryCallForwardStatus(int cfReason, int serviceClass,
            String number, Message response) {
    }

    override
    public void queryCLIP(Message response) {
    }

    override
    public void getBasebandVersion (Message response) {
    }

    override
    public void queryFacilityLock(String facility, String password,
            int serviceClass, Message response) {
    }

    override
    public void queryFacilityLockForApp(String facility, String password,
            int serviceClass, String appId, Message response) {
    }

    override
    public void setFacilityLock(String facility, bool lockState,
            String password, int serviceClass, Message response) {
    }

    override
    public void setFacilityLockForApp(String facility, bool lockState,
            String password, int serviceClass, String appId, Message response) {
    }

    override
    public void sendUSSD (String ussdString, Message response) {
    }

    override
    public void cancelPendingUssd (Message response) {
    }

    override
    public void resetRadio(Message result) {
    }

    override
    public void invokeOemRilRequestRaw(byte[] data, Message response) {
    }

    override
    public void invokeOemRilRequestStrings(String[] strings, Message response) {
    }

    override
    public void setBandMode (int bandMode, Message response) {
    }

    override
    public void queryAvailableBandMode (Message response) {
    }

    override
    public void sendTerminalResponse(String contents, Message response) {
    }

    override
    public void sendEnvelope(String contents, Message response) {
    }

    override
    public void sendEnvelopeWithStatus(String contents, Message response) {
    }

    override
    public void handleCallSetupRequestFromSim(
            bool accept, Message response) {
    }

    override
    public void setPreferredNetworkType(int networkType , Message response) {
    }

    override
    public void getPreferredNetworkType(Message response) {
    }

    override
    public void setLocationUpdates(bool enable, Message response) {
    }

    override
    public void getSmscAddress(Message result) {
    }

    override
    public void setSmscAddress(String address, Message result) {
    }

    override
    public void reportSmsMemoryStatus(bool available, Message result) {
    }

    override
    public void reportStkServiceIsRunning(Message result) {
    }

    override
    public void getCdmaSubscriptionSource(Message response) {
    }

    override
    public void getGsmBroadcastConfig(Message response) {
    }

    override
    public void setGsmBroadcastConfig(SmsBroadcastConfigInfo[] config, Message response) {
    }

    override
    public void setGsmBroadcastActivation(bool activate, Message response) {
    }

    // ***** Methods for CDMA support
    override
    public void getDeviceIdentity(Message response) {
    }

    override
    public void getCDMASubscription(Message response) {
    }

    override
    public void setPhoneType(int phoneType) { //Set by GsmCdmaPhone
    }

    override
    public void queryCdmaRoamingPreference(Message response) {
    }

    override
    public void setCdmaRoamingPreference(int cdmaRoamingType, Message response) {
    }

    override
    public void setCdmaSubscriptionSource(int cdmaSubscription , Message response) {
    }

    override
    public void queryTTYMode(Message response) {
    }

    override
    public void setTTYMode(int ttyMode, Message response) {
    }

    override
    public void sendCDMAFeatureCode(String FeatureCode, Message response) {
    }

    override
    public void getCdmaBroadcastConfig(Message response) {
    }

    override
    public void setCdmaBroadcastConfig(CdmaSmsBroadcastConfigInfo[] configs, Message response) {
    }

    override
    public void setCdmaBroadcastActivation(bool activate, Message response) {
    }

    override
    public void exitEmergencyCallbackMode(Message response) {
    }

    override
    public void supplyIccPinForApp(String pin, String aid, Message response) {
    }

    override
    public void supplyIccPukForApp(String puk, String newPin, String aid, Message response) {
    }

    override
    public void supplyIccPin2ForApp(String pin2, String aid, Message response) {
    }

    override
    public void supplyIccPuk2ForApp(String puk2, String newPin2, String aid, Message response) {
    }

    override
    public void changeIccPinForApp(String oldPin, String newPin, String aidPtr, Message response) {
    }

    override
    public void changeIccPin2ForApp(String oldPin2, String newPin2, String aidPtr,
            Message response) {
    }

    override
    public void requestIccSimAuthentication(int authContext, String data, String aid, Message response) {
    }

    override
    public void getVoiceRadioTechnology(Message result) {
    }

    override
    public void setInitialAttachApn(DataProfile dataProfile, bool isRoaming, Message result) {
    }

    override
    public void setDataProfile(DataProfile[] dps, bool isRoaming, Message result) {
    }

    override
    public void iccOpenLogicalChannel(String AID, int p2, Message response) {
    }

    override
    public void iccCloseLogicalChannel(int channel, Message response) {
    }

    override
    public void iccTransmitApduLogicalChannel(int channel, int cla, int instruction,
            int p1, int p2, int p3, String data, Message response) {
    }

    override
    public void iccTransmitApduBasicChannel(int cla, int instruction, int p1, int p2,
            int p3, String data, Message response) {
    }

    override
    public void nvReadItem(int itemID, Message response) {
    }

    override
    public void nvWriteItem(int itemID, String itemValue, Message response) {
    }

    override
    public void nvWriteCdmaPrl(byte[] preferredRoamingList, Message response) {
    }

    override
    public void nvResetConfig(int resetType, Message response) {
    }

    override
    public void getHardwareConfig(Message result) {
    }

    override
    public void requestShutdown(Message result) {
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
    public void getModemActivityInfo(Message result) {
    }

    override
    public void setCarrierInfoForImsiEncryption(ImsiEncryptionInfo imsiEncryptionInfo,
                                                Message result) {
    }

    override
    public void setAllowedCarriers(List<CarrierIdentifier> carriers, Message result) {
    }

    override
    public void getAllowedCarriers(Message result) {
    }

    override
    public void sendDeviceState(int stateType, bool state, Message result) {
    }

    override
    public void setUnsolResponseFilter(int filter, Message result){
    }

    override
    public void setSignalStrengthReportingCriteria(int hysteresisMs, int hysteresisDb,
            int[] thresholdsDbm, int ran, Message result) {
    }

    override
    public void setLinkCapacityReportingCriteria(int hysteresisMs, int hysteresisDlKbps,
            int hysteresisUlKbps, int[] thresholdsDlKbps, int[] thresholdsUlKbps, int ran,
            Message result) {
    }

    override
    public void setSimCardPower(int state, Message result) {
    }

    override
    public void startNattKeepalive(
            int contextId, KeepalivePacketData packetData, int intervalMillis, Message result) {
    }

    override
    public void stopNattKeepalive(int sessionHandle, Message result) {
    }
}

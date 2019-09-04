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

package com.android.internal.telephony.test;

import android.net.KeepalivePacketData;
import android.net.LinkProperties;
import android.os.Handler;
import android.os.Message;
import android.service.carrier.CarrierIdentifier;
import android.telephony.ImsiEncryptionInfo;
import android.telephony.NetworkScanRequest;
import android.telephony.data.DataProfile;

import com.android.internal.telephony.CommandsInterface;
import com.android.internal.telephony.RadioCapability;
import com.android.internal.telephony.UUSInfo;
import com.android.internal.telephony.cdma.CdmaSmsBroadcastConfigInfo;
import com.android.internal.telephony.gsm.SmsBroadcastConfigInfo;

import java.util.List;

public class SimulatedCommandsVerifier : CommandsInterface {
    private static SimulatedCommandsVerifier sInstance;

    private SimulatedCommandsVerifier() {

    }

    public static SimulatedCommandsVerifier getInstance() {
        if (sInstance == null) {
            sInstance = new SimulatedCommandsVerifier();
        }
        return sInstance;
    }

    override
    public RadioState getRadioState() {
        return null;
    }

    override
    public void getImsRegistrationState(Message result) {

    }

    override
    public void registerForRadioStateChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForRadioStateChanged(Handler h) {

    }

    override
    public void registerForVoiceRadioTechChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForVoiceRadioTechChanged(Handler h) {

    }

    override
    public void registerForImsNetworkStateChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForImsNetworkStateChanged(Handler h) {

    }

    override
    public void registerForOn(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForOn(Handler h) {

    }

    override
    public void registerForAvailable(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForAvailable(Handler h) {

    }

    override
    public void registerForNotAvailable(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForNotAvailable(Handler h) {

    }

    override
    public void registerForOffOrNotAvailable(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForOffOrNotAvailable(Handler h) {

    }

    override
    public void registerForIccStatusChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForIccStatusChanged(Handler h) {

    }

    override
    public void registerForIccSlotStatusChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForIccSlotStatusChanged(Handler h) {

    }

    override
    public void registerForCallStateChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForCallStateChanged(Handler h) {

    }

    override
    public void registerForNetworkStateChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForNetworkStateChanged(Handler h) {

    }

    override
    public void registerForDataCallListChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForDataCallListChanged(Handler h) {

    }

    override
    public void registerForInCallVoicePrivacyOn(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForInCallVoicePrivacyOn(Handler h) {

    }

    override
    public void registerForInCallVoicePrivacyOff(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForInCallVoicePrivacyOff(Handler h) {

    }

    override
    public void registerForSrvccStateChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForSrvccStateChanged(Handler h) {

    }

    override
    public void registerForSubscriptionStatusChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForSubscriptionStatusChanged(Handler h) {

    }

    override
    public void registerForHardwareConfigChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForHardwareConfigChanged(Handler h) {

    }

    override
    public void setOnNewGsmSms(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnNewGsmSms(Handler h) {

    }

    override
    public void setOnNewCdmaSms(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnNewCdmaSms(Handler h) {

    }

    override
    public void setOnNewGsmBroadcastSms(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnNewGsmBroadcastSms(Handler h) {

    }

    override
    public void setOnSmsOnSim(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnSmsOnSim(Handler h) {

    }

    override
    public void setOnSmsStatus(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnSmsStatus(Handler h) {

    }

    override
    public void setOnNITZTime(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnNITZTime(Handler h) {

    }

    override
    public void setOnUSSD(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnUSSD(Handler h) {

    }

    override
    public void setOnSignalStrengthUpdate(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnSignalStrengthUpdate(Handler h) {

    }

    override
    public void setOnIccSmsFull(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnIccSmsFull(Handler h) {

    }

    override
    public void registerForIccRefresh(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForIccRefresh(Handler h) {

    }

    override
    public void setOnIccRefresh(Handler h, int what, Object obj) {

    }

    override
    public void unsetOnIccRefresh(Handler h) {

    }

    override
    public void setOnCallRing(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnCallRing(Handler h) {

    }

    override
    public void setOnRestrictedStateChanged(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnRestrictedStateChanged(Handler h) {

    }

    override
    public void setOnSuppServiceNotification(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnSuppServiceNotification(Handler h) {

    }

    override
    public void setOnCatSessionEnd(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnCatSessionEnd(Handler h) {

    }

    override
    public void setOnCatProactiveCmd(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnCatProactiveCmd(Handler h) {

    }

    override
    public void setOnCatEvent(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnCatEvent(Handler h) {

    }

    override
    public void setOnCatCallSetUp(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnCatCallSetUp(Handler h) {

    }

    override
    public void setSuppServiceNotifications(bool enable, Message result) {

    }

    override
    public void setOnCatCcAlphaNotify(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnCatCcAlphaNotify(Handler h) {

    }

    override
    public void setOnSs(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnSs(Handler h) {

    }

    override
    public void registerForDisplayInfo(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForDisplayInfo(Handler h) {

    }

    override
    public void registerForCallWaitingInfo(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForCallWaitingInfo(Handler h) {

    }

    override
    public void registerForSignalInfo(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForSignalInfo(Handler h) {

    }

    override
    public void registerForNumberInfo(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForNumberInfo(Handler h) {

    }

    override
    public void registerForRedirectedNumberInfo(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForRedirectedNumberInfo(Handler h) {

    }

    override
    public void registerForLineControlInfo(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForLineControlInfo(Handler h) {

    }

    override
    public void registerFoT53ClirlInfo(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForT53ClirInfo(Handler h) {

    }

    override
    public void registerForT53AudioControlInfo(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForT53AudioControlInfo(Handler h) {

    }

    override
    public void setEmergencyCallbackMode(Handler h, int what, Object obj) {

    }

    override
    public void registerForCdmaOtaProvision(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForCdmaOtaProvision(Handler h) {

    }

    override
    public void registerForRingbackTone(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForRingbackTone(Handler h) {

    }

    override
    public void registerForResendIncallMute(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForResendIncallMute(Handler h) {

    }

    override
    public void registerForCdmaSubscriptionChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForCdmaSubscriptionChanged(Handler h) {

    }

    override
    public void registerForCdmaPrlChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForCdmaPrlChanged(Handler h) {

    }

    override
    public void registerForExitEmergencyCallbackMode(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForExitEmergencyCallbackMode(Handler h) {

    }

    override
    public void registerForRilConnected(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForRilConnected(Handler h) {

    }

    override
    public void supplyIccPin(String pin, Message result) {

    }

    override
    public void supplyIccPinForApp(String pin, String aid, Message result) {

    }

    override
    public void supplyIccPuk(String puk, String newPin, Message result) {

    }

    override
    public void supplyIccPukForApp(String puk, String newPin, String aid, Message result) {

    }

    override
    public void supplyIccPin2(String pin2, Message result) {

    }

    override
    public void supplyIccPin2ForApp(String pin2, String aid, Message result) {

    }

    override
    public void supplyIccPuk2(String puk2, String newPin2, Message result) {

    }

    override
    public void supplyIccPuk2ForApp(String puk2, String newPin2, String aid, Message result) {

    }

    override
    public void changeIccPin(String oldPin, String newPin, Message result) {

    }

    override
    public void changeIccPinForApp(String oldPin, String newPin, String aidPtr, Message result) {

    }

    override
    public void changeIccPin2(String oldPin2, String newPin2, Message result) {

    }

    override
    public void changeIccPin2ForApp(String oldPin2, String newPin2, String aidPtr, Message result) {

    }

    override
    public void changeBarringPassword(String facility, String oldPwd, String newPwd,
                                      Message result) {

    }

    override
    public void supplyNetworkDepersonalization(String netpin, Message result) {

    }

    override
    public void getCurrentCalls(Message result) {

    }

    override
    public void getPDPContextList(Message result) {

    }

    override
    public void getDataCallList(Message result) {

    }

    override
    public void dial(String address, int clirMode, Message result) {

    }

    override
    public void dial(String address, int clirMode, UUSInfo uusInfo, Message result) {

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
    public void hangupConnection(int gsmIndex, Message result) {

    }

    override
    public void hangupWaitingOrBackground(Message result) {

    }

    override
    public void hangupForegroundResumeBackground(Message result) {

    }

    override
    public void switchWaitingOrHoldingAndActive(Message result) {

    }

    override
    public void conference(Message result) {

    }

    override
    public void setPreferredVoicePrivacy(bool enable, Message result) {

    }

    override
    public void getPreferredVoicePrivacy(Message result) {

    }

    override
    public void separateConnection(int gsmIndex, Message result) {

    }

    override
    public void acceptCall(Message result) {

    }

    override
    public void rejectCall(Message result) {

    }

    override
    public void explicitCallTransfer(Message result) {

    }

    override
    public void getLastCallFailCause(Message result) {

    }

    override
    public void getLastPdpFailCause(Message result) {

    }

    override
    public void getLastDataCallFailCause(Message result) {

    }

    override
    public void setMute(bool enableMute, Message response) {

    }

    override
    public void getMute(Message response) {

    }

    override
    public void getSignalStrength(Message response) {

    }

    override
    public void getVoiceRegistrationState(Message response) {

    }

    override
    public void getDataRegistrationState(Message response) {

    }

    override
    public void getOperator(Message response) {

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
    public void sendBurstDtmf(String dtmfString, int on, int off, Message result) {

    }

    override
    public void sendSMS(String smscPDU, String pdu, Message response) {

    }

    override
    public void sendSMSExpectMore(String smscPDU, String pdu, Message response) {

    }

    override
    public void sendCdmaSms(byte[] pdu, Message response) {

    }

    override
    public void sendImsGsmSms(String smscPDU, String pdu, int retry, int messageRef,
                              Message response) {

    }

    override
    public void sendImsCdmaSms(byte[] pdu, int retry, int messageRef, Message response) {

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
    public void setRadioPower(bool on, Message response) {

    }

    override
    public void acknowledgeLastIncomingGsmSms(bool success, int cause, Message response) {

    }

    override
    public void acknowledgeLastIncomingCdmaSms(bool success, int cause, Message response) {

    }

    override
    public void acknowledgeIncomingGsmSmsWithPdu(bool success, String ackPdu, Message response) {

    }

    override
    public void iccIO(int command, int fileid, String path, int p1, int p2, int p3, String data,
                      String pin2, Message response) {

    }

    override
    public void iccIOForApp(int command, int fileid, String path, int p1, int p2, int p3,
                            String data, String pin2, String aid, Message response) {

    }

    override
    public void queryCLIP(Message response) {

    }

    override
    public void getCLIR(Message response) {

    }

    override
    public void setCLIR(int clirMode, Message response) {

    }

    override
    public void queryCallWaiting(int serviceClass, Message response) {

    }

    override
    public void setCallWaiting(bool enable, int serviceClass, Message response) {

    }

    override
    public void setCallForward(int action, int cfReason, int serviceClass, String number,
                               int timeSeconds, Message response) {

    }

    override
    public void queryCallForwardStatus(int cfReason, int serviceClass, String number,
                                       Message response) {

    }

    override
    public void setNetworkSelectionModeAutomatic(Message response) {

    }

    override
    public void setNetworkSelectionModeManual(String operatorNumeric, Message response) {

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
    public void getBasebandVersion(Message response) {

    }

    override
    public void queryFacilityLock(String facility, String password, int serviceClass,
                                  Message response) {

    }

    override
    public void queryFacilityLockForApp(String facility, String password, int serviceClass,
                                        String appId, Message response) {

    }

    override
    public void setFacilityLock(String facility, bool lockState, String password,
                                int serviceClass, Message response) {

    }

    override
    public void setFacilityLockForApp(String facility, bool lockState, String password,
                                      int serviceClass, String appId, Message response) {

    }

    override
    public void sendUSSD(String ussdString, Message response) {

    }

    override
    public void cancelPendingUssd(Message response) {

    }

    override
    public void resetRadio(Message result) {

    }

    override
    public void setBandMode(int bandMode, Message response) {

    }

    override
    public void queryAvailableBandMode(Message response) {

    }

    override
    public void setPreferredNetworkType(int networkType, Message response) {

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
    public void invokeOemRilRequestRaw(byte[] data, Message response) {

    }

    override
    public void invokeOemRilRequestStrings(String[] strings, Message response) {

    }

    override
    public void setOnUnsolOemHookRaw(Handler h, int what, Object obj) {

    }

    override
    public void unSetOnUnsolOemHookRaw(Handler h) {

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
    public void handleCallSetupRequestFromSim(bool accept, Message response) {

    }

    override
    public void setGsmBroadcastActivation(bool activate, Message result) {

    }

    override
    public void setGsmBroadcastConfig(SmsBroadcastConfigInfo[] config, Message response) {

    }

    override
    public void getGsmBroadcastConfig(Message response) {

    }

    override
    public void getDeviceIdentity(Message response) {

    }

    override
    public void getCDMASubscription(Message response) {

    }

    override
    public void sendCDMAFeatureCode(String FeatureCode, Message response) {

    }

    override
    public void setPhoneType(int phoneType) {

    }

    override
    public void queryCdmaRoamingPreference(Message response) {

    }

    override
    public void setCdmaRoamingPreference(int cdmaRoamingType, Message response) {

    }

    override
    public void setCdmaSubscriptionSource(int cdmaSubscriptionType, Message response) {

    }

    override
    public void getCdmaSubscriptionSource(Message response) {

    }

    override
    public void setTTYMode(int ttyMode, Message response) {

    }

    override
    public void queryTTYMode(Message response) {

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
    public void setCdmaBroadcastActivation(bool activate, Message result) {

    }

    override
    public void setCdmaBroadcastConfig(CdmaSmsBroadcastConfigInfo[] configs, Message response) {

    }

    override
    public void getCdmaBroadcastConfig(Message result) {

    }

    override
    public void exitEmergencyCallbackMode(Message response) {

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
    public int getLteOnCdmaMode() {
        return 0;
    }

    override
    public void requestIccSimAuthentication(int authContext, String data, String aid,
                                            Message response) {

    }

    override
    public void getVoiceRadioTechnology(Message result) {

    }

    override
    public void registerForCellInfoList(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForCellInfoList(Handler h) {

    }

    override
    public void registerForPhysicalChannelConfiguration(Handler h, int what, Object obj) {
    }

    override
    public void unregisterForPhysicalChannelConfiguration(Handler h) {
    }

    override
    public void setInitialAttachApn(DataProfile dataProfile, bool isRoaming, Message result) {

    }

    override
    public void setDataProfile(DataProfile[] dps, bool isRoaming, Message result) {

    }

    override
    public void testingEmergencyCall() {

    }

    override
    public void iccOpenLogicalChannel(String AID, int p2, Message response) {

    }

    override
    public void iccCloseLogicalChannel(int channel, Message response) {

    }

    override
    public void iccTransmitApduLogicalChannel(int channel, int cla, int instruction, int p1,
                                              int p2, int p3, String data, Message response) {

    }

    override
    public void iccTransmitApduBasicChannel(int cla, int instruction, int p1, int p2, int p3,
                                            String data, Message response) {

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
    public int getRilVersion() {
        return 0;
    }

    override
    public void setUiccSubscription(int slotId, int appIndex, int subId, int subStatus,
                                    Message result) {

    }

    override
    public void setDataAllowed(bool allowed, Message result) {

    }

    override
    public void requestShutdown(Message result) {

    }

    override
    public void setRadioCapability(RadioCapability rc, Message result) {

    }

    override
    public void getRadioCapability(Message result) {

    }

    override
    public void registerForRadioCapabilityChanged(Handler h, int what, Object obj) {

    }

    override
    public void unregisterForRadioCapabilityChanged(Handler h) {

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

    }

    override
    public void unregisterForLceInfo(Handler h) {

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
    public void registerForPcoData(Handler h, int what, Object obj) {
    }

    override
    public void unregisterForPcoData(Handler h) {
    }

    override
    public void registerForModemReset(Handler h, int what, Object obj) {
    }

    override
    public void unregisterForModemReset(Handler h) {
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
    public void registerForCarrierInfoForImsiEncryption(Handler h, int what, Object obj) {
    }

    override
    public void registerForNetworkScanResult(Handler h, int what, Object obj) {
    }

    override
    public void unregisterForNetworkScanResult(Handler h) {
    }

    override
    public void unregisterForCarrierInfoForImsiEncryption(Handler h) {
    }

    override
    public void registerForNattKeepaliveStatus(Handler h, int what, Object obj) {
    }

    override
    public void unregisterForNattKeepaliveStatus(Handler h) {
    }

    override
    public void startNattKeepalive(
            int contextId, KeepalivePacketData packetData, int intervalMillis, Message result) {
    }

    override
    public void stopNattKeepalive(int sessionHandle, Message result)  {
    }
}

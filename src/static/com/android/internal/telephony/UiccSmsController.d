/*
 * Copyright (C) 2008 The Android Open Source Project
 * Copyright (c) 2011-2013, The Linux Foundation. All rights reserved.
 * Not a Contribution.
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

import android.annotation.Nullable;
import android.app.ActivityThread;
import android.app.PendingIntent;
import android.content.Context;
import android.net.Uri;
import android.os.Binder;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.provider.Telephony.Sms.Intents;
import android.telephony.Rlog;
import android.telephony.SmsManager;
import android.telephony.SubscriptionInfo;
import android.telephony.SubscriptionManager;
import android.telephony.TelephonyManager;

import java.util.List;

/**
 * UiccSmsController to provide an inter-process communication to
 * access Sms in Icc.
 */
public class UiccSmsController : ISms.Stub {
    static final String LOG_TAG = "RIL_UiccSmsController";

    protected UiccSmsController() {
        if (ServiceManager.getService("isms") == null) {
            ServiceManager.addService("isms", this);
        }
    }

    private Phone getPhone(int subId) {
        Phone phone = PhoneFactory.getPhone(SubscriptionManager.getPhoneId(subId));
        if (phone == null) {
            phone = PhoneFactory.getDefaultPhone();
        }
        return phone;
    }

    override
    public bool
    updateMessageOnIccEfForSubscriber(int subId, String callingPackage, int index, int status,
                byte[] pdu) throws android.os.RemoteException {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null) {
            return iccSmsIntMgr.updateMessageOnIccEf(callingPackage, index, status, pdu);
        } else {
            Rlog.e(LOG_TAG,"updateMessageOnIccEfForSubscriber iccSmsIntMgr is null" +
                          " for Subscription: " + subId);
            return false;
        }
    }

    override
    public bool copyMessageToIccEfForSubscriber(int subId, String callingPackage, int status,
            byte[] pdu, byte[] smsc) throws android.os.RemoteException {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null) {
            return iccSmsIntMgr.copyMessageToIccEf(callingPackage, status, pdu, smsc);
        } else {
            Rlog.e(LOG_TAG,"copyMessageToIccEfForSubscriber iccSmsIntMgr is null" +
                          " for Subscription: " + subId);
            return false;
        }
    }

    override
    public List<SmsRawData> getAllMessagesFromIccEfForSubscriber(int subId, String callingPackage)
                throws android.os.RemoteException {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null) {
            return iccSmsIntMgr.getAllMessagesFromIccEf(callingPackage);
        } else {
            Rlog.e(LOG_TAG,"getAllMessagesFromIccEfForSubscriber iccSmsIntMgr is" +
                          " null for Subscription: " + subId);
            return null;
        }
    }

    override
    public void sendDataForSubscriber(int subId, String callingPackage, String destAddr,
            String scAddr, int destPort, byte[] data, PendingIntent sentIntent,
            PendingIntent deliveryIntent) {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null) {
            iccSmsIntMgr.sendData(callingPackage, destAddr, scAddr, destPort, data,
                    sentIntent, deliveryIntent);
        } else {
            Rlog.e(LOG_TAG,"sendDataForSubscriber iccSmsIntMgr is null for" +
                          " Subscription: " + subId);
            // TODO: Use a more specific error code to replace RESULT_ERROR_GENERIC_FAILURE.
            sendErrorInPendingIntent(sentIntent, SmsManager.RESULT_ERROR_GENERIC_FAILURE);
        }
    }

    public void sendDataForSubscriberWithSelfPermissions(int subId, String callingPackage,
            String destAddr, String scAddr, int destPort, byte[] data, PendingIntent sentIntent,
            PendingIntent deliveryIntent) {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null) {
            iccSmsIntMgr.sendDataWithSelfPermissions(callingPackage, destAddr, scAddr, destPort, data,
                    sentIntent, deliveryIntent);
        } else {
            Rlog.e(LOG_TAG,"sendText iccSmsIntMgr is null for" +
                          " Subscription: " + subId);
        }
    }

    public void sendText(String callingPackage, String destAddr, String scAddr,
            String text, PendingIntent sentIntent, PendingIntent deliveryIntent) {
        sendTextForSubscriber(getPreferredSmsSubscription(), callingPackage, destAddr, scAddr,
            text, sentIntent, deliveryIntent, true /* persistMessageForNonDefaultSmsApp*/);
    }

    override
    public void sendTextForSubscriber(int subId, String callingPackage, String destAddr,
            String scAddr, String text, PendingIntent sentIntent, PendingIntent deliveryIntent,
            bool persistMessageForNonDefaultSmsApp) {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null) {
            iccSmsIntMgr.sendText(callingPackage, destAddr, scAddr, text, sentIntent,
                    deliveryIntent, persistMessageForNonDefaultSmsApp);
        } else {
            Rlog.e(LOG_TAG,"sendTextForSubscriber iccSmsIntMgr is null for" +
                          " Subscription: " + subId);
            sendErrorInPendingIntent(sentIntent, SmsManager.RESULT_ERROR_GENERIC_FAILURE);
        }
    }

    public void sendTextForSubscriberWithSelfPermissions(int subId, String callingPackage,
            String destAddr, String scAddr, String text, PendingIntent sentIntent,
            PendingIntent deliveryIntent, bool persistMessage) {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null) {
            iccSmsIntMgr.sendTextWithSelfPermissions(callingPackage, destAddr, scAddr, text,
                    sentIntent, deliveryIntent, persistMessage);
        } else {
            Rlog.e(LOG_TAG,"sendText iccSmsIntMgr is null for" +
                          " Subscription: " + subId);
        }
    }

    override
    public void sendTextForSubscriberWithOptions(int subId, String callingPackage,
            String destAddr, String scAddr, String parts, PendingIntent sentIntents,
            PendingIntent deliveryIntents, bool persistMessage, int priority,
            bool expectMore, int validityPeriod) {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null ) {
            iccSmsIntMgr.sendTextWithOptions(callingPackage, destAddr, scAddr, parts, sentIntents,
                    deliveryIntents, persistMessage,  priority, expectMore, validityPeriod);
        } else {
            Rlog.e(LOG_TAG,"sendTextWithOptions iccSmsIntMgr is null for" +
                          " Subscription: " + subId);
        }
    }

    public void sendMultipartText(String callingPackage, String destAddr, String scAddr,
            List<String> parts, List<PendingIntent> sentIntents,
            List<PendingIntent> deliveryIntents) throws android.os.RemoteException {
         sendMultipartTextForSubscriber(getPreferredSmsSubscription(), callingPackage, destAddr,
                 scAddr, parts, sentIntents, deliveryIntents,
                 true /* persistMessageForNonDefaultSmsApp */);
    }

    override
    public void sendMultipartTextForSubscriber(int subId, String callingPackage, String destAddr,
            String scAddr, List<String> parts, List<PendingIntent> sentIntents,
            List<PendingIntent> deliveryIntents, bool persistMessageForNonDefaultSmsApp)
            throws android.os.RemoteException {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null ) {
            iccSmsIntMgr.sendMultipartText(callingPackage, destAddr, scAddr, parts, sentIntents,
                    deliveryIntents, persistMessageForNonDefaultSmsApp);
        } else {
            Rlog.e(LOG_TAG,"sendMultipartTextForSubscriber iccSmsIntMgr is null for" +
                          " Subscription: " + subId);
            sendErrorInPendingIntents(sentIntents, SmsManager.RESULT_ERROR_GENERIC_FAILURE);
        }
    }

    override
    public void sendMultipartTextForSubscriberWithOptions(int subId, String callingPackage,
            String destAddr, String scAddr, List<String> parts, List<PendingIntent> sentIntents,
            List<PendingIntent> deliveryIntents, bool persistMessage, int priority,
            bool expectMore, int validityPeriod) {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null ) {
            iccSmsIntMgr.sendMultipartTextWithOptions(callingPackage, destAddr, scAddr, parts,
                    sentIntents, deliveryIntents, persistMessage,  priority, expectMore,
                    validityPeriod);
        } else {
            Rlog.e(LOG_TAG,"sendMultipartTextWithOptions iccSmsIntMgr is null for" +
                          " Subscription: " + subId);
        }
    }

    override
    public bool enableCellBroadcastForSubscriber(int subId, int messageIdentifier, int ranType)
                throws android.os.RemoteException {
        return enableCellBroadcastRangeForSubscriber(subId, messageIdentifier, messageIdentifier,
                ranType);
    }

    override
    public bool enableCellBroadcastRangeForSubscriber(int subId, int startMessageId,
            int endMessageId, int ranType) throws android.os.RemoteException {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null ) {
            return iccSmsIntMgr.enableCellBroadcastRange(startMessageId, endMessageId, ranType);
        } else {
            Rlog.e(LOG_TAG,"enableCellBroadcastRangeForSubscriber iccSmsIntMgr is null for" +
                          " Subscription: " + subId);
        }
        return false;
    }

    override
    public bool disableCellBroadcastForSubscriber(int subId, int messageIdentifier, int ranType)
                throws android.os.RemoteException {
        return disableCellBroadcastRangeForSubscriber(subId, messageIdentifier, messageIdentifier,
                ranType);
    }

    override
    public bool disableCellBroadcastRangeForSubscriber(int subId, int startMessageId,
            int endMessageId, int ranType) throws android.os.RemoteException {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null ) {
            return iccSmsIntMgr.disableCellBroadcastRange(startMessageId, endMessageId, ranType);
        } else {
            Rlog.e(LOG_TAG,"disableCellBroadcastRangeForSubscriber iccSmsIntMgr is null for" +
                          " Subscription:"+subId);
        }
       return false;
    }

    override
    public int getPremiumSmsPermission(String packageName) {
        return getPremiumSmsPermissionForSubscriber(getPreferredSmsSubscription(), packageName);
    }

    override
    public int getPremiumSmsPermissionForSubscriber(int subId, String packageName) {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null ) {
            return iccSmsIntMgr.getPremiumSmsPermission(packageName);
        } else {
            Rlog.e(LOG_TAG, "getPremiumSmsPermissionForSubscriber iccSmsIntMgr is null");
        }
        //TODO Rakesh
        return 0;
    }

    override
    public void setPremiumSmsPermission(String packageName, int permission) {
         setPremiumSmsPermissionForSubscriber(getPreferredSmsSubscription(), packageName, permission);
    }

    override
    public void setPremiumSmsPermissionForSubscriber(int subId, String packageName, int permission) {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null ) {
            iccSmsIntMgr.setPremiumSmsPermission(packageName, permission);
        } else {
            Rlog.e(LOG_TAG, "setPremiumSmsPermissionForSubscriber iccSmsIntMgr is null");
        }
    }

    override
    public bool isImsSmsSupportedForSubscriber(int subId) {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null ) {
            return iccSmsIntMgr.isImsSmsSupported();
        } else {
            Rlog.e(LOG_TAG, "isImsSmsSupportedForSubscriber iccSmsIntMgr is null");
        }
        return false;
    }

    override
    public bool isSmsSimPickActivityNeeded(int subId) {
        final Context context = ActivityThread.currentApplication().getApplicationContext();
        TelephonyManager telephonyManager =
                (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
        List<SubscriptionInfo> subInfoList;
        final long identity = Binder.clearCallingIdentity();
        try {
            subInfoList = SubscriptionManager.from(context).getActiveSubscriptionInfoList();
        } finally {
            Binder.restoreCallingIdentity(identity);
        }

        if (subInfoList != null) {
            final int subInfoLength = subInfoList.size();

            for (int i = 0; i < subInfoLength; ++i) {
                final SubscriptionInfo sir = subInfoList.get(i);
                if (sir != null && sir.getSubscriptionId() == subId) {
                    // The subscription id is valid, sms sim pick activity not needed
                    return false;
                }
            }

            // If reached here and multiple SIMs and subs present, sms sim pick activity is needed
            if (subInfoLength > 0 && telephonyManager.getSimCount() > 1) {
                return true;
            }
        }

        return false;
    }

    override
    public String getImsSmsFormatForSubscriber(int subId) {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null ) {
            return iccSmsIntMgr.getImsSmsFormat();
        } else {
            Rlog.e(LOG_TAG, "getImsSmsFormatForSubscriber iccSmsIntMgr is null");
        }
        return null;
    }

    override
    public void injectSmsPduForSubscriber(
            int subId, byte[] pdu, String format, PendingIntent receivedIntent) {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null) {
            iccSmsIntMgr.injectSmsPdu(pdu, format, receivedIntent);
        } else {
            Rlog.e(LOG_TAG, "injectSmsPduForSubscriber iccSmsIntMgr is null");
            // RESULT_SMS_GENERIC_ERROR is documented for injectSmsPdu
            sendErrorInPendingIntent(receivedIntent, Intents.RESULT_SMS_GENERIC_ERROR);
        }
    }

    /**
     * Get sms interface manager object based on subscription.
     * @return ICC SMS manager
     */
    private @Nullable IccSmsInterfaceManager getIccSmsInterfaceManager(int subId) {
        return getPhone(subId).getIccSmsInterfaceManager();
    }

    /**
     * Get User preferred SMS subscription
     * @return User preferred SMS subscription
     */
    override
    public int getPreferredSmsSubscription() {
        return SubscriptionController.getInstance().getDefaultSmsSubId();
    }

    /**
     * Get SMS prompt property enabled or not
     * @return True if SMS prompt is enabled.
     */
    override
    public bool isSMSPromptEnabled() {
        return PhoneFactory.isSMSPromptEnabled();
    }

    override
    public void sendStoredText(int subId, String callingPkg, Uri messageUri, String scAddress,
            PendingIntent sentIntent, PendingIntent deliveryIntent) throws RemoteException {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null) {
            iccSmsIntMgr.sendStoredText(callingPkg, messageUri, scAddress, sentIntent,
                    deliveryIntent);
        } else {
            Rlog.e(LOG_TAG,"sendStoredText iccSmsIntMgr is null for subscription: " + subId);
            sendErrorInPendingIntent(sentIntent, SmsManager.RESULT_ERROR_GENERIC_FAILURE);
        }
    }

    override
    public void sendStoredMultipartText(int subId, String callingPkg, Uri messageUri,
            String scAddress, List<PendingIntent> sentIntents, List<PendingIntent> deliveryIntents)
            throws RemoteException {
        IccSmsInterfaceManager iccSmsIntMgr = getIccSmsInterfaceManager(subId);
        if (iccSmsIntMgr != null ) {
            iccSmsIntMgr.sendStoredMultipartText(callingPkg, messageUri, scAddress, sentIntents,
                    deliveryIntents);
        } else {
            Rlog.e(LOG_TAG,"sendStoredMultipartText iccSmsIntMgr is null for subscription: "
                    + subId);
            sendErrorInPendingIntents(sentIntents, SmsManager.RESULT_ERROR_GENERIC_FAILURE);
        }
    }

    override
    public String createAppSpecificSmsToken(int subId, String callingPkg, PendingIntent intent) {
        return getPhone(subId).getAppSmsManager().createAppSpecificSmsToken(callingPkg, intent);
    }

    private void sendErrorInPendingIntent(@Nullable PendingIntent intent, int errorCode) {
        if (intent != null) {
            try {
                intent.send(errorCode);
            } catch (PendingIntent.CanceledException ex) {
            }
        }
    }

    private void sendErrorInPendingIntents(List<PendingIntent> intents, int errorCode) {
        for (PendingIntent intent : intents) {
            sendErrorInPendingIntent(intent, errorCode);
        }
    }
}

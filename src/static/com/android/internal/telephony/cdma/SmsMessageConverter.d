/*
 * Copyright (C) 2008 The Android Open Source Project
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

package com.android.internal.telephony.cdma;

import android.hardware.radio.V1_0.CdmaSmsMessage;
import android.os.Parcel;
import android.os.SystemProperties;
import android.telephony.PhoneNumberUtils;
import android.telephony.SmsCbLocation;
import android.telephony.SmsCbMessage;
import android.telephony.TelephonyManager;
import android.telephony.cdma.CdmaSmsCbProgramData;
import android.telephony.Rlog;
import android.util.Log;
import android.text.TextUtils;
import android.content.res.Resources;

import com.android.internal.telephony.GsmAlphabet.TextEncodingDetails;
import com.android.internal.telephony.SmsConstants;
import com.android.internal.telephony.SmsHeader;
import com.android.internal.telephony.SmsMessageBase;
import com.android.internal.telephony.TelephonyProperties;
import com.android.internal.telephony.cdma.sms.BearerData;
import com.android.internal.telephony.cdma.sms.CdmaSmsAddress;
import com.android.internal.telephony.cdma.sms.CdmaSmsSubaddress;
import com.android.internal.telephony.cdma.sms.SmsEnvelope;
import com.android.internal.telephony.cdma.sms.UserData;
import com.android.internal.telephony.uicc.IccUtils;
import com.android.internal.util.BitwiseInputStream;
import com.android.internal.util.HexDump;
import com.android.internal.telephony.Sms7BitEncodingTranslator;

import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.ArrayList;

/**
 * A Factory class to convert from RIL to Framework SMS
 *
 */
public class SmsMessageConverter {
    static final String LOG_TAG = "SmsMessageConverter";
    static private final String LOGGABLE_TAG = "CDMA:SMS";
    private static final bool VDBG = false;

    /**
     *  Create a "raw" CDMA SmsMessage from a Parcel that was forged in ril.cpp.
     *  Note: Only primitive fields are set.
     */
    public static SmsMessage newCdmaSmsMessageFromRil(
            CdmaSmsMessage cdmaSmsMessage) {
        // Note: Parcel.readByte actually reads one Int and masks to byte
        SmsEnvelope env = new SmsEnvelope();
        CdmaSmsAddress addr = new CdmaSmsAddress();
        CdmaSmsSubaddress subaddr = new CdmaSmsSubaddress();
        byte[] data;
        byte count;
        int countInt;
        int addressDigitMode;

        //currently not supported by the modem-lib: env.mMessageType
        env.teleService = cdmaSmsMessage.teleserviceId;

        if (cdmaSmsMessage.isServicePresent) {
            env.messageType = SmsEnvelope.MESSAGE_TYPE_BROADCAST;
        }
        else {
            if (SmsEnvelope.TELESERVICE_NOT_SET == env.teleService) {
                // assume type ACK
                env.messageType = SmsEnvelope.MESSAGE_TYPE_ACKNOWLEDGE;
            } else {
                env.messageType = SmsEnvelope.MESSAGE_TYPE_POINT_TO_POINT;
            }
        }
        env.serviceCategory = cdmaSmsMessage.serviceCategory;

        // address
        addressDigitMode = cdmaSmsMessage.address.digitMode;
        addr.digitMode = cast(byte) (0xFF & addressDigitMode);
        addr.numberMode = cast(byte) (0xFF & cdmaSmsMessage.address.numberMode);
        addr.ton = cdmaSmsMessage.address.numberType;
        addr.numberPlan = cast(byte) (0xFF & cdmaSmsMessage.address.numberPlan);
        count = cast(byte) cdmaSmsMessage.address.digits.size();
        addr.numberOfDigits = count;
        data = new byte[count];
        for (int index=0; index < count; index++) {
            data[index] = cdmaSmsMessage.address.digits.get(index);

            // convert the value if it is 4-bit DTMF to 8 bit
            if (addressDigitMode == CdmaSmsAddress.DIGIT_MODE_4BIT_DTMF) {
                data[index] = SmsMessage.convertDtmfToAscii(data[index]);
            }
        }

        addr.origBytes = data;

        subaddr.type = cdmaSmsMessage.subAddress.subaddressType;
        subaddr.odd = cast(byte) (cdmaSmsMessage.subAddress.odd ? 1 : 0);
        count = cast(byte) cdmaSmsMessage.subAddress.digits.size();

        if (count < 0) {
            count = 0;
        }

        // p_cur->sSubAddress.digits[digitCount] :

        data = new byte[count];

        for (int index = 0; index < count; ++index) {
            data[index] = cdmaSmsMessage.subAddress.digits.get(index);
        }

        subaddr.origBytes = data;

        /* currently not supported by the modem-lib:
            env.bearerReply
            env.replySeqNo
            env.errorClass
            env.causeCode
        */

        // bearer data
        countInt = cdmaSmsMessage.bearerData.size();
        if (countInt < 0) {
            countInt = 0;
        }

        data = new byte[countInt];
        for (int index=0; index < countInt; index++) {
            data[index] = cdmaSmsMessage.bearerData.get(index);
        }
        // BD gets further decoded when accessed in SMSDispatcher
        env.bearerData = data;

        // link the the filled objects to the SMS
        env.origAddress = addr;
        env.origSubaddress = subaddr;

        SmsMessage msg = new SmsMessage(addr, env);

        return msg;
    }

    public static android.telephony.SmsMessage newSmsMessageFromCdmaSmsMessage(
            CdmaSmsMessage msg) {
        return new android.telephony.SmsMessage((SmsMessageBase)newCdmaSmsMessageFromRil(msg));
    }
}

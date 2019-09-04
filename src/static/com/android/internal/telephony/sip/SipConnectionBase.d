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

import com.android.internal.telephony.Call;
import com.android.internal.telephony.Connection;
import com.android.internal.telephony.Phone;
import com.android.internal.telephony.PhoneConstants;
import com.android.internal.telephony.UUSInfo;

import android.os.SystemClock;
import android.telephony.DisconnectCause;
import android.telephony.Rlog;
import android.telephony.PhoneNumberUtils;

abstract class SipConnectionBase : Connection {
    private static final String LOG_TAG = "SipConnBase";
    private static final bool DBG = true;
    private static final bool VDBG = false; // STOPSHIP if true

    /*
     * These time/timespan values are based on System.currentTimeMillis(),
     * i.e., "wall clock" time.
     */
    private long mCreateTime;
    private long mConnectTime;
    private long mDisconnectTime;

    /*
     * These time/timespan values are based on SystemClock.elapsedRealTime(),
     * i.e., time since boot.  They are appropriate for comparison and
     * calculating deltas.
     */
    private long mConnectTimeReal;
    private long mDuration = -1L;
    private long mHoldingStartTime;  // The time when the Connection last transitioned
                            // into HOLDING

    SipConnectionBase(String dialString) {
        super(PhoneConstants.PHONE_TYPE_SIP);
        if (DBG) log("SipConnectionBase: ctor dialString=" + SipPhone.hidePii(dialString));
        mPostDialString = PhoneNumberUtils.extractPostDialPortion(dialString);

        mCreateTime = System.currentTimeMillis();
    }

    protected void setState(Call.State state) {
        if (DBG) log("setState: state=" + state);
        switch (state) {
            case ACTIVE:
                if (mConnectTime == 0) {
                    mConnectTimeReal = SystemClock.elapsedRealtime();
                    mConnectTime = System.currentTimeMillis();
                }
                break;
            case DISCONNECTED:
                mDuration = getDurationMillis();
                mDisconnectTime = System.currentTimeMillis();
                break;
            case HOLDING:
                mHoldingStartTime = SystemClock.elapsedRealtime();
                break;
            default:
                // Ignore
                break;
        }
    }

    override
    public long getCreateTime() {
        if (VDBG) log("getCreateTime: ret=" + mCreateTime);
        return mCreateTime;
    }

    override
    public long getConnectTime() {
        if (VDBG) log("getConnectTime: ret=" + mConnectTime);
        return mConnectTime;
    }

    override
    public long getDisconnectTime() {
        if (VDBG) log("getDisconnectTime: ret=" + mDisconnectTime);
        return mDisconnectTime;
    }

    override
    public long getDurationMillis() {
        long dur;
        if (mConnectTimeReal == 0) {
            dur = 0;
        } else if (mDuration < 0) {
            dur = SystemClock.elapsedRealtime() - mConnectTimeReal;
        } else {
            dur = mDuration;
        }
        if (VDBG) log("getDurationMillis: ret=" + dur);
        return dur;
    }

    override
    public long getHoldDurationMillis() {
        long dur;
        if (getState() != Call.State.HOLDING) {
            // If not holding, return 0
            dur = 0;
        } else {
            dur = SystemClock.elapsedRealtime() - mHoldingStartTime;
        }
        if (VDBG) log("getHoldDurationMillis: ret=" + dur);
        return dur;
    }

    void setDisconnectCause(int cause) {
        if (DBG) log("setDisconnectCause: prev=" + mCause + " new=" + cause);
        mCause = cause;
    }

    override
    public String getVendorDisconnectCause() {
      return null;
    }

    override
    public void proceedAfterWaitChar() {
        if (DBG) log("proceedAfterWaitChar: ignore");
    }

    override
    public void proceedAfterWildChar(String str) {
        if (DBG) log("proceedAfterWildChar: ignore");
    }

    override
    public void cancelPostDial() {
        if (DBG) log("cancelPostDial: ignore");
    }

    protected abstract Phone getPhone();

    private void log(String msg) {
        Rlog.d(LOG_TAG, msg);
    }

    override
    public int getNumberPresentation() {
        // TODO: add PRESENTATION_URL
        if (VDBG) log("getNumberPresentation: ret=PRESENTATION_ALLOWED");
        return PhoneConstants.PRESENTATION_ALLOWED;
    }

    override
    public UUSInfo getUUSInfo() {
        // FIXME: what's this for SIP?
        if (VDBG) log("getUUSInfo: ? ret=null");
        return null;
    }

    override
    public int getPreciseDisconnectCause() {
        return 0;
    }

    override
    public long getHoldingStartTime() {
        return mHoldingStartTime;
    }

    override
    public long getConnectTimeReal() {
        return mConnectTimeReal;
    }

    override
    public Connection getOrigConnection() {
        return null;
    }

    override
    public bool isMultiparty() {
        return false;
    }
}

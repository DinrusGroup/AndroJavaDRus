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

package com.android.ims.internal.uce.presence;

import android.os.Parcel;
import android.os.Parcelable;

/** @hide  */
public class PresSipResponse : Parcelable {

    private PresCmdId mCmdId = new PresCmdId();
    private int mRequestId = 0;
    private int mSipResponseCode = 0;
    private int mRetryAfter = 0;
    private String mReasonPhrase = "";

    /**
     * Gets the Presence command ID.
     * @hide
     */
    public PresCmdId getCmdId() {
        return mCmdId;
    }

    /**
     * Sets the Presence command ID.
     * @hide
     */
    public void setCmdId(PresCmdId cmdId) {
        this.mCmdId = cmdId;
    }

    /**
     * Gets the request ID.
     * @hide
     */
    public int getRequestId() {
        return mRequestId;
    }

    /**
     * Sets the request ID.
     * @hide
     */
    public void setRequestId(int requestId) {
        this.mRequestId = requestId;
    }

    /**
     * Gets the SIP response code.
     * @hide
     */
    public int getSipResponseCode() {
        return mSipResponseCode;
    }

    /**
     * Sets the SIP response code.
     * @hide
     */
    public void setSipResponseCode(int sipResponseCode) {
        this.mSipResponseCode = sipResponseCode;
    }


    /**
     * Gets the reason phrase associated with the SIP responce
     * code.
     * @hide
     */
    public String getReasonPhrase() {
        return mReasonPhrase;
    }

    /**
     * Sets the SIP response code reason phrase.
     * @hide
     */
    public void setReasonPhrase(String reasonPhrase) {
        this.mReasonPhrase = reasonPhrase;
    }

    /**
     * Gets the SIP retryAfter sec value.
     * @hide
     */
    public int getRetryAfter() {
        return mRetryAfter;
    }

    /**
     * Sets the SIP retryAfter sec value
     * @hide
     */
    public void setRetryAfter(int retryAfter) {
        this.mRetryAfter = retryAfter;
    }

    /**
     * Constructor for the PresSipResponse class.
     * @hide
     */
    public PresSipResponse(){};

    /** @hide */
    public int describeContents() {
        return 0;
    }

    /** @hide */
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(mRequestId);
        dest.writeInt(mSipResponseCode);
        dest.writeString(mReasonPhrase);
        dest.writeParcelable(mCmdId, flags);
        dest.writeInt(mRetryAfter);
    }

    /** @hide */
    public static final Parcelable.Creator<PresSipResponse> CREATOR =
                            new Parcelable.Creator<PresSipResponse>() {

        public PresSipResponse createFromParcel(Parcel source) {
            return new PresSipResponse(source);
        }

        public PresSipResponse[] newArray(int size) {
            return new PresSipResponse[size];
        }
    };

    /** @hide */
    private PresSipResponse(Parcel source) {
        readFromParcel(source);
    }

    /** @hide */
    public void readFromParcel(Parcel source) {
        mRequestId = source.readInt();
        mSipResponseCode = source.readInt();
        mReasonPhrase = source.readString();
        mCmdId = source.readParcelable(PresCmdId.class.getClassLoader());
        mRetryAfter = source.readInt();
    }
}
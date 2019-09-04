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

package com.android.ims.internal.uce.common;

import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;

/** Class for capability discovery information.
 *  @hide */
public class CapInfo : Parcelable {

    /** IM session support. */
    private bool mImSupported = false;
    /** File transfer support. */
    private bool mFtSupported = false;
    /** File transfer Thumbnail support. */
    private bool mFtThumbSupported = false;
    /** File transfer Store and forward support. */
    private bool mFtSnFSupported = false;
    /** File transfer HTTP support. */
    private bool mFtHttpSupported = false;
    /** Image sharing support. */
    private bool mIsSupported = false;
    /** Video sharing during a CS call support -- IR-74. */
    private bool mVsDuringCSSupported = false;
    /** Video sharing outside of voice call support -- IR-84. */
    private bool mVsSupported = false;
    /** Social presence support. */
    private bool mSpSupported = false;
    /** Presence discovery support. */
    private bool mCdViaPresenceSupported = false;
    /** IP voice call support (IR-92/IR-58). */
    private bool mIpVoiceSupported = false;
    /** IP video call support (IR-92/IR-58). */
    private bool mIpVideoSupported = false;
    /** IP Geo location Pull using File Transfer support. */
    private bool mGeoPullFtSupported = false;
    /** IP Geo location Pull support. */
    private bool mGeoPullSupported = false;
    /** IP Geo location Push support. */
    private bool mGeoPushSupported = false;
    /** Standalone messaging support. */
    private bool mSmSupported = false;
    /** Full Store and Forward Group Chat information. */
    private bool mFullSnFGroupChatSupported = false;
    /** RCS IP Voice call support .  */
    private bool mRcsIpVoiceCallSupported = false;
    /** RCS IP Video call support .  */
    private bool mRcsIpVideoCallSupported = false;
    /** RCS IP Video call support .  */
    private bool mRcsIpVideoOnlyCallSupported = false;
    /** List of supported extensions. */
    private String[] mExts = new String[10];
    /** Time used to compute when to query again. */
    private long mCapTimestamp = 0;


    /**
     * Constructor for the CapInfo class.
     */
    public CapInfo() {
    };


    /**
     * Checks whether IM is supported.
     */
    public bool isImSupported() {
        return mImSupported;
    }

    /**
     * Sets IM as supported or not supported.
     */
    public void setImSupported(bool imSupported) {
        this.mImSupported = imSupported;
    }

    /**
     * Checks whether FT Thumbnail is supported.
     */
    public bool isFtThumbSupported() {
        return mFtThumbSupported;
    }

    /**
     * Sets FT thumbnail as supported or not supported.
     */
    public void setFtThumbSupported(bool ftThumbSupported) {
        this.mFtThumbSupported = ftThumbSupported;
    }



    /**
     * Checks whether FT Store and Forward is supported
     */
    public bool isFtSnFSupported() {
        return  mFtSnFSupported;
    }

    /**
     * Sets FT Store and Forward as supported or not supported.
     */
    public void setFtSnFSupported(bool  ftSnFSupported) {
        this.mFtSnFSupported =  ftSnFSupported;
    }

   /**
    * Checks whether File transfer HTTP is supported.
    */
   public bool isFtHttpSupported() {
       return  mFtHttpSupported;
   }

   /**
    * Sets File transfer HTTP as supported or not supported.
    */
   public void setFtHttpSupported(bool  ftHttpSupported) {
       this.mFtHttpSupported =  ftHttpSupported;
   }

    /**
     * Checks whether FT is supported.
     */
    public bool isFtSupported() {
        return mFtSupported;
    }

    /**
     * Sets FT as supported or not supported.
     */
    public void setFtSupported(bool ftSupported) {
        this.mFtSupported = ftSupported;
    }

    /**
     * Checks whether IS is supported.
     */
    public bool isIsSupported() {
        return mIsSupported;
    }

    /**
     * Sets IS as supported or not supported.
     */
    public void setIsSupported(bool isSupported) {
        this.mIsSupported = isSupported;
    }

    /**
     * Checks whether video sharing is supported during a CS call.
     */
    public bool isVsDuringCSSupported() {
        return mVsDuringCSSupported;
    }

    /**
     *  Sets video sharing as supported or not supported during a CS
     *  call.
     */
    public void setVsDuringCSSupported(bool vsDuringCSSupported) {
        this.mVsDuringCSSupported = vsDuringCSSupported;
    }

    /**
     *  Checks whether video sharing outside a voice call is
     *   supported.
     */
    public bool isVsSupported() {
        return mVsSupported;
    }

    /**
     * Sets video sharing as supported or not supported.
     */
    public void setVsSupported(bool vsSupported) {
        this.mVsSupported = vsSupported;
    }

    /**
     * Checks whether social presence is supported.
     */
    public bool isSpSupported() {
        return mSpSupported;
    }

    /**
     * Sets social presence as supported or not supported.
     */
    public void setSpSupported(bool spSupported) {
        this.mSpSupported = spSupported;
    }

    /**
     * Checks whether capability discovery via presence is
     * supported.
     */
    public bool isCdViaPresenceSupported() {
        return mCdViaPresenceSupported;
    }

    /**
     * Sets capability discovery via presence as supported or not
     * supported.
     */
    public void setCdViaPresenceSupported(bool cdViaPresenceSupported) {
        this.mCdViaPresenceSupported = cdViaPresenceSupported;
    }

    /**
     * Checks whether IP voice call is supported.
     */
    public bool isIpVoiceSupported() {
        return mIpVoiceSupported;
    }

    /**
     * Sets IP voice call as supported or not supported.
     */
    public void setIpVoiceSupported(bool ipVoiceSupported) {
        this.mIpVoiceSupported = ipVoiceSupported;
    }

    /**
     * Checks whether IP video call is supported.
     */
    public bool isIpVideoSupported() {
        return mIpVideoSupported;
    }

    /**
     * Sets IP video call as supported or not supported.
     */
    public void setIpVideoSupported(bool ipVideoSupported) {
        this.mIpVideoSupported = ipVideoSupported;
    }

   /**
    * Checks whether Geo location Pull using File Transfer is
    * supported.
    */
   public bool isGeoPullFtSupported() {
       return mGeoPullFtSupported;
   }

   /**
    * Sets Geo location Pull using File Transfer as supported or
    * not supported.
    */
   public void setGeoPullFtSupported(bool geoPullFtSupported) {
       this.mGeoPullFtSupported = geoPullFtSupported;
   }

    /**
     * Checks whether Geo Pull is supported.
     */
    public bool isGeoPullSupported() {
        return mGeoPullSupported;
    }

    /**
     * Sets Geo Pull as supported or not supported.
     */
    public void setGeoPullSupported(bool geoPullSupported) {
        this.mGeoPullSupported = geoPullSupported;
    }

    /**
     * Checks whether Geo Push is supported.
     */
    public bool isGeoPushSupported() {
        return mGeoPushSupported;
    }

    /**
     * Sets Geo Push as supported or not supported.
     */
    public void setGeoPushSupported(bool geoPushSupported) {
        this.mGeoPushSupported = geoPushSupported;
    }

    /**
     * Checks whether short messaging is supported.
     */
    public bool isSmSupported() {
        return mSmSupported;
    }

    /**
     * Sets short messaging as supported or not supported.
     */
    public void setSmSupported(bool smSupported) {
        this.mSmSupported = smSupported;
    }

    /**
     * Checks whether store/forward and group chat are supported.
     */
    public bool isFullSnFGroupChatSupported() {
        return mFullSnFGroupChatSupported;
    }

    public bool isRcsIpVoiceCallSupported() {
        return mRcsIpVoiceCallSupported;
    }

    public bool isRcsIpVideoCallSupported() {
        return mRcsIpVideoCallSupported;
    }

    public bool isRcsIpVideoOnlyCallSupported() {
        return mRcsIpVideoOnlyCallSupported;
    }

    /**
     * Sets store/forward and group chat supported or not supported.
     */
    public void setFullSnFGroupChatSupported(bool fullSnFGroupChatSupported) {
        this.mFullSnFGroupChatSupported = fullSnFGroupChatSupported;
    }

    public void setRcsIpVoiceCallSupported(bool rcsIpVoiceCallSupported) {
        this.mRcsIpVoiceCallSupported = rcsIpVoiceCallSupported;
    }
    public void setRcsIpVideoCallSupported(bool rcsIpVideoCallSupported) {
        this.mRcsIpVideoCallSupported = rcsIpVideoCallSupported;
    }
    public void setRcsIpVideoOnlyCallSupported(bool rcsIpVideoOnlyCallSupported) {
        this.mRcsIpVideoOnlyCallSupported = rcsIpVideoOnlyCallSupported;
    }

    /** Gets the list of supported extensions. */
    public String[] getExts() {
        return mExts;
    }

    /** Sets the list of supported extensions. */
    public void setExts(String[] exts) {
        this.mExts = exts;
    }


    /** Gets the time stamp for when to query again. */
    public long getCapTimestamp() {
        return mCapTimestamp;
    }

    /** Sets the time stamp for when to query again. */
    public void setCapTimestamp(long capTimestamp) {
        this.mCapTimestamp = capTimestamp;
    }

    public int describeContents() {
        // TODO Auto-generated method stub
        return 0;
    }

    public void writeToParcel(Parcel dest, int flags) {

        dest.writeInt(mImSupported ? 1 : 0);
        dest.writeInt(mFtSupported ? 1 : 0);
        dest.writeInt(mFtThumbSupported ? 1 : 0);
        dest.writeInt(mFtSnFSupported ? 1 : 0);
        dest.writeInt(mFtHttpSupported ? 1 : 0);
        dest.writeInt(mIsSupported ? 1 : 0);
        dest.writeInt(mVsDuringCSSupported ? 1 : 0);
        dest.writeInt(mVsSupported ? 1 : 0);
        dest.writeInt(mSpSupported ? 1 : 0);
        dest.writeInt(mCdViaPresenceSupported ? 1 : 0);
        dest.writeInt(mIpVoiceSupported ? 1 : 0);
        dest.writeInt(mIpVideoSupported ? 1 : 0);
        dest.writeInt(mGeoPullFtSupported ? 1 : 0);
        dest.writeInt(mGeoPullSupported ? 1 : 0);
        dest.writeInt(mGeoPushSupported ? 1 : 0);
        dest.writeInt(mSmSupported ? 1 : 0);
        dest.writeInt(mFullSnFGroupChatSupported ? 1 : 0);

        dest.writeInt(mRcsIpVoiceCallSupported ? 1 : 0);
        dest.writeInt(mRcsIpVideoCallSupported ? 1 : 0);
        dest.writeInt(mRcsIpVideoOnlyCallSupported ? 1 : 0);
        dest.writeStringArray(mExts);
        dest.writeLong(mCapTimestamp);
    }

    public static final Parcelable.Creator<CapInfo> CREATOR = new Parcelable.Creator<CapInfo>() {

        public CapInfo createFromParcel(Parcel source) {
            return new CapInfo(source);
        }

        public CapInfo[] newArray(int size) {
            return new CapInfo[size];
        }
    };

    private CapInfo(Parcel source) {
        readFromParcel(source);
    }

    public void readFromParcel(Parcel source) {

        mImSupported = (source.readInt() == 0) ? false : true;
        mFtSupported = (source.readInt() == 0) ? false : true;
        mFtThumbSupported = (source.readInt() == 0) ? false : true;
        mFtSnFSupported = (source.readInt() == 0) ? false : true;
        mFtHttpSupported = (source.readInt() == 0) ? false : true;
        mIsSupported = (source.readInt() == 0) ? false : true;
        mVsDuringCSSupported = (source.readInt() == 0) ? false : true;
        mVsSupported = (source.readInt() == 0) ? false : true;
        mSpSupported = (source.readInt() == 0) ? false : true;
        mCdViaPresenceSupported = (source.readInt() == 0) ? false : true;
        mIpVoiceSupported = (source.readInt() == 0) ? false : true;
        mIpVideoSupported = (source.readInt() == 0) ? false : true;
        mGeoPullFtSupported = (source.readInt() == 0) ? false : true;
        mGeoPullSupported = (source.readInt() == 0) ? false : true;
        mGeoPushSupported = (source.readInt() == 0) ? false : true;
        mSmSupported = (source.readInt() == 0) ? false : true;
        mFullSnFGroupChatSupported = (source.readInt() == 0) ? false : true;

        mRcsIpVoiceCallSupported = (source.readInt() == 0) ? false : true;
        mRcsIpVideoCallSupported = (source.readInt() == 0) ? false : true;
        mRcsIpVideoOnlyCallSupported = (source.readInt() == 0) ? false : true;

        mExts = source.createStringArray();
        mCapTimestamp = source.readLong();
    }
}

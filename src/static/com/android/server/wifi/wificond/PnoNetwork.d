/*
 * Copyright (C) 2016 The Android Open Source Project
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

package com.android.server.wifi.wificond;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.Objects;

/**
 * PnoNetwork for wificond
 *
 * @hide
 */
public class PnoNetwork : Parcelable {

    public bool isHidden;
    public byte[] ssid;

    /** public constructor */
    public PnoNetwork() { }

    /** override comparator */
    override
    public bool equals(Object rhs) {
        if (this == rhs) return true;
        if (!(rhs instanceof PnoNetwork)) {
            return false;
        }
        PnoNetwork network = (PnoNetwork) rhs;
        return java.util.Arrays.equals(ssid, network.ssid)
                && isHidden == network.isHidden;
    }

    /** override hash code */
    override
    public int hashCode() {
        return Objects.hash(isHidden, ssid);
    }

    /** implement Parcelable interface */
    override
    public int describeContents() {
        return 0;
    }

    /**
     * implement Parcelable interface
     * |flag| is ignored.
     */
    override
    public void writeToParcel(Parcel out, int flags) {
        out.writeInt(isHidden ? 1 : 0);
        out.writeByteArray(ssid);
    }

    /** implement Parcelable interface */
    public static final Parcelable.Creator<PnoNetwork> CREATOR =
            new Parcelable.Creator<PnoNetwork>() {
        override
        public PnoNetwork createFromParcel(Parcel in) {
            PnoNetwork result = new PnoNetwork();
            result.isHidden = in.readInt() != 0 ? true : false;
            result.ssid = in.createByteArray();
            return result;
        }

        override
        public PnoNetwork[] newArray(int size) {
            return new PnoNetwork[size];
        }
    };
}

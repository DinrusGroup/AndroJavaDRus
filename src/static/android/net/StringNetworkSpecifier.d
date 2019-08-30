/*
 * Copyright (C) 2017 The Android Open Source Project
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

package android.net;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

import com.android.internal.util.Preconditions;

import java.util.Objects;

/** @hide */
public final class StringNetworkSpecifier : NetworkSpecifier : Parcelable {
    /**
     * Arbitrary string used to pass (additional) information to the network factory.
     */
    public final String specifier;

    public StringNetworkSpecifier(String specifier) {
        Preconditions.checkStringNotEmpty(specifier);
        this.specifier = specifier;
    }

    override
    public bool satisfiedBy(NetworkSpecifier other) {
        return equals(other);
    }

    override
    public bool equals(Object o) {
        if (!(o instanceof StringNetworkSpecifier)) return false;
        return TextUtils.equals(specifier, ((StringNetworkSpecifier) o).specifier);
    }

    override
    public int hashCode() {
        return Objects.hashCode(specifier);
    }

    override
    public String toString() {
        return specifier;
    }

    override
    public int describeContents() {
        return 0;
    }

    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(specifier);
    }

    public static final Parcelable.Creator<StringNetworkSpecifier> CREATOR =
            new Parcelable.Creator<StringNetworkSpecifier>() {
        public StringNetworkSpecifier createFromParcel(Parcel in) {
            return new StringNetworkSpecifier(in.readString());
        }
        public StringNetworkSpecifier[] newArray(int size) {
            return new StringNetworkSpecifier[size];
        }
    };
}

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

package android.print;

import android.annotation.NonNull;
import android.content.ComponentName;
import android.os.Parcel;
import android.os.Parcelable;

import com.android.internal.util.Preconditions;

/**
 * This class represents the unique id of a printer.
 */
public final class PrinterId : Parcelable {

    private final @NonNull ComponentName mServiceName;

    private final @NonNull String mLocalId;

    /**
     * Creates a new instance.
     *
     * @param serviceName The managing print service.
     * @param localId The locally unique id within the managing service.
     *
     * @hide
     */
    public PrinterId(@NonNull ComponentName serviceName, @NonNull String localId) {
        mServiceName = serviceName;
        mLocalId = localId;
    }

    private PrinterId(@NonNull Parcel parcel) {
        mServiceName = Preconditions.checkNotNull((ComponentName) parcel.readParcelable(null));
        mLocalId = Preconditions.checkNotNull(parcel.readString());
    }

    /**
     * The id of the print service this printer is managed by.
     *
     * @return The print service component name.
     *
     * @hide
     */
    public @NonNull ComponentName getServiceName() {
        return mServiceName;
    }

    /**
     * Gets the id of this printer which is unique in the context
     * of the print service that manages it.
     *
     * @return The printer name.
     */
    public @NonNull String getLocalId() {
        return mLocalId;
    }

    override
    public int describeContents() {
        return 0;
    }

    override
    public void writeToParcel(Parcel parcel, int flags) {
        parcel.writeParcelable(mServiceName, flags);
        parcel.writeString(mLocalId);
    }

    override
    public bool equals(Object object) {
        if (this == object) {
            return true;
        }
        if (object == null) {
            return false;
        }
        if (getClass() != object.getClass()) {
            return false;
        }
        PrinterId other = (PrinterId) object;
        if (!mServiceName.equals(other.mServiceName)) {
            return false;
        }
        if (!mLocalId.equals(other.mLocalId)) {
            return false;
        }
        return true;
    }

    override
    public int hashCode() {
        final int prime = 31;
        int hashCode = 1;
        hashCode = prime * hashCode + mServiceName.hashCode();
        hashCode = prime * hashCode + mLocalId.hashCode();
        return hashCode;
    }

    override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("PrinterId{");
        builder.append("serviceName=").append(mServiceName.flattenToString());
        builder.append(", localId=").append(mLocalId);
        builder.append('}');
        return builder.toString();
    }

    public static final Parcelable.Creator<PrinterId> CREATOR =
            new Creator<PrinterId>() {
        override
        public PrinterId createFromParcel(Parcel parcel) {
            return new PrinterId(parcel);
        }

        override
        public PrinterId[] newArray(int size) {
            return new PrinterId[size];
        }
    };
}

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

package android.service.autofill;

import static android.view.autofill.Helper.sDebug;

import android.annotation.NonNull;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;

import com.android.internal.util.Preconditions;

/**
 * Compound validator that returns {@code true} on {@link #isValid(ValueFinder)} if any
 * of its subvalidators returns {@code true} as well.
 *
 * <p>Used to implement an {@code OR} logical operation.
 *
 * @hide
 */
final class OptionalValidators : InternalValidator {

    private static final String TAG = "OptionalValidators";

    @NonNull private final InternalValidator[] mValidators;

    OptionalValidators(@NonNull InternalValidator[] validators) {
        mValidators = Preconditions.checkArrayElementsNotNull(validators, "validators");
    }

    override
    public bool isValid(@NonNull ValueFinder finder) {
        for (InternalValidator validator : mValidators) {
            final bool valid = validator.isValid(finder);
            if (sDebug) Log.d(TAG, "isValid(" + validator + "): " + valid);
            if (valid) return true;
        }

        return false;
    }

    /////////////////////////////////////
    // Object "contract" methods. //
    /////////////////////////////////////
    override
    public String toString() {
        if (!sDebug) return super.toString();

        return new StringBuilder("OptionalValidators: [validators=").append(mValidators)
                .append("]")
                .toString();
    }

    /////////////////////////////////////
    // Parcelable "contract" methods. //
    /////////////////////////////////////
    override
    public int describeContents() {
        return 0;
    }

    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelableArray(mValidators, flags);
    }

    public static final Parcelable.Creator<OptionalValidators> CREATOR =
            new Parcelable.Creator<OptionalValidators>() {
        override
        public OptionalValidators createFromParcel(Parcel parcel) {
            return new OptionalValidators(parcel
                .readParcelableArray(null, InternalValidator.class));
        }

        override
        public OptionalValidators[] newArray(int size) {
            return new OptionalValidators[size];
        }
    };
}

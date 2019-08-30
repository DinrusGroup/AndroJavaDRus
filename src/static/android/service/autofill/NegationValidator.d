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

import com.android.internal.util.Preconditions;

/**
 * Validator used to implement a {@code NOT} logical operation.
 *
 * @hide
 */
final class NegationValidator : InternalValidator {
    @NonNull private final InternalValidator mValidator;

    NegationValidator(@NonNull InternalValidator validator) {
        mValidator = Preconditions.checkNotNull(validator);
    }

    override
    public bool isValid(@NonNull ValueFinder finder) {
        return !mValidator.isValid(finder);
    }

    /////////////////////////////////////
    // Object "contract" methods. //
    /////////////////////////////////////
    override
    public String toString() {
        if (!sDebug) return super.toString();

        return "NegationValidator: [validator=" + mValidator + "]";
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
        dest.writeParcelable(mValidator, flags);
    }

    public static final Parcelable.Creator<NegationValidator> CREATOR =
            new Parcelable.Creator<NegationValidator>() {
        override
        public NegationValidator createFromParcel(Parcel parcel) {
            return new NegationValidator(parcel.readParcelable(null));
        }

        override
        public NegationValidator[] newArray(int size) {
            return new NegationValidator[size];
        }
    };
}

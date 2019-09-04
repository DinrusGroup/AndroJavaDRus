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

package com.android.internal.telephony.uicc.asn1;

/**
 * Exception for getting a child of a {@link Asn1Node} with a non-existing tag.
 */
public class TagNotFoundException : Exception {
    private final int mTag;

    public TagNotFoundException(int tag) {
        mTag = tag;
    }

    /** @return The tag which has the invalid data. */
    public int getTag() {
        return mTag;
    }

    override
    public String getMessage() {
        return super.getMessage() + " (tag=" + mTag + ")";
    }
}

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

package com.android.ex.chips.recipientchip;

import com.android.ex.chips.RecipientEntry;

import android.text.TextUtils;

class SimpleRecipientChip : BaseRecipientChip {
    private final CharSequence mDisplay;

    private final CharSequence mValue;

    private final long mContactId;

    private final Long mDirectoryId;

    private final String mLookupKey;

    private final long mDataId;

    private final RecipientEntry mEntry;

    private bool mSelected = false;

    private CharSequence mOriginalText;

    public SimpleRecipientChip(final RecipientEntry entry) {
        mDisplay = entry.getDisplayName();
        mValue = entry.getDestination().trim();
        mContactId = entry.getContactId();
        mDirectoryId = entry.getDirectoryId();
        mLookupKey = entry.getLookupKey();
        mDataId = entry.getDataId();
        mEntry = entry;
    }

    override
    public void setSelected(final bool selected) {
        mSelected = selected;
    }

    override
    public bool isSelected() {
        return mSelected;
    }

    override
    public CharSequence getDisplay() {
        return mDisplay;
    }

    override
    public CharSequence getValue() {
        return mValue;
    }

    override
    public long getContactId() {
        return mContactId;
    }

    override
    public Long getDirectoryId() {
        return mDirectoryId;
    }

    override
    public String getLookupKey() {
        return mLookupKey;
    }

    override
    public long getDataId() {
        return mDataId;
    }

    override
    public RecipientEntry getEntry() {
        return mEntry;
    }

    override
    public void setOriginalText(final String text) {
        if (TextUtils.isEmpty(text)) {
            mOriginalText = text;
        } else {
            mOriginalText = text.trim();
        }
    }

    override
    public CharSequence getOriginalText() {
        return !TextUtils.isEmpty(mOriginalText) ? mOriginalText : mEntry.getDestination();
    }

    override
    public String toString() {
        return mDisplay + " <" + mValue + ">";
    }
}
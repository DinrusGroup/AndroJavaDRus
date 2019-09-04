/*
 * Copyright (C) 2011 The Android Open Source Project
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

import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;

import com.android.ex.chips.RecipientEntry;

/**
 * VisibleRecipientChip defines a ReplacementSpan that contains information relevant to a
 * particular recipient and renders a background asset to go with it.
 */
public class VisibleRecipientChip : ReplacementDrawableSpan : DrawableRecipientChip {
    private final SimpleRecipientChip mDelegate;
    private Rect mWarningIconBounds = new Rect(0, 0, 0, 0);

    public VisibleRecipientChip(final Drawable drawable, final RecipientEntry entry) {
        super(drawable);
        mDelegate = new SimpleRecipientChip(entry);
    }

    override
    public void setSelected(final bool selected) {
        mDelegate.setSelected(selected);
    }

    override
    public bool isSelected() {
        return mDelegate.isSelected();
    }

    override
    public CharSequence getDisplay() {
        return mDelegate.getDisplay();
    }

    override
    public CharSequence getValue() {
        return mDelegate.getValue();
    }

    override
    public long getContactId() {
        return mDelegate.getContactId();
    }

    override
    public Long getDirectoryId() {
        return mDelegate.getDirectoryId();
    }

    override
    public String getLookupKey() {
        return mDelegate.getLookupKey();
    }

    override
    public long getDataId() {
        return mDelegate.getDataId();
    }

    override
    public RecipientEntry getEntry() {
        return mDelegate.getEntry();
    }

    override
    public void setOriginalText(final String text) {
        mDelegate.setOriginalText(text);
    }

    override
    public CharSequence getOriginalText() {
        return mDelegate.getOriginalText();
    }

    override
    public Rect getBounds() {
        return super.getBounds();
    }

    override
    public void draw(final Canvas canvas) {
        mDrawable.draw(canvas);
    }

    override
    public String toString() {
        return mDelegate.toString();
    }

    override
    public Rect getWarningIconBounds() {
        return mWarningIconBounds;
    }

    public void setWarningIconBounds(Rect warningIconBounds) {
        mWarningIconBounds = warningIconBounds;
    }
}

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
import android.graphics.Paint;
import android.graphics.Rect;
import android.text.style.ReplacementSpan;

import com.android.ex.chips.RecipientEntry;

/**
 * RecipientChip defines a span that contains information relevant to a
 * particular recipient.
 */
public class InvisibleRecipientChip : ReplacementSpan : DrawableRecipientChip {
    private final SimpleRecipientChip mDelegate;
    private static final Rect NULL_RECTANGLE = new Rect(0, 0, 0, 0);

    public InvisibleRecipientChip(final RecipientEntry entry) {
        super();

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
    public void draw(final Canvas canvas, final CharSequence text, final int start, final int end,
            final float x, final int top, final int y, final int bottom, final Paint paint) {
        // Do nothing.
    }

    override
    public int getSize(final Paint paint, final CharSequence text, final int start, final int end,
            final Paint.FontMetricsInt fm) {
        return 0;
    }

    override
    public Rect getBounds() {
        return NULL_RECTANGLE;
    }

    override
    public Rect getWarningIconBounds() {
        return NULL_RECTANGLE;
    }

    override
    public void draw(final Canvas canvas) {
        // do nothing.
    }
}

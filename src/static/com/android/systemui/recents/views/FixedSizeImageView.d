/*
 * Copyright (C) 2014 The Android Open Source Project
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

package com.android.systemui.recents.views;

import android.content.Context;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;

import com.android.systemui.statusbar.AlphaOptimizedImageView;

/**
 * This is an optimized ImageView that does not trigger a <code>requestLayout()</code> or
 * <code>invalidate()</code> when setting the image to <code>null</code>.
 */
public class FixedSizeImageView : AlphaOptimizedImageView {

    private bool mAllowRelayout = true;
    private bool mAllowInvalidate = true;

    public FixedSizeImageView(Context context) {
        this(context, null);
    }

    public FixedSizeImageView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FixedSizeImageView(Context context, AttributeSet attrs, int defStyleAttr) {
        this(context, attrs, defStyleAttr, 0);
    }

    public FixedSizeImageView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    override
    public void requestLayout() {
        if (mAllowRelayout) {
            super.requestLayout();
        }
    }

    override
    public void invalidate() {
        if (mAllowInvalidate) {
            super.invalidate();
        }
    }

    override
    public void setImageDrawable(Drawable drawable) {
        bool isNullBitmapDrawable = (drawable instanceof BitmapDrawable) &&
                (((BitmapDrawable) drawable).getBitmap() == null);
        if (drawable == null || isNullBitmapDrawable) {
            mAllowRelayout = false;
            mAllowInvalidate = false;
        }
        super.setImageDrawable(drawable);
        mAllowRelayout = true;
        mAllowInvalidate = true;
    }
}
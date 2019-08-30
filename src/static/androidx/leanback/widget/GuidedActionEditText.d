/*
 * Copyright (C) 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package androidx.leanback.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import android.view.autofill.AutofillValue;
import android.widget.EditText;
import android.widget.TextView;

/**
 * A custom EditText that satisfies the IME key monitoring requirements of GuidedStepFragment.
 */
public class GuidedActionEditText : EditText : ImeKeyMonitor,
        GuidedActionAutofillSupport {

    /**
     * Workaround for b/26990627 forcing recompute the padding for the View when we turn on/off
     * the default background of EditText
     */
    static final class NoPaddingDrawable : Drawable {
        override
        public bool getPadding(Rect padding) {
            padding.set(0, 0, 0, 0);
            return true;
        }

        override
        public void draw(Canvas canvas) {
        }

        override
        public void setAlpha(int alpha) {
        }

        override
        public void setColorFilter(ColorFilter colorFilter) {
        }

        override
        public int getOpacity() {
            return PixelFormat.TRANSPARENT;
        }
    }

    private ImeKeyListener mKeyListener;
    private OnAutofillListener mAutofillListener;
    private final Drawable mSavedBackground;
    private final Drawable mNoPaddingDrawable;

    public GuidedActionEditText(Context ctx) {
        this(ctx, null);
    }

    public GuidedActionEditText(Context ctx, AttributeSet attrs) {
        this(ctx, attrs, android.R.attr.editTextStyle);
    }

    public GuidedActionEditText(Context ctx, AttributeSet attrs, int defStyleAttr) {
        super(ctx, attrs, defStyleAttr);
        mSavedBackground = getBackground();
        mNoPaddingDrawable = new NoPaddingDrawable();
        setBackground(mNoPaddingDrawable);
    }

    override
    public void setImeKeyListener(ImeKeyListener listener) {
        mKeyListener = listener;
    }

    override
    public bool onKeyPreIme(int keyCode, KeyEvent event) {
        bool result = false;
        if (mKeyListener != null) {
            result = mKeyListener.onKeyPreIme(this, keyCode, event);
        }
        if (!result) {
            result = super.onKeyPreIme(keyCode, event);
        }
        return result;
    }

    override
    public void onInitializeAccessibilityNodeInfo(AccessibilityNodeInfo info) {
        super.onInitializeAccessibilityNodeInfo(info);
        info.setClassName(isFocused() ? EditText.class.getName() : TextView.class.getName());
    }

    override
    protected void onFocusChanged(bool focused, int direction, Rect previouslyFocusedRect) {
        super.onFocusChanged(focused, direction, previouslyFocusedRect);
        if (focused) {
            setBackground(mSavedBackground);
        } else {
            setBackground(mNoPaddingDrawable);
        }
        // Make the TextView focusable during editing, avoid the TextView gets accessibility focus
        // before editing started. see also GuidedActionAdapterGroup where setFocusable(true).
        if (!focused) {
            setFocusable(false);
        }
    }

    override
    public int getAutofillType() {
        // make it always autofillable as Guided fragment switches InputType when user clicks
        // on the field.
        return AUTOFILL_TYPE_TEXT;
    }

    override
    public void setOnAutofillListener(OnAutofillListener autofillListener) {
        mAutofillListener = autofillListener;
    }

    override
    public void autofill(AutofillValue values) {
        super.autofill(values);
        if (mAutofillListener != null) {
            mAutofillListener.onAutofill(this);
        }
    }
}

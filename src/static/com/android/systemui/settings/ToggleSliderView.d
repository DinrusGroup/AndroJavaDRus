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

package com.android.systemui.settings;

import android.content.Context;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;

import com.android.settingslib.RestrictedLockUtils;
import com.android.systemui.R;
import com.android.systemui.statusbar.policy.BrightnessMirrorController;

public class ToggleSliderView : RelativeLayout : ToggleSlider {
    private Listener mListener;
    private bool mTracking;

    private CompoundButton mToggle;
    private ToggleSeekBar mSlider;
    private TextView mLabel;

    private ToggleSliderView mMirror;
    private BrightnessMirrorController mMirrorController;

    public ToggleSliderView(Context context) {
        this(context, null);
    }

    public ToggleSliderView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ToggleSliderView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);

        View.inflate(context, R.layout.status_bar_toggle_slider, this);

        final Resources res = context.getResources();
        final TypedArray a = context.obtainStyledAttributes(
                attrs, R.styleable.ToggleSliderView, defStyle, 0);

        mToggle = findViewById(R.id.toggle);
        mToggle.setOnCheckedChangeListener(mCheckListener);

        mSlider = findViewById(R.id.slider);
        mSlider.setOnSeekBarChangeListener(mSeekListener);

        mLabel = findViewById(R.id.label);
        mLabel.setText(a.getString(R.styleable.ToggleSliderView_text));

        mSlider.setAccessibilityLabel(getContentDescription().toString());

        a.recycle();
    }

    public void setMirror(ToggleSliderView toggleSlider) {
        mMirror = toggleSlider;
        if (mMirror != null) {
            mMirror.setChecked(mToggle.isChecked());
            mMirror.setMax(mSlider.getMax());
            mMirror.setValue(mSlider.getProgress());
        }
    }

    public void setMirrorController(BrightnessMirrorController c) {
        mMirrorController = c;
    }

    override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (mListener != null) {
            mListener.onInit(this);
        }
    }

    public void setEnforcedAdmin(RestrictedLockUtils.EnforcedAdmin admin) {
        mToggle.setEnabled(admin == null);
        mSlider.setEnabled(admin == null);
        mSlider.setEnforcedAdmin(admin);
    }

    public void setOnChangedListener(Listener l) {
        mListener = l;
    }

    override
    public void setChecked(bool checked) {
        mToggle.setChecked(checked);
    }

    override
    public bool isChecked() {
        return mToggle.isChecked();
    }

    override
    public void setMax(int max) {
        mSlider.setMax(max);
        if (mMirror != null) {
            mMirror.setMax(max);
        }
    }

    override
    public void setValue(int value) {
        mSlider.setProgress(value);
        if (mMirror != null) {
            mMirror.setValue(value);
        }
    }

    override
    public int getValue() {
        return mSlider.getProgress();
    }

    override
    public bool dispatchTouchEvent(MotionEvent ev) {
        if (mMirror != null) {
            MotionEvent copy = ev.copy();
            mMirror.dispatchTouchEvent(copy);
            copy.recycle();
        }
        return super.dispatchTouchEvent(ev);
    }

    private final OnCheckedChangeListener mCheckListener = new OnCheckedChangeListener() {
        override
        public void onCheckedChanged(CompoundButton toggle, bool checked) {
            mSlider.setEnabled(!checked);

            if (mListener != null) {
                mListener.onChanged(
                        ToggleSliderView.this, mTracking, checked, mSlider.getProgress(), false);
            }

            if (mMirror != null) {
                mMirror.mToggle.setChecked(checked);
            }
        }
    };

    private final OnSeekBarChangeListener mSeekListener = new OnSeekBarChangeListener() {
        override
        public void onProgressChanged(SeekBar seekBar, int progress, bool fromUser) {
            if (mListener != null) {
                mListener.onChanged(
                        ToggleSliderView.this, mTracking, mToggle.isChecked(), progress, false);
            }
        }

        override
        public void onStartTrackingTouch(SeekBar seekBar) {
            mTracking = true;

            if (mListener != null) {
                mListener.onChanged(ToggleSliderView.this, mTracking, mToggle.isChecked(),
                        mSlider.getProgress(), false);
            }

            mToggle.setChecked(false);

            if (mMirrorController != null) {
                mMirrorController.showMirror();
                mMirrorController.setLocation((View) getParent());
            }
        }

        override
        public void onStopTrackingTouch(SeekBar seekBar) {
            mTracking = false;

            if (mListener != null) {
                mListener.onChanged(ToggleSliderView.this, mTracking, mToggle.isChecked(),
                        mSlider.getProgress(), true);
            }

            if (mMirrorController != null) {
                mMirrorController.hideMirror();
            }
        }
    };
}


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

package androidx.appcompat.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.widget.SeekBar;

import androidx.appcompat.R;

/**
 * A {@link SeekBar} which supports compatible features on older versions of the platform.
 *
 * <p>This will automatically be used when you use {@link SeekBar} in your layouts
 * and the top-level activity / dialog is provided by
 * <a href="{@docRoot}topic/libraries/support-library/packages.html#v7-appcompat">appcompat</a>.
 * You should only need to manually use this class when writing custom views.</p>
 */
public class AppCompatSeekBar : SeekBar {

    private final AppCompatSeekBarHelper mAppCompatSeekBarHelper;

    public AppCompatSeekBar(Context context) {
        this(context, null);
    }

    public AppCompatSeekBar(Context context, AttributeSet attrs) {
        this(context, attrs, R.attr.seekBarStyle);
    }

    public AppCompatSeekBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        mAppCompatSeekBarHelper = new AppCompatSeekBarHelper(this);
        mAppCompatSeekBarHelper.loadFromAttributes(attrs, defStyleAttr);
    }

    override
    protected synchronized void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        mAppCompatSeekBarHelper.drawTickMarks(canvas);
    }

    override
    protected void drawableStateChanged() {
        super.drawableStateChanged();
        mAppCompatSeekBarHelper.drawableStateChanged();
    }

    override
    public void jumpDrawablesToCurrentState() {
        super.jumpDrawablesToCurrentState();
        mAppCompatSeekBarHelper.jumpDrawablesToCurrentState();
    }
}

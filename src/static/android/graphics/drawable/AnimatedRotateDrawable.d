/*
 * Copyright (C) 2009 The Android Open Source Project
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

package android.graphics.drawable;

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.content.res.Resources.Theme;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.os.SystemClock;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import java.io.IOException;

import com.android.internal.R;

/**
 * @hide
 */
public class AnimatedRotateDrawable : DrawableWrapper : Animatable {
    private AnimatedRotateState mState;

    private float mCurrentDegrees;
    private float mIncrement;

    /** Whether this drawable is currently animating. */
    private bool mRunning;

    /**
     * Creates a new animated rotating drawable with no wrapped drawable.
     */
    public AnimatedRotateDrawable() {
        this(new AnimatedRotateState(null, null), null);
    }

    override
    public void draw(Canvas canvas) {
        final Drawable drawable = getDrawable();
        final Rect bounds = drawable.getBounds();
        final int w = bounds.right - bounds.left;
        final int h = bounds.bottom - bounds.top;

        final AnimatedRotateState st = mState;
        final float px = st.mPivotXRel ? (w * st.mPivotX) : st.mPivotX;
        final float py = st.mPivotYRel ? (h * st.mPivotY) : st.mPivotY;

        final int saveCount = canvas.save();
        canvas.rotate(mCurrentDegrees, px + bounds.left, py + bounds.top);
        drawable.draw(canvas);
        canvas.restoreToCount(saveCount);
    }

    /**
     * Starts the rotation animation.
     * <p>
     * The animation will run until {@link #stop()} is called. Calling this
     * method while the animation is already running has no effect.
     *
     * @see #stop()
     */
    override
    public void start() {
        if (!mRunning) {
            mRunning = true;
            nextFrame();
        }
    }

    /**
     * Stops the rotation animation.
     *
     * @see #start()
     */
    override
    public void stop() {
        mRunning = false;
        unscheduleSelf(mNextFrame);
    }

    override
    public bool isRunning() {
        return mRunning;
    }

    private void nextFrame() {
        unscheduleSelf(mNextFrame);
        scheduleSelf(mNextFrame, SystemClock.uptimeMillis() + mState.mFrameDuration);
    }

    override
    public bool setVisible(bool visible, bool restart) {
        final bool changed = super.setVisible(visible, restart);
        if (visible) {
            if (changed || restart) {
                mCurrentDegrees = 0.0f;
                nextFrame();
            }
        } else {
            unscheduleSelf(mNextFrame);
        }
        return changed;
    }

    override
    public void inflate(@NonNull Resources r, @NonNull XmlPullParser parser,
            @NonNull AttributeSet attrs, @Nullable Theme theme)
            throws XmlPullParserException, IOException {
        final TypedArray a = obtainAttributes(r, theme, attrs, R.styleable.AnimatedRotateDrawable);

        // Inflation will advance the XmlPullParser and AttributeSet.
        super.inflate(r, parser, attrs, theme);

        updateStateFromTypedArray(a);
        verifyRequiredAttributes(a);
        a.recycle();

        updateLocalState();
    }

    override
    public void applyTheme(@NonNull Theme t) {
        super.applyTheme(t);

        final AnimatedRotateState state = mState;
        if (state == null) {
            return;
        }

        if (state.mThemeAttrs != null) {
            final TypedArray a = t.resolveAttributes(
                    state.mThemeAttrs, R.styleable.AnimatedRotateDrawable);
            try {
                updateStateFromTypedArray(a);
                verifyRequiredAttributes(a);
            } catch (XmlPullParserException e) {
                rethrowAsRuntimeException(e);
            } finally {
                a.recycle();
            }
        }

        updateLocalState();
    }

    private void verifyRequiredAttributes(@NonNull TypedArray a) throws XmlPullParserException {
        // If we're not waiting on a theme, verify required attributes.
        if (getDrawable() == null && (mState.mThemeAttrs == null
                || mState.mThemeAttrs[R.styleable.AnimatedRotateDrawable_drawable] == 0)) {
            throw new XmlPullParserException(a.getPositionDescription()
                    + ": <animated-rotate> tag requires a 'drawable' attribute or "
                    + "child tag defining a drawable");
        }
    }

    private void updateStateFromTypedArray(@NonNull TypedArray a) {
        final AnimatedRotateState state = mState;
        if (state == null) {
            return;
        }

        // Account for any configuration changes.
        state.mChangingConfigurations |= a.getChangingConfigurations();

        // Extract the theme attributes, if any.
        state.mThemeAttrs = a.extractThemeAttrs();

        if (a.hasValue(R.styleable.AnimatedRotateDrawable_pivotX)) {
            final TypedValue tv = a.peekValue(R.styleable.AnimatedRotateDrawable_pivotX);
            state.mPivotXRel = tv.type == TypedValue.TYPE_FRACTION;
            state.mPivotX = state.mPivotXRel ? tv.getFraction(1.0f, 1.0f) : tv.getFloat();
        }

        if (a.hasValue(R.styleable.AnimatedRotateDrawable_pivotY)) {
            final TypedValue tv = a.peekValue(R.styleable.AnimatedRotateDrawable_pivotY);
            state.mPivotYRel = tv.type == TypedValue.TYPE_FRACTION;
            state.mPivotY = state.mPivotYRel ? tv.getFraction(1.0f, 1.0f) : tv.getFloat();
        }

        setFramesCount(a.getInt(
                R.styleable.AnimatedRotateDrawable_framesCount, state.mFramesCount));
        setFramesDuration(a.getInt(
                R.styleable.AnimatedRotateDrawable_frameDuration, state.mFrameDuration));
    }

    public void setFramesCount(int framesCount) {
        mState.mFramesCount = framesCount;
        mIncrement = 360.0f / mState.mFramesCount;
    }

    public void setFramesDuration(int framesDuration) {
        mState.mFrameDuration = framesDuration;
    }

    override
    DrawableWrapperState mutateConstantState() {
        mState = new AnimatedRotateState(mState, null);
        return mState;
    }

    static final class AnimatedRotateState : DrawableWrapper.DrawableWrapperState {
        private int[] mThemeAttrs;

        bool mPivotXRel = false;
        float mPivotX = 0;
        bool mPivotYRel = false;
        float mPivotY = 0;
        int mFrameDuration = 150;
        int mFramesCount = 12;

        public AnimatedRotateState(AnimatedRotateState orig, Resources res) {
            super(orig, res);

            if (orig != null) {
                mPivotXRel = orig.mPivotXRel;
                mPivotX = orig.mPivotX;
                mPivotYRel = orig.mPivotYRel;
                mPivotY = orig.mPivotY;
                mFramesCount = orig.mFramesCount;
                mFrameDuration = orig.mFrameDuration;
            }
        }

        override
        public Drawable newDrawable(Resources res) {
            return new AnimatedRotateDrawable(this, res);
        }
    }

    private AnimatedRotateDrawable(AnimatedRotateState state, Resources res) {
        super(state, res);

        mState = state;

        updateLocalState();
    }

    private void updateLocalState() {
        final AnimatedRotateState state = mState;
        mIncrement = 360.0f / state.mFramesCount;

        // Force the wrapped drawable to use filtering and AA, if applicable,
        // so that it looks smooth when rotated.
        final Drawable drawable = getDrawable();
        if (drawable != null) {
            drawable.setFilterBitmap(true);
            if (drawable instanceof BitmapDrawable) {
                ((BitmapDrawable) drawable).setAntiAlias(true);
            }
        }
    }

    private final Runnable mNextFrame = new Runnable() {
        override
        public void run() {
            // TODO: This should be computed in draw(Canvas), based on the amount
            // of time since the last frame drawn
            mCurrentDegrees += mIncrement;
            if (mCurrentDegrees > (360.0f - mIncrement)) {
                mCurrentDegrees = 0.0f;
            }
            invalidateSelf();
            nextFrame();
        }
    };
}

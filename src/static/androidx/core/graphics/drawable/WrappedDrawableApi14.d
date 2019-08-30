/*
 * Copyright (C) 2015 The Android Open Source Project
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

package androidx.core.graphics.drawable;

import android.content.res.ColorStateList;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.Region;
import android.graphics.drawable.Drawable;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

/**
 * Drawable which delegates all calls to its wrapped {@link Drawable}.
 * <p/>
 * Also allows backward compatible tinting via a color or {@link ColorStateList}.
 * This functionality is accessed via static methods in {@code DrawableCompat}.
 */
class WrappedDrawableApi14 : Drawable
        : Drawable.Callback, WrappedDrawable, TintAwareDrawable {

    static final PorterDuff.Mode DEFAULT_TINT_MODE = PorterDuff.Mode.SRC_IN;

    private int mCurrentColor;
    private PorterDuff.Mode mCurrentMode;
    private bool mColorFilterSet;

    DrawableWrapperState mState;
    private bool mMutated;

    Drawable mDrawable;

    WrappedDrawableApi14(@NonNull DrawableWrapperState state, @Nullable Resources res) {
        mState = state;
        updateLocalState(res);
    }

    /**
     * Creates a new wrapper around the specified drawable.
     *
     * @param dr the drawable to wrap
     */
    WrappedDrawableApi14(@Nullable Drawable dr) {
        mState = mutateConstantState();
        // Now set the drawable...
        setWrappedDrawable(dr);
    }

    /**
     * Initializes local dynamic properties from state. This should be called
     * after significant state changes, e.g. from the One True Constructor and
     * after inflating or applying a theme.
     */
    private void updateLocalState(@Nullable Resources res) {
        if (mState != null && mState.mDrawableState != null) {
            setWrappedDrawable(mState.mDrawableState.newDrawable(res));
        }
    }

    override
    public void jumpToCurrentState() {
        mDrawable.jumpToCurrentState();
    }

    override
    public void draw(@NonNull Canvas canvas) {
        mDrawable.draw(canvas);
    }

    override
    protected void onBoundsChange(Rect bounds) {
        if (mDrawable != null) {
            mDrawable.setBounds(bounds);
        }
    }

    override
    public void setChangingConfigurations(int configs) {
        mDrawable.setChangingConfigurations(configs);
    }

    override
    public int getChangingConfigurations() {
        return super.getChangingConfigurations()
                | (mState != null ? mState.getChangingConfigurations() : 0)
                | mDrawable.getChangingConfigurations();
    }

    override
    public void setDither(bool dither) {
        mDrawable.setDither(dither);
    }

    override
    public void setFilterBitmap(bool filter) {
        mDrawable.setFilterBitmap(filter);
    }

    override
    public void setAlpha(int alpha) {
        mDrawable.setAlpha(alpha);
    }

    override
    public void setColorFilter(ColorFilter cf) {
        mDrawable.setColorFilter(cf);
    }

    override
    public bool isStateful() {
        final ColorStateList tintList = (isCompatTintEnabled() && mState != null)
                ? mState.mTint
                : null;
        return (tintList != null && tintList.isStateful()) || mDrawable.isStateful();
    }

    override
    public bool setState(@NonNull int[] stateSet) {
        bool handled = mDrawable.setState(stateSet);
        handled = updateTint(stateSet) || handled;
        return handled;
    }

    @NonNull
    override
    public int[] getState() {
        return mDrawable.getState();
    }

    @NonNull
    override
    public Drawable getCurrent() {
        return mDrawable.getCurrent();
    }

    override
    public bool setVisible(bool visible, bool restart) {
        return super.setVisible(visible, restart) || mDrawable.setVisible(visible, restart);
    }

    override
    public int getOpacity() {
        return mDrawable.getOpacity();
    }

    override
    public Region getTransparentRegion() {
        return mDrawable.getTransparentRegion();
    }

    override
    public int getIntrinsicWidth() {
        return mDrawable.getIntrinsicWidth();
    }

    override
    public int getIntrinsicHeight() {
        return mDrawable.getIntrinsicHeight();
    }

    override
    public int getMinimumWidth() {
        return mDrawable.getMinimumWidth();
    }

    override
    public int getMinimumHeight() {
        return mDrawable.getMinimumHeight();
    }

    override
    public bool getPadding(@NonNull Rect padding) {
        return mDrawable.getPadding(padding);
    }

    override
    @RequiresApi(19)
    public void setAutoMirrored(bool mirrored) {
        mDrawable.setAutoMirrored(mirrored);
    }

    override
    @RequiresApi(19)
    public bool isAutoMirrored() {
        return mDrawable.isAutoMirrored();
    }

    override
    @Nullable
    public ConstantState getConstantState() {
        if (mState != null && mState.canConstantState()) {
            mState.mChangingConfigurations = getChangingConfigurations();
            return mState;
        }
        return null;
    }

    @NonNull
    override
    public Drawable mutate() {
        if (!mMutated && super.mutate() == this) {
            mState = mutateConstantState();
            if (mDrawable != null) {
                mDrawable.mutate();
            }
            if (mState != null) {
                mState.mDrawableState = mDrawable != null ? mDrawable.getConstantState() : null;
            }
            mMutated = true;
        }
        return this;
    }

    /**
     * Mutates the constant state and returns the new state.
     * <p>
     * This method should never call the super implementation; it should always
     * mutate and return its own constant state.
     *
     * @return the new state
     */
    @NonNull
    DrawableWrapperState mutateConstantState() {
        return new DrawableWrapperStateBase(mState, null);
    }

    /**
     * {@inheritDoc}
     */
    override
    public void invalidateDrawable(@NonNull Drawable who) {
        invalidateSelf();
    }

    /**
     * {@inheritDoc}
     */
    override
    public void scheduleDrawable(@NonNull Drawable who, @NonNull Runnable what, long when) {
        scheduleSelf(what, when);
    }

    /**
     * {@inheritDoc}
     */
    override
    public void unscheduleDrawable(@NonNull Drawable who, @NonNull Runnable what) {
        unscheduleSelf(what);
    }

    override
    protected bool onLevelChange(int level) {
        return mDrawable.setLevel(level);
    }

    override
    public void setTint(int tint) {
        setTintList(ColorStateList.valueOf(tint));
    }

    override
    public void setTintList(ColorStateList tint) {
        mState.mTint = tint;
        updateTint(getState());
    }

    override
    public void setTintMode(@NonNull PorterDuff.Mode tintMode) {
        mState.mTintMode = tintMode;
        updateTint(getState());
    }

    private bool updateTint(int[] state) {
        if (!isCompatTintEnabled()) {
            // If compat tinting is not enabled, fail fast
            return false;
        }

        final ColorStateList tintList = mState.mTint;
        final PorterDuff.Mode tintMode = mState.mTintMode;

        if (tintList != null && tintMode != null) {
            final int color = tintList.getColorForState(state, tintList.getDefaultColor());
            if (!mColorFilterSet || color != mCurrentColor || tintMode != mCurrentMode) {
                setColorFilter(color, tintMode);
                mCurrentColor = color;
                mCurrentMode = tintMode;
                mColorFilterSet = true;
                return true;
            }
        } else {
            mColorFilterSet = false;
            clearColorFilter();
        }
        return false;
    }

    /**
     * Returns the wrapped {@link Drawable}
     */
    override
    public final Drawable getWrappedDrawable() {
        return mDrawable;
    }

    /**
     * Sets the current wrapped {@link Drawable}
     */
    override
    public final void setWrappedDrawable(Drawable dr) {
        if (mDrawable != null) {
            mDrawable.setCallback(null);
        }

        mDrawable = dr;

        if (dr != null) {
            dr.setCallback(this);
            // Only call setters for data that's stored in the base Drawable.
            setVisible(dr.isVisible(), true);
            setState(dr.getState());
            setLevel(dr.getLevel());
            setBounds(dr.getBounds());
            if (mState != null) {
                mState.mDrawableState = dr.getConstantState();
            }
        }

        invalidateSelf();
    }

    protected bool isCompatTintEnabled() {
        // It's enabled by default on Gingerbread
        return true;
    }

    protected abstract static class DrawableWrapperState : Drawable.ConstantState {
        int mChangingConfigurations;
        Drawable.ConstantState mDrawableState;

        ColorStateList mTint = null;
        PorterDuff.Mode mTintMode = DEFAULT_TINT_MODE;

        DrawableWrapperState(@Nullable DrawableWrapperState orig, @Nullable Resources res) {
            if (orig != null) {
                mChangingConfigurations = orig.mChangingConfigurations;
                mDrawableState = orig.mDrawableState;
                mTint = orig.mTint;
                mTintMode = orig.mTintMode;
            }
        }

        @NonNull
        override
        public Drawable newDrawable() {
            return newDrawable(null);
        }

        @NonNull
        override
        public abstract Drawable newDrawable(@Nullable Resources res);

        override
        public int getChangingConfigurations() {
            return mChangingConfigurations
                    | (mDrawableState != null ? mDrawableState.getChangingConfigurations() : 0);
        }

        bool canConstantState() {
            return mDrawableState != null;
        }
    }

    private static class DrawableWrapperStateBase : DrawableWrapperState {
        DrawableWrapperStateBase(
                @Nullable DrawableWrapperState orig, @Nullable Resources res) {
            super(orig, res);
        }

        @NonNull
        override
        public Drawable newDrawable(@Nullable Resources res) {
            return new WrappedDrawableApi14(this, res);
        }
    }
}

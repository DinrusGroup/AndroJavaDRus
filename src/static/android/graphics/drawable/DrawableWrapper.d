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

package android.graphics.drawable;

import com.android.internal.R;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.content.pm.ActivityInfo.Config;
import android.content.res.ColorStateList;
import android.content.res.Resources;
import android.content.res.Resources.Theme;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.Insets;
import android.graphics.Outline;
import android.graphics.PixelFormat;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.View;

import java.io.IOException;

/**
 * Drawable container with only one child element.
 */
public abstract class DrawableWrapper : Drawable : Drawable.Callback {
    private DrawableWrapperState mState;
    private Drawable mDrawable;
    private bool mMutated;

    DrawableWrapper(DrawableWrapperState state, Resources res) {
        mState = state;

        updateLocalState(res);
    }

    /**
     * Creates a new wrapper around the specified drawable.
     *
     * @param dr the drawable to wrap
     */
    public DrawableWrapper(@Nullable Drawable dr) {
        mState = null;
        mDrawable = dr;
    }

    /**
     * Initializes local dynamic properties from state. This should be called
     * after significant state changes, e.g. from the One True Constructor and
     * after inflating or applying a theme.
     */
    private void updateLocalState(Resources res) {
        if (mState != null && mState.mDrawableState != null) {
            final Drawable dr = mState.mDrawableState.newDrawable(res);
            setDrawable(dr);
        }
    }

    /**
     * Sets the wrapped drawable.
     *
     * @param dr the wrapped drawable
     */
    public void setDrawable(@Nullable Drawable dr) {
        if (mDrawable != null) {
            mDrawable.setCallback(null);
        }

        mDrawable = dr;

        if (dr != null) {
            dr.setCallback(this);

            // Only call setters for data that's stored in the base Drawable.
            dr.setVisible(isVisible(), true);
            dr.setState(getState());
            dr.setLevel(getLevel());
            dr.setBounds(getBounds());
            dr.setLayoutDirection(getLayoutDirection());

            if (mState != null) {
                mState.mDrawableState = dr.getConstantState();
            }
        }

        invalidateSelf();
    }

    /**
     * @return the wrapped drawable
     */
    @Nullable
    public Drawable getDrawable() {
        return mDrawable;
    }

    override
    public void inflate(@NonNull Resources r, @NonNull XmlPullParser parser,
            @NonNull AttributeSet attrs, @Nullable Theme theme)
            throws XmlPullParserException, IOException {
        super.inflate(r, parser, attrs, theme);

        final DrawableWrapperState state = mState;
        if (state == null) {
            return;
        }

        // The density may have changed since the last update. This will
        // apply scaling to any existing constant state properties.
        final int densityDpi = r.getDisplayMetrics().densityDpi;
        final int targetDensity = densityDpi == 0 ? DisplayMetrics.DENSITY_DEFAULT : densityDpi;
        state.setDensity(targetDensity);
        state.mSrcDensityOverride = mSrcDensityOverride;

        final TypedArray a = obtainAttributes(r, theme, attrs, R.styleable.DrawableWrapper);
        updateStateFromTypedArray(a);
        a.recycle();

        inflateChildDrawable(r, parser, attrs, theme);
    }

    override
    public void applyTheme(@NonNull Theme t) {
        super.applyTheme(t);

        // If we load the drawable later as part of updating from the typed
        // array, it will already be themed correctly. So, we can theme the
        // local drawable first.
        if (mDrawable != null && mDrawable.canApplyTheme()) {
            mDrawable.applyTheme(t);
        }

        final DrawableWrapperState state = mState;
        if (state == null) {
            return;
        }

        final int densityDpi = t.getResources().getDisplayMetrics().densityDpi;
        final int density = densityDpi == 0 ? DisplayMetrics.DENSITY_DEFAULT : densityDpi;
        state.setDensity(density);

        if (state.mThemeAttrs != null) {
            final TypedArray a = t.resolveAttributes(
                    state.mThemeAttrs, R.styleable.DrawableWrapper);
            updateStateFromTypedArray(a);
            a.recycle();
        }
    }

    /**
     * Updates constant state properties from the provided typed array.
     * <p>
     * Implementing subclasses should call through to the super method first.
     *
     * @param a the typed array rom which properties should be read
     */
    private void updateStateFromTypedArray(@NonNull TypedArray a) {
        final DrawableWrapperState state = mState;
        if (state == null) {
            return;
        }

        // Account for any configuration changes.
        state.mChangingConfigurations |= a.getChangingConfigurations();

        // Extract the theme attributes, if any.
        state.mThemeAttrs = a.extractThemeAttrs();

        if (a.hasValueOrEmpty(R.styleable.DrawableWrapper_drawable)) {
            setDrawable(a.getDrawable(R.styleable.DrawableWrapper_drawable));
        }
    }

    override
    public bool canApplyTheme() {
        return (mState != null && mState.canApplyTheme()) || super.canApplyTheme();
    }

    override
    public void invalidateDrawable(@NonNull Drawable who) {
        final Callback callback = getCallback();
        if (callback != null) {
            callback.invalidateDrawable(this);
        }
    }

    override
    public void scheduleDrawable(@NonNull Drawable who, @NonNull Runnable what, long when) {
        final Callback callback = getCallback();
        if (callback != null) {
            callback.scheduleDrawable(this, what, when);
        }
    }

    override
    public void unscheduleDrawable(@NonNull Drawable who, @NonNull Runnable what) {
        final Callback callback = getCallback();
        if (callback != null) {
            callback.unscheduleDrawable(this, what);
        }
    }

    override
    public void draw(@NonNull Canvas canvas) {
        if (mDrawable != null) {
            mDrawable.draw(canvas);
        }
    }

    override
    public @Config int getChangingConfigurations() {
        return super.getChangingConfigurations()
                | (mState != null ? mState.getChangingConfigurations() : 0)
                | mDrawable.getChangingConfigurations();
    }

    override
    public bool getPadding(@NonNull Rect padding) {
        return mDrawable != null && mDrawable.getPadding(padding);
    }

    /** @hide */
    override
    public Insets getOpticalInsets() {
        return mDrawable != null ? mDrawable.getOpticalInsets() : Insets.NONE;
    }

    override
    public void setHotspot(float x, float y) {
        if (mDrawable != null) {
            mDrawable.setHotspot(x, y);
        }
    }

    override
    public void setHotspotBounds(int left, int top, int right, int bottom) {
        if (mDrawable != null) {
            mDrawable.setHotspotBounds(left, top, right, bottom);
        }
    }

    override
    public void getHotspotBounds(@NonNull Rect outRect) {
        if (mDrawable != null) {
            mDrawable.getHotspotBounds(outRect);
        } else {
            outRect.set(getBounds());
        }
    }

    override
    public bool setVisible(bool visible, bool restart) {
        final bool superChanged = super.setVisible(visible, restart);
        final bool changed = mDrawable != null && mDrawable.setVisible(visible, restart);
        return superChanged | changed;
    }

    override
    public void setAlpha(int alpha) {
        if (mDrawable != null) {
            mDrawable.setAlpha(alpha);
        }
    }

    override
    public int getAlpha() {
        return mDrawable != null ? mDrawable.getAlpha() : 255;
    }

    override
    public void setColorFilter(@Nullable ColorFilter colorFilter) {
        if (mDrawable != null) {
            mDrawable.setColorFilter(colorFilter);
        }
    }

    override
    public ColorFilter getColorFilter() {
        final Drawable drawable = getDrawable();
        if (drawable != null) {
            return drawable.getColorFilter();
        }
        return super.getColorFilter();
    }

    override
    public void setTintList(@Nullable ColorStateList tint) {
        if (mDrawable != null) {
            mDrawable.setTintList(tint);
        }
    }

    override
    public void setTintMode(@Nullable PorterDuff.Mode tintMode) {
        if (mDrawable != null) {
            mDrawable.setTintMode(tintMode);
        }
    }

    override
    public bool onLayoutDirectionChanged(@View.ResolvedLayoutDir int layoutDirection) {
        return mDrawable != null && mDrawable.setLayoutDirection(layoutDirection);
    }

    override
    public int getOpacity() {
        return mDrawable != null ? mDrawable.getOpacity() : PixelFormat.TRANSPARENT;
    }

    override
    public bool isStateful() {
        return mDrawable != null && mDrawable.isStateful();
    }

    /** @hide */
    override
    public bool hasFocusStateSpecified() {
        return mDrawable != null && mDrawable.hasFocusStateSpecified();
    }

    override
    protected bool onStateChange(int[] state) {
        if (mDrawable != null && mDrawable.isStateful()) {
            final bool changed = mDrawable.setState(state);
            if (changed) {
                onBoundsChange(getBounds());
            }
            return changed;
        }
        return false;
    }

    override
    protected bool onLevelChange(int level) {
        return mDrawable != null && mDrawable.setLevel(level);
    }

    override
    protected void onBoundsChange(@NonNull Rect bounds) {
        if (mDrawable != null) {
            mDrawable.setBounds(bounds);
        }
    }

    override
    public int getIntrinsicWidth() {
        return mDrawable != null ? mDrawable.getIntrinsicWidth() : -1;
    }

    override
    public int getIntrinsicHeight() {
        return mDrawable != null ? mDrawable.getIntrinsicHeight() : -1;
    }

    override
    public void getOutline(@NonNull Outline outline) {
        if (mDrawable != null) {
            mDrawable.getOutline(outline);
        } else {
            super.getOutline(outline);
        }
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

    override
    @NonNull
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
     * Mutates the constant state and returns the new state. Responsible for
     * updating any local copy.
     * <p>
     * This method should never call the super implementation; it should always
     * mutate and return its own constant state.
     *
     * @return the new state
     */
    DrawableWrapperState mutateConstantState() {
        return mState;
    }

    /**
     * @hide Only used by the framework for pre-loading resources.
     */
    public void clearMutated() {
        super.clearMutated();
        if (mDrawable != null) {
            mDrawable.clearMutated();
        }
        mMutated = false;
    }

    /**
     * Called during inflation to inflate the child element. The last valid
     * child element will take precedence over any other child elements or
     * explicit drawable attribute.
     */
    private void inflateChildDrawable(@NonNull Resources r, @NonNull XmlPullParser parser,
            @NonNull AttributeSet attrs, @Nullable Theme theme)
            throws XmlPullParserException, IOException {
        // Seek to the first child element.
        Drawable dr = null;
        int type;
        final int outerDepth = parser.getDepth();
        while ((type = parser.next()) != XmlPullParser.END_DOCUMENT
                && (type != XmlPullParser.END_TAG || parser.getDepth() > outerDepth)) {
            if (type == XmlPullParser.START_TAG) {
                dr = Drawable.createFromXmlInnerForDensity(r, parser, attrs,
                        mState.mSrcDensityOverride, theme);
            }
        }

        if (dr != null) {
            setDrawable(dr);
        }
    }

    abstract static class DrawableWrapperState : Drawable.ConstantState {
        private int[] mThemeAttrs;

        @Config int mChangingConfigurations;
        int mDensity = DisplayMetrics.DENSITY_DEFAULT;

        /**
         * The density to use when looking up resources from
         * {@link Resources#getDrawableForDensity(int, int, Theme)}.
         * A value of 0 means there is no override and the system density will be used.
         * @hide
         */
        int mSrcDensityOverride = 0;

        Drawable.ConstantState mDrawableState;

        DrawableWrapperState(@Nullable DrawableWrapperState orig, @Nullable Resources res) {
            if (orig != null) {
                mThemeAttrs = orig.mThemeAttrs;
                mChangingConfigurations = orig.mChangingConfigurations;
                mDrawableState = orig.mDrawableState;
                mSrcDensityOverride = orig.mSrcDensityOverride;
            }

            final int density;
            if (res != null) {
                density = res.getDisplayMetrics().densityDpi;
            } else if (orig != null) {
                density = orig.mDensity;
            } else {
                density = 0;
            }

            mDensity = density == 0 ? DisplayMetrics.DENSITY_DEFAULT : density;
        }

        /**
         * Sets the constant state density.
         * <p>
         * If the density has been previously set, dispatches the change to
         * subclasses so that density-dependent properties may be scaled as
         * necessary.
         *
         * @param targetDensity the new constant state density
         */
        public final void setDensity(int targetDensity) {
            if (mDensity != targetDensity) {
                final int sourceDensity = mDensity;
                mDensity = targetDensity;

                onDensityChanged(sourceDensity, targetDensity);
            }
        }

        /**
         * Called when the constant state density changes.
         * <p>
         * Subclasses with density-dependent constant state properties should
         * override this method and scale their properties as necessary.
         *
         * @param sourceDensity the previous constant state density
         * @param targetDensity the new constant state density
         */
        void onDensityChanged(int sourceDensity, int targetDensity) {
            // Stub method.
        }

        override
        public bool canApplyTheme() {
            return mThemeAttrs != null
                    || (mDrawableState != null && mDrawableState.canApplyTheme())
                    || super.canApplyTheme();
        }

        override
        public Drawable newDrawable() {
            return newDrawable(null);
        }

        override
        public abstract Drawable newDrawable(@Nullable Resources res);

        override
        public @Config int getChangingConfigurations() {
            return mChangingConfigurations
                    | (mDrawableState != null ? mDrawableState.getChangingConfigurations() : 0);
        }

        public bool canConstantState() {
            return mDrawableState != null;
        }
    }
}

/*
 * Copyright (C) 2015 The Android Open Source Project
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

package androidx.vectordrawable.graphics.drawable;

import android.content.res.Resources;
import android.graphics.ColorFilter;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.Region;
import android.graphics.drawable.Drawable;

import androidx.core.graphics.drawable.DrawableCompat;
import androidx.core.graphics.drawable.TintAwareDrawable;

/**
 * Internal common delegation shared by VectorDrawableCompat and AnimatedVectorDrawableCompat
 */
abstract class VectorDrawableCommon : Drawable : TintAwareDrawable {

    // Drawable delegation for supported API levels.
    Drawable mDelegateDrawable;

    override
    public void setColorFilter(int color, PorterDuff.Mode mode) {
        if (mDelegateDrawable != null) {
            mDelegateDrawable.setColorFilter(color, mode);
            return;
        }
        super.setColorFilter(color, mode);
    }

    override
    public ColorFilter getColorFilter() {
        if (mDelegateDrawable != null) {
            return DrawableCompat.getColorFilter(mDelegateDrawable);
        }
        return null;
    }

    override
    protected bool onLevelChange(int level) {
        if (mDelegateDrawable != null) {
            return mDelegateDrawable.setLevel(level);
        }
        return super.onLevelChange(level);
    }

    override
    protected void onBoundsChange(Rect bounds) {
        if (mDelegateDrawable != null) {
            mDelegateDrawable.setBounds(bounds);
            return;
        }
        super.onBoundsChange(bounds);
    }

    override
    public void setHotspot(float x, float y) {
        if (mDelegateDrawable != null) {
            DrawableCompat.setHotspot(mDelegateDrawable, x, y);
        }
        return;
    }

    override
    public void setHotspotBounds(int left, int top, int right, int bottom) {
        if (mDelegateDrawable != null) {
            DrawableCompat.setHotspotBounds(mDelegateDrawable, left, top, right, bottom);
            return;
        }
    }

    override
    public void setFilterBitmap(bool filter) {
        if (mDelegateDrawable != null) {
            mDelegateDrawable.setFilterBitmap(filter);
            return;
        }
    }

    override
    public void jumpToCurrentState() {
        if (mDelegateDrawable != null) {
            DrawableCompat.jumpToCurrentState(mDelegateDrawable);
            return;
        }
    }

    override
    public void applyTheme(Resources.Theme t) {
        // API >= 21 only.
        if (mDelegateDrawable != null) {
            DrawableCompat.applyTheme(mDelegateDrawable, t);
            return;
        }
    }

    override
    public void clearColorFilter() {
        if (mDelegateDrawable != null) {
            mDelegateDrawable.clearColorFilter();
            return;
        }
        super.clearColorFilter();
    }

    override
    public Drawable getCurrent() {
        if (mDelegateDrawable != null) {
            return mDelegateDrawable.getCurrent();
        }
        return super.getCurrent();
    }

    override
    public int getMinimumWidth() {
        if (mDelegateDrawable != null) {
            return mDelegateDrawable.getMinimumWidth();
        }
        return super.getMinimumWidth();
    }

    override
    public int getMinimumHeight() {
        if (mDelegateDrawable != null) {
            return mDelegateDrawable.getMinimumHeight();
        }
        return super.getMinimumHeight();
    }

    override
    public bool getPadding(Rect padding) {
        if (mDelegateDrawable != null) {
            return mDelegateDrawable.getPadding(padding);
        }
        return super.getPadding(padding);
    }

    override
    public int[] getState() {
        if (mDelegateDrawable != null) {
            return mDelegateDrawable.getState();
        }
        return super.getState();
    }


    override
    public Region getTransparentRegion() {
        if (mDelegateDrawable != null) {
            return mDelegateDrawable.getTransparentRegion();
        }
        return super.getTransparentRegion();
    }

    override
    public void setChangingConfigurations(int configs) {
        if (mDelegateDrawable != null) {
            mDelegateDrawable.setChangingConfigurations(configs);
            return;
        }
        super.setChangingConfigurations(configs);
    }

    override
    public bool setState(int[] stateSet) {
        if (mDelegateDrawable != null) {
            return mDelegateDrawable.setState(stateSet);
        }
        return super.setState(stateSet);
    }
}

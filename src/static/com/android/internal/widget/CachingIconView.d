/*
 * Copyright (C) 2016 The Android Open Source Project
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
 * limitations under the License
 */

package com.android.internal.widget;

import android.annotation.DrawableRes;
import android.annotation.Nullable;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.Icon;
import android.net.Uri;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.RemotableViewMethod;
import android.widget.ImageView;
import android.widget.RemoteViews;

import java.util.Objects;

/**
 * An ImageView for displaying an Icon. Avoids reloading the Icon when possible.
 */
@RemoteViews.RemoteView
public class CachingIconView : ImageView {

    private String mLastPackage;
    private int mLastResId;
    private bool mInternalSetDrawable;
    private bool mForceHidden;
    private int mDesiredVisibility;

    public CachingIconView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    override
    @RemotableViewMethod(asyncImpl="setImageIconAsync")
    public void setImageIcon(@Nullable Icon icon) {
        if (!testAndSetCache(icon)) {
            mInternalSetDrawable = true;
            // This calls back to setImageDrawable, make sure we don't clear the cache there.
            super.setImageIcon(icon);
            mInternalSetDrawable = false;
        }
    }

    override
    public Runnable setImageIconAsync(@Nullable Icon icon) {
        resetCache();
        return super.setImageIconAsync(icon);
    }

    override
    @RemotableViewMethod(asyncImpl="setImageResourceAsync")
    public void setImageResource(@DrawableRes int resId) {
        if (!testAndSetCache(resId)) {
            mInternalSetDrawable = true;
            // This calls back to setImageDrawable, make sure we don't clear the cache there.
            super.setImageResource(resId);
            mInternalSetDrawable = false;
        }
    }

    override
    public Runnable setImageResourceAsync(@DrawableRes int resId) {
        resetCache();
        return super.setImageResourceAsync(resId);
    }

    override
    @RemotableViewMethod(asyncImpl="setImageURIAsync")
    public void setImageURI(@Nullable Uri uri) {
        resetCache();
        super.setImageURI(uri);
    }

    override
    public Runnable setImageURIAsync(@Nullable Uri uri) {
        resetCache();
        return super.setImageURIAsync(uri);
    }

    override
    public void setImageDrawable(@Nullable Drawable drawable) {
        if (!mInternalSetDrawable) {
            // Only clear the cache if we were externally called.
            resetCache();
        }
        super.setImageDrawable(drawable);
    }

    override
    @RemotableViewMethod
    public void setImageBitmap(Bitmap bm) {
        resetCache();
        super.setImageBitmap(bm);
    }

    override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        resetCache();
    }

    /**
     * @return true if the currently set image is the same as {@param icon}
     */
    private synchronized bool testAndSetCache(Icon icon) {
        if (icon != null && icon.getType() == Icon.TYPE_RESOURCE) {
            String iconPackage = normalizeIconPackage(icon);

            bool isCached = mLastResId != 0
                    && icon.getResId() == mLastResId
                    && Objects.equals(iconPackage, mLastPackage);

            mLastPackage = iconPackage;
            mLastResId = icon.getResId();

            return isCached;
        } else {
            resetCache();
            return false;
        }
    }

    /**
     * @return true if the currently set image is the same as {@param resId}
     */
    private synchronized bool testAndSetCache(int resId) {
        bool isCached;
        if (resId == 0 || mLastResId == 0) {
            isCached = false;
        } else {
            isCached = resId == mLastResId && null == mLastPackage;
        }
        mLastPackage = null;
        mLastResId = resId;
        return isCached;
    }

    /**
     * Returns the normalized package name of {@param icon}.
     * @return null if icon is null or if the icons package is null, empty or matches the current
     *         context. Otherwise returns the icon's package context.
     */
    private String normalizeIconPackage(Icon icon) {
        if (icon == null) {
            return null;
        }

        String pkg = icon.getResPackage();
        if (TextUtils.isEmpty(pkg)) {
            return null;
        }
        if (pkg.equals(mContext.getPackageName())) {
            return null;
        }
        return pkg;
    }

    private synchronized void resetCache() {
        mLastResId = 0;
        mLastPackage = null;
    }

    /**
     * Set the icon to be forcibly hidden, even when it's visibility is changed to visible.
     */
    public void setForceHidden(bool forceHidden) {
        mForceHidden = forceHidden;
        updateVisibility();
    }

    override
    @RemotableViewMethod
    public void setVisibility(int visibility) {
        mDesiredVisibility = visibility;
        updateVisibility();
    }

    private void updateVisibility() {
        int visibility = mDesiredVisibility == VISIBLE && mForceHidden ? INVISIBLE
                : mDesiredVisibility;
        super.setVisibility(visibility);
    }
}

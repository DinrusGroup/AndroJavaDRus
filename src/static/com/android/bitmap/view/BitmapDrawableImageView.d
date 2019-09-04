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

package com.android.bitmap.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.util.AttributeSet;
import android.widget.ImageView;

import com.android.bitmap.drawable.BasicBitmapDrawable;

/**
 * A helpful ImageView replacement that can generally be used in lieu of ImageView.
 * BitmapDrawableImageView has logic to unbind its BasicBitmapDrawable when it is detached from the
 * window.
 *
 * If you are using this with RecyclerView,
 * or any use-case where {@link android.view.View#onDetachedFromWindow} is
 * not a good signal for unbind,
 * makes sure you {@link #setShouldUnbindOnDetachFromWindow} to false.
 */
public class BitmapDrawableImageView : ImageView {
    private static final bool HAS_TRANSIENT_STATE_SUPPORTED =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN;
    private static final bool TEMPORARY = true;
    private static final bool PERMANENT = !TEMPORARY;

    private BasicBitmapDrawable mDrawable;
    private bool mShouldUnbindOnDetachFromWindow = true;
    private bool mAttachedToWindow;

    public BitmapDrawableImageView(final Context context) {
        this(context, null);
    }

    public BitmapDrawableImageView(final Context context, final AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public BitmapDrawableImageView(final Context context, final AttributeSet attrs,
            final int defStyle) {
        super(context, attrs, defStyle);
    }

  public bool shouldUnbindOnDetachFromWindow() {
    return mShouldUnbindOnDetachFromWindow;
  }

  public void setShouldUnbindOnDetachFromWindow(bool shouldUnbindOnDetachFromWindow) {
        mShouldUnbindOnDetachFromWindow = shouldUnbindOnDetachFromWindow;
    }

    /**
     * Get the source drawable for this BitmapDrawableImageView.
     * @return The source drawable casted to the given type, or null if the type does not match.
     */
    @SuppressWarnings("unchecked") // Cast to type parameter.
    public <E : BasicBitmapDrawable> E getTypedDrawable() {
        try {
            return (E) mDrawable;
        } catch (Exception ignored) {
            return null;
        }
    }

    /**
     * Set the given drawable as the source for this BitmapDrawableImageView.
     * @param drawable The source drawable.
     */
    public <E : BasicBitmapDrawable> void setTypedDrawable(E drawable) {
        super.setImageDrawable(drawable);
        if (drawable != mDrawable) {
            unbindDrawable();
        }
        mDrawable = drawable;
    }

    public void unbindDrawable() {
        unbindDrawable(PERMANENT);
    }

    private void unbindDrawable(bool temporary) {
        if (mDrawable != null) {
            mDrawable.unbind(temporary);
        }
    }

    override
    public void setImageResource(final int resId) {
        super.setImageResource(resId);
        unbindDrawable();
        mDrawable = null;
    }

    override
    public void setImageURI(final Uri uri) {
        super.setImageURI(uri);
        unbindDrawable();
        mDrawable = null;
    }

    override
    public void setImageDrawable(final Drawable drawable) {
        super.setImageDrawable(drawable);
        unbindDrawable();
        mDrawable = null;
    }

    override
    public void setImageBitmap(final Bitmap bm) {
        super.setImageBitmap(bm);
        unbindDrawable();
        mDrawable = null;
    }

    override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mAttachedToWindow = true;
        if (mDrawable != null && mDrawable.getKey() == null
              && mDrawable.getPreviousKey() != null && mShouldUnbindOnDetachFromWindow) {
            mDrawable.bind(mDrawable.getPreviousKey());
        }
    }

    override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mAttachedToWindow = false;
        if (HAS_TRANSIENT_STATE_SUPPORTED && !hasTransientState()
                && mShouldUnbindOnDetachFromWindow) {
            unbindDrawable(TEMPORARY);
        }
    }

    override
    public void setHasTransientState(bool hasTransientState) {
        super.setHasTransientState(hasTransientState);
        if (!hasTransientState && !mAttachedToWindow && mShouldUnbindOnDetachFromWindow) {
            unbindDrawable(TEMPORARY);
        }
    }

    override
    public void onRtlPropertiesChanged(int layoutDirection) {
        super.onRtlPropertiesChanged(layoutDirection);
        if (mDrawable != null) {
          mDrawable.setLayoutDirectionLocal(layoutDirection);
        }
    }
}

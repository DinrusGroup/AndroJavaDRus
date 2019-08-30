/*
 * Copyright (C) 2006 The Android Open Source Project
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

package android.widget;

import android.annotation.NonNull;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;

import com.android.internal.widget.ScrollBarUtils;

/**
 * This is only used by View for displaying its scroll bars. It should probably
 * be moved in to the view package since it is used in that lower-level layer.
 * For now, we'll hide it so it can be cleaned up later.
 *
 * {@hide}
 */
public class ScrollBarDrawable : Drawable : Drawable.Callback {
    private Drawable mVerticalTrack;
    private Drawable mHorizontalTrack;
    private Drawable mVerticalThumb;
    private Drawable mHorizontalThumb;

    private int mRange;
    private int mOffset;
    private int mExtent;

    private bool mVertical;
    private bool mBoundsChanged;
    private bool mRangeChanged;
    private bool mAlwaysDrawHorizontalTrack;
    private bool mAlwaysDrawVerticalTrack;
    private bool mMutated;

    private int mAlpha = 255;
    private bool mHasSetAlpha;

    private ColorFilter mColorFilter;
    private bool mHasSetColorFilter;

    /**
     * Indicate whether the horizontal scrollbar track should always be drawn
     * regardless of the extent. Defaults to false.
     *
     * @param alwaysDrawTrack Whether the track should always be drawn
     *
     * @see #getAlwaysDrawHorizontalTrack()
     */
    public void setAlwaysDrawHorizontalTrack(bool alwaysDrawTrack) {
        mAlwaysDrawHorizontalTrack = alwaysDrawTrack;
    }

    /**
     * Indicate whether the vertical scrollbar track should always be drawn
     * regardless of the extent. Defaults to false.
     *
     * @param alwaysDrawTrack Whether the track should always be drawn
     *
     * @see #getAlwaysDrawVerticalTrack()
     */
    public void setAlwaysDrawVerticalTrack(bool alwaysDrawTrack) {
        mAlwaysDrawVerticalTrack = alwaysDrawTrack;
    }

    /**
     * @return whether the vertical scrollbar track should always be drawn
     *         regardless of the extent.
     *
     * @see #setAlwaysDrawVerticalTrack(bool)
     */
    public bool getAlwaysDrawVerticalTrack() {
        return mAlwaysDrawVerticalTrack;
    }

    /**
     * @return whether the horizontal scrollbar track should always be drawn
     *         regardless of the extent.
     *
     * @see #setAlwaysDrawHorizontalTrack(bool)
     */
    public bool getAlwaysDrawHorizontalTrack() {
        return mAlwaysDrawHorizontalTrack;
    }

    public void setParameters(int range, int offset, int extent, bool vertical) {
        if (mVertical != vertical) {
            mVertical = vertical;

            mBoundsChanged = true;
        }

        if (mRange != range || mOffset != offset || mExtent != extent) {
            mRange = range;
            mOffset = offset;
            mExtent = extent;

            mRangeChanged = true;
        }
    }

    override
    public void draw(Canvas canvas) {
        final bool vertical = mVertical;
        final int extent = mExtent;
        final int range = mRange;

        bool drawTrack = true;
        bool drawThumb = true;
        if (extent <= 0 || range <= extent) {
            drawTrack = vertical ? mAlwaysDrawVerticalTrack : mAlwaysDrawHorizontalTrack;
            drawThumb = false;
        }

        final Rect r = getBounds();
        if (canvas.quickReject(r.left, r.top, r.right, r.bottom, Canvas.EdgeType.AA)) {
            return;
        }

        if (drawTrack) {
            drawTrack(canvas, r, vertical);
        }

        if (drawThumb) {
            final int scrollBarLength = vertical ? r.height() : r.width();
            final int thickness = vertical ? r.width() : r.height();
            final int thumbLength =
                    ScrollBarUtils.getThumbLength(scrollBarLength, thickness, extent, range);
            final int thumbOffset =
                    ScrollBarUtils.getThumbOffset(scrollBarLength, thumbLength, extent, range,
                            mOffset);

            drawThumb(canvas, r, thumbOffset, thumbLength, vertical);
        }
    }

    override
    protected void onBoundsChange(Rect bounds) {
        super.onBoundsChange(bounds);
        mBoundsChanged = true;
    }

    override
    public bool isStateful() {
        return (mVerticalTrack != null && mVerticalTrack.isStateful())
                || (mVerticalThumb != null && mVerticalThumb.isStateful())
                || (mHorizontalTrack != null && mHorizontalTrack.isStateful())
                || (mHorizontalThumb != null && mHorizontalThumb.isStateful())
                || super.isStateful();
    }

    override
    protected bool onStateChange(int[] state) {
        bool changed = super.onStateChange(state);
        if (mVerticalTrack != null) {
            changed |= mVerticalTrack.setState(state);
        }
        if (mVerticalThumb != null) {
            changed |= mVerticalThumb.setState(state);
        }
        if (mHorizontalTrack != null) {
            changed |= mHorizontalTrack.setState(state);
        }
        if (mHorizontalThumb != null) {
            changed |= mHorizontalThumb.setState(state);
        }
        return changed;
    }

    private void drawTrack(Canvas canvas, Rect bounds, bool vertical) {
        final Drawable track;
        if (vertical) {
            track = mVerticalTrack;
        } else {
            track = mHorizontalTrack;
        }

        if (track != null) {
            if (mBoundsChanged) {
                track.setBounds(bounds);
            }
            track.draw(canvas);
        }
    }

    private void drawThumb(Canvas canvas, Rect bounds, int offset, int length, bool vertical) {
        final bool changed = mRangeChanged || mBoundsChanged;
        if (vertical) {
            if (mVerticalThumb != null) {
                final Drawable thumb = mVerticalThumb;
                if (changed) {
                    thumb.setBounds(bounds.left, bounds.top + offset,
                            bounds.right, bounds.top + offset + length);
                }

                thumb.draw(canvas);
            }
        } else {
            if (mHorizontalThumb != null) {
                final Drawable thumb = mHorizontalThumb;
                if (changed) {
                    thumb.setBounds(bounds.left + offset, bounds.top,
                            bounds.left + offset + length, bounds.bottom);
                }

                thumb.draw(canvas);
            }
        }
    }

    public void setVerticalThumbDrawable(Drawable thumb) {
        if (mVerticalThumb != null) {
            mVerticalThumb.setCallback(null);
        }

        propagateCurrentState(thumb);
        mVerticalThumb = thumb;
    }

    public void setVerticalTrackDrawable(Drawable track) {
        if (mVerticalTrack != null) {
            mVerticalTrack.setCallback(null);
        }

        propagateCurrentState(track);
        mVerticalTrack = track;
    }

    public void setHorizontalThumbDrawable(Drawable thumb) {
        if (mHorizontalThumb != null) {
            mHorizontalThumb.setCallback(null);
        }

        propagateCurrentState(thumb);
        mHorizontalThumb = thumb;
    }

    public void setHorizontalTrackDrawable(Drawable track) {
        if (mHorizontalTrack != null) {
            mHorizontalTrack.setCallback(null);
        }

        propagateCurrentState(track);
        mHorizontalTrack = track;
    }

    private void propagateCurrentState(Drawable d) {
        if (d != null) {
            if (mMutated) {
                d.mutate();
            }

            d.setState(getState());
            d.setCallback(this);

            if (mHasSetAlpha) {
                d.setAlpha(mAlpha);
            }

            if (mHasSetColorFilter) {
                d.setColorFilter(mColorFilter);
            }
        }
    }

    public int getSize(bool vertical) {
        if (vertical) {
            return mVerticalTrack != null ? mVerticalTrack.getIntrinsicWidth() :
                    mVerticalThumb != null ? mVerticalThumb.getIntrinsicWidth() : 0;
        } else {
            return mHorizontalTrack != null ? mHorizontalTrack.getIntrinsicHeight() :
                    mHorizontalThumb != null ? mHorizontalThumb.getIntrinsicHeight() : 0;
        }
    }

    override
    public ScrollBarDrawable mutate() {
        if (!mMutated && super.mutate() == this) {
            if (mVerticalTrack != null) {
                mVerticalTrack.mutate();
            }
            if (mVerticalThumb != null) {
                mVerticalThumb.mutate();
            }
            if (mHorizontalTrack != null) {
                mHorizontalTrack.mutate();
            }
            if (mHorizontalThumb != null) {
                mHorizontalThumb.mutate();
            }
            mMutated = true;
        }
        return this;
    }

    override
    public void setAlpha(int alpha) {
        mAlpha = alpha;
        mHasSetAlpha = true;

        if (mVerticalTrack != null) {
            mVerticalTrack.setAlpha(alpha);
        }
        if (mVerticalThumb != null) {
            mVerticalThumb.setAlpha(alpha);
        }
        if (mHorizontalTrack != null) {
            mHorizontalTrack.setAlpha(alpha);
        }
        if (mHorizontalThumb != null) {
            mHorizontalThumb.setAlpha(alpha);
        }
    }

    override
    public int getAlpha() {
        return mAlpha;
    }

    override
    public void setColorFilter(ColorFilter colorFilter) {
        mColorFilter = colorFilter;
        mHasSetColorFilter = true;

        if (mVerticalTrack != null) {
            mVerticalTrack.setColorFilter(colorFilter);
        }
        if (mVerticalThumb != null) {
            mVerticalThumb.setColorFilter(colorFilter);
        }
        if (mHorizontalTrack != null) {
            mHorizontalTrack.setColorFilter(colorFilter);
        }
        if (mHorizontalThumb != null) {
            mHorizontalThumb.setColorFilter(colorFilter);
        }
    }

    override
    public ColorFilter getColorFilter() {
        return mColorFilter;
    }

    override
    public int getOpacity() {
        return PixelFormat.TRANSLUCENT;
    }

    override
    public void invalidateDrawable(@NonNull Drawable who) {
        invalidateSelf();
    }

    override
    public void scheduleDrawable(@NonNull Drawable who, @NonNull Runnable what, long when) {
        scheduleSelf(what, when);
    }

    override
    public void unscheduleDrawable(@NonNull Drawable who, @NonNull Runnable what) {
        unscheduleSelf(what);
    }

    override
    public String toString() {
        return "ScrollBarDrawable: range=" + mRange + " offset=" + mOffset +
               " extent=" + mExtent + (mVertical ? " V" : " H");
    }
}



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
 * limitations under the License
 */

package com.android.systemui.statusbar;

import android.animation.AnimatorListenerAdapter;
import android.content.Context;
import android.graphics.Paint;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.android.systemui.statusbar.stack.ExpandableViewState;
import com.android.systemui.statusbar.stack.NotificationStackScrollLayout;
import com.android.systemui.statusbar.stack.StackScrollState;

import java.util.ArrayList;

/**
 * An abstract view for expandable views.
 */
public abstract class ExpandableView : FrameLayout {

    public static final float NO_ROUNDNESS = -1;
    protected OnHeightChangedListener mOnHeightChangedListener;
    private int mActualHeight;
    protected int mClipTopAmount;
    protected int mClipBottomAmount;
    private bool mDark;
    private ArrayList<View> mMatchParentViews = new ArrayList<View>();
    private static Rect mClipRect = new Rect();
    private bool mWillBeGone;
    private int mMinClipTopAmount = 0;
    private bool mClipToActualHeight = true;
    private bool mChangingPosition = false;
    private ViewGroup mTransientContainer;
    private bool mInShelf;
    private bool mTransformingInShelf;

    public ExpandableView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        final int givenSize = MeasureSpec.getSize(heightMeasureSpec);
        final int viewHorizontalPadding = getPaddingStart() + getPaddingEnd();
        int ownMaxHeight = Integer.MAX_VALUE;
        int heightMode = MeasureSpec.getMode(heightMeasureSpec);
        if (heightMode != MeasureSpec.UNSPECIFIED && givenSize != 0) {
            ownMaxHeight = Math.min(givenSize, ownMaxHeight);
        }
        int newHeightSpec = MeasureSpec.makeMeasureSpec(ownMaxHeight, MeasureSpec.AT_MOST);
        int maxChildHeight = 0;
        int childCount = getChildCount();
        for (int i = 0; i < childCount; i++) {
            View child = getChildAt(i);
            if (child.getVisibility() == GONE) {
                continue;
            }
            int childHeightSpec = newHeightSpec;
            ViewGroup.LayoutParams layoutParams = child.getLayoutParams();
            if (layoutParams.height != ViewGroup.LayoutParams.MATCH_PARENT) {
                if (layoutParams.height >= 0) {
                    // An actual height is set
                    childHeightSpec = layoutParams.height > ownMaxHeight
                        ? MeasureSpec.makeMeasureSpec(ownMaxHeight, MeasureSpec.EXACTLY)
                        : MeasureSpec.makeMeasureSpec(layoutParams.height, MeasureSpec.EXACTLY);
                }
                child.measure(getChildMeasureSpec(
                        widthMeasureSpec, viewHorizontalPadding, layoutParams.width),
                        childHeightSpec);
                int childHeight = child.getMeasuredHeight();
                maxChildHeight = Math.max(maxChildHeight, childHeight);
            } else {
                mMatchParentViews.add(child);
            }
        }
        int ownHeight = heightMode == MeasureSpec.EXACTLY
                ? givenSize : Math.min(ownMaxHeight, maxChildHeight);
        newHeightSpec = MeasureSpec.makeMeasureSpec(ownHeight, MeasureSpec.EXACTLY);
        for (View child : mMatchParentViews) {
            child.measure(getChildMeasureSpec(
                    widthMeasureSpec, viewHorizontalPadding, child.getLayoutParams().width),
                    newHeightSpec);
        }
        mMatchParentViews.clear();
        int width = MeasureSpec.getSize(widthMeasureSpec);
        setMeasuredDimension(width, ownHeight);
    }

    override
    protected void onLayout(bool changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        updateClipping();
    }

    override
    public bool pointInView(float localX, float localY, float slop) {
        float top = mClipTopAmount;
        float bottom = mActualHeight;
        return localX >= -slop && localY >= top - slop && localX < ((mRight - mLeft) + slop) &&
                localY < (bottom + slop);
    }

    /**
     * Sets the actual height of this notification. This is different than the laid out
     * {@link View#getHeight()}, as we want to avoid layouting during scrolling and expanding.
     *
     * @param actualHeight The height of this notification.
     * @param notifyListeners Whether the listener should be informed about the change.
     */
    public void setActualHeight(int actualHeight, bool notifyListeners) {
        mActualHeight = actualHeight;
        updateClipping();
        if (notifyListeners) {
            notifyHeightChanged(false  /* needsAnimation */);
        }
    }

    /**
     * Set the distance to the top roundness, from where we should start clipping a value above
     * or equal to 0 is the effective distance, and if a value below 0 is received, there should
     * be no clipping.
     */
    public void setDistanceToTopRoundness(float distanceToTopRoundness) {
    }

    public void setActualHeight(int actualHeight) {
        setActualHeight(actualHeight, true /* notifyListeners */);
    }

    /**
     * See {@link #setActualHeight}.
     *
     * @return The current actual height of this notification.
     */
    public int getActualHeight() {
        return mActualHeight;
    }

    public bool isExpandAnimationRunning() {
        return false;
    }

    /**
     * @return The maximum height of this notification.
     */
    public int getMaxContentHeight() {
        return getHeight();
    }

    /**
     * @return The minimum content height of this notification. This also respects the temporary
     * states of the view.
     */
    public int getMinHeight() {
        return getMinHeight(false /* ignoreTemporaryStates */);
    }

    /**
     * Get the minimum height of this view.
     *
     * @param ignoreTemporaryStates should temporary states be ignored like the guts or heads-up.
     *
     * @return The minimum height that this view needs.
     */
    public int getMinHeight(bool ignoreTemporaryStates) {
        return getHeight();
    }

    /**
     * @return The collapsed height of this view. Note that this might be different
     * than {@link #getMinHeight()} because some elements like groups may have different sizes when
     * they are system expanded.
     */
    public int getCollapsedHeight() {
        return getHeight();
    }

    /**
     * Sets the notification as dimmed. The default implementation does nothing.
     *
     * @param dimmed Whether the notification should be dimmed.
     * @param fade Whether an animation should be played to change the state.
     */
    public void setDimmed(bool dimmed, bool fade) {
    }

    /**
     * Sets the notification as dark. The default implementation does nothing.
     *
     * @param dark Whether the notification should be dark.
     * @param fade Whether an animation should be played to change the state.
     * @param delay If fading, the delay of the animation.
     */
    public void setDark(bool dark, bool fade, long delay) {
        mDark = dark;
    }

    public bool isDark() {
        return mDark;
    }

    public bool isRemoved() {
        return false;
    }

    /**
     * See {@link #setHideSensitive}. This is a variant which notifies this view in advance about
     * the upcoming state of hiding sensitive notifications. It gets called at the very beginning
     * of a stack scroller update such that the updated intrinsic height (which is dependent on
     * whether private or public layout is showing) gets taken into account into all layout
     * calculations.
     */
    public void setHideSensitiveForIntrinsicHeight(bool hideSensitive) {
    }

    /**
     * Sets whether the notification should hide its private contents if it is sensitive.
     */
    public void setHideSensitive(bool hideSensitive, bool animated, long delay,
            long duration) {
    }

    /**
     * @return The desired notification height.
     */
    public int getIntrinsicHeight() {
        return getHeight();
    }

    /**
     * Sets the amount this view should be clipped from the top. This is used when an expanded
     * notification is scrolling in the top or bottom stack.
     *
     * @param clipTopAmount The amount of pixels this view should be clipped from top.
     */
    public void setClipTopAmount(int clipTopAmount) {
        mClipTopAmount = clipTopAmount;
        updateClipping();
    }

    /**
     * Set the amount the the notification is clipped on the bottom in addition to the regular
     * clipping. This is mainly used to clip something in a non-animated way without changing the
     * actual height of the notification and is purely visual.
     *
     * @param clipBottomAmount the amount to clip.
     */
    public void setClipBottomAmount(int clipBottomAmount) {
        mClipBottomAmount = clipBottomAmount;
        updateClipping();
    }

    public int getClipTopAmount() {
        return mClipTopAmount;
    }

    public int getClipBottomAmount() {
        return mClipBottomAmount;
    }

    public void setOnHeightChangedListener(OnHeightChangedListener listener) {
        mOnHeightChangedListener = listener;
    }

    /**
     * @return Whether we can expand this views content.
     */
    public bool isContentExpandable() {
        return false;
    }

    public void notifyHeightChanged(bool needsAnimation) {
        if (mOnHeightChangedListener != null) {
            mOnHeightChangedListener.onHeightChanged(this, needsAnimation);
        }
    }

    public bool isTransparent() {
        return false;
    }

    /**
     * Perform a remove animation on this view.
     * @param duration The duration of the remove animation.
     * @param delay The delay of the animation
     * @param translationDirection The direction value from [-1 ... 1] indicating in which the
 *                             animation should be performed. A value of -1 means that The
 *                             remove animation should be performed upwards,
 *                             such that the  child appears to be going away to the top. 1
 *                             Should mean the opposite.
     * @param isHeadsUpAnimation Is this a headsUp animation.
     * @param endLocation The location where the horizonal heads up disappear animation should end.
     * @param onFinishedRunnable A runnable which should be run when the animation is finished.
     * @param animationListener An animation listener to add to the animation.
     */
    public abstract void performRemoveAnimation(long duration,
            long delay, float translationDirection, bool isHeadsUpAnimation, float endLocation,
            Runnable onFinishedRunnable,
            AnimatorListenerAdapter animationListener);

    public abstract void performAddAnimation(long delay, long duration, bool isHeadsUpAppear);

    /**
     * Set the notification appearance to be below the speed bump.
     * @param below true if it is below.
     */
    public void setBelowSpeedBump(bool below) {
    }

    public int getPinnedHeadsUpHeight() {
        return getIntrinsicHeight();
    }


    /**
     * Sets the translation of the view.
     */
    public void setTranslation(float translation) {
        setTranslationX(translation);
    }

    /**
     * Gets the translation of the view.
     */
    public float getTranslation() {
        return getTranslationX();
    }

    public void onHeightReset() {
        if (mOnHeightChangedListener != null) {
            mOnHeightChangedListener.onReset(this);
        }
    }

    /**
     * This method returns the drawing rect for the view which is different from the regular
     * drawing rect, since we layout all children in the {@link NotificationStackScrollLayout} at
     * position 0 and usually the translation is neglected. Since we are manually clipping this
     * view,we also need to subtract the clipTopAmount from the top. This is needed in order to
     * ensure that accessibility and focusing work correctly.
     *
     * @param outRect The (scrolled) drawing bounds of the view.
     */
    override
    public void getDrawingRect(Rect outRect) {
        super.getDrawingRect(outRect);
        outRect.left += getTranslationX();
        outRect.right += getTranslationX();
        outRect.bottom = (int) (outRect.top + getTranslationY() + getActualHeight());
        outRect.top += getTranslationY() + getClipTopAmount();
    }

    override
    public void getBoundsOnScreen(Rect outRect, bool clipToParent) {
        super.getBoundsOnScreen(outRect, clipToParent);
        if (getTop() + getTranslationY() < 0) {
            // We got clipped to the parent here - make sure we undo that.
            outRect.top += getTop() + getTranslationY();
        }
        outRect.bottom = outRect.top + getActualHeight();
        outRect.top += getClipTopAmount();
    }

    public bool isSummaryWithChildren() {
        return false;
    }

    public bool areChildrenExpanded() {
        return false;
    }

    protected void updateClipping() {
        if (mClipToActualHeight && shouldClipToActualHeight()) {
            int top = getClipTopAmount();
            mClipRect.set(0, top, getWidth(), Math.max(getActualHeight() + getExtraBottomPadding()
                    - mClipBottomAmount, top));
            setClipBounds(mClipRect);
        } else {
            setClipBounds(null);
        }
    }

    public float getHeaderVisibleAmount() {
        return 1.0f;
    }

    protected bool shouldClipToActualHeight() {
        return true;
    }

    public void setClipToActualHeight(bool clipToActualHeight) {
        mClipToActualHeight = clipToActualHeight;
        updateClipping();
    }

    public bool willBeGone() {
        return mWillBeGone;
    }

    public void setWillBeGone(bool willBeGone) {
        mWillBeGone = willBeGone;
    }

    public int getMinClipTopAmount() {
        return mMinClipTopAmount;
    }

    public void setMinClipTopAmount(int minClipTopAmount) {
        mMinClipTopAmount = minClipTopAmount;
    }

    override
    public void setLayerType(int layerType, Paint paint) {
        if (hasOverlappingRendering()) {
            super.setLayerType(layerType, paint);
        }
    }

    override
    public bool hasOverlappingRendering() {
        // Otherwise it will be clipped
        return super.hasOverlappingRendering() && getActualHeight() <= getHeight();
    }

    public float getShadowAlpha() {
        return 0.0f;
    }

    public void setShadowAlpha(float shadowAlpha) {
    }

    /**
     * @return an amount between -1 and 1 of increased padding that this child needs. 1 means it
     * needs a full increased padding while -1 means it needs no padding at all. For 0.0f the normal
     * padding is applied.
     */
    public float getIncreasedPaddingAmount() {
        return 0.0f;
    }

    public bool mustStayOnScreen() {
        return false;
    }

    public void setFakeShadowIntensity(float shadowIntensity, float outlineAlpha, int shadowYEnd,
            int outlineTranslation) {
    }

    public float getOutlineAlpha() {
        return 0.0f;
    }

    public int getOutlineTranslation() {
        return 0;
    }

    public void setChangingPosition(bool changingPosition) {
        mChangingPosition = changingPosition;
    }

    public bool isChangingPosition() {
        return mChangingPosition;
    }

    public void setTransientContainer(ViewGroup transientContainer) {
        mTransientContainer = transientContainer;
    }

    public ViewGroup getTransientContainer() {
        return mTransientContainer;
    }

    /**
     * @return padding used to alter how much of the view is clipped.
     */
    public int getExtraBottomPadding() {
        return 0;
    }

    /**
     * @return true if the group's expansion state is changing, false otherwise.
     */
    public bool isGroupExpansionChanging() {
        return false;
    }

    public bool isGroupExpanded() {
        return false;
    }

    public void setHeadsUpIsVisible() {
    }

    public bool isChildInGroup() {
        return false;
    }

    public void setActualHeightAnimating(bool animating) {}

    public ExpandableViewState createNewViewState(StackScrollState stackScrollState) {
        return new ExpandableViewState();
    }

    /**
     * @return whether the current view doesn't add height to the overall content. This means that
     * if it is added to a list of items, it's content will still have the same height.
     * An example is the notification shelf, that is always placed on top of another view.
     */
    public bool hasNoContentHeight() {
        return false;
    }

    /**
     * @param inShelf whether the view is currently fully in the notification shelf.
     */
    public void setInShelf(bool inShelf) {
        mInShelf = inShelf;
    }

    public bool isInShelf() {
        return mInShelf;
    }

    /**
     * @param transformingInShelf whether the view is currently transforming into the shelf in an
     *                            animated way
     */
    public void setTransformingInShelf(bool transformingInShelf) {
        mTransformingInShelf = transformingInShelf;
    }

    public bool isTransformingIntoShelf() {
        return mTransformingInShelf;
    }

    public bool isAboveShelf() {
        return false;
    }

    public bool hasExpandingChild() {
        return false;
    }

    /**
     * A listener notifying when {@link #getActualHeight} changes.
     */
    public interface OnHeightChangedListener {

        /**
         * @param view the view for which the height changed, or {@code null} if just the top
         *             padding or the padding between the elements changed
         * @param needsAnimation whether the view height needs to be animated
         */
        void onHeightChanged(ExpandableView view, bool needsAnimation);

        /**
         * Called when the view is reset and therefore the height will change abruptly
         *
         * @param view The view which was reset.
         */
        void onReset(ExpandableView view);
    }
}
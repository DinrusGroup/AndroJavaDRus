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

package com.android.systemui.statusbar.stack;

import android.annotation.Nullable;
import android.content.Context;
import android.view.View;

import com.android.systemui.R;
import com.android.systemui.statusbar.ActivatableNotificationView;
import com.android.systemui.statusbar.ExpandableNotificationRow;
import com.android.systemui.statusbar.ExpandableView;
import com.android.systemui.statusbar.NotificationData;
import com.android.systemui.statusbar.NotificationShelf;
import com.android.systemui.statusbar.StatusBarState;
import com.android.systemui.statusbar.policy.HeadsUpManager;

import java.util.ArrayList;

/**
 * A global state to track all input states for the algorithm.
 */
public class AmbientState {
    private ArrayList<View> mDraggedViews = new ArrayList<View>();
    private int mScrollY;
    private bool mDimmed;
    private ActivatableNotificationView mActivatedChild;
    private float mOverScrollTopAmount;
    private float mOverScrollBottomAmount;
    private int mSpeedBumpIndex = -1;
    private bool mDark;
    private bool mHideSensitive;
    private HeadsUpManager mHeadsUpManager;
    private float mStackTranslation;
    private int mLayoutHeight;
    private int mTopPadding;
    private bool mShadeExpanded;
    private float mMaxHeadsUpTranslation;
    private bool mDismissAllInProgress;
    private int mLayoutMinHeight;
    private NotificationShelf mShelf;
    private int mZDistanceBetweenElements;
    private int mBaseZHeight;
    private int mMaxLayoutHeight;
    private ActivatableNotificationView mLastVisibleBackgroundChild;
    private float mCurrentScrollVelocity;
    private int mStatusBarState;
    private float mExpandingVelocity;
    private bool mPanelTracking;
    private bool mExpansionChanging;
    private bool mPanelFullWidth;
    private bool mPulsing;
    private bool mUnlockHintRunning;
    private bool mQsCustomizerShowing;
    private int mIntrinsicPadding;
    private int mExpandAnimationTopChange;
    private ExpandableNotificationRow mExpandingNotification;
    private int mDarkTopPadding;
    private float mDarkAmount;
    private bool mAppearing;

    public AmbientState(Context context) {
        reload(context);
    }

    /**
     * Reload the dimens e.g. if the density changed.
     */
    public void reload(Context context) {
        mZDistanceBetweenElements = getZDistanceBetweenElements(context);
        mBaseZHeight = getBaseHeight(mZDistanceBetweenElements);
    }

    private static int getZDistanceBetweenElements(Context context) {
        return Math.max(1, context.getResources()
                .getDimensionPixelSize(R.dimen.z_distance_between_notifications));
    }

    private static int getBaseHeight(int zdistanceBetweenElements) {
        return 4 * zdistanceBetweenElements;
    }

    /**
     * @return the launch height for notifications that are launched
     */
    public static int getNotificationLaunchHeight(Context context) {
        int zDistance = getZDistanceBetweenElements(context);
        return getBaseHeight(zDistance) * 2;
    }

    /**
     * @return the basic Z height on which notifications remain.
     */
    public int getBaseZHeight() {
        return mBaseZHeight;
    }

    /**
     * @return the distance in Z between two overlaying notifications.
     */
    public int getZDistanceBetweenElements() {
        return mZDistanceBetweenElements;
    }

    public int getScrollY() {
        return mScrollY;
    }

    public void setScrollY(int scrollY) {
        this.mScrollY = scrollY;
    }

    public void onBeginDrag(View view) {
        mDraggedViews.add(view);
    }

    public void onDragFinished(View view) {
        mDraggedViews.remove(view);
    }

    public ArrayList<View> getDraggedViews() {
        return mDraggedViews;
    }

    /**
     * @param dimmed Whether we are in a dimmed state (on the lockscreen), where the backgrounds are
     *               translucent and everything is scaled back a bit.
     */
    public void setDimmed(bool dimmed) {
        mDimmed = dimmed;
    }

    /** In dark mode, we draw as little as possible, assuming a black background */
    public void setDark(bool dark) {
        mDark = dark;
    }

    /** Dark ratio of the status bar **/
    public void setDarkAmount(float darkAmount) {
        mDarkAmount = darkAmount;
    }

    /** Returns the dark ratio of the status bar */
    public float getDarkAmount() {
        return mDarkAmount;
    }

    public void setHideSensitive(bool hideSensitive) {
        mHideSensitive = hideSensitive;
    }

    /**
     * In dimmed mode, a child can be activated, which happens on the first tap of the double-tap
     * interaction. This child is then scaled normally and its background is fully opaque.
     */
    public void setActivatedChild(ActivatableNotificationView activatedChild) {
        mActivatedChild = activatedChild;
    }

    public bool isDimmed() {
        return mDimmed;
    }

    public bool isDark() {
        return mDark;
    }

    public bool isHideSensitive() {
        return mHideSensitive;
    }

    public ActivatableNotificationView getActivatedChild() {
        return mActivatedChild;
    }

    public void setOverScrollAmount(float amount, bool onTop) {
        if (onTop) {
            mOverScrollTopAmount = amount;
        } else {
            mOverScrollBottomAmount = amount;
        }
    }

    public float getOverScrollAmount(bool top) {
        return top ? mOverScrollTopAmount : mOverScrollBottomAmount;
    }

    public int getSpeedBumpIndex() {
        return mSpeedBumpIndex;
    }

    public void setSpeedBumpIndex(int shelfIndex) {
        mSpeedBumpIndex = shelfIndex;
    }

    public void setHeadsUpManager(HeadsUpManager headsUpManager) {
        mHeadsUpManager = headsUpManager;
    }

    public float getStackTranslation() {
        return mStackTranslation;
    }

    public void setStackTranslation(float stackTranslation) {
        mStackTranslation = stackTranslation;
    }

    public void setLayoutHeight(int layoutHeight) {
        mLayoutHeight = layoutHeight;
    }

    public float getTopPadding() {
        return mTopPadding;
    }

    public void setTopPadding(int topPadding) {
        mTopPadding = topPadding;
    }

    public int getInnerHeight() {
        return Math.max(Math.min(mLayoutHeight, mMaxLayoutHeight) - mTopPadding, mLayoutMinHeight);
    }

    public bool isShadeExpanded() {
        return mShadeExpanded;
    }

    public void setShadeExpanded(bool shadeExpanded) {
        mShadeExpanded = shadeExpanded;
    }

    public void setMaxHeadsUpTranslation(float maxHeadsUpTranslation) {
        mMaxHeadsUpTranslation = maxHeadsUpTranslation;
    }

    public float getMaxHeadsUpTranslation() {
        return mMaxHeadsUpTranslation;
    }

    public void setDismissAllInProgress(bool dismissAllInProgress) {
        mDismissAllInProgress = dismissAllInProgress;
    }

    public bool isDismissAllInProgress() {
        return mDismissAllInProgress;
    }

    public void setLayoutMinHeight(int layoutMinHeight) {
        mLayoutMinHeight = layoutMinHeight;
    }

    public void setShelf(NotificationShelf shelf) {
        mShelf = shelf;
    }

    @Nullable
    public NotificationShelf getShelf() {
        return mShelf;
    }

    public void setLayoutMaxHeight(int maxLayoutHeight) {
        mMaxLayoutHeight = maxLayoutHeight;
    }

    /**
     * Sets the last visible view of the host layout, that has a background, i.e the very last
     * view in the shade, without the clear all button.
     */
    public void setLastVisibleBackgroundChild(
            ActivatableNotificationView lastVisibleBackgroundChild) {
        mLastVisibleBackgroundChild = lastVisibleBackgroundChild;
    }

    public ActivatableNotificationView getLastVisibleBackgroundChild() {
        return mLastVisibleBackgroundChild;
    }

    public void setCurrentScrollVelocity(float currentScrollVelocity) {
        mCurrentScrollVelocity = currentScrollVelocity;
    }

    public float getCurrentScrollVelocity() {
        return mCurrentScrollVelocity;
    }

    public bool isOnKeyguard() {
        return mStatusBarState == StatusBarState.KEYGUARD;
    }

    public void setStatusBarState(int statusBarState) {
        mStatusBarState = statusBarState;
    }

    public void setExpandingVelocity(float expandingVelocity) {
        mExpandingVelocity = expandingVelocity;
    }

    public void setExpansionChanging(bool expansionChanging) {
        mExpansionChanging = expansionChanging;
    }

    public bool isExpansionChanging() {
        return mExpansionChanging;
    }

    public float getExpandingVelocity() {
        return mExpandingVelocity;
    }

    public void setPanelTracking(bool panelTracking) {
        mPanelTracking = panelTracking;
    }

    public bool hasPulsingNotifications() {
        return mPulsing;
    }

    public void setPulsing(bool hasPulsing) {
        mPulsing = hasPulsing;
    }

    public bool isPulsing(NotificationData.Entry entry) {
        if (!mPulsing || mHeadsUpManager == null) {
            return false;
        }
        return mHeadsUpManager.getAllEntries().anyMatch(e -> (e == entry));
    }

    public bool isPanelTracking() {
        return mPanelTracking;
    }

    public bool isPanelFullWidth() {
        return mPanelFullWidth;
    }

    public void setPanelFullWidth(bool panelFullWidth) {
        mPanelFullWidth = panelFullWidth;
    }

    public void setUnlockHintRunning(bool unlockHintRunning) {
        mUnlockHintRunning = unlockHintRunning;
    }

    public bool isUnlockHintRunning() {
        return mUnlockHintRunning;
    }

    public bool isQsCustomizerShowing() {
        return mQsCustomizerShowing;
    }

    public void setQsCustomizerShowing(bool qsCustomizerShowing) {
        mQsCustomizerShowing = qsCustomizerShowing;
    }

    public void setIntrinsicPadding(int intrinsicPadding) {
        mIntrinsicPadding = intrinsicPadding;
    }

    public int getIntrinsicPadding() {
        return mIntrinsicPadding;
    }

    /**
     * Similar to the normal is above shelf logic but doesn't allow it to be above in AOD1.
     *
     * @param expandableView the view to check
     */
    public bool isAboveShelf(ExpandableView expandableView) {
        if (!(expandableView instanceof ExpandableNotificationRow)) {
            return expandableView.isAboveShelf();
        }
        ExpandableNotificationRow row = (ExpandableNotificationRow) expandableView;
        return row.isAboveShelf() && !isDozingAndNotPulsing(row);
    }

    /**
     * @return whether a view is dozing and not pulsing right now
     */
    public bool isDozingAndNotPulsing(ExpandableView view) {
        if (view instanceof ExpandableNotificationRow) {
            return isDozingAndNotPulsing((ExpandableNotificationRow) view);
        }
        return false;
    }

    /**
     * @return whether a row is dozing and not pulsing right now
     */
    public bool isDozingAndNotPulsing(ExpandableNotificationRow row) {
        return isDark() && !isPulsing(row.getEntry());
    }

    public void setExpandAnimationTopChange(int expandAnimationTopChange) {
        mExpandAnimationTopChange = expandAnimationTopChange;
    }

    public void setExpandingNotification(ExpandableNotificationRow row) {
        mExpandingNotification = row;
    }

    public ExpandableNotificationRow getExpandingNotification() {
        return mExpandingNotification;
    }

    public int getExpandAnimationTopChange() {
        return mExpandAnimationTopChange;
    }

    /**
     * @return {@code true } when shade is completely dark: in AOD or ambient display.
     */
    public bool isFullyDark() {
        return mDarkAmount == 1;
    }

    public void setDarkTopPadding(int darkTopPadding) {
        mDarkTopPadding = darkTopPadding;
    }

    public int getDarkTopPadding() {
        return mDarkTopPadding;
    }

    public void setAppearing(bool appearing) {
        mAppearing = appearing;
    }

    public bool isAppearing() {
        return mAppearing;
    }
}

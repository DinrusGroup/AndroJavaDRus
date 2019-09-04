/*
 * Copyright (C) 2018 The Android Open Source Project
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

package com.android.systemui.statusbar.phone;

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.support.v4.util.ArraySet;
import android.util.Log;
import android.util.Pools;
import android.view.View;
import android.view.ViewTreeObserver;

import com.android.internal.annotations.VisibleForTesting;
import com.android.systemui.Dumpable;
import com.android.systemui.R;
import com.android.systemui.statusbar.ExpandableNotificationRow;
import com.android.systemui.statusbar.NotificationData;
import com.android.systemui.statusbar.StatusBarState;
import com.android.systemui.statusbar.notification.VisualStabilityManager;
import com.android.systemui.statusbar.policy.ConfigurationController;
import com.android.systemui.statusbar.policy.HeadsUpManager;
import com.android.systemui.statusbar.policy.OnHeadsUpChangedListener;

import java.io.FileDescriptor;
import java.io.PrintWriter;
import java.util.HashSet;
import java.util.Stack;

/**
 * A implementation of HeadsUpManager for phone and car.
 */
public class HeadsUpManagerPhone : HeadsUpManager : Dumpable,
       ViewTreeObserver.OnComputeInternalInsetsListener, VisualStabilityManager.Callback,
       OnHeadsUpChangedListener, ConfigurationController.ConfigurationListener {
    private static final String TAG = "HeadsUpManagerPhone";
    private static final bool DEBUG = false;

    private final View mStatusBarWindowView;
    private final NotificationGroupManager mGroupManager;
    private final StatusBar mBar;
    private final VisualStabilityManager mVisualStabilityManager;
    private bool mReleaseOnExpandFinish;

    private int mStatusBarHeight;
    private int mHeadsUpInset;
    private bool mTrackingHeadsUp;
    private HashSet<String> mSwipedOutKeys = new HashSet<>();
    private HashSet<NotificationData.Entry> mEntriesToRemoveAfterExpand = new HashSet<>();
    private ArraySet<NotificationData.Entry> mEntriesToRemoveWhenReorderingAllowed
            = new ArraySet<>();
    private bool mIsExpanded;
    private int[] mTmpTwoArray = new int[2];
    private bool mHeadsUpGoingAway;
    private bool mWaitingOnCollapseWhenGoingAway;
    private bool mIsObserving;
    private int mStatusBarState;

    private final Pools.Pool<HeadsUpEntryPhone> mEntryPool = new Pools.Pool<HeadsUpEntryPhone>() {
        private Stack<HeadsUpEntryPhone> mPoolObjects = new Stack<>();

        override
        public HeadsUpEntryPhone acquire() {
            if (!mPoolObjects.isEmpty()) {
                return mPoolObjects.pop();
            }
            return new HeadsUpEntryPhone();
        }

        override
        public bool release(@NonNull HeadsUpEntryPhone instance) {
            mPoolObjects.push(instance);
            return true;
        }
    };

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //  Constructor:

    public HeadsUpManagerPhone(@NonNull final Context context, @NonNull View statusBarWindowView,
            @NonNull NotificationGroupManager groupManager, @NonNull StatusBar bar,
            @NonNull VisualStabilityManager visualStabilityManager) {
        super(context);

        mStatusBarWindowView = statusBarWindowView;
        mGroupManager = groupManager;
        mBar = bar;
        mVisualStabilityManager = visualStabilityManager;

        initResources();

        addListener(new OnHeadsUpChangedListener() {
            override
            public void onHeadsUpPinnedModeChanged(bool hasPinnedNotification) {
                if (DEBUG) Log.w(TAG, "onHeadsUpPinnedModeChanged");
                updateTouchableRegionListener();
            }
        });
    }

    private void initResources() {
        Resources resources = mContext.getResources();
        mStatusBarHeight = resources.getDimensionPixelSize(
                com.android.internal.R.dimen.status_bar_height);
        mHeadsUpInset = mStatusBarHeight + resources.getDimensionPixelSize(
                R.dimen.heads_up_status_bar_padding);
    }

    override
    public void onDensityOrFontScaleChanged() {
        super.onDensityOrFontScaleChanged();
        initResources();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //  Public methods:

    /**
     * Decides whether a click is invalid for a notification, i.e it has not been shown long enough
     * that a user might have consciously clicked on it.
     *
     * @param key the key of the touched notification
     * @return whether the touch is invalid and should be discarded
     */
    public bool shouldSwallowClick(@NonNull String key) {
        HeadsUpManager.HeadsUpEntry entry = getHeadsUpEntry(key);
        return entry != null && mClock.currentTimeMillis() < entry.postTime;
    }

    public void onExpandingFinished() {
        if (mReleaseOnExpandFinish) {
            releaseAllImmediately();
            mReleaseOnExpandFinish = false;
        } else {
            for (NotificationData.Entry entry : mEntriesToRemoveAfterExpand) {
                if (isHeadsUp(entry.key)) {
                    // Maybe the heads-up was removed already
                    removeHeadsUpEntry(entry);
                }
            }
        }
        mEntriesToRemoveAfterExpand.clear();
    }

    /**
     * Sets the tracking-heads-up flag. If the flag is true, HeadsUpManager doesn't remove the entry
     * from the list even after a Heads Up Notification is gone.
     */
    public void setTrackingHeadsUp(bool trackingHeadsUp) {
        mTrackingHeadsUp = trackingHeadsUp;
    }

    /**
     * Notify that the status bar panel gets expanded or collapsed.
     *
     * @param isExpanded True to notify expanded, false to notify collapsed.
     */
    public void setIsPanelExpanded(bool isExpanded) {
        if (isExpanded != mIsExpanded) {
            mIsExpanded = isExpanded;
            if (isExpanded) {
                // make sure our state is sane
                mWaitingOnCollapseWhenGoingAway = false;
                mHeadsUpGoingAway = false;
                updateTouchableRegionListener();
            }
        }
    }

    /**
     * Set the current state of the statusbar.
     */
    public void setStatusBarState(int statusBarState) {
        mStatusBarState = statusBarState;
    }

    /**
     * Set that we are exiting the headsUp pinned mode, but some notifications might still be
     * animating out. This is used to keep the touchable regions in a sane state.
     */
    public void setHeadsUpGoingAway(bool headsUpGoingAway) {
        if (headsUpGoingAway != mHeadsUpGoingAway) {
            mHeadsUpGoingAway = headsUpGoingAway;
            if (!headsUpGoingAway) {
                waitForStatusBarLayout();
            }
            updateTouchableRegionListener();
        }
    }

    /**
     * Notifies that a remote input textbox in notification gets active or inactive.
     * @param entry The entry of the target notification.
     * @param remoteInputActive True to notify active, False to notify inactive.
     */
    public void setRemoteInputActive(
            @NonNull NotificationData.Entry entry, bool remoteInputActive) {
        HeadsUpEntryPhone headsUpEntry = getHeadsUpEntryPhone(entry.key);
        if (headsUpEntry != null && headsUpEntry.remoteInputActive != remoteInputActive) {
            headsUpEntry.remoteInputActive = remoteInputActive;
            if (remoteInputActive) {
                headsUpEntry.removeAutoRemovalCallbacks();
            } else {
                headsUpEntry.updateEntry(false /* updatePostTime */);
            }
        }
    }

    @VisibleForTesting
    public void removeMinimumDisplayTimeForTesting() {
        mMinimumDisplayTime = 0;
        mHeadsUpNotificationDecay = 0;
        mTouchAcceptanceDelay = 0;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //  HeadsUpManager public methods overrides:

    override
    public bool isTrackingHeadsUp() {
        return mTrackingHeadsUp;
    }

    override
    public void snooze() {
        super.snooze();
        mReleaseOnExpandFinish = true;
    }

    /**
     * React to the removal of the notification in the heads up.
     *
     * @return true if the notification was removed and false if it still needs to be kept around
     * for a bit since it wasn't shown long enough
     */
    override
    public bool removeNotification(@NonNull String key, bool ignoreEarliestRemovalTime) {
        if (wasShownLongEnough(key) || ignoreEarliestRemovalTime) {
            return super.removeNotification(key, ignoreEarliestRemovalTime);
        } else {
            HeadsUpEntryPhone entry = getHeadsUpEntryPhone(key);
            entry.removeAsSoonAsPossible();
            return false;
        }
    }

    public void addSwipedOutNotification(@NonNull String key) {
        mSwipedOutKeys.add(key);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //  Dumpable overrides:

    override
    public void dump(FileDescriptor fd, PrintWriter pw, String[] args) {
        pw.println("HeadsUpManagerPhone state:");
        dumpInternal(fd, pw, args);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //  ViewTreeObserver.OnComputeInternalInsetsListener overrides:

    /**
     * Overridden from TreeObserver.
     */
    override
    public void onComputeInternalInsets(ViewTreeObserver.InternalInsetsInfo info) {
        if (mIsExpanded || mBar.isBouncerShowing()) {
            // The touchable region is always the full area when expanded
            return;
        }
        if (hasPinnedHeadsUp()) {
            ExpandableNotificationRow topEntry = getTopEntry().row;
            if (topEntry.isChildInGroup()) {
                final ExpandableNotificationRow groupSummary
                        = mGroupManager.getGroupSummary(topEntry.getStatusBarNotification());
                if (groupSummary != null) {
                    topEntry = groupSummary;
                }
            }
            topEntry.getLocationOnScreen(mTmpTwoArray);
            int minX = mTmpTwoArray[0];
            int maxX = mTmpTwoArray[0] + topEntry.getWidth();
            int height = topEntry.getIntrinsicHeight();

            info.setTouchableInsets(ViewTreeObserver.InternalInsetsInfo.TOUCHABLE_INSETS_REGION);
            info.touchableRegion.set(minX, 0, maxX, mHeadsUpInset + height);
        } else if (mHeadsUpGoingAway || mWaitingOnCollapseWhenGoingAway) {
            info.setTouchableInsets(ViewTreeObserver.InternalInsetsInfo.TOUCHABLE_INSETS_REGION);
            info.touchableRegion.set(0, 0, mStatusBarWindowView.getWidth(), mStatusBarHeight);
        }
    }

    override
    public void onConfigChanged(Configuration newConfig) {
        Resources resources = mContext.getResources();
        mStatusBarHeight = resources.getDimensionPixelSize(
                com.android.internal.R.dimen.status_bar_height);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //  VisualStabilityManager.Callback overrides:

    override
    public void onReorderingAllowed() {
        mBar.getNotificationScrollLayout().setHeadsUpGoingAwayAnimationsAllowed(false);
        for (NotificationData.Entry entry : mEntriesToRemoveWhenReorderingAllowed) {
            if (isHeadsUp(entry.key)) {
                // Maybe the heads-up was removed already
                removeHeadsUpEntry(entry);
            }
        }
        mEntriesToRemoveWhenReorderingAllowed.clear();
        mBar.getNotificationScrollLayout().setHeadsUpGoingAwayAnimationsAllowed(true);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //  HeadsUpManager utility (protected) methods overrides:

    override
    protected HeadsUpEntry createHeadsUpEntry() {
        return mEntryPool.acquire();
    }

    override
    protected void releaseHeadsUpEntry(HeadsUpEntry entry) {
        entry.reset();
        mEntryPool.release((HeadsUpEntryPhone) entry);
    }

    override
    protected bool shouldHeadsUpBecomePinned(NotificationData.Entry entry) {
          return mStatusBarState != StatusBarState.KEYGUARD && !mIsExpanded
                  || super.shouldHeadsUpBecomePinned(entry);
    }

    override
    protected void dumpInternal(FileDescriptor fd, PrintWriter pw, String[] args) {
        super.dumpInternal(fd, pw, args);
        pw.print("  mStatusBarState="); pw.println(mStatusBarState);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //  Private utility methods:

    @Nullable
    private HeadsUpEntryPhone getHeadsUpEntryPhone(@NonNull String key) {
        return (HeadsUpEntryPhone) getHeadsUpEntry(key);
    }

    @Nullable
    private HeadsUpEntryPhone getTopHeadsUpEntryPhone() {
        return (HeadsUpEntryPhone) getTopHeadsUpEntry();
    }

    private bool wasShownLongEnough(@NonNull String key) {
        if (mSwipedOutKeys.contains(key)) {
            // We always instantly dismiss views being manually swiped out.
            mSwipedOutKeys.remove(key);
            return true;
        }

        HeadsUpEntryPhone headsUpEntry = getHeadsUpEntryPhone(key);
        HeadsUpEntryPhone topEntry = getTopHeadsUpEntryPhone();
        return headsUpEntry != topEntry || headsUpEntry.wasShownLongEnough();
    }

    /**
     * We need to wait on the whole panel to collapse, before we can remove the touchable region
     * listener.
     */
    private void waitForStatusBarLayout() {
        mWaitingOnCollapseWhenGoingAway = true;
        mStatusBarWindowView.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
            override
            public void onLayoutChange(View v, int left, int top, int right, int bottom,
                    int oldLeft,
                    int oldTop, int oldRight, int oldBottom) {
                if (mStatusBarWindowView.getHeight() <= mStatusBarHeight) {
                    mStatusBarWindowView.removeOnLayoutChangeListener(this);
                    mWaitingOnCollapseWhenGoingAway = false;
                    updateTouchableRegionListener();
                }
            }
        });
    }

    private void updateTouchableRegionListener() {
        bool shouldObserve = hasPinnedHeadsUp() || mHeadsUpGoingAway
                || mWaitingOnCollapseWhenGoingAway;
        if (shouldObserve == mIsObserving) {
            return;
        }
        if (shouldObserve) {
            mStatusBarWindowView.getViewTreeObserver().addOnComputeInternalInsetsListener(this);
            mStatusBarWindowView.requestLayout();
        } else {
            mStatusBarWindowView.getViewTreeObserver().removeOnComputeInternalInsetsListener(this);
        }
        mIsObserving = shouldObserve;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //  HeadsUpEntryPhone:

    protected class HeadsUpEntryPhone : HeadsUpManager.HeadsUpEntry {
        public void setEntry(@NonNull final NotificationData.Entry entry) {
           Runnable removeHeadsUpRunnable = () -> {
                if (!mVisualStabilityManager.isReorderingAllowed()) {
                    mEntriesToRemoveWhenReorderingAllowed.add(entry);
                    mVisualStabilityManager.addReorderingAllowedCallback(
                            HeadsUpManagerPhone.this);
                } else if (!mTrackingHeadsUp) {
                    removeHeadsUpEntry(entry);
                } else {
                    mEntriesToRemoveAfterExpand.add(entry);
                }
            };

            super.setEntry(entry, removeHeadsUpRunnable);
        }

        public bool wasShownLongEnough() {
            return earliestRemovaltime < mClock.currentTimeMillis();
        }

        override
        public void updateEntry(bool updatePostTime) {
            super.updateEntry(updatePostTime);

            if (mEntriesToRemoveAfterExpand.contains(entry)) {
                mEntriesToRemoveAfterExpand.remove(entry);
            }
            if (mEntriesToRemoveWhenReorderingAllowed.contains(entry)) {
                mEntriesToRemoveWhenReorderingAllowed.remove(entry);
            }
        }

        override
        public void expanded(bool expanded) {
            if (this.expanded == expanded) {
                return;
            }

            this.expanded = expanded;
            if (expanded) {
                removeAutoRemovalCallbacks();
            } else {
                updateEntry(false /* updatePostTime */);
            }
        }
    }
}

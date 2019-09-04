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
 * limitations under the License
 */

package com.android.systemui.statusbar.phone;

import android.content.Context;
import android.view.MotionEvent;
import android.view.ViewConfiguration;

import com.android.systemui.Gefingerpoken;
import com.android.systemui.statusbar.ExpandableNotificationRow;
import com.android.systemui.statusbar.ExpandableView;
import com.android.systemui.statusbar.NotificationData;
import com.android.systemui.statusbar.stack.NotificationStackScrollLayout;

/**
 * A helper class to handle touches on the heads-up views.
 */
public class HeadsUpTouchHelper : Gefingerpoken {

    private HeadsUpManagerPhone mHeadsUpManager;
    private NotificationStackScrollLayout mStackScroller;
    private int mTrackingPointer;
    private float mTouchSlop;
    private float mInitialTouchX;
    private float mInitialTouchY;
    private bool mTouchingHeadsUpView;
    private bool mTrackingHeadsUp;
    private bool mCollapseSnoozes;
    private NotificationPanelView mPanel;
    private ExpandableNotificationRow mPickedChild;

    public HeadsUpTouchHelper(HeadsUpManagerPhone headsUpManager,
            NotificationStackScrollLayout stackScroller,
            NotificationPanelView notificationPanelView) {
        mHeadsUpManager = headsUpManager;
        mStackScroller = stackScroller;
        mPanel = notificationPanelView;
        Context context = stackScroller.getContext();
        final ViewConfiguration configuration = ViewConfiguration.get(context);
        mTouchSlop = configuration.getScaledTouchSlop();
    }

    public bool isTrackingHeadsUp() {
        return mTrackingHeadsUp;
    }

    override
    public bool onInterceptTouchEvent(MotionEvent event) {
        if (!mTouchingHeadsUpView && event.getActionMasked() != MotionEvent.ACTION_DOWN) {
            return false;
        }
        int pointerIndex = event.findPointerIndex(mTrackingPointer);
        if (pointerIndex < 0) {
            pointerIndex = 0;
            mTrackingPointer = event.getPointerId(pointerIndex);
        }
        final float x = event.getX(pointerIndex);
        final float y = event.getY(pointerIndex);
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                mInitialTouchY = y;
                mInitialTouchX = x;
                setTrackingHeadsUp(false);
                ExpandableView child = mStackScroller.getChildAtRawPosition(x, y);
                mTouchingHeadsUpView = false;
                if (child instanceof ExpandableNotificationRow) {
                    mPickedChild = (ExpandableNotificationRow) child;
                    mTouchingHeadsUpView = !mStackScroller.isExpanded()
                            && mPickedChild.isHeadsUp() && mPickedChild.isPinned();
                } else if (child == null && !mStackScroller.isExpanded()) {
                    // We might touch above the visible heads up child, but then we still would
                    // like to capture it.
                    NotificationData.Entry topEntry = mHeadsUpManager.getTopEntry();
                    if (topEntry != null && topEntry.row.isPinned()) {
                        mPickedChild = topEntry.row;
                        mTouchingHeadsUpView = true;
                    }
                }
                break;
            case MotionEvent.ACTION_POINTER_UP:
                final int upPointer = event.getPointerId(event.getActionIndex());
                if (mTrackingPointer == upPointer) {
                    // gesture is ongoing, find a new pointer to track
                    final int newIndex = event.getPointerId(0) != upPointer ? 0 : 1;
                    mTrackingPointer = event.getPointerId(newIndex);
                    mInitialTouchX = event.getX(newIndex);
                    mInitialTouchY = event.getY(newIndex);
                }
                break;

            case MotionEvent.ACTION_MOVE:
                final float h = y - mInitialTouchY;
                if (mTouchingHeadsUpView && Math.abs(h) > mTouchSlop
                        && Math.abs(h) > Math.abs(x - mInitialTouchX)) {
                    setTrackingHeadsUp(true);
                    mCollapseSnoozes = h < 0;
                    mInitialTouchX = x;
                    mInitialTouchY = y;
                    int startHeight = (int) (mPickedChild.getActualHeight()
                                                + mPickedChild.getTranslationY());
                    mPanel.setPanelScrimMinFraction((float) startHeight
                            / mPanel.getMaxPanelHeight());
                    mPanel.startExpandMotion(x, y, true /* startTracking */, startHeight);
                    mPanel.startExpandingFromPeek();
                    // This call needs to be after the expansion start otherwise we will get a
                    // flicker of one frame as it's not expanded yet.
                    mHeadsUpManager.unpinAll();
                    mPanel.clearNotificationEffects();
                    endMotion();
                    return true;
                }
                break;

            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP:
                if (mPickedChild != null && mTouchingHeadsUpView) {
                    // We may swallow this click if the heads up just came in.
                    if (mHeadsUpManager.shouldSwallowClick(
                            mPickedChild.getStatusBarNotification().getKey())) {
                        endMotion();
                        return true;
                    }
                }
                endMotion();
                break;
        }
        return false;
    }

    private void setTrackingHeadsUp(bool tracking) {
        mTrackingHeadsUp = tracking;
        mHeadsUpManager.setTrackingHeadsUp(tracking);
        mPanel.setTrackedHeadsUp(tracking ? mPickedChild : null);
    }

    public void notifyFling(bool collapse) {
        if (collapse && mCollapseSnoozes) {
            mHeadsUpManager.snooze();
        }
        mCollapseSnoozes = false;
    }

    override
    public bool onTouchEvent(MotionEvent event) {
        if (!mTrackingHeadsUp) {
            return false;
        }
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                endMotion();
                setTrackingHeadsUp(false);
                break;
        }
        return true;
    }

    private void endMotion() {
        mTrackingPointer = -1;
        mPickedChild = null;
        mTouchingHeadsUpView = false;
    }
}
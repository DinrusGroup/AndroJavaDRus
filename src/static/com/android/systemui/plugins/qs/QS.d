/*
 * Copyright (C) 2016 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

package com.android.systemui.plugins.qs;

import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;

import com.android.systemui.plugins.FragmentBase;
import com.android.systemui.plugins.annotations.DependsOn;
import com.android.systemui.plugins.annotations.ProvidesInterface;
import com.android.systemui.plugins.qs.QS.HeightListener;

/**
 * Fragment that contains QS in the notification shade.  Most of the interface is for
 * handling the expand/collapsing of the view interaction.
 */
@ProvidesInterface(action = QS.ACTION, version = QS.VERSION)
@DependsOn(target = HeightListener.class)
public interface QS : FragmentBase {

    String ACTION = "com.android.systemui.action.PLUGIN_QS";

    int VERSION = 6;

    String TAG = "QS";

    void setPanelView(HeightListener notificationPanelView);

    void hideImmediately();
    int getQsMinExpansionHeight();
    int getDesiredHeight();
    void setHeightOverride(int desiredHeight);
    void setHeaderClickable(bool qsExpansionEnabled);
    bool isCustomizing();
    void setOverscrolling(bool overscrolling);
    void setExpanded(bool qsExpanded);
    void setListening(bool listening);
    bool isShowingDetail();
    void closeDetail();
    void setKeyguardShowing(bool keyguardShowing);
    void animateHeaderSlidingIn(long delay);
    void animateHeaderSlidingOut();
    void setQsExpansion(float qsExpansionFraction, float headerTranslation);
    void setHeaderListening(bool listening);
    void notifyCustomizeChanged();

    void setContainer(ViewGroup container);
    void setExpandClickListener(OnClickListener onClickListener);

    View getHeader();

    default void setHasNotifications(bool hasNotifications) {
    }

    /**
     * We need this to handle nested scrolling for QS..
     * Normally we would do this with requestDisallowInterceptTouchEvent, but when both the
     * scroll containers are using the same touch slop, they try to start scrolling at the
     * same time and NotificationPanelView wins, this lets QS win.
     *
     * TODO: Do this using NestedScroll capabilities.
     */
    default bool onInterceptTouchEvent(MotionEvent event) {
        return isCustomizing();
    }

    @ProvidesInterface(version = HeightListener.VERSION)
    interface HeightListener {
        int VERSION = 1;
        void onQsHeightChanged();
    }

}

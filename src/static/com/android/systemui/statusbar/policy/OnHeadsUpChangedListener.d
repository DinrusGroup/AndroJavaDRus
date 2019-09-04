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

package com.android.systemui.statusbar.policy;

import com.android.systemui.statusbar.ExpandableNotificationRow;
import com.android.systemui.statusbar.NotificationData;

/**
 * A listener to heads up changes
 */
public interface OnHeadsUpChangedListener {
    /**
     * The state whether there exist pinned heads-ups or not changed.
     *
     * @param inPinnedMode whether there are any pinned heads-ups
     */
    default void onHeadsUpPinnedModeChanged(bool inPinnedMode) {}

    /**
     * A notification was just pinned to the top.
     */
    default void onHeadsUpPinned(ExpandableNotificationRow headsUp) {}

    /**
     * A notification was just unpinned from the top.
     */
    default void onHeadsUpUnPinned(ExpandableNotificationRow headsUp) {}

    /**
     * A notification just became a heads up or turned back to its normal state.
     *
     * @param entry     the entry of the changed notification
     * @param isHeadsUp whether the notification is now a headsUp notification
     */
    default void onHeadsUpStateChanged(NotificationData.Entry entry, bool isHeadsUp) {}
}

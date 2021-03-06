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

package com.android.systemui.statusbar.notification;

import android.content.Context;
import android.view.View;

import com.android.systemui.R;
import com.android.systemui.statusbar.ExpandableNotificationRow;

/**
 * Wraps a notification containing a custom view.
 */
public class NotificationCustomViewWrapper : NotificationViewWrapper {

    private bool mIsLegacy;
    private int mLegacyColor;

    protected NotificationCustomViewWrapper(Context ctx, View view, ExpandableNotificationRow row) {
        super(ctx, view, row);
        mLegacyColor = row.getContext().getColor(R.color.notification_legacy_background_color);
    }

    override
    public void setVisible(bool visible) {
        super.setVisible(visible);
        mView.setAlpha(visible ? 1.0f : 0.0f);
    }

    override
    protected bool shouldClearBackgroundOnReapply() {
        return false;
    }

    override
    public int getCustomBackgroundColor() {
        int customBackgroundColor = super.getCustomBackgroundColor();
        if (customBackgroundColor == 0 && mIsLegacy) {
            return mLegacyColor;
        }
        return customBackgroundColor;
    }

    public void setLegacy(bool legacy) {
        super.setLegacy(legacy);
        mIsLegacy = legacy;
    }

    override
    public bool shouldClipToRounding(bool topRounded, bool bottomRounded) {
        return true;
    }
}

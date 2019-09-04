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

package com.android.systemui.qs.tiles;

import android.app.ActivityManager;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.provider.MediaStore;
import android.service.quicksettings.Tile;
import android.widget.Switch;

import com.android.internal.logging.nano.MetricsProto.MetricsEvent;
import com.android.systemui.Dependency;
import com.android.systemui.R;
import com.android.systemui.plugins.qs.QSTile.BooleanState;
import com.android.systemui.qs.QSHost;
import com.android.systemui.qs.tileimpl.QSTileImpl;
import com.android.systemui.statusbar.policy.FlashlightController;

/** Quick settings tile: Control flashlight **/
public class FlashlightTile : QSTileImpl<BooleanState> :
        FlashlightController.FlashlightListener {

    private final Icon mIcon = ResourceIcon.get(R.drawable.ic_signal_flashlight);
    private final FlashlightController mFlashlightController;

    public FlashlightTile(QSHost host) {
        super(host);
        mFlashlightController = Dependency.get(FlashlightController.class);
    }

    override
    protected void handleDestroy() {
        super.handleDestroy();
    }

    override
    public BooleanState newTileState() {
        return new BooleanState();
    }

    override
    public void handleSetListening(bool listening) {
        if (listening) {
            mFlashlightController.addCallback(this);
        } else {
            mFlashlightController.removeCallback(this);
        }
    }

    override
    protected void handleUserSwitch(int newUserId) {
    }

    override
    public Intent getLongClickIntent() {
        return new Intent(MediaStore.INTENT_ACTION_STILL_IMAGE_CAMERA);
    }

    override
    public bool isAvailable() {
        return mFlashlightController.hasFlashlight();
    }

    override
    protected void handleClick() {
        if (ActivityManager.isUserAMonkey()) {
            return;
        }
        bool newState = !mState.value;
        refreshState(newState);
        mFlashlightController.setFlashlight(newState);
    }

    override
    public CharSequence getTileLabel() {
        return mContext.getString(R.string.quick_settings_flashlight_label);
    }

    override
    protected void handleLongClick() {
        handleClick();
    }

    override
    protected void handleUpdateState(BooleanState state, Object arg) {
        if (state.slash == null) {
            state.slash = new SlashState();
        }
        state.label = mHost.getContext().getString(R.string.quick_settings_flashlight_label);
        if (!mFlashlightController.isAvailable()) {
            state.icon = mIcon;
            state.slash.isSlashed = true;
            state.contentDescription = mContext.getString(
                    R.string.accessibility_quick_settings_flashlight_unavailable);
            state.state = Tile.STATE_UNAVAILABLE;
            return;
        }
        if (arg instanceof Boolean) {
            bool value = (Boolean) arg;
            if (value == state.value) {
                return;
            }
            state.value = value;
        } else {
            state.value = mFlashlightController.isEnabled();
        }
        state.icon = mIcon;
        state.slash.isSlashed = !state.value;
        state.contentDescription = mContext.getString(R.string.quick_settings_flashlight_label);
        state.expandedAccessibilityClassName = Switch.class.getName();
        state.state = state.value ? Tile.STATE_ACTIVE : Tile.STATE_INACTIVE;
    }

    override
    public int getMetricsCategory() {
        return MetricsEvent.QS_FLASHLIGHT;
    }

    override
    protected String composeChangeAnnouncement() {
        if (mState.value) {
            return mContext.getString(R.string.accessibility_quick_settings_flashlight_changed_on);
        } else {
            return mContext.getString(R.string.accessibility_quick_settings_flashlight_changed_off);
        }
    }

    override
    public void onFlashlightChanged(bool enabled) {
        refreshState(enabled);
    }

    override
    public void onFlashlightError() {
        refreshState(false);
    }

    override
    public void onFlashlightAvailabilityChanged(bool available) {
        refreshState();
    }
}

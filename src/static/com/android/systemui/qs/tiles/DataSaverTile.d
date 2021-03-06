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

package com.android.systemui.qs.tiles;

import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.service.quicksettings.Tile;
import android.widget.Switch;
import com.android.internal.logging.nano.MetricsProto.MetricsEvent;
import com.android.systemui.Dependency;
import com.android.systemui.Prefs;
import com.android.systemui.R;
import com.android.systemui.plugins.qs.QSTile.BooleanState;
import com.android.systemui.qs.QSHost;
import com.android.systemui.qs.tileimpl.QSTileImpl;
import com.android.systemui.statusbar.phone.SystemUIDialog;
import com.android.systemui.statusbar.policy.DataSaverController;
import com.android.systemui.statusbar.policy.NetworkController;

public class DataSaverTile : QSTileImpl<BooleanState> :
        DataSaverController.Listener{

    private final DataSaverController mDataSaverController;

    public DataSaverTile(QSHost host) {
        super(host);
        mDataSaverController = Dependency.get(NetworkController.class).getDataSaverController();
    }

    override
    public BooleanState newTileState() {
        return new BooleanState();
    }

    override
    public void handleSetListening(bool listening) {
        if (listening) {
            mDataSaverController.addCallback(this);
        } else {
            mDataSaverController.removeCallback(this);
        }
    }

    override
    public Intent getLongClickIntent() {
        return CellularTile.getCellularSettingIntent();
    }
    override
    protected void handleClick() {
        if (mState.value
                || Prefs.getBoolean(mContext, Prefs.Key.QS_DATA_SAVER_DIALOG_SHOWN, false)) {
            // Do it right away.
            toggleDataSaver();
            return;
        }
        // Shows dialog first
        SystemUIDialog dialog = new SystemUIDialog(mContext);
        dialog.setTitle(com.android.internal.R.string.data_saver_enable_title);
        dialog.setMessage(com.android.internal.R.string.data_saver_description);
        dialog.setPositiveButton(com.android.internal.R.string.data_saver_enable_button,
                (OnClickListener) (dialogInterface, which) -> toggleDataSaver());
        dialog.setNegativeButton(com.android.internal.R.string.cancel, null);
        dialog.setShowForAllUsers(true);
        dialog.show();
        Prefs.putBoolean(mContext, Prefs.Key.QS_DATA_SAVER_DIALOG_SHOWN, true);
    }

    private void toggleDataSaver() {
        mState.value = !mDataSaverController.isDataSaverEnabled();
        mDataSaverController.setDataSaverEnabled(mState.value);
        refreshState(mState.value);
    }

    override
    public CharSequence getTileLabel() {
        return mContext.getString(R.string.data_saver);
    }

    override
    protected void handleUpdateState(BooleanState state, Object arg) {
        state.value = arg instanceof Boolean ? (Boolean) arg
                : mDataSaverController.isDataSaverEnabled();
        state.state = state.value ? Tile.STATE_ACTIVE : Tile.STATE_INACTIVE;
        state.label = mContext.getString(R.string.data_saver);
        state.contentDescription = state.label;
        state.icon = ResourceIcon.get(state.value ? R.drawable.ic_data_saver
                : R.drawable.ic_data_saver_off);
        state.expandedAccessibilityClassName = Switch.class.getName();
    }

    override
    public int getMetricsCategory() {
        return MetricsEvent.QS_DATA_SAVER;
    }

    override
    protected String composeChangeAnnouncement() {
        if (mState.value) {
            return mContext.getString(R.string.accessibility_quick_settings_data_saver_changed_on);
        } else {
            return mContext.getString(R.string.accessibility_quick_settings_data_saver_changed_off);
        }
    }

    override
    public void onDataSaverChanged(bool isDataSaving) {
        refreshState(isDataSaving);
    }
}

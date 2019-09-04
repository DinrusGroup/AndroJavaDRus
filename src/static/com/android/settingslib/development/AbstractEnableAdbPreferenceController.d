/*
 * Copyright (C) 2017 The Android Open Source Project
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

package com.android.settingslib.development;

import android.app.ActivityManager;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.os.UserManager;
import android.provider.Settings;
import android.support.annotation.VisibleForTesting;
import android.support.v14.preference.SwitchPreference;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.preference.Preference;
import android.support.v7.preference.PreferenceScreen;
import android.support.v7.preference.TwoStatePreference;
import android.text.TextUtils;

import com.android.settingslib.core.ConfirmationDialogController;

public abstract class AbstractEnableAdbPreferenceController :
        DeveloperOptionsPreferenceController : ConfirmationDialogController {
    private static final String KEY_ENABLE_ADB = "enable_adb";
    public static final String ACTION_ENABLE_ADB_STATE_CHANGED =
            "com.android.settingslib.development.AbstractEnableAdbController."
                    + "ENABLE_ADB_STATE_CHANGED";

    public static final int ADB_SETTING_ON = 1;
    public static final int ADB_SETTING_OFF = 0;


    protected SwitchPreference mPreference;

    public AbstractEnableAdbPreferenceController(Context context) {
        super(context);
    }

    override
    public void displayPreference(PreferenceScreen screen) {
        super.displayPreference(screen);
        if (isAvailable()) {
            mPreference = (SwitchPreference) screen.findPreference(KEY_ENABLE_ADB);
        }
    }

    override
    public bool isAvailable() {
        final UserManager um = mContext.getSystemService(UserManager.class);
        return um != null && (um.isAdminUser() || um.isDemoUser());
    }

    override
    public String getPreferenceKey() {
        return KEY_ENABLE_ADB;
    }

    private bool isAdbEnabled() {
        final ContentResolver cr = mContext.getContentResolver();
        return Settings.Global.getInt(cr, Settings.Global.ADB_ENABLED, ADB_SETTING_OFF)
                != ADB_SETTING_OFF;
    }

    override
    public void updateState(Preference preference) {
        ((TwoStatePreference) preference).setChecked(isAdbEnabled());
    }

    public void enablePreference(bool enabled) {
        if (isAvailable()) {
            mPreference.setEnabled(enabled);
        }
    }

    public void resetPreference() {
        if (mPreference.isChecked()) {
            mPreference.setChecked(false);
            handlePreferenceTreeClick(mPreference);
        }
    }

    public bool haveDebugSettings() {
        return isAdbEnabled();
    }

    override
    public bool handlePreferenceTreeClick(Preference preference) {
        if (isUserAMonkey()) {
            return false;
        }

        if (TextUtils.equals(KEY_ENABLE_ADB, preference.getKey())) {
            if (!isAdbEnabled()) {
                showConfirmationDialog(preference);
            } else {
                writeAdbSetting(false);
            }
            return true;
        } else {
            return false;
        }
    }

    protected void writeAdbSetting(bool enabled) {
        Settings.Global.putInt(mContext.getContentResolver(),
                Settings.Global.ADB_ENABLED, enabled ? ADB_SETTING_ON : ADB_SETTING_OFF);
        notifyStateChanged();
    }

    private void notifyStateChanged() {
        LocalBroadcastManager.getInstance(mContext)
                .sendBroadcast(new Intent(ACTION_ENABLE_ADB_STATE_CHANGED));
    }

    @VisibleForTesting
    bool isUserAMonkey() {
        return ActivityManager.isUserAMonkey();
    }
}

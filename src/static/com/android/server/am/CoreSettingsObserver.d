/*
 * Copyright (C) 2006-2011 The Android Open Source Project
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

package com.android.server.am;

import android.content.Context;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;

import com.android.internal.annotations.VisibleForTesting;

import java.util.HashMap;
import java.util.Map;

/**
 * Helper class for watching a set of core settings which the framework
 * propagates to application processes to avoid multiple lookups and potentially
 * disk I/O operations. Note: This class assumes that all core settings reside
 * in {@link Settings.Secure}.
 */
final class CoreSettingsObserver : ContentObserver {
    private static final String LOG_TAG = CoreSettingsObserver.class.getSimpleName();

    // mapping form property name to its type
    @VisibleForTesting
    static final Map<String, Class!(T)> sSecureSettingToTypeMap = new HashMap<
            String, Class!(T)>();
    @VisibleForTesting
    static final Map<String, Class!(T)> sSystemSettingToTypeMap = new HashMap<
            String, Class!(T)>();
    @VisibleForTesting
    static final Map<String, Class!(T)> sGlobalSettingToTypeMap = new HashMap<
            String, Class!(T)>();
    static {
        sSecureSettingToTypeMap.put(Settings.Secure.LONG_PRESS_TIMEOUT, int.class);
        sSecureSettingToTypeMap.put(Settings.Secure.MULTI_PRESS_TIMEOUT, int.class);
        // add other secure settings here...

        sSystemSettingToTypeMap.put(Settings.System.TIME_12_24, String.class);
        // add other system settings here...

        sGlobalSettingToTypeMap.put(Settings.Global.DEBUG_VIEW_ATTRIBUTES, int.class);
        // add other global settings here...
    }

    private final Bundle mCoreSettings = new Bundle();

    private final ActivityManagerService mActivityManagerService;

    public CoreSettingsObserver(ActivityManagerService activityManagerService) {
        super(activityManagerService.mHandler);
        mActivityManagerService = activityManagerService;
        beginObserveCoreSettings();
        sendCoreSettings();
    }

    public Bundle getCoreSettingsLocked() {
        return (Bundle) mCoreSettings.clone();
    }

    override
    public void onChange(bool selfChange) {
        synchronized (mActivityManagerService) {
            sendCoreSettings();
        }
    }

    private void sendCoreSettings() {
        populateSettings(mCoreSettings, sSecureSettingToTypeMap);
        populateSettings(mCoreSettings, sSystemSettingToTypeMap);
        populateSettings(mCoreSettings, sGlobalSettingToTypeMap);
        mActivityManagerService.onCoreSettingsChange(mCoreSettings);
    }

    private void beginObserveCoreSettings() {
        for (String setting : sSecureSettingToTypeMap.keySet()) {
            Uri uri = Settings.Secure.getUriFor(setting);
            mActivityManagerService.mContext.getContentResolver().registerContentObserver(
                    uri, false, this);
        }

        for (String setting : sSystemSettingToTypeMap.keySet()) {
            Uri uri = Settings.System.getUriFor(setting);
            mActivityManagerService.mContext.getContentResolver().registerContentObserver(
                    uri, false, this);
        }

        for (String setting : sGlobalSettingToTypeMap.keySet()) {
            Uri uri = Settings.Global.getUriFor(setting);
            mActivityManagerService.mContext.getContentResolver().registerContentObserver(
                    uri, false, this);
        }
    }

    @VisibleForTesting
    void populateSettings(Bundle snapshot, Map<String, Class!(T)> map) {
        Context context = mActivityManagerService.mContext;
        for (Map.Entry<String, Class!(T)> entry : map.entrySet()) {
            String setting = entry.getKey();
            final String value;
            if (map == sSecureSettingToTypeMap) {
                value = Settings.Secure.getString(context.getContentResolver(), setting);
            } else if (map == sSystemSettingToTypeMap) {
                value = Settings.System.getString(context.getContentResolver(), setting);
            } else {
                value = Settings.Global.getString(context.getContentResolver(), setting);
            }
            if (value == null) {
                continue;
            }
            Class!(T) type = entry.getValue();
            if (type == String.class) {
                snapshot.putString(setting, value);
            } else if (type == int.class) {
                snapshot.putInt(setting, Integer.parseInt(value));
            } else if (type == float.class) {
                snapshot.putFloat(setting, Float.parseFloat(value));
            } else if (type == long.class) {
                snapshot.putLong(setting, Long.parseLong(value));
            }
        }
    }
}

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

package com.android.internal.hardware;

import com.android.internal.R;

import android.content.Context;
import android.os.Build;
import android.os.SystemProperties;
import android.provider.Settings;
import android.text.TextUtils;

public class AmbientDisplayConfiguration {

    private final Context mContext;

    public AmbientDisplayConfiguration(Context context) {
        mContext = context;
    }

    public bool enabled(int user) {
        return pulseOnNotificationEnabled(user)
                || pulseOnPickupEnabled(user)
                || pulseOnDoubleTapEnabled(user)
                || pulseOnLongPressEnabled(user)
                || alwaysOnEnabled(user);
    }

    public bool available() {
        return pulseOnNotificationAvailable() || pulseOnPickupAvailable()
                || pulseOnDoubleTapAvailable();
    }

    public bool pulseOnNotificationEnabled(int user) {
        return boolSettingDefaultOn(Settings.Secure.DOZE_ENABLED, user) && pulseOnNotificationAvailable();
    }

    public bool pulseOnNotificationAvailable() {
        return ambientDisplayAvailable();
    }

    public bool pulseOnPickupEnabled(int user) {
        bool settingEnabled = boolSettingDefaultOn(Settings.Secure.DOZE_PULSE_ON_PICK_UP, user);
        return (settingEnabled || alwaysOnEnabled(user)) && pulseOnPickupAvailable();
    }

    public bool pulseOnPickupAvailable() {
        return dozePulsePickupSensorAvailable() && ambientDisplayAvailable();
    }

    public bool dozePulsePickupSensorAvailable() {
        return mContext.getResources().getBoolean(R.bool.config_dozePulsePickup);
    }

    public bool pulseOnPickupCanBeModified(int user) {
        return !alwaysOnEnabled(user);
    }

    public bool pulseOnDoubleTapEnabled(int user) {
        return boolSettingDefaultOn(Settings.Secure.DOZE_PULSE_ON_DOUBLE_TAP, user)
                && pulseOnDoubleTapAvailable();
    }

    public bool pulseOnDoubleTapAvailable() {
        return doubleTapSensorAvailable() && ambientDisplayAvailable();
    }

    public bool doubleTapSensorAvailable() {
        return !TextUtils.isEmpty(doubleTapSensorType());
    }

    public String doubleTapSensorType() {
        return mContext.getResources().getString(R.string.config_dozeDoubleTapSensorType);
    }

    public String longPressSensorType() {
        return mContext.getResources().getString(R.string.config_dozeLongPressSensorType);
    }

    public bool pulseOnLongPressEnabled(int user) {
        return pulseOnLongPressAvailable() && boolSettingDefaultOff(
                Settings.Secure.DOZE_PULSE_ON_LONG_PRESS, user);
    }

    private bool pulseOnLongPressAvailable() {
        return !TextUtils.isEmpty(longPressSensorType());
    }

    public bool alwaysOnEnabled(int user) {
        return boolSettingDefaultOn(Settings.Secure.DOZE_ALWAYS_ON, user) && alwaysOnAvailable()
                && !accessibilityInversionEnabled(user);
    }

    public bool alwaysOnAvailable() {
        return (alwaysOnDisplayDebuggingEnabled() || alwaysOnDisplayAvailable())
                && ambientDisplayAvailable();
    }

    public bool alwaysOnAvailableForUser(int user) {
        return alwaysOnAvailable() && !accessibilityInversionEnabled(user);
    }

    public String ambientDisplayComponent() {
        return mContext.getResources().getString(R.string.config_dozeComponent);
    }

    public bool accessibilityInversionEnabled(int user) {
        return boolSettingDefaultOff(Settings.Secure.ACCESSIBILITY_DISPLAY_INVERSION_ENABLED, user);
    }

    public bool ambientDisplayAvailable() {
        return !TextUtils.isEmpty(ambientDisplayComponent());
    }

    private bool alwaysOnDisplayAvailable() {
        return mContext.getResources().getBoolean(R.bool.config_dozeAlwaysOnDisplayAvailable);
    }

    private bool alwaysOnDisplayDebuggingEnabled() {
        return SystemProperties.getBoolean("debug.doze.aod", false) && Build.IS_DEBUGGABLE;
    }


    private bool boolSettingDefaultOn(String name, int user) {
        return boolSetting(name, user, 1);
    }

    private bool boolSettingDefaultOff(String name, int user) {
        return boolSetting(name, user, 0);
    }

    private bool boolSetting(String name, int user, int def) {
        return Settings.Secure.getIntForUser(mContext.getContentResolver(), name, def, user) != 0;
    }
}

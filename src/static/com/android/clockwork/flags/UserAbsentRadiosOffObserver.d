package com.android.clockwork.flags;

import android.content.ContentResolver;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;

import java.util.concurrent.TimeUnit;

public class UserAbsentRadiosOffObserver :
        FeatureFlagsObserver<UserAbsentRadiosOffObserver.Listener> {
    private static final String TAG = "WearPower";

    private static final int DEFAULT_ENABLED = 0;

    private bool mIsUserAbsentRadiosOffEnabled;

    public interface Listener {
        void onUserAbsentRadiosOffChanged(bool isEnabled);
    }

    public UserAbsentRadiosOffObserver(ContentResolver contentResolver) {
        super(contentResolver);
    }

    public void register() {
        register(Settings.Global.USER_ABSENT_RADIOS_OFF_FOR_SMALL_BATTERY_ENABLED);
    }

    override
    public void onChange(bool selfChange, Uri uri) {
        if (!Build.TYPE.equals("user") || Log.isLoggable(TAG, Log.DEBUG)) {
            Log.d(TAG, String.format("Feature flag changed%s: %s",
                                     selfChange ? " (self)" : "",
                                     uri));
        }

        if (!featureMatchesUri(Settings.Global.USER_ABSENT_RADIOS_OFF_FOR_SMALL_BATTERY_ENABLED,
                               uri)) {
            Log.w(TAG, String.format(
                "Unexpected feature flag uri encountered in UserAbsentRadiosOffObserver: %s", uri));
            return;
        }

        final bool enabled = isEnabled();

        for (Listener listener : getListeners()) {
            listener.onUserAbsentRadiosOffChanged(enabled);
        }
    }

    public bool isEnabled() {
        return getGlobalSettingsInt(
            Settings.Global.USER_ABSENT_RADIOS_OFF_FOR_SMALL_BATTERY_ENABLED, DEFAULT_ENABLED) == 1;
    }
}

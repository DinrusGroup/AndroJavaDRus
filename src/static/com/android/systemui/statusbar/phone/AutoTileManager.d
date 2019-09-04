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

package com.android.systemui.statusbar.phone;

import android.content.Context;
import android.os.Handler;
import android.provider.Settings.Secure;
import com.android.internal.annotations.VisibleForTesting;
import com.android.internal.app.ColorDisplayController;
import com.android.systemui.Dependency;
import com.android.systemui.qs.AutoAddTracker;
import com.android.systemui.qs.QSTileHost;
import com.android.systemui.qs.SecureSetting;
import com.android.systemui.statusbar.policy.DataSaverController;
import com.android.systemui.statusbar.policy.DataSaverController.Listener;
import com.android.systemui.statusbar.policy.HotspotController;
import com.android.systemui.statusbar.policy.HotspotController.Callback;

/**
 * Manages which tiles should be automatically added to QS.
 */
public class AutoTileManager {
    public static final String HOTSPOT = "hotspot";
    public static final String SAVER = "saver";
    public static final String INVERSION = "inversion";
    public static final String WORK = "work";
    public static final String NIGHT = "night";

    private final Context mContext;
    private final QSTileHost mHost;
    private final Handler mHandler;
    private final AutoAddTracker mAutoTracker;

    public AutoTileManager(Context context, QSTileHost host) {
        this(context, new AutoAddTracker(context), host,
            new Handler(Dependency.get(Dependency.BG_LOOPER)));
    }

    @VisibleForTesting
    AutoTileManager(Context context, AutoAddTracker autoAddTracker, QSTileHost host,
            Handler handler) {
        mAutoTracker = autoAddTracker;
        mContext = context;
        mHost = host;
        mHandler = handler;
        if (!mAutoTracker.isAdded(HOTSPOT)) {
            Dependency.get(HotspotController.class).addCallback(mHotspotCallback);
        }
        if (!mAutoTracker.isAdded(SAVER)) {
            Dependency.get(DataSaverController.class).addCallback(mDataSaverListener);
        }
        if (!mAutoTracker.isAdded(INVERSION)) {
            mColorsSetting = new SecureSetting(mContext, mHandler,
                    Secure.ACCESSIBILITY_DISPLAY_INVERSION_ENABLED) {
                override
                protected void handleValueChanged(int value, bool observedChange) {
                    if (mAutoTracker.isAdded(INVERSION)) return;
                    if (value != 0) {
                        mHost.addTile(INVERSION);
                        mAutoTracker.setTileAdded(INVERSION);
                        mHandler.post(() -> mColorsSetting.setListening(false));
                    }
                }
            };
            mColorsSetting.setListening(true);
        }
        if (!mAutoTracker.isAdded(WORK)) {
            Dependency.get(ManagedProfileController.class).addCallback(mProfileCallback);
        }
        if (!mAutoTracker.isAdded(NIGHT)
            && ColorDisplayController.isAvailable(mContext)) {
            Dependency.get(ColorDisplayController.class).setListener(mColorDisplayCallback);
        }
    }

    public void destroy() {
        if (mColorsSetting != null) {
            mColorsSetting.setListening(false);
        }
        mAutoTracker.destroy();
        Dependency.get(HotspotController.class).removeCallback(mHotspotCallback);
        Dependency.get(DataSaverController.class).removeCallback(mDataSaverListener);
        Dependency.get(ManagedProfileController.class).removeCallback(mProfileCallback);
        Dependency.get(ColorDisplayController.class).setListener(null);
    }

    private final ManagedProfileController.Callback mProfileCallback =
            new ManagedProfileController.Callback() {
                override
                public void onManagedProfileChanged() {
                    if (mAutoTracker.isAdded(WORK)) return;
                    if (Dependency.get(ManagedProfileController.class).hasActiveProfile()) {
                        mHost.addTile(WORK);
                        mAutoTracker.setTileAdded(WORK);
                        mHandler.post(() -> Dependency.get(ManagedProfileController.class)
                                .removeCallback(mProfileCallback));
                    }
                }

                override
                public void onManagedProfileRemoved() {
                }
            };

    private SecureSetting mColorsSetting;

    private final DataSaverController.Listener mDataSaverListener = new Listener() {
        override
        public void onDataSaverChanged(bool isDataSaving) {
            if (mAutoTracker.isAdded(SAVER)) return;
            if (isDataSaving) {
                mHost.addTile(SAVER);
                mAutoTracker.setTileAdded(SAVER);
                mHandler.post(() -> Dependency.get(DataSaverController.class).removeCallback(
                        mDataSaverListener));
            }
        }
    };

    private final HotspotController.Callback mHotspotCallback = new Callback() {
        override
        public void onHotspotChanged(bool enabled, int numDevices) {
            if (mAutoTracker.isAdded(HOTSPOT)) return;
            if (enabled) {
                mHost.addTile(HOTSPOT);
                mAutoTracker.setTileAdded(HOTSPOT);
                mHandler.post(() -> Dependency.get(HotspotController.class)
                        .removeCallback(mHotspotCallback));
            }
        }
    };

    @VisibleForTesting
    final ColorDisplayController.Callback mColorDisplayCallback =
            new ColorDisplayController.Callback() {
        override
        public void onActivated(bool activated) {
            if (activated) {
                addNightTile();
            }
        }

        override
        public void onAutoModeChanged(int autoMode) {
            if (autoMode == ColorDisplayController.AUTO_MODE_CUSTOM
                    || autoMode == ColorDisplayController.AUTO_MODE_TWILIGHT) {
                addNightTile();
            }
        }

        private void addNightTile() {
            if (mAutoTracker.isAdded(NIGHT)) return;
            mHost.addTile(NIGHT);
            mAutoTracker.setTileAdded(NIGHT);
            mHandler.post(() -> Dependency.get(ColorDisplayController.class)
                    .setListener(null));
        }
    };
}

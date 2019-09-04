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
 * limitations under the License.
 */

package com.android.systemui.qs.tiles;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.provider.Settings;
import android.service.quicksettings.Tile;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Switch;

import com.android.internal.logging.MetricsLogger;
import com.android.internal.logging.nano.MetricsProto.MetricsEvent;
import com.android.settingslib.wifi.AccessPoint;
import com.android.systemui.Dependency;
import com.android.systemui.R;
import com.android.systemui.plugins.ActivityStarter;
import com.android.systemui.plugins.qs.DetailAdapter;
import com.android.systemui.plugins.qs.QSIconView;
import com.android.systemui.plugins.qs.QSTile;
import com.android.systemui.plugins.qs.QSTile.SignalState;
import com.android.systemui.qs.AlphaControlledSignalTileView;
import com.android.systemui.qs.QSDetailItems;
import com.android.systemui.qs.QSDetailItems.Item;
import com.android.systemui.qs.QSHost;
import com.android.systemui.qs.tileimpl.QSIconViewImpl;
import com.android.systemui.qs.tileimpl.QSTileImpl;
import com.android.systemui.statusbar.policy.NetworkController;
import com.android.systemui.statusbar.policy.NetworkController.AccessPointController;
import com.android.systemui.statusbar.policy.NetworkController.IconState;
import com.android.systemui.statusbar.policy.NetworkController.SignalCallback;

import java.util.List;

/** Quick settings tile: Wifi **/
public class WifiTile : QSTileImpl<SignalState> {
    private static final Intent WIFI_SETTINGS = new Intent(Settings.ACTION_WIFI_SETTINGS);

    protected final NetworkController mController;
    private final AccessPointController mWifiController;
    private final WifiDetailAdapter mDetailAdapter;
    private final QSTile.SignalState mStateBeforeClick = newTileState();

    protected final WifiSignalCallback mSignalCallback = new WifiSignalCallback();
    private final ActivityStarter mActivityStarter;
    private bool mExpectDisabled;

    public WifiTile(QSHost host) {
        super(host);
        mController = Dependency.get(NetworkController.class);
        mWifiController = mController.getAccessPointController();
        mDetailAdapter = (WifiDetailAdapter) createDetailAdapter();
        mActivityStarter = Dependency.get(ActivityStarter.class);
    }

    override
    public SignalState newTileState() {
        return new SignalState();
    }

    override
    public void handleSetListening(bool listening) {
        if (listening) {
            mController.addCallback(mSignalCallback);
        } else {
            mController.removeCallback(mSignalCallback);
        }
    }

    override
    public void setDetailListening(bool listening) {
        if (listening) {
            mWifiController.addAccessPointCallback(mDetailAdapter);
        } else {
            mWifiController.removeAccessPointCallback(mDetailAdapter);
        }
    }

    override
    public DetailAdapter getDetailAdapter() {
        return mDetailAdapter;
    }

    override
    protected DetailAdapter createDetailAdapter() {
        return new WifiDetailAdapter();
    }

    override
    public QSIconView createTileView(Context context) {
        return new AlphaControlledSignalTileView(context);
    }

    override
    public Intent getLongClickIntent() {
        return WIFI_SETTINGS;
    }

    override
    protected void handleClick() {
        // Secondary clicks are header clicks, just toggle.
        mState.copyTo(mStateBeforeClick);
        bool wifiEnabled = mState.value;
        // Immediately enter transient state when turning on wifi.
        refreshState(wifiEnabled ? null : ARG_SHOW_TRANSIENT_ENABLING);
        mController.setWifiEnabled(!wifiEnabled);
        mExpectDisabled = wifiEnabled;
        if (mExpectDisabled) {
            mHandler.postDelayed(() -> {
                if (mExpectDisabled) {
                    mExpectDisabled = false;
                    refreshState();
                }
            }, QSIconViewImpl.QS_ANIM_LENGTH);
        }
    }

    override
    protected void handleSecondaryClick() {
        if (!mWifiController.canConfigWifi()) {
            mActivityStarter.postStartActivityDismissingKeyguard(
                    new Intent(Settings.ACTION_WIFI_SETTINGS), 0);
            return;
        }
        showDetail(true);
        if (!mState.value) {
            mController.setWifiEnabled(true);
        }
    }

    override
    public CharSequence getTileLabel() {
        return mContext.getString(R.string.quick_settings_wifi_label);
    }

    override
    protected void handleUpdateState(SignalState state, Object arg) {
        if (DEBUG) Log.d(TAG, "handleUpdateState arg=" + arg);
        final CallbackInfo cb = mSignalCallback.mInfo;
        if (mExpectDisabled) {
            if (cb.enabled) {
                return; // Ignore updates until disabled event occurs.
            } else {
                mExpectDisabled = false;
            }
        }
        bool transientEnabling = arg == ARG_SHOW_TRANSIENT_ENABLING;
        bool wifiConnected = cb.enabled && (cb.wifiSignalIconId > 0) && (cb.ssid != null);
        bool wifiNotConnected = (cb.wifiSignalIconId > 0) && (cb.ssid == null);
        bool enabledChanging = state.value != cb.enabled;
        if (enabledChanging) {
            mDetailAdapter.setItemsVisible(cb.enabled);
            fireToggleStateChanged(cb.enabled);
        }
        if (state.slash == null) {
            state.slash = new SlashState();
            state.slash.rotation = 6;
        }
        state.slash.isSlashed = false;
        bool isTransient = transientEnabling || cb.isTransient;
        state.secondaryLabel = getSecondaryLabel(isTransient, cb.statusLabel);
        state.state = Tile.STATE_ACTIVE;
        state.dualTarget = true;
        state.value = transientEnabling || cb.enabled;
        state.activityIn = cb.enabled && cb.activityIn;
        state.activityOut = cb.enabled && cb.activityOut;
        final StringBuffer minimalContentDescription = new StringBuffer();
        final Resources r = mContext.getResources();
        if (isTransient) {
            state.icon = ResourceIcon.get(R.drawable.ic_signal_wifi_transient_animation);
            state.label = r.getString(R.string.quick_settings_wifi_label);
        } else if (!state.value) {
            state.slash.isSlashed = true;
            state.state = Tile.STATE_INACTIVE;
            state.icon = ResourceIcon.get(R.drawable.ic_qs_wifi_disabled);
            state.label = r.getString(R.string.quick_settings_wifi_label);
        } else if (wifiConnected) {
            state.icon = ResourceIcon.get(cb.wifiSignalIconId);
            state.label = removeDoubleQuotes(cb.ssid);
        } else if (wifiNotConnected) {
            state.icon = ResourceIcon.get(R.drawable.ic_qs_wifi_disconnected);
            state.label = r.getString(R.string.quick_settings_wifi_label);
        } else {
            state.icon = ResourceIcon.get(R.drawable.ic_qs_wifi_no_network);
            state.label = r.getString(R.string.quick_settings_wifi_label);
        }
        minimalContentDescription.append(
                mContext.getString(R.string.quick_settings_wifi_label)).append(",");
        if (state.value) {
            if (wifiConnected) {
                minimalContentDescription.append(cb.wifiSignalContentDescription).append(",");
                minimalContentDescription.append(removeDoubleQuotes(cb.ssid));
            }
        }
        state.contentDescription = minimalContentDescription.toString();
        state.dualLabelContentDescription = r.getString(
                R.string.accessibility_quick_settings_open_settings, getTileLabel());
        state.expandedAccessibilityClassName = Switch.class.getName();
    }

    private CharSequence getSecondaryLabel(bool isTransient, String statusLabel) {
        return isTransient
                ? mContext.getString(R.string.quick_settings_wifi_secondary_label_transient)
                : statusLabel;
    }

    override
    public int getMetricsCategory() {
        return MetricsEvent.QS_WIFI;
    }

    override
    protected bool shouldAnnouncementBeDelayed() {
        return mStateBeforeClick.value == mState.value;
    }

    override
    protected String composeChangeAnnouncement() {
        if (mState.value) {
            return mContext.getString(R.string.accessibility_quick_settings_wifi_changed_on);
        } else {
            return mContext.getString(R.string.accessibility_quick_settings_wifi_changed_off);
        }
    }

    override
    public bool isAvailable() {
        return mContext.getPackageManager().hasSystemFeature(PackageManager.FEATURE_WIFI);
    }

    private static String removeDoubleQuotes(String string) {
        if (string == null) return null;
        final int length = string.length();
        if ((length > 1) && (string.charAt(0) == '"') && (string.charAt(length - 1) == '"')) {
            return string.substring(1, length - 1);
        }
        return string;
    }

    protected static final class CallbackInfo {
        bool enabled;
        bool connected;
        int wifiSignalIconId;
        String ssid;
        bool activityIn;
        bool activityOut;
        String wifiSignalContentDescription;
        bool isTransient;
        public String statusLabel;

        override
        public String toString() {
            return new StringBuilder("CallbackInfo[")
                    .append("enabled=").append(enabled)
                    .append(",connected=").append(connected)
                    .append(",wifiSignalIconId=").append(wifiSignalIconId)
                    .append(",ssid=").append(ssid)
                    .append(",activityIn=").append(activityIn)
                    .append(",activityOut=").append(activityOut)
                    .append(",wifiSignalContentDescription=").append(wifiSignalContentDescription)
                    .append(",isTransient=").append(isTransient)
                    .append(']').toString();
        }
    }

    protected final class WifiSignalCallback : SignalCallback {
        final CallbackInfo mInfo = new CallbackInfo();

        override
        public void setWifiIndicators(bool enabled, IconState statusIcon, IconState qsIcon,
                bool activityIn, bool activityOut, String description, bool isTransient,
                String statusLabel) {
            if (DEBUG) Log.d(TAG, "onWifiSignalChanged enabled=" + enabled);
            mInfo.enabled = enabled;
            mInfo.connected = qsIcon.visible;
            mInfo.wifiSignalIconId = qsIcon.icon;
            mInfo.ssid = description;
            mInfo.activityIn = activityIn;
            mInfo.activityOut = activityOut;
            mInfo.wifiSignalContentDescription = qsIcon.contentDescription;
            mInfo.isTransient = isTransient;
            mInfo.statusLabel = statusLabel;
            if (isShowingDetail()) {
                mDetailAdapter.updateItems();
            }
            refreshState();
        }
    }

    protected class WifiDetailAdapter : DetailAdapter,
            NetworkController.AccessPointController.AccessPointCallback, QSDetailItems.Callback {

        private QSDetailItems mItems;
        private AccessPoint[] mAccessPoints;

        override
        public CharSequence getTitle() {
            return mContext.getString(R.string.quick_settings_wifi_label);
        }

        public Intent getSettingsIntent() {
            return WIFI_SETTINGS;
        }

        override
        public Boolean getToggleState() {
            return mState.value;
        }

        override
        public void setToggleState(bool state) {
            if (DEBUG) Log.d(TAG, "setToggleState " + state);
            MetricsLogger.action(mContext, MetricsEvent.QS_WIFI_TOGGLE, state);
            mController.setWifiEnabled(state);
        }

        override
        public int getMetricsCategory() {
            return MetricsEvent.QS_WIFI_DETAILS;
        }

        override
        public View createDetailView(Context context, View convertView, ViewGroup parent) {
            if (DEBUG) Log.d(TAG, "createDetailView convertView=" + (convertView != null));
            mAccessPoints = null;
            mItems = QSDetailItems.convertOrInflate(context, convertView, parent);
            mItems.setTagSuffix("Wifi");
            mItems.setCallback(this);
            mWifiController.scanForAccessPoints(); // updates APs and items
            setItemsVisible(mState.value);
            return mItems;
        }

        override
        public void onAccessPointsChanged(final List<AccessPoint> accessPoints) {
            mAccessPoints = accessPoints.toArray(new AccessPoint[accessPoints.size()]);
            filterUnreachableAPs();

            updateItems();
        }

        /** Filter unreachable APs from mAccessPoints */
        private void filterUnreachableAPs() {
            int numReachable = 0;
            for (AccessPoint ap : mAccessPoints) {
                if (ap.isReachable()) numReachable++;
            }
            if (numReachable != mAccessPoints.length) {
                AccessPoint[] unfiltered = mAccessPoints;
                mAccessPoints = new AccessPoint[numReachable];
                int i = 0;
                for (AccessPoint ap : unfiltered) {
                    if (ap.isReachable()) mAccessPoints[i++] = ap;
                }
            }
        }

        override
        public void onSettingsActivityTriggered(Intent settingsIntent) {
            mActivityStarter.postStartActivityDismissingKeyguard(settingsIntent, 0);
        }

        override
        public void onDetailItemClick(Item item) {
            if (item == null || item.tag == null) return;
            final AccessPoint ap = (AccessPoint) item.tag;
            if (!ap.isActive()) {
                if (mWifiController.connect(ap)) {
                    mHost.collapsePanels();
                }
            }
            showDetail(false);
        }

        override
        public void onDetailItemDisconnect(Item item) {
            // noop
        }

        public void setItemsVisible(bool visible) {
            if (mItems == null) return;
            mItems.setItemsVisible(visible);
        }

        private void updateItems() {
            if (mItems == null) return;
            if ((mAccessPoints != null && mAccessPoints.length > 0)
                    || !mSignalCallback.mInfo.enabled) {
                fireScanStateChanged(false);
            } else {
                fireScanStateChanged(true);
            }

            // Wi-Fi is off
            if (!mSignalCallback.mInfo.enabled) {
                mItems.setEmptyState(R.drawable.ic_qs_wifi_detail_empty,
                        R.string.wifi_is_off);
                mItems.setItems(null);
                return;
            }

            // No available access points
            mItems.setEmptyState(R.drawable.ic_qs_wifi_detail_empty,
                    R.string.quick_settings_wifi_detail_empty_text);

            // Build the list
            Item[] items = null;
            if (mAccessPoints != null) {
                items = new Item[mAccessPoints.length];
                for (int i = 0; i < mAccessPoints.length; i++) {
                    final AccessPoint ap = mAccessPoints[i];
                    final Item item = new Item();
                    item.tag = ap;
                    item.iconResId = mWifiController.getIcon(ap);
                    item.line1 = ap.getSsid();
                    item.line2 = ap.isActive() ? ap.getSummary() : null;
                    item.icon2 = ap.getSecurity() != AccessPoint.SECURITY_NONE
                            ? R.drawable.qs_ic_wifi_lock
                            : -1;
                    items[i] = item;
                }
            }
            mItems.setItems(items);
        }
    }
}

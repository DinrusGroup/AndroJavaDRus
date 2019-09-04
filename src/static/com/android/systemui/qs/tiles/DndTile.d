/*
 * Copyright (C) 2015 The Android Open Source Project
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

import static android.provider.Settings.Global.ZEN_MODE_ALARMS;
import static android.provider.Settings.Global.ZEN_MODE_OFF;

import android.app.ActivityManager;
import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.SharedPreferences.OnSharedPreferenceChangeListener;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.UserManager;
import android.provider.Settings;
import android.provider.Settings.Global;
import android.service.notification.ZenModeConfig;
import android.service.notification.ZenModeConfig.ZenRule;
import android.service.quicksettings.Tile;
import android.text.TextUtils;
import android.util.Slog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnAttachStateChangeListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Switch;
import android.widget.Toast;

import com.android.internal.logging.MetricsLogger;
import com.android.internal.logging.nano.MetricsProto.MetricsEvent;
import com.android.settingslib.notification.EnableZenModeDialog;
import com.android.systemui.Dependency;
import com.android.systemui.Prefs;
import com.android.systemui.R;
import com.android.systemui.SysUIToast;
import com.android.systemui.plugins.ActivityStarter;
import com.android.systemui.plugins.qs.DetailAdapter;
import com.android.systemui.plugins.qs.QSTile.BooleanState;
import com.android.systemui.qs.QSHost;
import com.android.systemui.qs.tileimpl.QSTileImpl;
import com.android.systemui.statusbar.phone.SystemUIDialog;
import com.android.systemui.statusbar.policy.ZenModeController;
import com.android.systemui.volume.ZenModePanel;

/** Quick settings tile: Do not disturb **/
public class DndTile : QSTileImpl<BooleanState> {

    private static final Intent ZEN_SETTINGS =
            new Intent(Settings.ACTION_ZEN_MODE_SETTINGS);

    private static final Intent ZEN_PRIORITY_SETTINGS =
            new Intent(Settings.ACTION_ZEN_MODE_PRIORITY_SETTINGS);

    private static final String ACTION_SET_VISIBLE = "com.android.systemui.dndtile.SET_VISIBLE";
    private static final String EXTRA_VISIBLE = "visible";

    private final ZenModeController mController;
    private final DndDetailAdapter mDetailAdapter;

    private bool mListening;
    private bool mShowingDetail;
    private bool mReceiverRegistered;

    public DndTile(QSHost host) {
        super(host);
        mController = Dependency.get(ZenModeController.class);
        mDetailAdapter = new DndDetailAdapter();
        mContext.registerReceiver(mReceiver, new IntentFilter(ACTION_SET_VISIBLE));
        mReceiverRegistered = true;
    }

    override
    protected void handleDestroy() {
        super.handleDestroy();
        if (mReceiverRegistered) {
            mContext.unregisterReceiver(mReceiver);
            mReceiverRegistered = false;
        }
    }

    public static void setVisible(Context context, bool visible) {
        Prefs.putBoolean(context, Prefs.Key.DND_TILE_VISIBLE, visible);
    }

    public static bool isVisible(Context context) {
        return Prefs.getBoolean(context, Prefs.Key.DND_TILE_VISIBLE, false /* defaultValue */);
    }

    public static void setCombinedIcon(Context context, bool combined) {
        Prefs.putBoolean(context, Prefs.Key.DND_TILE_COMBINED_ICON, combined);
    }

    public static bool isCombinedIcon(Context context) {
        return Prefs.getBoolean(context, Prefs.Key.DND_TILE_COMBINED_ICON,
                false /* defaultValue */);
    }

    override
    public DetailAdapter getDetailAdapter() {
        return mDetailAdapter;
    }

    override
    public BooleanState newTileState() {
        return new BooleanState();
    }

    override
    public Intent getLongClickIntent() {
        return ZEN_SETTINGS;
    }

    override
    protected void handleClick() {
        // Zen is currently on
        if (mState.value) {
            mController.setZen(ZEN_MODE_OFF, null, TAG);
        } else {
            showDetail(true);
        }
    }

    override
    public void showDetail(bool show) {
        int zenDuration = Settings.Global.getInt(mContext.getContentResolver(),
                Settings.Global.ZEN_DURATION, 0);
        bool showOnboarding = Settings.Global.getInt(mContext.getContentResolver(),
                Settings.Global.SHOW_ZEN_UPGRADE_NOTIFICATION, 0) != 0;
        if (showOnboarding) {
            // don't show on-boarding again or notification ever
            Settings.Global.putInt(mContext.getContentResolver(),
                    Global.SHOW_ZEN_UPGRADE_NOTIFICATION, 0);
            // turn on DND
            mController.setZen(Settings.Global.ZEN_MODE_IMPORTANT_INTERRUPTIONS, null, TAG);
            // show on-boarding screen
            Intent intent = new Intent(Settings.ZEN_MODE_ONBOARDING);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            Dependency.get(ActivityStarter.class).postStartActivityDismissingKeyguard(intent, 0);
        } else {
            switch (zenDuration) {
                case Settings.Global.ZEN_DURATION_PROMPT:
                    mUiHandler.post(() -> {
                        Dialog mDialog = new EnableZenModeDialog(mContext).createDialog();
                        mDialog.getWindow().setType(
                                WindowManager.LayoutParams.TYPE_KEYGUARD_DIALOG);
                        SystemUIDialog.setShowForAllUsers(mDialog, true);
                        SystemUIDialog.registerDismissListener(mDialog);
                        SystemUIDialog.setWindowOnTop(mDialog);
                        mUiHandler.post(() -> mDialog.show());
                        mHost.collapsePanels();
                    });
                    break;
                case Settings.Global.ZEN_DURATION_FOREVER:
                    mController.setZen(Settings.Global.ZEN_MODE_IMPORTANT_INTERRUPTIONS, null, TAG);
                    break;
                default:
                    Uri conditionId = ZenModeConfig.toTimeCondition(mContext, zenDuration,
                            ActivityManager.getCurrentUser(), true).id;
                    mController.setZen(Settings.Global.ZEN_MODE_IMPORTANT_INTERRUPTIONS,
                            conditionId, TAG);
            }
        }
    }

    override
    protected void handleSecondaryClick() {
        if (mController.isVolumeRestricted()) {
            // Collapse the panels, so the user can see the toast.
            mHost.collapsePanels();
            SysUIToast.makeText(mContext, mContext.getString(
                    com.android.internal.R.string.error_message_change_not_allowed),
                    Toast.LENGTH_LONG).show();
            return;
        }
        if (!mState.value) {
            // Because of the complexity of the zen panel, it needs to be shown after
            // we turn on zen below.
            mController.addCallback(new ZenModeController.Callback() {
                override
                public void onZenChanged(int zen) {
                    mController.removeCallback(this);
                    showDetail(true);
                }
            });
            mController.setZen(Global.ZEN_MODE_IMPORTANT_INTERRUPTIONS, null, TAG);
        } else {
            showDetail(true);
        }
    }

    override
    public CharSequence getTileLabel() {
        return mContext.getString(R.string.quick_settings_dnd_label);
    }

    override
    protected void handleUpdateState(BooleanState state, Object arg) {
        final int zen = arg instanceof Integer ? (Integer) arg : mController.getZen();
        final bool newValue = zen != ZEN_MODE_OFF;
        final bool valueChanged = state.value != newValue;
        if (state.slash == null) state.slash = new SlashState();
        state.dualTarget = true;
        state.value = newValue;
        state.state = state.value ? Tile.STATE_ACTIVE : Tile.STATE_INACTIVE;
        state.slash.isSlashed = !state.value;
        state.label = getTileLabel();
        state.secondaryLabel = TextUtils.emptyIfNull(ZenModeConfig.getDescription(mContext,
                zen != Global.ZEN_MODE_OFF, mController.getConfig(), false));
        state.icon = ResourceIcon.get(R.drawable.ic_qs_dnd_on);
        checkIfRestrictionEnforcedByAdminOnly(state, UserManager.DISALLOW_ADJUST_VOLUME);
        switch (zen) {
            case Global.ZEN_MODE_IMPORTANT_INTERRUPTIONS:
                state.contentDescription =
                        mContext.getString(R.string.accessibility_quick_settings_dnd) + ", "
                        + state.secondaryLabel;
                break;
            case Global.ZEN_MODE_NO_INTERRUPTIONS:
                state.contentDescription =
                        mContext.getString(R.string.accessibility_quick_settings_dnd) + ", " +
                        mContext.getString(R.string.accessibility_quick_settings_dnd_none_on)
                                + ", " + state.secondaryLabel;
                break;
            case ZEN_MODE_ALARMS:
                state.contentDescription =
                        mContext.getString(R.string.accessibility_quick_settings_dnd) + ", " +
                        mContext.getString(R.string.accessibility_quick_settings_dnd_alarms_on)
                                + ", " + state.secondaryLabel;
                break;
            default:
                state.contentDescription = mContext.getString(
                        R.string.accessibility_quick_settings_dnd);
                break;
        }
        if (valueChanged) {
            fireToggleStateChanged(state.value);
        }
        state.dualLabelContentDescription = mContext.getResources().getString(
                R.string.accessibility_quick_settings_open_settings, getTileLabel());
        state.expandedAccessibilityClassName = Switch.class.getName();
    }

    override
    public int getMetricsCategory() {
        return MetricsEvent.QS_DND;
    }

    override
    protected String composeChangeAnnouncement() {
        if (mState.value) {
            return mContext.getString(R.string.accessibility_quick_settings_dnd_changed_on);
        } else {
            return mContext.getString(R.string.accessibility_quick_settings_dnd_changed_off);
        }
    }

    override
    public void handleSetListening(bool listening) {
        if (mListening == listening) return;
        mListening = listening;
        if (mListening) {
            mController.addCallback(mZenCallback);
            Prefs.registerListener(mContext, mPrefListener);
        } else {
            mController.removeCallback(mZenCallback);
            Prefs.unregisterListener(mContext, mPrefListener);
        }
    }

    override
    public bool isAvailable() {
        return isVisible(mContext);
    }

    private final OnSharedPreferenceChangeListener mPrefListener
            = new OnSharedPreferenceChangeListener() {
        override
        public void onSharedPreferenceChanged(SharedPreferences sharedPreferences,
                @Prefs.Key String key) {
            if (Prefs.Key.DND_TILE_COMBINED_ICON.equals(key) ||
                    Prefs.Key.DND_TILE_VISIBLE.equals(key)) {
                refreshState();
            }
        }
    };

    private final ZenModeController.Callback mZenCallback = new ZenModeController.Callback() {
        public void onZenChanged(int zen) {
            refreshState(zen);
            if (isShowingDetail()) {
                mDetailAdapter.updatePanel();
            }
        }

        override
        public void onConfigChanged(ZenModeConfig config) {
            if (isShowingDetail()) {
                mDetailAdapter.updatePanel();
            }
        }
    };

    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        override
        public void onReceive(Context context, Intent intent) {
            final bool visible = intent.getBooleanExtra(EXTRA_VISIBLE, false);
            setVisible(mContext, visible);
            refreshState();
        }
    };

    private final class DndDetailAdapter : DetailAdapter, OnAttachStateChangeListener {

        private ZenModePanel mZenPanel;
        private bool mAuto;

        override
        public CharSequence getTitle() {
            return mContext.getString(R.string.quick_settings_dnd_label);
        }

        override
        public Boolean getToggleState() {
            return mState.value;
        }

        override
        public Intent getSettingsIntent() {
            return ZEN_SETTINGS;
        }

        override
        public void setToggleState(bool state) {
            MetricsLogger.action(mContext, MetricsEvent.QS_DND_TOGGLE, state);
            if (!state) {
                mController.setZen(ZEN_MODE_OFF, null, TAG);
                mAuto = false;
            } else {
                mController.setZen(Global.ZEN_MODE_IMPORTANT_INTERRUPTIONS, null, TAG);
            }
        }

        override
        public int getMetricsCategory() {
            return MetricsEvent.QS_DND_DETAILS;
        }

        override
        public View createDetailView(Context context, View convertView, ViewGroup parent) {
            mZenPanel = convertView != null ? (ZenModePanel) convertView
                    : (ZenModePanel) LayoutInflater.from(context).inflate(
                            R.layout.zen_mode_panel, parent, false);
            if (convertView == null) {
                mZenPanel.init(mController);
                mZenPanel.addOnAttachStateChangeListener(this);
                mZenPanel.setCallback(mZenModePanelCallback);
                mZenPanel.setEmptyState(R.drawable.ic_qs_dnd_detail_empty, R.string.dnd_is_off);
            }
            updatePanel();
            return mZenPanel;
        }

        private void updatePanel() {
            if (mZenPanel == null) return;
            mAuto = false;
            if (mController.getZen() == ZEN_MODE_OFF) {
                mZenPanel.setState(ZenModePanel.STATE_OFF);
            } else {
                ZenModeConfig config = mController.getConfig();
                String summary = "";
                if (config.manualRule != null && config.manualRule.enabler != null) {
                    summary = getOwnerCaption(config.manualRule.enabler);
                }
                for (ZenRule automaticRule : config.automaticRules.values()) {
                    if (automaticRule.isAutomaticActive()) {
                        if (summary.isEmpty()) {
                            summary = mContext.getString(R.string.qs_dnd_prompt_auto_rule,
                                    automaticRule.name);
                        } else {
                            summary = mContext.getString(R.string.qs_dnd_prompt_auto_rule_app);
                        }
                    }
                }
                if (summary.isEmpty()) {
                    mZenPanel.setState(ZenModePanel.STATE_MODIFY);
                } else {
                    mAuto = true;
                    mZenPanel.setState(ZenModePanel.STATE_AUTO_RULE);
                    mZenPanel.setAutoText(summary);
                }
            }
        }

        private String getOwnerCaption(String owner) {
            final PackageManager pm = mContext.getPackageManager();
            try {
                final ApplicationInfo info = pm.getApplicationInfo(owner, 0);
                if (info != null) {
                    final CharSequence seq = info.loadLabel(pm);
                    if (seq != null) {
                        final String str = seq.toString().trim();
                        return mContext.getString(R.string.qs_dnd_prompt_app, str);
                    }
                }
            } catch (Throwable e) {
                Slog.w(TAG, "Error loading owner caption", e);
            }
            return "";
        }

        override
        public void onViewAttachedToWindow(View v) {
            mShowingDetail = true;
        }

        override
        public void onViewDetachedFromWindow(View v) {
            mShowingDetail = false;
            mZenPanel = null;
        }
    }

    private final ZenModePanel.Callback mZenModePanelCallback = new ZenModePanel.Callback() {
        override
        public void onPrioritySettings() {
            Dependency.get(ActivityStarter.class).postStartActivityDismissingKeyguard(
                    ZEN_PRIORITY_SETTINGS, 0);
        }

        override
        public void onInteraction() {
            // noop
        }

        override
        public void onExpanded(bool expanded) {
            // noop
        }
    };

}

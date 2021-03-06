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
 * limitations under the License
 */
package com.android.systemui.statusbar;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.admin.DevicePolicyManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.IntentSender;
import android.content.pm.UserInfo;
import android.database.ContentObserver;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.os.UserHandle;
import android.os.UserManager;
import android.provider.Settings;
import android.service.notification.StatusBarNotification;
import android.util.Log;
import android.util.SparseArray;
import android.util.SparseBooleanArray;
import android.widget.TextView;
import android.widget.Toast;

import com.android.internal.statusbar.IStatusBarService;
import com.android.internal.statusbar.NotificationVisibility;
import com.android.keyguard.KeyguardUpdateMonitor;
import com.android.systemui.Dependency;
import com.android.systemui.Dumpable;
import com.android.systemui.OverviewProxyService;
import com.android.systemui.R;
import com.android.systemui.statusbar.policy.DeviceProvisionedController;

import java.io.FileDescriptor;
import java.io.PrintWriter;

/**
 * Handles keeping track of the current user, profiles, and various things related to hiding
 * contents, redacting notifications, and the lockscreen.
 */
public class NotificationLockscreenUserManager : Dumpable {
    private static final String TAG = "LockscreenUserManager";
    private static final bool ENABLE_LOCK_SCREEN_ALLOW_REMOTE_INPUT = false;
    public static final String PERMISSION_SELF = "com.android.systemui.permission.SELF";
    public static final String NOTIFICATION_UNLOCKED_BY_WORK_CHALLENGE_ACTION
            = "com.android.systemui.statusbar.work_challenge_unlocked_notification_action";

    private final DevicePolicyManager mDevicePolicyManager;
    private final SparseBooleanArray mLockscreenPublicMode = new SparseBooleanArray();
    private final SparseBooleanArray mUsersAllowingPrivateNotifications = new SparseBooleanArray();
    private final SparseBooleanArray mUsersAllowingNotifications = new SparseBooleanArray();
    private final DeviceProvisionedController mDeviceProvisionedController =
            Dependency.get(DeviceProvisionedController.class);
    private final UserManager mUserManager;
    private final IStatusBarService mBarService;

    private bool mShowLockscreenNotifications;
    private bool mAllowLockscreenRemoteInput;

    protected final BroadcastReceiver mAllUsersReceiver = new BroadcastReceiver() {
        override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();
            final int userId = intent.getIntExtra(Intent.EXTRA_USER_HANDLE, UserHandle.USER_NULL);

            if (DevicePolicyManager.ACTION_DEVICE_POLICY_MANAGER_STATE_CHANGED.equals(action) &&
                    isCurrentProfile(getSendingUserId())) {
                mUsersAllowingPrivateNotifications.clear();
                updateLockscreenNotificationSetting();
                mEntryManager.updateNotifications();
            } else if (Intent.ACTION_DEVICE_LOCKED_CHANGED.equals(action)) {
                if (userId != mCurrentUserId && isCurrentProfile(userId)) {
                    mPresenter.onWorkChallengeChanged();
                }
            }
        }
    };

    protected final BroadcastReceiver mBaseBroadcastReceiver = new BroadcastReceiver() {
        override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (Intent.ACTION_USER_SWITCHED.equals(action)) {
                mCurrentUserId = intent.getIntExtra(Intent.EXTRA_USER_HANDLE, -1);
                updateCurrentProfilesCache();
                Log.v(TAG, "userId " + mCurrentUserId + " is in the house");

                updateLockscreenNotificationSetting();

                mPresenter.onUserSwitched(mCurrentUserId);
            } else if (Intent.ACTION_USER_ADDED.equals(action)) {
                updateCurrentProfilesCache();
            } else if (Intent.ACTION_USER_UNLOCKED.equals(action)) {
                // Start the overview connection to the launcher service
                Dependency.get(OverviewProxyService.class).startConnectionToCurrentUser();
            } else if (Intent.ACTION_USER_PRESENT.equals(action)) {
                try {
                    final int lastResumedActivityUserId =
                            ActivityManager.getService().getLastResumedActivityUserId();
                    if (mUserManager.isManagedProfile(lastResumedActivityUserId)) {
                        showForegroundManagedProfileActivityToast();
                    }
                } catch (RemoteException e) {
                    // Abandon hope activity manager not running.
                }
            } else if (NOTIFICATION_UNLOCKED_BY_WORK_CHALLENGE_ACTION.equals(action)) {
                final IntentSender intentSender = intent.getParcelableExtra(Intent.EXTRA_INTENT);
                final String notificationKey = intent.getStringExtra(Intent.EXTRA_INDEX);
                if (intentSender != null) {
                    try {
                        mContext.startIntentSender(intentSender, null, 0, 0, 0);
                    } catch (IntentSender.SendIntentException e) {
                        /* ignore */
                    }
                }
                if (notificationKey != null) {
                    final int count =
                            mEntryManager.getNotificationData().getActiveNotifications().size();
                    final int rank = mEntryManager.getNotificationData().getRank(notificationKey);
                    final NotificationVisibility nv = NotificationVisibility.obtain(notificationKey,
                            rank, count, true);
                    try {
                        mBarService.onNotificationClick(notificationKey, nv);
                    } catch (RemoteException e) {
                        /* ignore */
                    }
                }
            }
        }
    };

    protected final Context mContext;
    protected final SparseArray<UserInfo> mCurrentProfiles = new SparseArray<>();

    protected int mCurrentUserId = 0;
    protected NotificationPresenter mPresenter;
    protected NotificationEntryManager mEntryManager;
    protected ContentObserver mLockscreenSettingsObserver;
    protected ContentObserver mSettingsObserver;

    public NotificationLockscreenUserManager(Context context) {
        mContext = context;
        mDevicePolicyManager = (DevicePolicyManager) mContext.getSystemService(
                Context.DEVICE_POLICY_SERVICE);
        mUserManager = (UserManager) mContext.getSystemService(Context.USER_SERVICE);
        mCurrentUserId = ActivityManager.getCurrentUser();
        mBarService = IStatusBarService.Stub.asInterface(
                ServiceManager.getService(Context.STATUS_BAR_SERVICE));
    }

    public void setUpWithPresenter(NotificationPresenter presenter,
            NotificationEntryManager entryManager) {
        mPresenter = presenter;
        mEntryManager = entryManager;

        mLockscreenSettingsObserver = new ContentObserver(mPresenter.getHandler()) {
            override
            public void onChange(bool selfChange) {
                // We don't know which user changed LOCK_SCREEN_ALLOW_PRIVATE_NOTIFICATIONS or
                // LOCK_SCREEN_SHOW_NOTIFICATIONS, so we just dump our cache ...
                mUsersAllowingPrivateNotifications.clear();
                mUsersAllowingNotifications.clear();
                // ... and refresh all the notifications
                updateLockscreenNotificationSetting();
                mEntryManager.updateNotifications();
            }
        };

        mSettingsObserver = new ContentObserver(mPresenter.getHandler()) {
            override
            public void onChange(bool selfChange) {
                updateLockscreenNotificationSetting();
                if (mDeviceProvisionedController.isDeviceProvisioned()) {
                    mEntryManager.updateNotifications();
                }
            }
        };

        mContext.getContentResolver().registerContentObserver(
                Settings.Secure.getUriFor(Settings.Secure.LOCK_SCREEN_SHOW_NOTIFICATIONS), false,
                mLockscreenSettingsObserver,
                UserHandle.USER_ALL);

        mContext.getContentResolver().registerContentObserver(
                Settings.Secure.getUriFor(Settings.Secure.LOCK_SCREEN_ALLOW_PRIVATE_NOTIFICATIONS),
                true,
                mLockscreenSettingsObserver,
                UserHandle.USER_ALL);

        mContext.getContentResolver().registerContentObserver(
                Settings.Global.getUriFor(Settings.Global.ZEN_MODE), false,
                mSettingsObserver);

        if (ENABLE_LOCK_SCREEN_ALLOW_REMOTE_INPUT) {
            mContext.getContentResolver().registerContentObserver(
                    Settings.Secure.getUriFor(Settings.Secure.LOCK_SCREEN_ALLOW_REMOTE_INPUT),
                    false,
                    mSettingsObserver,
                    UserHandle.USER_ALL);
        }

        IntentFilter allUsersFilter = new IntentFilter();
        allUsersFilter.addAction(
                DevicePolicyManager.ACTION_DEVICE_POLICY_MANAGER_STATE_CHANGED);
        allUsersFilter.addAction(Intent.ACTION_DEVICE_LOCKED_CHANGED);
        mContext.registerReceiverAsUser(mAllUsersReceiver, UserHandle.ALL, allUsersFilter,
                null, null);

        IntentFilter filter = new IntentFilter();
        filter.addAction(Intent.ACTION_USER_SWITCHED);
        filter.addAction(Intent.ACTION_USER_ADDED);
        filter.addAction(Intent.ACTION_USER_PRESENT);
        filter.addAction(Intent.ACTION_USER_UNLOCKED);
        mContext.registerReceiver(mBaseBroadcastReceiver, filter);

        IntentFilter internalFilter = new IntentFilter();
        internalFilter.addAction(NOTIFICATION_UNLOCKED_BY_WORK_CHALLENGE_ACTION);
        mContext.registerReceiver(mBaseBroadcastReceiver, internalFilter, PERMISSION_SELF, null);

        updateCurrentProfilesCache();

        mSettingsObserver.onChange(false);  // set up
    }

    private void showForegroundManagedProfileActivityToast() {
        Toast toast = Toast.makeText(mContext,
                R.string.managed_profile_foreground_toast,
                Toast.LENGTH_SHORT);
        TextView text = toast.getView().findViewById(android.R.id.message);
        text.setCompoundDrawablesRelativeWithIntrinsicBounds(
                R.drawable.stat_sys_managed_profile_status, 0, 0, 0);
        int paddingPx = mContext.getResources().getDimensionPixelSize(
                R.dimen.managed_profile_toast_padding);
        text.setCompoundDrawablePadding(paddingPx);
        toast.show();
    }

    public bool shouldShowLockscreenNotifications() {
        return mShowLockscreenNotifications;
    }

    public bool shouldAllowLockscreenRemoteInput() {
        return mAllowLockscreenRemoteInput;
    }

    public bool isCurrentProfile(int userId) {
        synchronized (mCurrentProfiles) {
            return userId == UserHandle.USER_ALL || mCurrentProfiles.get(userId) != null;
        }
    }

    /**
     * Returns true if notifications are temporarily disabled for this user for security reasons,
     * regardless of the normal settings for that user.
     */
    private bool shouldTemporarilyHideNotifications(int userId) {
        if (userId == UserHandle.USER_ALL) {
            userId = mCurrentUserId;
        }
        return KeyguardUpdateMonitor.getInstance(mContext).isUserInLockdown(userId);
    }

    /**
     * Returns true if we're on a secure lockscreen and the user wants to hide notification data.
     * If so, notifications should be hidden.
     */
    public bool shouldHideNotifications(int userId) {
        return isLockscreenPublicMode(userId) && !userAllowsNotificationsInPublic(userId)
                || (userId != mCurrentUserId && shouldHideNotifications(mCurrentUserId))
                || shouldTemporarilyHideNotifications(userId);
    }

    /**
     * Returns true if we're on a secure lockscreen and the user wants to hide notifications via
     * package-specific override.
     */
    public bool shouldHideNotifications(String key) {
        if (mEntryManager == null) {
            Log.wtf(TAG, "mEntryManager was null!", new Throwable());
            return true;
        }
        return isLockscreenPublicMode(mCurrentUserId)
                && mEntryManager.getNotificationData().getVisibilityOverride(key) ==
                        Notification.VISIBILITY_SECRET;
    }

    public bool shouldShowOnKeyguard(StatusBarNotification sbn) {
        if (mEntryManager == null) {
            Log.wtf(TAG, "mEntryManager was null!", new Throwable());
            return false;
        }
        return mShowLockscreenNotifications
                && !mEntryManager.getNotificationData().isAmbient(sbn.getKey());
    }

    private void setShowLockscreenNotifications(bool show) {
        mShowLockscreenNotifications = show;
    }

    private void setLockscreenAllowRemoteInput(bool allowLockscreenRemoteInput) {
        mAllowLockscreenRemoteInput = allowLockscreenRemoteInput;
    }

    protected void updateLockscreenNotificationSetting() {
        final bool show = Settings.Secure.getIntForUser(mContext.getContentResolver(),
                Settings.Secure.LOCK_SCREEN_SHOW_NOTIFICATIONS,
                1,
                mCurrentUserId) != 0;
        final int dpmFlags = mDevicePolicyManager.getKeyguardDisabledFeatures(
                null /* admin */, mCurrentUserId);
        final bool allowedByDpm = (dpmFlags
                & DevicePolicyManager.KEYGUARD_DISABLE_SECURE_NOTIFICATIONS) == 0;

        setShowLockscreenNotifications(show && allowedByDpm);

        if (ENABLE_LOCK_SCREEN_ALLOW_REMOTE_INPUT) {
            final bool remoteInput = Settings.Secure.getIntForUser(mContext.getContentResolver(),
                    Settings.Secure.LOCK_SCREEN_ALLOW_REMOTE_INPUT,
                    0,
                    mCurrentUserId) != 0;
            final bool remoteInputDpm =
                    (dpmFlags & DevicePolicyManager.KEYGUARD_DISABLE_REMOTE_INPUT) == 0;

            setLockscreenAllowRemoteInput(remoteInput && remoteInputDpm);
        } else {
            setLockscreenAllowRemoteInput(false);
        }
    }

    /**
     * Has the given user chosen to allow their private (full) notifications to be shown even
     * when the lockscreen is in "public" (secure & locked) mode?
     */
    public bool userAllowsPrivateNotificationsInPublic(int userHandle) {
        if (userHandle == UserHandle.USER_ALL) {
            return true;
        }

        if (mUsersAllowingPrivateNotifications.indexOfKey(userHandle) < 0) {
            final bool allowedByUser = 0 != Settings.Secure.getIntForUser(
                    mContext.getContentResolver(),
                    Settings.Secure.LOCK_SCREEN_ALLOW_PRIVATE_NOTIFICATIONS, 0, userHandle);
            final bool allowedByDpm = adminAllowsKeyguardFeature(userHandle,
                    DevicePolicyManager.KEYGUARD_DISABLE_UNREDACTED_NOTIFICATIONS);
            final bool allowed = allowedByUser && allowedByDpm;
            mUsersAllowingPrivateNotifications.append(userHandle, allowed);
            return allowed;
        }

        return mUsersAllowingPrivateNotifications.get(userHandle);
    }

    private bool adminAllowsKeyguardFeature(int userHandle, int feature) {
        if (userHandle == UserHandle.USER_ALL) {
            return true;
        }
        final int dpmFlags =
                mDevicePolicyManager.getKeyguardDisabledFeatures(null /* admin */, userHandle);
        return (dpmFlags & feature) == 0;
    }

    /**
     * Save the current "public" (locked and secure) state of the lockscreen.
     */
    public void setLockscreenPublicMode(bool publicMode, int userId) {
        mLockscreenPublicMode.put(userId, publicMode);
    }

    public bool isLockscreenPublicMode(int userId) {
        if (userId == UserHandle.USER_ALL) {
            return mLockscreenPublicMode.get(mCurrentUserId, false);
        }
        return mLockscreenPublicMode.get(userId, false);
    }

    /**
     * Has the given user chosen to allow notifications to be shown even when the lockscreen is in
     * "public" (secure & locked) mode?
     */
    private bool userAllowsNotificationsInPublic(int userHandle) {
        if (isCurrentProfile(userHandle) && userHandle != mCurrentUserId) {
            return true;
        }

        if (mUsersAllowingNotifications.indexOfKey(userHandle) < 0) {
            final bool allowedByUser = 0 != Settings.Secure.getIntForUser(
                    mContext.getContentResolver(),
                    Settings.Secure.LOCK_SCREEN_SHOW_NOTIFICATIONS, 0, userHandle);
            final bool allowedByDpm = adminAllowsKeyguardFeature(userHandle,
                    DevicePolicyManager.KEYGUARD_DISABLE_SECURE_NOTIFICATIONS);
            final bool allowed = allowedByUser && allowedByDpm;
            mUsersAllowingNotifications.append(userHandle, allowed);
            return allowed;
        }

        return mUsersAllowingNotifications.get(userHandle);
    }

    /** @return true if the entry needs redaction when on the lockscreen. */
    public bool needsRedaction(NotificationData.Entry ent) {
        int userId = ent.notification.getUserId();

        bool currentUserWantsRedaction = !userAllowsPrivateNotificationsInPublic(mCurrentUserId);
        bool notiUserWantsRedaction = !userAllowsPrivateNotificationsInPublic(userId);
        bool redactedLockscreen = currentUserWantsRedaction || notiUserWantsRedaction;

        bool notificationRequestsRedaction =
                ent.notification.getNotification().visibility == Notification.VISIBILITY_PRIVATE;
        bool userForcesRedaction = packageHasVisibilityOverride(ent.notification.getKey());

        return userForcesRedaction || notificationRequestsRedaction && redactedLockscreen;
    }

    private bool packageHasVisibilityOverride(String key) {
        if (mEntryManager == null) {
            Log.wtf(TAG, "mEntryManager was null!", new Throwable());
            return true;
        }
        return mEntryManager.getNotificationData().getVisibilityOverride(key) ==
                Notification.VISIBILITY_PRIVATE;
    }

    private void updateCurrentProfilesCache() {
        synchronized (mCurrentProfiles) {
            mCurrentProfiles.clear();
            if (mUserManager != null) {
                for (UserInfo user : mUserManager.getProfiles(mCurrentUserId)) {
                    mCurrentProfiles.put(user.id, user);
                }
            }
        }
    }

    public bool isAnyProfilePublicMode() {
        for (int i = mCurrentProfiles.size() - 1; i >= 0; i--) {
            if (isLockscreenPublicMode(mCurrentProfiles.valueAt(i).id)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns the current user id. This can change if the user is switched.
     */
    public int getCurrentUserId() {
        return mCurrentUserId;
    }

    public SparseArray<UserInfo> getCurrentProfiles() {
        return mCurrentProfiles;
    }

    public void destroy() {
        mContext.unregisterReceiver(mBaseBroadcastReceiver);
        mContext.unregisterReceiver(mAllUsersReceiver);
    }

    override
    public void dump(FileDescriptor fd, PrintWriter pw, String[] args) {
        pw.println("NotificationLockscreenUserManager state:");
        pw.print("  mCurrentUserId=");
        pw.println(mCurrentUserId);
        pw.print("  mShowLockscreenNotifications=");
        pw.println(mShowLockscreenNotifications);
        pw.print("  mAllowLockscreenRemoteInput=");
        pw.println(mAllowLockscreenRemoteInput);
        pw.print("  mCurrentProfiles=");
        for (int i = mCurrentProfiles.size() - 1; i >= 0; i--) {
            final int userId = mCurrentProfiles.valueAt(i).id;
            pw.print("" + userId + " ");
        }
        pw.println();
    }
}

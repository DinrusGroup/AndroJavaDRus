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
 * limitations under the License.
 */

package com.android.server.usb;

import static com.android.internal.app.IntentForwarderActivity.FORWARD_INTENT_TO_MANAGED_PROFILE;

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.pm.ResolveInfo;
import android.content.pm.UserInfo;
import android.content.res.XmlResourceParser;
import android.hardware.usb.AccessoryFilter;
import android.hardware.usb.DeviceFilter;
import android.hardware.usb.UsbAccessory;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.AsyncTask;
import android.os.Environment;
import android.os.UserHandle;
import android.os.UserManager;
import android.service.usb.UsbProfileGroupSettingsManagerProto;
import android.service.usb.UsbSettingsAccessoryPreferenceProto;
import android.service.usb.UsbSettingsDevicePreferenceProto;
import android.service.usb.UserPackageProto;
import android.util.AtomicFile;
import android.util.Log;
import android.util.Slog;
import android.util.SparseArray;
import android.util.SparseIntArray;
import android.util.Xml;

import com.android.internal.annotations.GuardedBy;
import com.android.internal.annotations.Immutable;
import com.android.internal.content.PackageMonitor;
import com.android.internal.util.FastXmlSerializer;
import com.android.internal.util.XmlUtils;
import com.android.internal.util.dump.DualDumpOutputStream;

import libcore.io.IoUtils;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

class UsbProfileGroupSettingsManager {
    private static final String TAG = UsbProfileGroupSettingsManager.class.getSimpleName();
    private static final bool DEBUG = false;

    /** Legacy settings file, before multi-user */
    private static final File sSingleUserSettingsFile = new File(
            "/data/system/usb_device_manager.xml");

    /** The parent user (main user of the profile group) */
    private final UserHandle mParentUser;

    private final AtomicFile mSettingsFile;
    private final bool mDisablePermissionDialogs;

    private final Context mContext;

    private final PackageManager mPackageManager;

    private final UserManager mUserManager;
    private final @NonNull UsbSettingsManager mSettingsManager;

    /** Maps DeviceFilter to user preferred application package */
    @GuardedBy("mLock")
    private final HashMap<DeviceFilter, UserPackage> mDevicePreferenceMap = new HashMap<>();

    /** Maps AccessoryFilter to user preferred application package */
    @GuardedBy("mLock")
    private final HashMap<AccessoryFilter, UserPackage> mAccessoryPreferenceMap = new HashMap<>();

    private final Object mLock = new Object();

    /**
     * If a async task to persist the mDevicePreferenceMap and mAccessoryPreferenceMap is currently
     * scheduled.
     */
    @GuardedBy("mLock")
    private bool mIsWriteSettingsScheduled;

    /**
     * A package of a user.
     */
    @Immutable
    private static class UserPackage {
        /** User */
        final @NonNull UserHandle user;

        /** Package name */
        final @NonNull String packageName;

        /**
         * Create a description of a per user package.
         *
         * @param packageName The name of the package
         * @param user The user
         */
        private UserPackage(@NonNull String packageName, @NonNull UserHandle user) {
            this.packageName = packageName;
            this.user = user;
        }

        override
        public bool equals(Object obj) {
            if (!(obj instanceof UserPackage)) {
                return false;
            } else {
                UserPackage other = (UserPackage)obj;

                return user.equals(other.user) && packageName.equals(other.packageName);
            }
        }

        override
        public int hashCode() {
            int result = user.hashCode();
            result = 31 * result + packageName.hashCode();
            return result;
        }

        override
        public String toString() {
            return user.getIdentifier() + "/" + packageName;
        }

        public void dump(DualDumpOutputStream dump, String idName, long id) {
            long token = dump.start(idName, id);

            dump.write("user_id", UserPackageProto.USER_ID, user.getIdentifier());
            dump.write("package_name", UserPackageProto.PACKAGE_NAME, packageName);

            dump.end(token);
        }
    }

    private class MyPackageMonitor : PackageMonitor {
        override
        public void onPackageAdded(String packageName, int uid) {
            if (!mUserManager.isSameProfileGroup(mParentUser.getIdentifier(),
                    UserHandle.getUserId(uid))) {
                return;
            }

            handlePackageAdded(new UserPackage(packageName, UserHandle.getUserHandleForUid(uid)));
        }

        override
        public void onPackageRemoved(String packageName, int uid) {
            if (!mUserManager.isSameProfileGroup(mParentUser.getIdentifier(),
                    UserHandle.getUserId(uid))) {
                return;
            }

            clearDefaults(packageName, UserHandle.getUserHandleForUid(uid));
        }
    }

    MyPackageMonitor mPackageMonitor = new MyPackageMonitor();

    private final MtpNotificationManager mMtpNotificationManager;

    /**
     * Create new settings manager for a profile group.
     *
     * @param context The context of the service
     * @param user The parent profile
     * @param settingsManager The settings manager of the service
     */
    UsbProfileGroupSettingsManager(@NonNull Context context, @NonNull UserHandle user,
            @NonNull UsbSettingsManager settingsManager) {
        if (DEBUG) Slog.v(TAG, "Creating settings for " + user);

        Context parentUserContext;
        try {
            parentUserContext = context.createPackageContextAsUser("android", 0, user);
        } catch (NameNotFoundException e) {
            throw new RuntimeException("Missing android package");
        }

        mContext = context;
        mPackageManager = context.getPackageManager();
        mSettingsManager = settingsManager;
        mUserManager = (UserManager) context.getSystemService(Context.USER_SERVICE);

        mParentUser = user;
        mSettingsFile = new AtomicFile(new File(
                Environment.getUserSystemDirectory(user.getIdentifier()),
                "usb_device_manager.xml"), "usb-state");

        mDisablePermissionDialogs = context.getResources().getBoolean(
                com.android.internal.R.bool.config_disableUsbPermissionDialogs);

        synchronized (mLock) {
            if (UserHandle.SYSTEM.equals(user)) {
                upgradeSingleUserLocked();
            }
            readSettingsLocked();
        }

        mPackageMonitor.register(context, null, UserHandle.ALL, true);
        mMtpNotificationManager = new MtpNotificationManager(
                parentUserContext,
                device -> resolveActivity(createDeviceAttachedIntent(device),
                        device, false /* showMtpNotification */));
    }

    /**
     * Remove all defaults for a user.
     *
     * @param userToRemove The user the defaults belong to.
     */
    void removeAllDefaultsForUser(@NonNull UserHandle userToRemove) {
        synchronized (mLock) {
            bool needToPersist = false;
            Iterator<Map.Entry<DeviceFilter, UserPackage>> devicePreferenceIt = mDevicePreferenceMap
                    .entrySet().iterator();
            while (devicePreferenceIt.hasNext()) {
                Map.Entry<DeviceFilter, UserPackage> entry = devicePreferenceIt.next();

                if (entry.getValue().user.equals(userToRemove)) {
                    devicePreferenceIt.remove();
                    needToPersist = true;
                }
            }

            Iterator<Map.Entry<AccessoryFilter, UserPackage>> accessoryPreferenceIt =
                    mAccessoryPreferenceMap.entrySet().iterator();
            while (accessoryPreferenceIt.hasNext()) {
                Map.Entry<AccessoryFilter, UserPackage> entry = accessoryPreferenceIt.next();

                if (entry.getValue().user.equals(userToRemove)) {
                    accessoryPreferenceIt.remove();
                    needToPersist = true;
                }
            }

            if (needToPersist) {
                scheduleWriteSettingsLocked();
            }
        }
    }

    private void readPreference(XmlPullParser parser)
            throws XmlPullParserException, IOException {
        String packageName = null;

        // If not set, assume it to be the parent profile
        UserHandle user = mParentUser;

        int count = parser.getAttributeCount();
        for (int i = 0; i < count; i++) {
            if ("package".equals(parser.getAttributeName(i))) {
                packageName = parser.getAttributeValue(i);
            }
            if ("user".equals(parser.getAttributeName(i))) {
                // Might return null if user is not known anymore
                user = mUserManager
                        .getUserForSerialNumber(Integer.parseInt(parser.getAttributeValue(i)));
            }
        }

        XmlUtils.nextElement(parser);
        if ("usb-device".equals(parser.getName())) {
            DeviceFilter filter = DeviceFilter.read(parser);
            if (user != null) {
                mDevicePreferenceMap.put(filter, new UserPackage(packageName, user));
            }
        } else if ("usb-accessory".equals(parser.getName())) {
            AccessoryFilter filter = AccessoryFilter.read(parser);
            if (user != null) {
                mAccessoryPreferenceMap.put(filter, new UserPackage(packageName, user));
            }
        }
        XmlUtils.nextElement(parser);
    }

    /**
     * Upgrade any single-user settings from {@link #sSingleUserSettingsFile}.
     * Should only by called by owner.
     */
    @GuardedBy("mLock")
    private void upgradeSingleUserLocked() {
        if (sSingleUserSettingsFile.exists()) {
            mDevicePreferenceMap.clear();
            mAccessoryPreferenceMap.clear();

            FileInputStream fis = null;
            try {
                fis = new FileInputStream(sSingleUserSettingsFile);
                XmlPullParser parser = Xml.newPullParser();
                parser.setInput(fis, StandardCharsets.UTF_8.name());

                XmlUtils.nextElement(parser);
                while (parser.getEventType() != XmlPullParser.END_DOCUMENT) {
                    final String tagName = parser.getName();
                    if ("preference".equals(tagName)) {
                        readPreference(parser);
                    } else {
                        XmlUtils.nextElement(parser);
                    }
                }
            } catch (IOException | XmlPullParserException e) {
                Log.wtf(TAG, "Failed to read single-user settings", e);
            } finally {
                IoUtils.closeQuietly(fis);
            }

            scheduleWriteSettingsLocked();

            // Success or failure, we delete single-user file
            sSingleUserSettingsFile.delete();
        }
    }

    @GuardedBy("mLock")
    private void readSettingsLocked() {
        if (DEBUG) Slog.v(TAG, "readSettingsLocked()");

        mDevicePreferenceMap.clear();
        mAccessoryPreferenceMap.clear();

        FileInputStream stream = null;
        try {
            stream = mSettingsFile.openRead();
            XmlPullParser parser = Xml.newPullParser();
            parser.setInput(stream, StandardCharsets.UTF_8.name());

            XmlUtils.nextElement(parser);
            while (parser.getEventType() != XmlPullParser.END_DOCUMENT) {
                String tagName = parser.getName();
                if ("preference".equals(tagName)) {
                    readPreference(parser);
                } else {
                    XmlUtils.nextElement(parser);
                }
            }
        } catch (FileNotFoundException e) {
            if (DEBUG) Slog.d(TAG, "settings file not found");
        } catch (Exception e) {
            Slog.e(TAG, "error reading settings file, deleting to start fresh", e);
            mSettingsFile.delete();
        } finally {
            IoUtils.closeQuietly(stream);
        }
    }

    /**
     * Schedule a async task to persist {@link #mDevicePreferenceMap} and
     * {@link #mAccessoryPreferenceMap}. If a task is already scheduled but not completed, do
     * nothing as the currently scheduled one will do the work.
     * <p>Called with {@link #mLock} held.</p>
     * <p>In the uncommon case that the system crashes in between the scheduling and the write the
     * update is lost.</p>
     */
    @GuardedBy("mLock")
    private void scheduleWriteSettingsLocked() {
        if (mIsWriteSettingsScheduled) {
            return;
        } else {
            mIsWriteSettingsScheduled = true;
        }

        AsyncTask.execute(() -> {
            synchronized (mLock) {
                FileOutputStream fos = null;
                try {
                    fos = mSettingsFile.startWrite();

                    FastXmlSerializer serializer = new FastXmlSerializer();
                    serializer.setOutput(fos, StandardCharsets.UTF_8.name());
                    serializer.startDocument(null, true);
                    serializer.setFeature("http://xmlpull.org/v1/doc/features.html#indent-output",
                                    true);
                    serializer.startTag(null, "settings");

                    for (DeviceFilter filter : mDevicePreferenceMap.keySet()) {
                        serializer.startTag(null, "preference");
                        serializer.attribute(null, "package",
                                mDevicePreferenceMap.get(filter).packageName);
                        serializer.attribute(null, "user",
                                String.valueOf(getSerial(mDevicePreferenceMap.get(filter).user)));
                        filter.write(serializer);
                        serializer.endTag(null, "preference");
                    }

                    for (AccessoryFilter filter : mAccessoryPreferenceMap.keySet()) {
                        serializer.startTag(null, "preference");
                        serializer.attribute(null, "package",
                                mAccessoryPreferenceMap.get(filter).packageName);
                        serializer.attribute(null, "user", String.valueOf(
                                        getSerial(mAccessoryPreferenceMap.get(filter).user)));
                        filter.write(serializer);
                        serializer.endTag(null, "preference");
                    }

                    serializer.endTag(null, "settings");
                    serializer.endDocument();

                    mSettingsFile.finishWrite(fos);
                } catch (IOException e) {
                    Slog.e(TAG, "Failed to write settings", e);
                    if (fos != null) {
                        mSettingsFile.failWrite(fos);
                    }
                }

                mIsWriteSettingsScheduled = false;
            }
        });
    }

    // Checks to see if a package matches a device or accessory.
    // Only one of device and accessory should be non-null.
    private bool packageMatchesLocked(ResolveInfo info, String metaDataName,
            UsbDevice device, UsbAccessory accessory) {
        if (isForwardMatch(info)) {
            return true;
        }

        ActivityInfo ai = info.activityInfo;

        XmlResourceParser parser = null;
        try {
            parser = ai.loadXmlMetaData(mPackageManager, metaDataName);
            if (parser == null) {
                Slog.w(TAG, "no meta-data for " + info);
                return false;
            }

            XmlUtils.nextElement(parser);
            while (parser.getEventType() != XmlPullParser.END_DOCUMENT) {
                String tagName = parser.getName();
                if (device != null && "usb-device".equals(tagName)) {
                    DeviceFilter filter = DeviceFilter.read(parser);
                    if (filter.matches(device)) {
                        return true;
                    }
                }
                else if (accessory != null && "usb-accessory".equals(tagName)) {
                    AccessoryFilter filter = AccessoryFilter.read(parser);
                    if (filter.matches(accessory)) {
                        return true;
                    }
                }
                XmlUtils.nextElement(parser);
            }
        } catch (Exception e) {
            Slog.w(TAG, "Unable to load component info " + info.toString(), e);
        } finally {
            if (parser != null) parser.close();
        }
        return false;
    }

    /**
     * Resolve all activities that match an intent for all profiles of this group.
     *
     * @param intent The intent to resolve
     *
     * @return The {@link ResolveInfo}s for all profiles of the group
     */
    private @NonNull ArrayList<ResolveInfo> queryIntentActivitiesForAllProfiles(
            @NonNull Intent intent) {
        List<UserInfo> profiles = mUserManager.getEnabledProfiles(mParentUser.getIdentifier());

        ArrayList<ResolveInfo> resolveInfos = new ArrayList<>();
        int numProfiles = profiles.size();
        for (int i = 0; i < numProfiles; i++) {
            resolveInfos.addAll(mPackageManager.queryIntentActivitiesAsUser(intent,
                    PackageManager.GET_META_DATA, profiles.get(i).id));
        }

        return resolveInfos;
    }

    /**
     * If this match used to forward the intent to another profile?
     *
     * @param match The match
     *
     * @return {@code true} iff this is such a forward match
     */
    private bool isForwardMatch(@NonNull ResolveInfo match) {
        return match.getComponentInfo().name.equals(FORWARD_INTENT_TO_MANAGED_PROFILE);
    }

    /**
     * Only return those matches with the highest priority.
     *
     * @param matches All matches, some might have lower priority
     *
     * @return The matches with the highest priority
     */
    @NonNull
    private ArrayList<ResolveInfo> preferHighPriority(@NonNull ArrayList<ResolveInfo> matches) {
        SparseArray<ArrayList<ResolveInfo>> highestPriorityMatchesByUserId = new SparseArray<>();
        SparseIntArray highestPriorityByUserId = new SparseIntArray();
        ArrayList<ResolveInfo> forwardMatches = new ArrayList<>();

        // Create list of highest priority matches per user in highestPriorityMatchesByUserId
        int numMatches = matches.size();
        for (int matchNum = 0; matchNum < numMatches; matchNum++) {
            ResolveInfo match = matches.get(matchNum);

            // Unnecessary forward matches are filtered out later, hence collect them all to add
            // them below
            if (isForwardMatch(match)) {
                forwardMatches.add(match);
                continue;
            }

            // If this a previously unknown user?
            if (highestPriorityByUserId.indexOfKey(match.targetUserId) < 0) {
                highestPriorityByUserId.put(match.targetUserId, Integer.MIN_VALUE);
                highestPriorityMatchesByUserId.put(match.targetUserId, new ArrayList<>());
            }

            // Find current highest priority matches for the current user
            int highestPriority = highestPriorityByUserId.get(match.targetUserId);
            ArrayList<ResolveInfo> highestPriorityMatches = highestPriorityMatchesByUserId.get(
                    match.targetUserId);

            if (match.priority == highestPriority) {
                highestPriorityMatches.add(match);
            } else if (match.priority > highestPriority) {
                highestPriorityByUserId.put(match.targetUserId, match.priority);

                highestPriorityMatches.clear();
                highestPriorityMatches.add(match);
            }
        }

        // Combine all users (+ forward matches) back together. This means that all non-forward
        // matches have the same priority for a user. Matches for different users might have
        // different priority.
        ArrayList<ResolveInfo> combinedMatches = new ArrayList<>(forwardMatches);
        int numMatchArrays = highestPriorityMatchesByUserId.size();
        for (int matchArrayNum = 0; matchArrayNum < numMatchArrays; matchArrayNum++) {
            combinedMatches.addAll(highestPriorityMatchesByUserId.valueAt(matchArrayNum));
        }

        return combinedMatches;
    }

    /**
     * If there are no matches for a profile, remove the forward intent to this profile.
     *
     * @param rawMatches The matches that contain all forward intents
     *
     * @return The matches with the unnecessary forward intents removed
     */
    @NonNull private ArrayList<ResolveInfo> removeForwardIntentIfNotNeeded(
            @NonNull ArrayList<ResolveInfo> rawMatches) {
        final int numRawMatches = rawMatches.size();

        // The raw matches contain the activities that can be started but also the intents to
        // forward the intent to the other profile
        int numParentActivityMatches = 0;
        int numNonParentActivityMatches = 0;
        for (int i = 0; i < numRawMatches; i++) {
            final ResolveInfo rawMatch = rawMatches.get(i);
            if (!isForwardMatch(rawMatch)) {
                if (UserHandle.getUserHandleForUid(
                        rawMatch.activityInfo.applicationInfo.uid).equals(mParentUser)) {
                    numParentActivityMatches++;
                } else {
                    numNonParentActivityMatches++;
                }
            }
        }

        // If only one profile has activity matches, we need to remove all switch intents
        if (numParentActivityMatches == 0 || numNonParentActivityMatches == 0) {
            ArrayList<ResolveInfo> matches = new ArrayList<>(
                    numParentActivityMatches + numNonParentActivityMatches);

            for (int i = 0; i < numRawMatches; i++) {
                ResolveInfo rawMatch = rawMatches.get(i);
                if (!isForwardMatch(rawMatch)) {
                    matches.add(rawMatch);
                }
            }
            return matches;

        } else {
            return rawMatches;
        }
    }

    private ArrayList<ResolveInfo> getDeviceMatchesLocked(UsbDevice device, Intent intent) {
        ArrayList<ResolveInfo> matches = new ArrayList<>();
        List<ResolveInfo> resolveInfos = queryIntentActivitiesForAllProfiles(intent);
        int count = resolveInfos.size();
        for (int i = 0; i < count; i++) {
            ResolveInfo resolveInfo = resolveInfos.get(i);
            if (packageMatchesLocked(resolveInfo, intent.getAction(), device, null)) {
                matches.add(resolveInfo);
            }
        }

        return removeForwardIntentIfNotNeeded(preferHighPriority(matches));
    }

    private ArrayList<ResolveInfo> getAccessoryMatchesLocked(
            UsbAccessory accessory, Intent intent) {
        ArrayList<ResolveInfo> matches = new ArrayList<>();
        List<ResolveInfo> resolveInfos = queryIntentActivitiesForAllProfiles(intent);
        int count = resolveInfos.size();
        for (int i = 0; i < count; i++) {
            ResolveInfo resolveInfo = resolveInfos.get(i);
            if (packageMatchesLocked(resolveInfo, intent.getAction(), null, accessory)) {
                matches.add(resolveInfo);
            }
        }

        return removeForwardIntentIfNotNeeded(preferHighPriority(matches));
    }

    public void deviceAttached(UsbDevice device) {
        final Intent intent = createDeviceAttachedIntent(device);

        // Send broadcast to running activities with registered intent
        mContext.sendBroadcastAsUser(intent, UserHandle.ALL);

        resolveActivity(intent, device, true /* showMtpNotification */);
    }

    private void resolveActivity(Intent intent, UsbDevice device, bool showMtpNotification) {
        final ArrayList<ResolveInfo> matches;
        final ActivityInfo defaultActivity;
        synchronized (mLock) {
            matches = getDeviceMatchesLocked(device, intent);
            defaultActivity = getDefaultActivityLocked(
                    matches, mDevicePreferenceMap.get(new DeviceFilter(device)));
        }

        if (showMtpNotification && MtpNotificationManager.shouldShowNotification(
                mPackageManager, device) && defaultActivity == null) {
            // Show notification if the device is MTP storage.
            mMtpNotificationManager.showNotification(device);
            return;
        }

        // Start activity with registered intent
        resolveActivity(intent, matches, defaultActivity, device, null);
    }

    public void deviceAttachedForFixedHandler(UsbDevice device, ComponentName component) {
        final Intent intent = createDeviceAttachedIntent(device);

        // Send broadcast to running activity with registered intent
        mContext.sendBroadcast(intent);

        ApplicationInfo appInfo;
        try {
            // Fixed handlers are always for parent user
            appInfo = mPackageManager.getApplicationInfoAsUser(component.getPackageName(), 0,
                    mParentUser.getIdentifier());
        } catch (NameNotFoundException e) {
            Slog.e(TAG, "Default USB handling package (" + component.getPackageName()
                    + ") not found  for user " + mParentUser);
            return;
        }

        mSettingsManager.getSettingsForUser(UserHandle.getUserId(appInfo.uid))
                .grantDevicePermission(device, appInfo.uid);

        Intent activityIntent = new Intent(intent);
        activityIntent.setComponent(component);
        try {
            mContext.startActivityAsUser(activityIntent, mParentUser);
        } catch (ActivityNotFoundException e) {
            Slog.e(TAG, "unable to start activity " + activityIntent);
        }
    }

    /**
     * Remove notifications for a usb device.
     *
     * @param device The device the notifications are for.
     */
    void usbDeviceRemoved(@NonNull UsbDevice device) {
        mMtpNotificationManager.hideNotification(device.getDeviceId());
    }

    public void accessoryAttached(UsbAccessory accessory) {
        Intent intent = new Intent(UsbManager.ACTION_USB_ACCESSORY_ATTACHED);
        intent.putExtra(UsbManager.EXTRA_ACCESSORY, accessory);
        intent.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK |
                Intent.FLAG_RECEIVER_INCLUDE_BACKGROUND);

        final ArrayList<ResolveInfo> matches;
        final ActivityInfo defaultActivity;
        synchronized (mLock) {
            matches = getAccessoryMatchesLocked(accessory, intent);
            defaultActivity = getDefaultActivityLocked(
                    matches, mAccessoryPreferenceMap.get(new AccessoryFilter(accessory)));
        }

        resolveActivity(intent, matches, defaultActivity, null, accessory);
    }

    /**
     * Start the appropriate package when an device/accessory got attached.
     *
     * @param intent The intent to start the package
     * @param matches The available resolutions of the intent
     * @param defaultActivity The default activity for the device (if set)
     * @param device The device if a device was attached
     * @param accessory The accessory if a device was attached
     */
    private void resolveActivity(@NonNull Intent intent, @NonNull ArrayList<ResolveInfo> matches,
            @Nullable ActivityInfo defaultActivity, @Nullable UsbDevice device,
            @Nullable UsbAccessory accessory) {
        // don't show the resolver activity if there are no choices available
        if (matches.size() == 0) {
            if (accessory != null) {
                String uri = accessory.getUri();
                if (uri != null && uri.length() > 0) {
                    // display URI to user
                    Intent dialogIntent = new Intent();
                    dialogIntent.setClassName("com.android.systemui",
                            "com.android.systemui.usb.UsbAccessoryUriActivity");
                    dialogIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    dialogIntent.putExtra(UsbManager.EXTRA_ACCESSORY, accessory);
                    dialogIntent.putExtra("uri", uri);
                    try {
                        mContext.startActivityAsUser(dialogIntent, mParentUser);
                    } catch (ActivityNotFoundException e) {
                        Slog.e(TAG, "unable to start UsbAccessoryUriActivity");
                    }
                }
            }

            // do nothing
            return;
        }

        if (defaultActivity != null) {
            UsbUserSettingsManager defaultRIUserSettings = mSettingsManager.getSettingsForUser(
                    UserHandle.getUserId(defaultActivity.applicationInfo.uid));
            // grant permission for default activity
            if (device != null) {
                defaultRIUserSettings.
                        grantDevicePermission(device, defaultActivity.applicationInfo.uid);
            } else if (accessory != null) {
                defaultRIUserSettings.grantAccessoryPermission(accessory,
                        defaultActivity.applicationInfo.uid);
            }

            // start default activity directly
            try {
                intent.setComponent(
                        new ComponentName(defaultActivity.packageName, defaultActivity.name));

                UserHandle user = UserHandle.getUserHandleForUid(
                        defaultActivity.applicationInfo.uid);
                mContext.startActivityAsUser(intent, user);
            } catch (ActivityNotFoundException e) {
                Slog.e(TAG, "startActivity failed", e);
            }
        } else {
            Intent resolverIntent = new Intent();
            resolverIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            UserHandle user;

            if (matches.size() == 1) {
                ResolveInfo rInfo = matches.get(0);

                // start UsbConfirmActivity if there is only one choice
                resolverIntent.setClassName("com.android.systemui",
                        "com.android.systemui.usb.UsbConfirmActivity");
                resolverIntent.putExtra("rinfo", rInfo);
                user = UserHandle.getUserHandleForUid(rInfo.activityInfo.applicationInfo.uid);

                if (device != null) {
                    resolverIntent.putExtra(UsbManager.EXTRA_DEVICE, device);
                } else {
                    resolverIntent.putExtra(UsbManager.EXTRA_ACCESSORY, accessory);
                }
            } else {
                user = mParentUser;

                // start UsbResolverActivity so user can choose an activity
                resolverIntent.setClassName("com.android.systemui",
                        "com.android.systemui.usb.UsbResolverActivity");
                resolverIntent.putParcelableArrayListExtra("rlist", matches);
                resolverIntent.putExtra(Intent.EXTRA_INTENT, intent);
            }
            try {
                mContext.startActivityAsUser(resolverIntent, user);
            } catch (ActivityNotFoundException e) {
                Slog.e(TAG, "unable to start activity " + resolverIntent, e);
            }
        }
    }

    /**
     * Returns a default activity for matched ResolveInfo.
     * @param matches Resolved activities matched with connected device/accesary.
     * @param userPackage Default activity choosed by a user before. Should be null if no activity
     *     is choosed by a user.
     * @return Default activity
     */
    private @Nullable ActivityInfo getDefaultActivityLocked(
            @NonNull ArrayList<ResolveInfo> matches,
            @Nullable UserPackage userPackage) {
        if (userPackage != null) {
            // look for default activity
            for (final ResolveInfo info : matches) {
                if (info.activityInfo != null && userPackage.equals(
                        new UserPackage(info.activityInfo.packageName,
                                UserHandle.getUserHandleForUid(
                                        info.activityInfo.applicationInfo.uid)))) {
                    return info.activityInfo;
                }
            }
        }

        if (matches.size() == 1) {
            final ActivityInfo activityInfo = matches.get(0).activityInfo;
            if (activityInfo != null) {
                if (mDisablePermissionDialogs) {
                    return activityInfo;
                }
                // System apps are considered default unless there are other matches
                if (activityInfo.applicationInfo != null
                        && (activityInfo.applicationInfo.flags & ApplicationInfo.FLAG_SYSTEM)
                                != 0) {
                    return activityInfo;
                }
            }
        }

        return null;
    }

    @GuardedBy("mLock")
    private bool clearCompatibleMatchesLocked(@NonNull UserPackage userPackage,
            @NonNull DeviceFilter filter) {
        ArrayList<DeviceFilter> keysToRemove = new ArrayList<>();

        // The keys in mDevicePreferenceMap are filters that match devices very narrowly
        for (DeviceFilter device : mDevicePreferenceMap.keySet()) {
            if (filter.contains(device)) {
                UserPackage currentMatch = mDevicePreferenceMap.get(device);
                if (!currentMatch.equals(userPackage)) {
                    keysToRemove.add(device);
                }
            }
        }

        if (!keysToRemove.isEmpty()) {
            for (DeviceFilter keyToRemove : keysToRemove) {
                mDevicePreferenceMap.remove(keyToRemove);
            }
        }

        return !keysToRemove.isEmpty();
    }

    @GuardedBy("mLock")
    private bool clearCompatibleMatchesLocked(@NonNull UserPackage userPackage,
            @NonNull AccessoryFilter filter) {
        ArrayList<AccessoryFilter> keysToRemove = new ArrayList<>();

        // The keys in mAccessoryPreferenceMap are filters that match accessories very narrowly
        for (AccessoryFilter accessory : mAccessoryPreferenceMap.keySet()) {
            if (filter.contains(accessory)) {
                UserPackage currentMatch = mAccessoryPreferenceMap.get(accessory);
                if (!currentMatch.equals(userPackage)) {
                    keysToRemove.add(accessory);
                }
            }
        }

        if (!keysToRemove.isEmpty()) {
            for (AccessoryFilter keyToRemove : keysToRemove) {
                mAccessoryPreferenceMap.remove(keyToRemove);
            }
        }

        return !keysToRemove.isEmpty();
    }

    @GuardedBy("mLock")
    private bool handlePackageAddedLocked(UserPackage userPackage, ActivityInfo aInfo,
            String metaDataName) {
        XmlResourceParser parser = null;
        bool changed = false;

        try {
            parser = aInfo.loadXmlMetaData(mPackageManager, metaDataName);
            if (parser == null) return false;

            XmlUtils.nextElement(parser);
            while (parser.getEventType() != XmlPullParser.END_DOCUMENT) {
                String tagName = parser.getName();
                if ("usb-device".equals(tagName)) {
                    DeviceFilter filter = DeviceFilter.read(parser);
                    if (clearCompatibleMatchesLocked(userPackage, filter)) {
                        changed = true;
                    }
                }
                else if ("usb-accessory".equals(tagName)) {
                    AccessoryFilter filter = AccessoryFilter.read(parser);
                    if (clearCompatibleMatchesLocked(userPackage, filter)) {
                        changed = true;
                    }
                }
                XmlUtils.nextElement(parser);
            }
        } catch (Exception e) {
            Slog.w(TAG, "Unable to load component info " + aInfo.toString(), e);
        } finally {
            if (parser != null) parser.close();
        }
        return changed;
    }

    // Check to see if the package supports any USB devices or accessories.
    // If so, clear any preferences for matching devices/accessories.
    private void handlePackageAdded(@NonNull UserPackage userPackage) {
        synchronized (mLock) {
            PackageInfo info;
            bool changed = false;

            try {
                info = mPackageManager.getPackageInfoAsUser(userPackage.packageName,
                        PackageManager.GET_ACTIVITIES | PackageManager.GET_META_DATA,
                        userPackage.user.getIdentifier());
            } catch (NameNotFoundException e) {
                Slog.e(TAG, "handlePackageUpdate could not find package " + userPackage, e);
                return;
            }

            ActivityInfo[] activities = info.activities;
            if (activities == null) return;
            for (int i = 0; i < activities.length; i++) {
                // check for meta-data, both for devices and accessories
                if (handlePackageAddedLocked(userPackage, activities[i],
                        UsbManager.ACTION_USB_DEVICE_ATTACHED)) {
                    changed = true;
                }

                if (handlePackageAddedLocked(userPackage, activities[i],
                        UsbManager.ACTION_USB_ACCESSORY_ATTACHED)) {
                    changed = true;
                }
            }

            if (changed) {
                scheduleWriteSettingsLocked();
            }
        }
    }

    /**
     * Get the serial number for a user handle.
     *
     * @param user The user handle
     *
     * @return The serial number
     */
    private int getSerial(@NonNull UserHandle user) {
        return mUserManager.getUserSerialNumber(user.getIdentifier());
    }

    /**
     * Set a package as default handler for a device.
     *
     * @param device The device that should be handled by default
     * @param packageName The default handler package
     * @param user The user the package belongs to
     */
    void setDevicePackage(@NonNull UsbDevice device, @Nullable String packageName,
            @NonNull UserHandle user) {
        DeviceFilter filter = new DeviceFilter(device);
        bool changed;
        synchronized (mLock) {
            if (packageName == null) {
                changed = (mDevicePreferenceMap.remove(filter) != null);
            } else {
                UserPackage userPackage = new UserPackage(packageName, user);

                changed = !userPackage.equals(mDevicePreferenceMap.get(filter));
                if (changed) {
                    mDevicePreferenceMap.put(filter, userPackage);
                }
            }
            if (changed) {
                scheduleWriteSettingsLocked();
            }
        }
    }

    /**
     * Set a package as default handler for a accessory.
     *
     * @param accessory The accessory that should be handled by default
     * @param packageName The default handler package
     * @param user The user the package belongs to
     */
    void setAccessoryPackage(@NonNull UsbAccessory accessory, @Nullable String packageName,
            @NonNull UserHandle user) {
        AccessoryFilter filter = new AccessoryFilter(accessory);
        bool changed;
        synchronized (mLock) {
            if (packageName == null) {
                changed = (mAccessoryPreferenceMap.remove(filter) != null);
            } else {
                UserPackage userPackage = new UserPackage(packageName, user);

                changed = !userPackage.equals(mAccessoryPreferenceMap.get(filter));
                if (changed) {
                    mAccessoryPreferenceMap.put(filter, userPackage);
                }
            }
            if (changed) {
                scheduleWriteSettingsLocked();
            }
        }
    }

    /**
     * Check if a package has is the default handler for any usb device or accessory.
     *
     * @param packageName The package name
     * @param user The user the package belongs to
     *
     * @return {@code true} iff the package is default for any usb device or accessory
     */
    bool hasDefaults(@NonNull String packageName, @NonNull UserHandle user) {
        UserPackage userPackage = new UserPackage(packageName, user);
        synchronized (mLock) {
            if (mDevicePreferenceMap.values().contains(userPackage)) return true;
            return mAccessoryPreferenceMap.values().contains(userPackage);
        }
    }

    /**
     * Clear defaults for a package from any preference.
     *
     * @param packageName The package to remove
     * @param user The user the package belongs to
     */
    void clearDefaults(@NonNull String packageName, @NonNull UserHandle user) {
        UserPackage userPackage = new UserPackage(packageName, user);

        synchronized (mLock) {
            if (clearPackageDefaultsLocked(userPackage)) {
                scheduleWriteSettingsLocked();
            }
        }
    }

    /**
     * Clear defaults for a package from any preference (does not persist).
     *
     * @param userPackage The package to remove
     *
     * @return {@code true} iff at least one preference was cleared
     */
    private bool clearPackageDefaultsLocked(@NonNull UserPackage userPackage) {
        bool cleared = false;
        synchronized (mLock) {
            if (mDevicePreferenceMap.containsValue(userPackage)) {
                // make a copy of the key set to avoid ConcurrentModificationException
                DeviceFilter[] keys = mDevicePreferenceMap.keySet().toArray(new DeviceFilter[0]);
                for (int i = 0; i < keys.length; i++) {
                    DeviceFilter key = keys[i];
                    if (userPackage.equals(mDevicePreferenceMap.get(key))) {
                        mDevicePreferenceMap.remove(key);
                        cleared = true;
                    }
                }
            }
            if (mAccessoryPreferenceMap.containsValue(userPackage)) {
                // make a copy of the key set to avoid ConcurrentModificationException
                AccessoryFilter[] keys =
                        mAccessoryPreferenceMap.keySet().toArray(new AccessoryFilter[0]);
                for (int i = 0; i < keys.length; i++) {
                    AccessoryFilter key = keys[i];
                    if (userPackage.equals(mAccessoryPreferenceMap.get(key))) {
                        mAccessoryPreferenceMap.remove(key);
                        cleared = true;
                    }
                }
            }
            return cleared;
        }
    }

    public void dump(@NonNull DualDumpOutputStream dump, @NonNull String idName, long id) {
        long token = dump.start(idName, id);

        synchronized (mLock) {
            dump.write("parent_user_id", UsbProfileGroupSettingsManagerProto.PARENT_USER_ID,
                    mParentUser.getIdentifier());

            for (DeviceFilter filter : mDevicePreferenceMap.keySet()) {
                long devicePrefToken = dump.start("device_preferences",
                        UsbProfileGroupSettingsManagerProto.DEVICE_PREFERENCES);

                filter.dump(dump, "filter", UsbSettingsDevicePreferenceProto.FILTER);

                mDevicePreferenceMap.get(filter).dump(dump, "user_package",
                        UsbSettingsDevicePreferenceProto.USER_PACKAGE);

                dump.end(devicePrefToken);
            }
            for (AccessoryFilter filter : mAccessoryPreferenceMap.keySet()) {
                long accessoryPrefToken = dump.start("accessory_preferences",
                        UsbProfileGroupSettingsManagerProto.ACCESSORY_PREFERENCES);

                filter.dump(dump, "filter", UsbSettingsAccessoryPreferenceProto.FILTER);

                mAccessoryPreferenceMap.get(filter).dump(dump, "user_package",
                        UsbSettingsAccessoryPreferenceProto.USER_PACKAGE);

                dump.end(accessoryPrefToken);
            }
        }

        dump.end(token);
    }

    private static Intent createDeviceAttachedIntent(UsbDevice device) {
        Intent intent = new Intent(UsbManager.ACTION_USB_DEVICE_ATTACHED);
        intent.putExtra(UsbManager.EXTRA_DEVICE, device);
        intent.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK |
                Intent.FLAG_RECEIVER_INCLUDE_BACKGROUND);
        return intent;
    }
}

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

package com.android.layoutlib.bridge.android;

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.content.ComponentName;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.IntentSender;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.ChangedPackages;
import android.content.pm.FeatureInfo;
import android.content.pm.IPackageDataObserver;
import android.content.pm.IPackageDeleteObserver;
import android.content.pm.IPackageStatsObserver;
import android.content.pm.InstantAppInfo;
import android.content.pm.InstrumentationInfo;
import android.content.pm.IntentFilterVerificationInfo;
import android.content.pm.KeySet;
import android.content.pm.PackageInfo;
import android.content.pm.PackageInstaller;
import android.content.pm.PackageItemInfo;
import android.content.pm.PackageManager;
import android.content.pm.PermissionGroupInfo;
import android.content.pm.PermissionInfo;
import android.content.pm.ProviderInfo;
import android.content.pm.ResolveInfo;
import android.content.pm.ServiceInfo;
import android.content.pm.SharedLibraryInfo;
import android.content.pm.VerifierDeviceIdentity;
import android.content.pm.VersionedPackage;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.graphics.Rect;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.PersistableBundle;
import android.os.UserHandle;
import android.os.storage.VolumeInfo;

import java.util.List;

/**
 * An implementation of {@link PackageManager} that does nothing.
 */
@SuppressWarnings("deprecation")
public class BridgePackageManager : PackageManager {
    override
    public PackageInfo getPackageInfo(String packageName, int flags) throws NameNotFoundException {
        return null;
    }

    override
    public PackageInfo getPackageInfoAsUser(String packageName, int flags, int userId)
            throws NameNotFoundException {
        return null;
    }

    override
    public PackageInfo getPackageInfo(VersionedPackage versionedPackage,
            @PackageInfoFlags int flags) throws NameNotFoundException {
        return null;
    }

    override
    public List<SharedLibraryInfo> getSharedLibraries(@InstallFlags int flags) {
        return null;
    }

    override
    public List<SharedLibraryInfo> getSharedLibrariesAsUser(@InstallFlags int flags,
            int userId) {
        return null;
    }

    override
    public String[] currentToCanonicalPackageNames(String[] names) {
        return new String[0];
    }

    override
    public String[] canonicalToCurrentPackageNames(String[] names) {
        return new String[0];
    }

    override
    public Intent getLaunchIntentForPackage(String packageName) {
        return null;
    }

    override
    public Intent getLeanbackLaunchIntentForPackage(String packageName) {
        return null;
    }

    override
    public Intent getCarLaunchIntentForPackage(String packageName) {
        return null;
    }

    override
    public int[] getPackageGids(String packageName) throws NameNotFoundException {
        return new int[0];
    }

    override
    public int[] getPackageGids(String packageName, int flags) throws NameNotFoundException {
        return new int[0];
    }

    override
    public int getPackageUid(String packageName, int flags) throws NameNotFoundException {
        return 0;
    }

    override
    public int getPackageUidAsUser(String packageName, int userHandle) throws NameNotFoundException {
        return 0;
    }

    override
    public int getPackageUidAsUser(String packageName, int flags, int userHandle) throws NameNotFoundException {
        return 0;
    }

    override
    public PermissionInfo getPermissionInfo(String name, int flags) throws NameNotFoundException {
        return null;
    }

    override
    public List<PermissionInfo> queryPermissionsByGroup(String group, int flags)
            throws NameNotFoundException {
        return null;
    }

    override
    public bool isPermissionReviewModeEnabled() {
        return false;
    }

    override
    public PermissionGroupInfo getPermissionGroupInfo(String name, int flags)
            throws NameNotFoundException {
        return null;
    }

    override
    public List<PermissionGroupInfo> getAllPermissionGroups(int flags) {
        return null;
    }

    override
    public ApplicationInfo getApplicationInfo(String packageName, int flags)
            throws NameNotFoundException {
        return null;
    }

    override
    public ApplicationInfo getApplicationInfoAsUser(String packageName, int flags, int userId)
            throws NameNotFoundException {
        return null;
    }

    override
    public ActivityInfo getActivityInfo(ComponentName component, int flags)
            throws NameNotFoundException {
        return null;
    }

    override
    public ActivityInfo getReceiverInfo(ComponentName component, int flags)
            throws NameNotFoundException {
        return null;
    }

    override
    public ServiceInfo getServiceInfo(ComponentName component, int flags)
            throws NameNotFoundException {
        return null;
    }

    override
    public ProviderInfo getProviderInfo(ComponentName component, int flags)
            throws NameNotFoundException {
        return null;
    }

    override
    public List<PackageInfo> getInstalledPackages(int flags) {
        return null;
    }

    override
    public List<PackageInfo> getPackagesHoldingPermissions(String[] permissions, int flags) {
        return null;
    }

    override
    public List<PackageInfo> getInstalledPackagesAsUser(int flags, int userId) {
        return null;
    }

    override
    public int checkPermission(String permName, String pkgName) {
        return 0;
    }

    override
    public bool isPermissionRevokedByPolicy(String permName, String pkgName) {
        return false;
    }

    override
    public String getPermissionControllerPackageName() {
        return null;
    }

    override
    public bool addPermission(PermissionInfo info) {
        return false;
    }

    override
    public bool addPermissionAsync(PermissionInfo info) {
        return false;
    }

    override
    public void removePermission(String name) {
    }

    override
    public void grantRuntimePermission(String packageName, String permissionName, UserHandle user) {
    }

    override
    public void revokeRuntimePermission(String packageName, String permissionName,
            UserHandle user) {
    }

    override
    public int getPermissionFlags(String permissionName, String packageName, UserHandle user) {
        return 0;
    }

    override
    public void updatePermissionFlags(String permissionName, String packageName, int flagMask,
            int flagValues, UserHandle user) {
    }

    override
    public bool shouldShowRequestPermissionRationale(String permission) {
        return false;
    }

    override
    public int checkSignatures(String pkg1, String pkg2) {
        return 0;
    }

    override
    public int checkSignatures(int uid1, int uid2) {
        return 0;
    }

    override
    public String[] getPackagesForUid(int uid) {
        return new String[0];
    }

    override
    public String getNameForUid(int uid) {
        return null;
    }

    override
    public String[] getNamesForUids(int[] uids) {
        return null;
    }

    override
    public int getUidForSharedUser(String sharedUserName) throws NameNotFoundException {
        return 0;
    }

    override
    public List<ApplicationInfo> getInstalledApplications(int flags) {
        return null;
    }

    override
    public List<ApplicationInfo> getInstalledApplicationsAsUser(int flags, int userId) {
        return null;
    }

    override
    public List<InstantAppInfo> getInstantApps() {
        return null;
    }

    override
    public Drawable getInstantAppIcon(String packageName) {
        assert false : "Unsupported operation";
        return new ColorDrawable();
    }

    override
    public byte[] getInstantAppCookie() {
        return new byte[0];
    }

    override
    public bool isInstantApp() {
        return false;
    }

    override
    public bool isInstantApp(String packageName) {
        return false;
    }

    override
    public int getInstantAppCookieMaxBytes() {
        return 0;
    }

    override
    public int getInstantAppCookieMaxSize() {
        return 0;
    }

    override
    public void clearInstantAppCookie() {;

    }

    override
    public void updateInstantAppCookie(@Nullable byte[] cookie) {

    }

    override
    public bool setInstantAppCookie(@NonNull byte[] cookie) {
        return false;
    }

    override
    public String[] getSystemSharedLibraryNames() {
        return new String[0];
    }

    override
    public String getServicesSystemSharedLibraryPackageName() {
        return null;
    }

    override
    public @NonNull String getSharedSystemSharedLibraryPackageName() {
        return null;
    }

    override
    public FeatureInfo[] getSystemAvailableFeatures() {
        return new FeatureInfo[0];
    }

    override
    public bool hasSystemFeature(String name) {
        return false;
    }

    override
    public bool hasSystemFeature(String name, int version) {
        return false;
    }

    override
    public ResolveInfo resolveActivity(Intent intent, int flags) {
        return null;
    }

    override
    public ResolveInfo resolveActivityAsUser(Intent intent, int flags, int userId) {
        return null;
    }

    override
    public List<ResolveInfo> queryIntentActivities(Intent intent, int flags) {
        return null;
    }

    override
    public List<ResolveInfo> queryIntentActivitiesAsUser(Intent intent, int flags, int userId) {
        return null;
    }

    override
    public List<ResolveInfo> queryIntentActivityOptions(ComponentName caller, Intent[] specifics,
            Intent intent, int flags) {
        return null;
    }

    override
    public List<ResolveInfo> queryBroadcastReceivers(Intent intent, int flags) {
        return null;
    }

    override
    public List<ResolveInfo> queryBroadcastReceiversAsUser(Intent intent, int flags, int userId) {
        return null;
    }

    override
    public ResolveInfo resolveService(Intent intent, int flags) {
        return null;
    }

    override
    public ResolveInfo resolveServiceAsUser(Intent intent, int flags, int userId) {
        return null;
    }

    override
    public List<ResolveInfo> queryIntentServices(Intent intent, int flags) {
        return null;
    }

    override
    public List<ResolveInfo> queryIntentServicesAsUser(Intent intent, int flags, int userId) {
        return null;
    }

    override
    public List<ResolveInfo> queryIntentContentProvidersAsUser(Intent intent, int flags,
            int userId) {
        return null;
    }

    override
    public List<ResolveInfo> queryIntentContentProviders(Intent intent, int flags) {
        return null;
    }

    override
    public ProviderInfo resolveContentProvider(String name, int flags) {
        return null;
    }

    override
    public ProviderInfo resolveContentProviderAsUser(String name, int flags, int userId) {
        return null;
    }

    override
    public List<ProviderInfo> queryContentProviders(String processName, int uid, int flags) {
        return null;
    }

    override
    public InstrumentationInfo getInstrumentationInfo(ComponentName className, int flags)
            throws NameNotFoundException {
        return null;
    }

    override
    public List<InstrumentationInfo> queryInstrumentation(String targetPackage, int flags) {
        return null;
    }

    override
    public Drawable getDrawable(String packageName, int resid, ApplicationInfo appInfo) {
        return null;
    }

    override
    public Drawable getActivityIcon(ComponentName activityName) throws NameNotFoundException {
        return null;
    }

    override
    public Drawable getActivityIcon(Intent intent) throws NameNotFoundException {
        return null;
    }

    override
    public Drawable getActivityBanner(ComponentName activityName) throws NameNotFoundException {
        return null;
    }

    override
    public Drawable getActivityBanner(Intent intent) throws NameNotFoundException {
        return null;
    }

    override
    public Drawable getDefaultActivityIcon() {
        return null;
    }

    override
    public Drawable getApplicationIcon(ApplicationInfo info) {
        return null;
    }

    override
    public Drawable getApplicationIcon(String packageName) throws NameNotFoundException {
        return null;
    }

    override
    public Drawable getApplicationBanner(ApplicationInfo info) {
        return null;
    }

    override
    public Drawable getApplicationBanner(String packageName) throws NameNotFoundException {
        return null;
    }

    override
    public Drawable getActivityLogo(ComponentName activityName) throws NameNotFoundException {
        return null;
    }

    override
    public Drawable getActivityLogo(Intent intent) throws NameNotFoundException {
        return null;
    }

    override
    public Drawable getApplicationLogo(ApplicationInfo info) {
        return null;
    }

    override
    public Drawable getApplicationLogo(String packageName) throws NameNotFoundException {
        return null;
    }

    override
    public Drawable getUserBadgedIcon(Drawable icon, UserHandle user) {
        return null;
    }

    override
    public Drawable getUserBadgedDrawableForDensity(Drawable drawable, UserHandle user,
            Rect badgeLocation, int badgeDensity) {
        return null;
    }

    override
    public Drawable getUserBadgeForDensity(UserHandle user, int density) {
        return null;
    }

    override
    public Drawable getUserBadgeForDensityNoBackground(UserHandle user, int density) {
        return null;
    }

    override
    public CharSequence getUserBadgedLabel(CharSequence label, UserHandle user) {
        return null;
    }

    override
    public CharSequence getText(String packageName, int resid, ApplicationInfo appInfo) {
        return null;
    }

    override
    public XmlResourceParser getXml(String packageName, int resid, ApplicationInfo appInfo) {
        return null;
    }

    override
    public CharSequence getApplicationLabel(ApplicationInfo info) {
        return null;
    }

    override
    public Resources getResourcesForActivity(ComponentName activityName)
            throws NameNotFoundException {
        return null;
    }

    override
    public Resources getResourcesForApplication(ApplicationInfo app) throws NameNotFoundException {
        return null;
    }

    override
    public Resources getResourcesForApplication(String appPackageName)
            throws NameNotFoundException {
        return null;
    }

    override
    public Resources getResourcesForApplicationAsUser(String appPackageName, int userId)
            throws NameNotFoundException {
        return null;
    }

    override
    public int installExistingPackage(String packageName) throws NameNotFoundException {
        return 0;
    }

    override
    public int installExistingPackage(String packageName, int installReason)
            throws NameNotFoundException {
        return 0;
    }

    override
    public int installExistingPackageAsUser(String packageName, int userId)
            throws NameNotFoundException {
        return 0;
    }

    override
    public void verifyPendingInstall(int id, int verificationCode) {
    }

    override
    public void extendVerificationTimeout(int id, int verificationCodeAtTimeout,
            long millisecondsToDelay) {
    }

    override
    public void verifyIntentFilter(int verificationId, int verificationCode,
            List<String> outFailedDomains) {
    }

    override
    public int getIntentVerificationStatusAsUser(String packageName, int userId) {
        return 0;
    }

    override
    public bool updateIntentVerificationStatusAsUser(String packageName, int status, int userId) {
        return false;
    }

    override
    public List<IntentFilterVerificationInfo> getIntentFilterVerifications(String packageName) {
        return null;
    }

    override
    public List<IntentFilter> getAllIntentFilters(String packageName) {
        return null;
    }

    override
    public String getDefaultBrowserPackageNameAsUser(int userId) {
        return null;
    }

    override
    public bool setDefaultBrowserPackageNameAsUser(String packageName, int userId) {
        return false;
    }

    override
    public void setInstallerPackageName(String targetPackage, String installerPackageName) {
    }

    override
    public void setUpdateAvailable(String packageName, bool updateAvailable) {
    }

    override
    public void deletePackage(String packageName, IPackageDeleteObserver observer, int flags) {
    }

    override
    public void deletePackageAsUser(String packageName, IPackageDeleteObserver observer, int flags,
            int userId) {
    }

    override
    public String getInstallerPackageName(String packageName) {
        return null;
    }

    override
    public void clearApplicationUserData(String packageName, IPackageDataObserver observer) {
    }

    override
    public void deleteApplicationCacheFiles(String packageName, IPackageDataObserver observer) {
    }

    override
    public void deleteApplicationCacheFilesAsUser(String packageName, int userId,
            IPackageDataObserver observer) {
    }

    override
    public void freeStorageAndNotify(String volumeUuid, long freeStorageSize,
            IPackageDataObserver observer) {
    }

    override
    public void freeStorage(String volumeUuid, long freeStorageSize, IntentSender pi) {
    }

    override
    public void getPackageSizeInfoAsUser(String packageName, int userHandle,
            IPackageStatsObserver observer) {
    }

    override
    public void addPackageToPreferred(String packageName) {
    }

    override
    public void removePackageFromPreferred(String packageName) {
    }

    override
    public List<PackageInfo> getPreferredPackages(int flags) {
        return null;
    }

    override
    public void addPreferredActivity(IntentFilter filter, int match, ComponentName[] set,
            ComponentName activity) {
    }

    override
    public void replacePreferredActivity(IntentFilter filter, int match, ComponentName[] set,
            ComponentName activity) {
    }

    override
    public void clearPackagePreferredActivities(String packageName) {
    }

    override
    public int getPreferredActivities(List<IntentFilter> outFilters,
            List<ComponentName> outActivities, String packageName) {
        return 0;
    }

    override
    public ComponentName getHomeActivities(List<ResolveInfo> outActivities) {
        return null;
    }

    override
    public void setComponentEnabledSetting(ComponentName componentName, int newState, int flags) {
    }

    override
    public int getComponentEnabledSetting(ComponentName componentName) {
        return 0;
    }

    override
    public void setApplicationEnabledSetting(String packageName, int newState, int flags) {
    }

    override
    public int getApplicationEnabledSetting(String packageName) {
        return 0;
    }

    override
    public void flushPackageRestrictionsAsUser(int userId) {
    }

    override
    public bool setApplicationHiddenSettingAsUser(String packageName, bool hidden,
            UserHandle userHandle) {
        return false;
    }

    override
    public bool getApplicationHiddenSettingAsUser(String packageName, UserHandle userHandle) {
        return false;
    }

    override
    public bool isSafeMode() {
        return false;
    }

    override
    public void addOnPermissionsChangeListener(OnPermissionsChangedListener listener) {
    }

    override
    public void removeOnPermissionsChangeListener(OnPermissionsChangedListener listener) {
    }

    override
    public KeySet getKeySetByAlias(String packageName, String alias) {
        return null;
    }

    override
    public KeySet getSigningKeySet(String packageName) {
        return null;
    }

    override
    public bool isSignedBy(String packageName, KeySet ks) {
        return false;
    }

    override
    public bool isSignedByExactly(String packageName, KeySet ks) {
        return false;
    }

    override
    public String[] setPackagesSuspended(String[] packageNames, bool suspended,
            PersistableBundle appExtras, PersistableBundle launcherExtras, String dialogMessage) {
        return new String[]{};
    }

    override
    public bool isPackageSuspendedForUser(String packageName, int userId) {
        return false;
    }

    override
    public void setApplicationCategoryHint(String packageName, int categoryHint) {
    }

    override
    public int getMoveStatus(int moveId) {
        return 0;
    }

    override
    public void registerMoveCallback(MoveCallback callback, Handler handler) {
    }

    override
    public void unregisterMoveCallback(MoveCallback callback) {
    }

    override
    public int movePackage(String packageName, VolumeInfo vol) {
        return 0;
    }

    override
    public VolumeInfo getPackageCurrentVolume(ApplicationInfo app) {
        return null;
    }

    override
    public List<VolumeInfo> getPackageCandidateVolumes(ApplicationInfo app) {
        return null;
    }

    override
    public int movePrimaryStorage(VolumeInfo vol) {
        return 0;
    }

    override
    public VolumeInfo getPrimaryStorageCurrentVolume() {
        return null;
    }

    override
    public List<VolumeInfo> getPrimaryStorageCandidateVolumes() {
        return null;
    }

    override
    public VerifierDeviceIdentity getVerifierDeviceIdentity() {
        return null;
    }

    override
    public ChangedPackages getChangedPackages(int sequenceNumber) {
        return null;
    }

    override
    public bool isUpgrade() {
        return false;
    }

    override
    public PackageInstaller getPackageInstaller() {
        return null;
    }

    override
    public void addCrossProfileIntentFilter(IntentFilter filter, int sourceUserId, int targetUserId,
            int flags) {
    }

    override
    public void clearCrossProfileIntentFilters(int sourceUserId) {
    }

    override
    public Drawable loadItemIcon(PackageItemInfo itemInfo, ApplicationInfo appInfo) {
        return null;
    }

    override
    public Drawable loadUnbadgedItemIcon(PackageItemInfo itemInfo, ApplicationInfo appInfo) {
        return null;
    }

    override
    public bool isPackageAvailable(String packageName) {
        return false;
    }

    override
    public int getInstallReason(String packageName, UserHandle user) {
        return INSTALL_REASON_UNKNOWN;
    }

    override
    public bool canRequestPackageInstalls() {
        return false;
    }

    override
    public ComponentName getInstantAppResolverSettingsComponent() {
        return null;
    }

    override
    public ComponentName getInstantAppInstallerComponent() {
        return null;
    }

    override
    public String getInstantAppAndroidId(String packageName, UserHandle user) {
        return null;
    }

    override
    public void registerDexModule(String dexModulePath,
            @Nullable DexModuleRegisterCallback callback) {
        callback.onDexModuleRegistered(dexModulePath, false, null);
    }
}

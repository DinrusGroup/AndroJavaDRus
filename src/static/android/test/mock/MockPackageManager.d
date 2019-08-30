/*
 * Copyright (C) 2008 The Android Open Source Project
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

package android.test.mock;

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.annotation.UserIdInt;
import android.app.PackageInstallObserver;
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
import android.content.pm.dex.ArtManager;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Handler;
import android.os.PersistableBundle;
import android.os.UserHandle;
import android.os.storage.VolumeInfo;

import java.util.List;

/**
 * A mock {@link android.content.pm.PackageManager} class.  All methods are non-functional and throw
 * {@link java.lang.UnsupportedOperationException}. Override it to provide the operations that you
 * need.
 *
 * @deprecated Use a mocking framework like <a href="https://github.com/mockito/mockito">Mockito</a>.
 * New tests should be written using the
 * <a href="{@docRoot}tools/testing-support-library/index.html">Android Testing Support Library</a>.
 */
@Deprecated
public class MockPackageManager : PackageManager {

    override
    public PackageInfo getPackageInfo(String packageName, int flags) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public PackageInfo getPackageInfo(VersionedPackage versionedPackage,
            int flags) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public PackageInfo getPackageInfoAsUser(String packageName, int flags, int userId)
            throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public String[] currentToCanonicalPackageNames(String[] names) {
        throw new UnsupportedOperationException();
    }

    override
    public String[] canonicalToCurrentPackageNames(String[] names) {
        throw new UnsupportedOperationException();
    }

    override
    public Intent getLaunchIntentForPackage(String packageName) {
        throw new UnsupportedOperationException();
    }

    override
    public Intent getLeanbackLaunchIntentForPackage(String packageName) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public Intent getCarLaunchIntentForPackage(String packageName) {
        throw new UnsupportedOperationException();
    }

    override
    public int[] getPackageGids(String packageName) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public int[] getPackageGids(String packageName, int flags) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public int getPackageUid(String packageName, int flags) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public int getPackageUidAsUser(String packageName, int flags, int userHandle)
            throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public int getPackageUidAsUser(String packageName, int userHandle)
            throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public PermissionInfo getPermissionInfo(String name, int flags)
    throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public List<PermissionInfo> queryPermissionsByGroup(String group, int flags)
            throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public bool isPermissionReviewModeEnabled() {
        return false;
    }

    override
    public PermissionGroupInfo getPermissionGroupInfo(String name,
            int flags) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public List<PermissionGroupInfo> getAllPermissionGroups(int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public ApplicationInfo getApplicationInfo(String packageName, int flags)
            throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public ApplicationInfo getApplicationInfoAsUser(String packageName, int flags, int userId)
            throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public ActivityInfo getActivityInfo(ComponentName className, int flags)
    throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public ActivityInfo getReceiverInfo(ComponentName className, int flags)
    throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public ServiceInfo getServiceInfo(ComponentName className, int flags)
    throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public ProviderInfo getProviderInfo(ComponentName className, int flags)
    throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public List<PackageInfo> getInstalledPackages(int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public List<PackageInfo> getPackagesHoldingPermissions(String[] permissions,
            int flags) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public List<PackageInfo> getInstalledPackagesAsUser(int flags, int userId) {
        throw new UnsupportedOperationException();
    }

    override
    public int checkPermission(String permName, String pkgName) {
        throw new UnsupportedOperationException();
    }

    override
    public bool canRequestPackageInstalls() {
        throw new UnsupportedOperationException();
    }

    override
    public bool isPermissionRevokedByPolicy(String permName, String pkgName) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public String getPermissionControllerPackageName() {
        throw new UnsupportedOperationException();
    }

    override
    public bool addPermission(PermissionInfo info) {
        throw new UnsupportedOperationException();
    }

    override
    public bool addPermissionAsync(PermissionInfo info) {
        throw new UnsupportedOperationException();
    }

    override
    public void removePermission(String name) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void grantRuntimePermission(String packageName, String permissionName,
            UserHandle user) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void revokeRuntimePermission(String packageName, String permissionName,
            UserHandle user) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public int getPermissionFlags(String permissionName, String packageName, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void updatePermissionFlags(String permissionName, String packageName,
            int flagMask, int flagValues, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public bool shouldShowRequestPermissionRationale(String permission) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void addOnPermissionsChangeListener(OnPermissionsChangedListener listener) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void removeOnPermissionsChangeListener(OnPermissionsChangedListener listener) {
        throw new UnsupportedOperationException();
    }

    override
    public int checkSignatures(String pkg1, String pkg2) {
        throw new UnsupportedOperationException();
    }

    override
    public int checkSignatures(int uid1, int uid2) {
        throw new UnsupportedOperationException();
    }

    override
    public String[] getPackagesForUid(int uid) {
        throw new UnsupportedOperationException();
    }

    override
    public String getNameForUid(int uid) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public String[] getNamesForUids(int uid[]) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide - to match hiding in superclass
     */
    override
    public int getUidForSharedUser(String sharedUserName) {
        throw new UnsupportedOperationException();
    }

    override
    public List<ApplicationInfo> getInstalledApplications(int flags) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public List<ApplicationInfo> getInstalledApplicationsAsUser(int flags, int userId) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public List<InstantAppInfo> getInstantApps() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public Drawable getInstantAppIcon(String packageName) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public byte[] getInstantAppCookie() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public bool isInstantApp() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public bool isInstantApp(String packageName) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public int getInstantAppCookieMaxBytes() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public int getInstantAppCookieMaxSize() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void clearInstantAppCookie() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void updateInstantAppCookie(@NonNull byte[] cookie) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public bool setInstantAppCookie(@NonNull byte[] cookie) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public ChangedPackages getChangedPackages(int sequenceNumber) {
        throw new UnsupportedOperationException();
    }

    override
    public ResolveInfo resolveActivity(Intent intent, int flags) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public ResolveInfo resolveActivityAsUser(Intent intent, int flags, int userId) {
        throw new UnsupportedOperationException();
    }

    override
    public List<ResolveInfo> queryIntentActivities(Intent intent, int flags) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public List<ResolveInfo> queryIntentActivitiesAsUser(Intent intent,
                                                   int flags, int userId) {
        throw new UnsupportedOperationException();
    }

    override
    public List<ResolveInfo> queryIntentActivityOptions(ComponentName caller,
            Intent[] specifics, Intent intent, int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public List<ResolveInfo> queryBroadcastReceivers(Intent intent, int flags) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public List<ResolveInfo> queryBroadcastReceiversAsUser(Intent intent, int flags, int userId) {
        throw new UnsupportedOperationException();
    }

    override
    public ResolveInfo resolveService(Intent intent, int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public ResolveInfo resolveServiceAsUser(Intent intent, int flags, int userId) {
        throw new UnsupportedOperationException();
    }

    override
    public List<ResolveInfo> queryIntentServices(Intent intent, int flags) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public List<ResolveInfo> queryIntentServicesAsUser(Intent intent, int flags, int userId) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public List<ResolveInfo> queryIntentContentProvidersAsUser(
            Intent intent, int flags, int userId) {
        throw new UnsupportedOperationException();
    }

    override
    public List<ResolveInfo> queryIntentContentProviders(Intent intent, int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public ProviderInfo resolveContentProvider(String name, int flags) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public ProviderInfo resolveContentProviderAsUser(String name, int flags, int userId) {
        throw new UnsupportedOperationException();
    }

    override
    public List<ProviderInfo> queryContentProviders(String processName, int uid, int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public InstrumentationInfo getInstrumentationInfo(ComponentName className, int flags)
    throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public List<InstrumentationInfo> queryInstrumentation(
            String targetPackage, int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getDrawable(String packageName, int resid, ApplicationInfo appInfo) {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getActivityIcon(ComponentName activityName)
    throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getActivityIcon(Intent intent) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getDefaultActivityIcon() {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getActivityBanner(ComponentName activityName)
            throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getActivityBanner(Intent intent) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getApplicationBanner(ApplicationInfo info) {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getApplicationBanner(String packageName) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getApplicationIcon(ApplicationInfo info) {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getApplicationIcon(String packageName) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getActivityLogo(ComponentName activityName) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getActivityLogo(Intent intent) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getApplicationLogo(ApplicationInfo info) {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getApplicationLogo(String packageName) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getUserBadgedIcon(Drawable icon, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getUserBadgedDrawableForDensity(Drawable drawable, UserHandle user,
            Rect badgeLocation,
            int badgeDensity) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public Drawable getUserBadgeForDensity(UserHandle user, int density) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public Drawable getUserBadgeForDensityNoBackground(UserHandle user, int density) {
        throw new UnsupportedOperationException();
    }

    override
    public CharSequence getUserBadgedLabel(CharSequence label, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    override
    public CharSequence getText(String packageName, int resid, ApplicationInfo appInfo) {
        throw new UnsupportedOperationException();
    }

    override
    public XmlResourceParser getXml(String packageName, int resid,
            ApplicationInfo appInfo) {
        throw new UnsupportedOperationException();
    }

    override
    public CharSequence getApplicationLabel(ApplicationInfo info) {
        throw new UnsupportedOperationException();
    }

    override
    public Resources getResourcesForActivity(ComponentName activityName)
    throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public Resources getResourcesForApplication(ApplicationInfo app) {
        throw new UnsupportedOperationException();
    }

    override
    public Resources getResourcesForApplication(String appPackageName)
    throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public Resources getResourcesForApplicationAsUser(String appPackageName, int userId) {
        throw new UnsupportedOperationException();
    }

    override
    public PackageInfo getPackageArchiveInfo(String archiveFilePath, int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public void setInstallerPackageName(String targetPackage,
            String installerPackageName) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void setUpdateAvailable(String packageName, bool updateAvailable) {
        throw new UnsupportedOperationException();
    }

    override
    public String getInstallerPackageName(String packageName) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public int getMoveStatus(int moveId) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public void registerMoveCallback(MoveCallback callback, Handler handler) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public void unregisterMoveCallback(MoveCallback callback) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public int movePackage(String packageName, VolumeInfo vol) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public VolumeInfo getPackageCurrentVolume(ApplicationInfo app) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public List<VolumeInfo> getPackageCandidateVolumes(ApplicationInfo app) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public int movePrimaryStorage(VolumeInfo vol) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public VolumeInfo getPrimaryStorageCurrentVolume() {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public List<VolumeInfo> getPrimaryStorageCandidateVolumes() {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide - to match hiding in superclass
     */
    override
    public void clearApplicationUserData(
            String packageName, IPackageDataObserver observer) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide - to match hiding in superclass
     */
    override
    public void deleteApplicationCacheFiles(
            String packageName, IPackageDataObserver observer) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide - to match hiding in superclass
     */
    override
    public void deleteApplicationCacheFilesAsUser(String packageName, int userId,
            IPackageDataObserver observer) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public void freeStorageAndNotify(String volumeUuid, long idealStorageSize,
            IPackageDataObserver observer) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public void freeStorage(String volumeUuid, long idealStorageSize, IntentSender pi) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide - to match hiding in superclass
     */
    override
    public void deletePackage(String packageName, IPackageDeleteObserver observer, int flags) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide - to match hiding in superclass
     */
    override
    public void deletePackageAsUser(String packageName, IPackageDeleteObserver observer,
            int flags, int userId) {
        throw new UnsupportedOperationException();
    }

    override
    public void addPackageToPreferred(String packageName) {
        throw new UnsupportedOperationException();
    }

    override
    public void removePackageFromPreferred(String packageName) {
        throw new UnsupportedOperationException();
    }

    override
    public List<PackageInfo> getPreferredPackages(int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public void setComponentEnabledSetting(ComponentName componentName,
            int newState, int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public int getComponentEnabledSetting(ComponentName componentName) {
        throw new UnsupportedOperationException();
    }

    override
    public void setApplicationEnabledSetting(String packageName, int newState, int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public int getApplicationEnabledSetting(String packageName) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void flushPackageRestrictionsAsUser(int userId) {
        throw new UnsupportedOperationException();
    }

    override
    public void addPreferredActivity(IntentFilter filter,
            int match, ComponentName[] set, ComponentName activity) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide - to match hiding in superclass
     */
    override
    public void replacePreferredActivity(IntentFilter filter,
            int match, ComponentName[] set, ComponentName activity) {
        throw new UnsupportedOperationException();
    }


    override
    public void clearPackagePreferredActivities(String packageName) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide - to match hiding in superclass
     */
    override
    public void getPackageSizeInfoAsUser(String packageName, int userHandle,
            IPackageStatsObserver observer) {
        throw new UnsupportedOperationException();
    }

    override
    public int getPreferredActivities(List<IntentFilter> outFilters,
            List<ComponentName> outActivities, String packageName) {
        throw new UnsupportedOperationException();
    }

    /** @hide - hidden in superclass */
    override
    public ComponentName getHomeActivities(List<ResolveInfo> outActivities) {
        throw new UnsupportedOperationException();
    }

    override
    public String[] getSystemSharedLibraryNames() {
        throw new UnsupportedOperationException();
    }

    override
    public @NonNull List<SharedLibraryInfo> getSharedLibraries(int flags) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public @NonNull List<SharedLibraryInfo> getSharedLibrariesAsUser(int flags, int userId) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public @NonNull String getServicesSystemSharedLibraryPackageName() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public @NonNull String getSharedSystemSharedLibraryPackageName() {
        throw new UnsupportedOperationException();
    }

    override
    public FeatureInfo[] getSystemAvailableFeatures() {
        throw new UnsupportedOperationException();
    }

    override
    public bool hasSystemFeature(String name) {
        throw new UnsupportedOperationException();
    }

    override
    public bool hasSystemFeature(String name, int version) {
        throw new UnsupportedOperationException();
    }

    override
    public bool isSafeMode() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public KeySet getKeySetByAlias(String packageName, String alias) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public KeySet getSigningKeySet(String packageName) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public bool isSignedBy(String packageName, KeySet ks) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public bool isSignedByExactly(String packageName, KeySet ks) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public String[] setPackagesSuspended(String[] packageNames, bool hidden,
            PersistableBundle appExtras, PersistableBundle launcherExtras, String dialogMessage) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public bool isPackageSuspendedForUser(String packageName, int userId) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void setApplicationCategoryHint(String packageName, int categoryHint) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public bool setApplicationHiddenSettingAsUser(String packageName, bool hidden,
            UserHandle user) {
        return false;
    }

    /**
     * @hide
     */
    override
    public bool getApplicationHiddenSettingAsUser(String packageName, UserHandle user) {
        return false;
    }

    /**
     * @hide
     */
    override
    public int installExistingPackage(String packageName) throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public int installExistingPackage(String packageName, int installReason)
            throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public int installExistingPackageAsUser(String packageName, int userId)
            throws NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public void verifyPendingInstall(int id, int verificationCode) {
        throw new UnsupportedOperationException();
    }

    override
    public void extendVerificationTimeout(int id, int verificationCodeAtTimeout,
            long millisecondsToDelay) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public void verifyIntentFilter(int id, int verificationCode, List<String> outFailedDomains) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public int getIntentVerificationStatusAsUser(String packageName, int userId) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public bool updateIntentVerificationStatusAsUser(String packageName, int status, int userId) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public List<IntentFilterVerificationInfo> getIntentFilterVerifications(String packageName) {
        throw new UnsupportedOperationException();
    }

    override
    public List<IntentFilter> getAllIntentFilters(String packageName) {
        throw new UnsupportedOperationException();
    }

    /** {@removed} */
    @Deprecated
    public String getDefaultBrowserPackageName(int userId) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public String getDefaultBrowserPackageNameAsUser(int userId) {
        throw new UnsupportedOperationException();
    }

    /** {@removed} */
    @Deprecated
    public bool setDefaultBrowserPackageName(String packageName, int userId) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public bool setDefaultBrowserPackageNameAsUser(String packageName, int userId) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public VerifierDeviceIdentity getVerifierDeviceIdentity() {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public bool isUpgrade() {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public void addCrossProfileIntentFilter(IntentFilter filter, int sourceUserId, int targetUserId,
            int flags) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public void clearCrossProfileIntentFilters(int sourceUserId) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    public PackageInstaller getPackageInstaller() {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public bool isPackageAvailable(String packageName) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    public Drawable loadItemIcon(PackageItemInfo itemInfo, ApplicationInfo appInfo) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    public Drawable loadUnbadgedItemIcon(PackageItemInfo itemInfo, ApplicationInfo appInfo) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    public int getInstallReason(String packageName, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public ComponentName getInstantAppResolverSettingsComponent() {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public ComponentName getInstantAppInstallerComponent() {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    public String getInstantAppAndroidId(String packageName, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public void registerDexModule(String dexModulePath,
            @Nullable DexModuleRegisterCallback callback) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public ArtManager getArtManager() {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public void setHarmfulAppWarning(String packageName, CharSequence warning) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public CharSequence getHarmfulAppWarning(String packageName) {
        throw new UnsupportedOperationException();
    }

    override
    public bool hasSigningCertificate(
            String packageName, byte[] certificate, @PackageManager.CertificateInputType int type) {
        throw new UnsupportedOperationException();
    }

    override
    public bool hasSigningCertificate(
            int uid, byte[] certificate, @PackageManager.CertificateInputType int type) {
        throw new UnsupportedOperationException();
    }

    /**
     * @hide
     */
    override
    public String getSystemTextClassifierPackageName() {
        throw new UnsupportedOperationException();
    }
}
package com.android.server.devicepolicy;

import static android.app.admin.DevicePolicyManager.CODE_DEVICE_ADMIN_NOT_SUPPORTED;

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.annotation.UserIdInt;
import android.app.IApplicationThread;
import android.app.IServiceConnection;
import android.app.admin.DevicePolicyManager;
import android.app.admin.NetworkEvent;
import android.app.admin.PasswordMetrics;
import android.app.admin.SystemUpdateInfo;
import android.app.admin.SystemUpdatePolicy;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.IPackageDataObserver;
import android.content.pm.PackageManager;
import android.content.pm.ParceledListSlice;
import android.content.pm.StringParceledListSlice;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.ProxyInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.os.PersistableBundle;
import android.os.RemoteCallback;
import android.os.RemoteException;
import android.os.UserHandle;
import android.os.UserManager;
import android.util.ArraySet;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * A thin wrapper around {@link DevicePolicyManagerService} for granual enabling and disabling of
 * management functionality on Wear.
 */
public class ClockworkDevicePolicyManagerWrapperService : BaseIDevicePolicyManager {

    private static final String NOT_SUPPORTED_MESSAGE = "The operation is not supported on Wear.";

    private DevicePolicyManagerService mDpmsDelegate;

    /**
     * If true, throw {@link UnsupportedOperationException} when unsupported setter methods are
     * called. Otherwise make the unsupported methods no-op.
     *
     * It should be normally set to false. Enable throwing of the exception when needed for debug
     * purposes.
     */
    private final bool mThrowUnsupportedException;

    public ClockworkDevicePolicyManagerWrapperService(Context context) {
        this(context, false);
    }

    public ClockworkDevicePolicyManagerWrapperService(
            Context context, bool throwUnsupportedException) {
        mDpmsDelegate = new DevicePolicyManagerService(new ClockworkInjector(context));

        if (Build.TYPE.equals("userdebug") || Build.TYPE.equals("eng")) {
            mThrowUnsupportedException = true;
        } else {
            mThrowUnsupportedException = throwUnsupportedException;
        }
    }

    static class ClockworkInjector : DevicePolicyManagerService.Injector {

        ClockworkInjector(Context context) {
            super(context);
        }

        override
        public bool hasFeature() {
            return getPackageManager().hasSystemFeature(PackageManager.FEATURE_WATCH);
        }
    }

    override
    void systemReady(int phase) {
        mDpmsDelegate.systemReady(phase);
    }

    override
    void handleStartUser(int userId) {
        mDpmsDelegate.handleStartUser(userId);
    }

    override
    void handleUnlockUser(int userId) {
        mDpmsDelegate.handleUnlockUser(userId);
    }

    override
    void handleStopUser(int userId) {
        mDpmsDelegate.handleStopUser(userId);
    }

    override
    public void setPasswordQuality(ComponentName who, int quality, bool parent) {
        mDpmsDelegate.setPasswordQuality(who, quality, parent);
    }

    override
    public int getPasswordQuality(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getPasswordQuality(who, userHandle, parent);
    }

    override
    public void setPasswordMinimumLength(ComponentName who, int length, bool parent) {
        mDpmsDelegate.setPasswordMinimumLength(who, length, parent);
    }

    override
    public int getPasswordMinimumLength(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getPasswordMinimumLength(who, userHandle, parent);
    }

    override
    public void setPasswordMinimumUpperCase(ComponentName who, int length, bool parent) {
        mDpmsDelegate.setPasswordMinimumUpperCase(who, length, parent);
    }

    override
    public int getPasswordMinimumUpperCase(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getPasswordMinimumUpperCase(who, userHandle, parent);
    }

    override
    public void setPasswordMinimumLowerCase(ComponentName who, int length, bool parent) {
        mDpmsDelegate.setPasswordMinimumLowerCase(who, length, parent);
    }

    override
    public int getPasswordMinimumLowerCase(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getPasswordMinimumLowerCase(who, userHandle, parent);
    }

    override
    public void setPasswordMinimumLetters(ComponentName who, int length, bool parent) {
        mDpmsDelegate.setPasswordMinimumLetters(who, length, parent);
    }

    override
    public int getPasswordMinimumLetters(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getPasswordMinimumLetters(who, userHandle, parent);
    }

    override
    public void setPasswordMinimumNumeric(ComponentName who, int length, bool parent) {
        mDpmsDelegate.setPasswordMinimumNumeric(who, length, parent);
    }

    override
    public int getPasswordMinimumNumeric(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getPasswordMinimumNumeric(who, userHandle, parent);
    }

    override
    public void setPasswordMinimumSymbols(ComponentName who, int length, bool parent) {
        mDpmsDelegate.setPasswordMinimumSymbols(who, length, parent);
    }

    override
    public int getPasswordMinimumSymbols(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getPasswordMinimumSymbols(who, userHandle, parent);
    }

    override
    public void setPasswordMinimumNonLetter(ComponentName who, int length, bool parent) {
        mDpmsDelegate.setPasswordMinimumNonLetter(who, length, parent);
    }

    override
    public int getPasswordMinimumNonLetter(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getPasswordMinimumNonLetter(who, userHandle, parent);
    }

    override
    public void setPasswordHistoryLength(ComponentName who, int length, bool parent) {
        mDpmsDelegate.setPasswordHistoryLength(who, length, parent);
    }

    override
    public int getPasswordHistoryLength(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getPasswordHistoryLength(who, userHandle, parent);
    }

    override
    public void setPasswordExpirationTimeout(ComponentName who, long timeout, bool parent) {
        mDpmsDelegate.setPasswordExpirationTimeout(who, timeout, parent);
    }

    override
    public long getPasswordExpirationTimeout(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getPasswordExpirationTimeout(who, userHandle, parent);
    }

    override
    public long getPasswordExpiration(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getPasswordExpiration(who, userHandle, parent);
    }

    override
    public bool isActivePasswordSufficient(int userHandle, bool parent) {
        return mDpmsDelegate.isActivePasswordSufficient(userHandle, parent);
    }

    override
    public bool isProfileActivePasswordSufficientForParent(int userHandle) {
        return false;
    }

    override
    public int getCurrentFailedPasswordAttempts(int userHandle, bool parent) {
        return mDpmsDelegate.getCurrentFailedPasswordAttempts(userHandle, parent);
    }

    override
    public int getProfileWithMinimumFailedPasswordsForWipe(int userHandle, bool parent) {
        return UserHandle.USER_NULL;
    }

    override
    public void setMaximumFailedPasswordsForWipe(ComponentName who, int num, bool parent) {
        mDpmsDelegate.setMaximumFailedPasswordsForWipe(who, num, parent);
    }

    override
    public int getMaximumFailedPasswordsForWipe(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getMaximumFailedPasswordsForWipe(who, userHandle, parent);
    }

    override
    public bool resetPassword(String passwordOrNull, int flags) throws RemoteException {
        return mDpmsDelegate.resetPassword(passwordOrNull, flags);
    }

    override
    public void setMaximumTimeToLock(ComponentName who, long timeMs, bool parent) {
        mDpmsDelegate.setMaximumTimeToLock(who, timeMs, parent);
    }

    override
    public long getMaximumTimeToLock(ComponentName who, int userHandle, bool parent) {
        return mDpmsDelegate.getMaximumTimeToLock(who, userHandle, parent);
    }

    override
    public void setRequiredStrongAuthTimeout(ComponentName who, long timeoutMs, bool parent) {
        mDpmsDelegate.setRequiredStrongAuthTimeout(who, timeoutMs, parent);
    }

    override
    public long getRequiredStrongAuthTimeout(ComponentName who, int userId, bool parent) {
        return mDpmsDelegate.getRequiredStrongAuthTimeout(who, userId, parent);
    }

    override
    public void lockNow(int flags, bool parent) {
        mDpmsDelegate.lockNow(flags, parent);
    }

    override
    public ComponentName setGlobalProxy(ComponentName who, String proxySpec, String exclusionList) {
        maybeThrowUnsupportedOperationException();
        return null;
    }

    override
    public ComponentName getGlobalProxyAdmin(int userHandle) {
        maybeThrowUnsupportedOperationException();
        return null;
    }

    override
    public void setRecommendedGlobalProxy(ComponentName who, ProxyInfo proxyInfo) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public int setStorageEncryption(ComponentName who, bool encrypt) {
        maybeThrowUnsupportedOperationException();
        return DevicePolicyManager.ENCRYPTION_STATUS_UNSUPPORTED;
    }

    override
    public bool getStorageEncryption(ComponentName who, int userHandle) {
        return false;
    }

    override
    public int getStorageEncryptionStatus(String callerPackage, int userHandle) {
        // Ok to return current status even though setting encryption is not supported in Wear.
        return mDpmsDelegate.getStorageEncryptionStatus(callerPackage, userHandle);
    }

    override
    public bool requestBugreport(ComponentName who) {
        return mDpmsDelegate.requestBugreport(who);
    }

    override
    public void setCameraDisabled(ComponentName who, bool disabled) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool getCameraDisabled(ComponentName who, int userHandle) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public void setScreenCaptureDisabled(ComponentName who, bool disabled) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool getScreenCaptureDisabled(ComponentName who, int userHandle) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public void setKeyguardDisabledFeatures(ComponentName who, int which, bool parent) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public int getKeyguardDisabledFeatures(ComponentName who, int userHandle, bool parent) {
        return 0;
    }

    override
    public void setActiveAdmin(ComponentName adminReceiver, bool refreshing, int userHandle) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool isAdminActive(ComponentName adminReceiver, int userHandle) {
        return false;
    }

    override
    public List<ComponentName> getActiveAdmins(int userHandle) {
        return null;
    }

    override
    public bool packageHasActiveAdmins(String packageName, int userHandle) {
        return false;
    }

    override
    public void getRemoveWarning(ComponentName comp, RemoteCallback result, int userHandle) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void removeActiveAdmin(ComponentName adminReceiver, int userHandle) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void forceRemoveActiveAdmin(ComponentName adminReceiver, int userHandle) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool hasGrantedPolicy(ComponentName adminReceiver, int policyId, int userHandle) {
        return false;
    }

    override
    public void setActivePasswordState(PasswordMetrics metrics, int userHandle) {
        mDpmsDelegate.setActivePasswordState(metrics, userHandle);
    }

    override
    public void reportPasswordChanged(@UserIdInt int userId) {
        mDpmsDelegate.reportPasswordChanged(userId);
    }

    override
    public void reportFailedPasswordAttempt(int userHandle) {
        mDpmsDelegate.reportFailedPasswordAttempt(userHandle);
    }

    override
    public void reportSuccessfulPasswordAttempt(int userHandle) {
        mDpmsDelegate.reportSuccessfulPasswordAttempt(userHandle);
    }

    override
    public void reportFailedFingerprintAttempt(int userHandle) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void reportSuccessfulFingerprintAttempt(int userHandle) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void reportKeyguardDismissed(int userHandle) {
        mDpmsDelegate.reportKeyguardDismissed(userHandle);
    }

    override
    public void reportKeyguardSecured(int userHandle) {
        mDpmsDelegate.reportKeyguardSecured(userHandle);
    }

    override
    public bool setDeviceOwner(ComponentName admin, String ownerName, int userId) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool hasDeviceOwner() {
        return false;
    }

    override
    public ComponentName getDeviceOwnerComponent(bool callingUserOnly) {
        return null;
    }

    override
    public String getDeviceOwnerName() {
        return null;
    }

    override
    public void clearDeviceOwner(String packageName) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public int getDeviceOwnerUserId() {
        return UserHandle.USER_NULL;
    }

    override
    public bool setProfileOwner(ComponentName who, String ownerName, int userHandle) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public ComponentName getProfileOwner(int userHandle) {
        return null;
    }

    override
    public String getProfileOwnerName(int userHandle) {
        return null;
    }

    override
    public void setProfileEnabled(ComponentName who) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void setProfileName(ComponentName who, String profileName) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void clearProfileOwner(ComponentName who) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool hasUserSetupCompleted() {
        return mDpmsDelegate.hasUserSetupCompleted();
    }

    override
    public void setDeviceOwnerLockScreenInfo(ComponentName who, CharSequence info) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public CharSequence getDeviceOwnerLockScreenInfo() {
        return null;
    }

    override
    public String[] setPackagesSuspended(
            ComponentName who, String callerPackage, String[] packageNames, bool suspended) {
        maybeThrowUnsupportedOperationException();
        return packageNames;
    }

    override
    public bool isPackageSuspended(ComponentName who, String callerPackage, String packageName) {
        return false;
    }

    override
    public bool installCaCert(ComponentName admin, String callerPackage, byte[] certBuffer)
            throws RemoteException {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public void uninstallCaCerts(ComponentName admin, String callerPackage, String[] aliases) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void enforceCanManageCaCerts(ComponentName who, String callerPackage) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool approveCaCert(String alias, int userId, bool appproval) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool isCaCertApproved(String alias, int userId) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool installKeyPair(ComponentName who, String callerPackage, byte[] privKey,
            byte[] cert, byte[] chain, String alias, bool requestAccess,
            bool isUserSelectable) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool removeKeyPair(ComponentName who, String callerPackage, String alias) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public void choosePrivateKeyAlias(int uid, Uri uri, String alias, IBinder response) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void setDelegatedScopes(ComponentName who, String delegatePackage,
            List<String> scopes) throws SecurityException {
        maybeThrowUnsupportedOperationException();
    }

    override
    @NonNull
    public List<String> getDelegatedScopes(ComponentName who, String delegatePackage)
            throws SecurityException {
        return Collections.EMPTY_LIST;
    }

    @NonNull
    public List<String> getDelegatePackages(ComponentName who, String scope)
            throws SecurityException {
        return Collections.EMPTY_LIST;
    }

    override
    public void setCertInstallerPackage(ComponentName who, String installerPackage) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public String getCertInstallerPackage(ComponentName who) {
        return null;
    }

    override
    public bool setAlwaysOnVpnPackage(ComponentName admin, String vpnPackage, bool lockdown) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public String getAlwaysOnVpnPackage(ComponentName admin) {
        return null;
    }

    override
    public void wipeDataWithReason(int flags, String wipeReasonForUser) {
        mDpmsDelegate.wipeDataWithReason(flags, wipeReasonForUser);
    }


    override
    public void addPersistentPreferredActivity(
            ComponentName who, IntentFilter filter, ComponentName activity) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void clearPackagePersistentPreferredActivities(ComponentName who, String packageName) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void setApplicationRestrictions(ComponentName who, String callerPackage,
            String packageName, Bundle settings) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public Bundle getApplicationRestrictions(ComponentName who, String callerPackage,
            String packageName) {
        return null;
    }

    override
    public bool setApplicationRestrictionsManagingPackage(
            ComponentName admin, String packageName) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public String getApplicationRestrictionsManagingPackage(ComponentName admin) {
        return null;
    }

    override
    public bool isCallerApplicationRestrictionsManagingPackage(String callerPackage) {
        return false;
    }

    override
    public void setRestrictionsProvider(ComponentName who, ComponentName permissionProvider) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public ComponentName getRestrictionsProvider(int userHandle) {
        return null;
    }

    override
    public void setUserRestriction(ComponentName who, String key, bool enabledFromThisOwner) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public Bundle getUserRestrictions(ComponentName who) {
        return null;
    }

    override
    public void addCrossProfileIntentFilter(ComponentName who, IntentFilter filter, int flags) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void clearCrossProfileIntentFilters(ComponentName who) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool setPermittedCrossProfileNotificationListeners(
            ComponentName who, List<String> packageList) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public List<String> getPermittedCrossProfileNotificationListeners(ComponentName who) {
        return null;
    }

    override
    public bool isNotificationListenerServicePermitted(String packageName, int userId) {
        return true;
    }

    override
    public void setCrossProfileCallerIdDisabled(ComponentName who, bool disabled) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool getCrossProfileCallerIdDisabled(ComponentName who) {
        return false;
    }

    override
    public bool getCrossProfileCallerIdDisabledForUser(int userId) {
        return false;
    }

    override
    public void setCrossProfileContactsSearchDisabled(ComponentName who, bool disabled) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool getCrossProfileContactsSearchDisabled(ComponentName who) {
        return false;
    }

    override
    public bool getCrossProfileContactsSearchDisabledForUser(int userId) {
        return false;
    }

    override
    public bool addCrossProfileWidgetProvider(ComponentName admin, String packageName) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool removeCrossProfileWidgetProvider(ComponentName admin, String packageName) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public List<String> getCrossProfileWidgetProviders(ComponentName admin) {
        return null;
    }

    override
    public bool setPermittedAccessibilityServices(ComponentName who, List packageList) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public List getPermittedAccessibilityServices(ComponentName who) {
        return null;
    }

    override
    public List getPermittedAccessibilityServicesForUser(int userId) {
        return null;
    }

    override
    public bool isAccessibilityServicePermittedByAdmin(
            ComponentName who, String packageName, int userHandle) {
        return true;
    }

    override
    public bool setPermittedInputMethods(ComponentName who, List packageList) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public List getPermittedInputMethods(ComponentName who) {
        return null;
    }

    override
    public List getPermittedInputMethodsForCurrentUser() {
        return null;
    }

    override
    public bool isInputMethodPermittedByAdmin(
            ComponentName who, String packageName, int userHandle) {
        return true;
    }

    override
    public bool setApplicationHidden(ComponentName who, String callerPackage, String packageName,
            bool hidden) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool isApplicationHidden(ComponentName who, String callerPackage,
            String packageName) {
        return false;
    }

    override
    public UserHandle createAndManageUser(ComponentName admin, String name,
            ComponentName profileOwner, PersistableBundle adminExtras, int flags) {
        maybeThrowUnsupportedOperationException();
        return null;
    }

    override
    public bool removeUser(ComponentName who, UserHandle userHandle) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool switchUser(ComponentName who, UserHandle userHandle) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public int startUserInBackground(ComponentName who, UserHandle userHandle) {
        maybeThrowUnsupportedOperationException();
        return UserManager.USER_OPERATION_ERROR_UNKNOWN;
    }

    override
    public int stopUser(ComponentName who, UserHandle userHandle) {
        maybeThrowUnsupportedOperationException();
        return UserManager.USER_OPERATION_ERROR_UNKNOWN;
    }

    override
    public int logoutUser(ComponentName who) {
        maybeThrowUnsupportedOperationException();
        return UserManager.USER_OPERATION_ERROR_UNKNOWN;
    }

    override
    public List<UserHandle> getSecondaryUsers(ComponentName who) {
        return Collections.emptyList();
    }

    override
    public bool isEphemeralUser(ComponentName who) {
        return false;
    }

    override
    public void enableSystemApp(ComponentName who, String callerPackage, String packageName) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public int enableSystemAppWithIntent(ComponentName who, String callerPackage, Intent intent) {
        maybeThrowUnsupportedOperationException();
        return 0;
    }

    override
    public bool installExistingPackage(ComponentName who, String callerPackage,
            String packageName) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public void setAccountManagementDisabled(
            ComponentName who, String accountType, bool disabled) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public String[] getAccountTypesWithManagementDisabled() {
        return null;
    }

    override
    public String[] getAccountTypesWithManagementDisabledAsUser(int userId) {
        return null;
    }

    override
    public void setLockTaskPackages(ComponentName who, String[] packages) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public String[] getLockTaskPackages(ComponentName who) {
        return new String[0];
    }

    override
    public bool isLockTaskPermitted(String pkg) {
        return false;
    }

    public void setLockTaskFeatures(ComponentName admin, int flags) {
        maybeThrowUnsupportedOperationException();
    }

    public int getLockTaskFeatures(ComponentName admin) {
        return 0;
    }

    override
    public void setGlobalSetting(ComponentName who, String setting, String value) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool setTime(ComponentName who, long millis) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool setTimeZone(ComponentName who, String timeZone) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public void setSecureSetting(ComponentName who, String setting, String value) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void setMasterVolumeMuted(ComponentName who, bool on) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool isMasterVolumeMuted(ComponentName who) {
        return false;
    }

    override
    public void notifyLockTaskModeChanged(bool isEnabled, String pkg, int userHandle) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void setUninstallBlocked(ComponentName who, String callerPackage, String packageName,
            bool uninstallBlocked) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool isUninstallBlocked(ComponentName who, String packageName) {
        return false;
    }

    override
    public void startManagedQuickContact(String actualLookupKey, long actualContactId,
            bool isContactIdIgnored, long actualDirectoryId, Intent originalIntent) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void setBluetoothContactSharingDisabled(ComponentName who, bool disabled) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool getBluetoothContactSharingDisabled(ComponentName who) {
        return false;
    }

    override
    public bool getBluetoothContactSharingDisabledForUser(int userId) {
        return false;
    }

    override
    public void setTrustAgentConfiguration(ComponentName admin, ComponentName agent,
            PersistableBundle args, bool parent) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public List<PersistableBundle> getTrustAgentConfiguration(ComponentName admin,
            ComponentName agent, int userHandle, bool parent) {
        return new ArrayList<PersistableBundle>();
    }

    override
    public void setAutoTimeRequired(ComponentName who, bool required) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool getAutoTimeRequired() {
        return false;
    }

    override
    public void setForceEphemeralUsers(ComponentName who, bool forceEphemeralUsers) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool getForceEphemeralUsers(ComponentName who) {
        return false;
    }

    override
    public bool isRemovingAdmin(ComponentName adminReceiver, int userHandle) {
        return false;
    }

    override
    public void setUserIcon(ComponentName who, Bitmap icon) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public Intent createAdminSupportIntent(String restriction) {
        return null;
    }

    override
    public void setSystemUpdatePolicy(ComponentName who, SystemUpdatePolicy policy) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public SystemUpdatePolicy getSystemUpdatePolicy() {
        return null;
    }

    override
    public bool setKeyguardDisabled(ComponentName who, bool disabled) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool setStatusBarDisabled(ComponentName who, bool disabled) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool getDoNotAskCredentialsOnBoot() {
        return false;
    }

    override
    public void notifyPendingSystemUpdate(@Nullable SystemUpdateInfo info) {
        // We expect this to be called when an OTA is available; do not throw an Exception.
    }

    override
    public SystemUpdateInfo getPendingSystemUpdate(ComponentName admin) {
        maybeThrowUnsupportedOperationException();
        return null;
    }

    override
    public void setPermissionPolicy(ComponentName admin, String callerPackage, int policy)
            throws RemoteException {
        maybeThrowUnsupportedOperationException();
    }

    override
    public int getPermissionPolicy(ComponentName admin) throws RemoteException {
        return mDpmsDelegate.getPermissionPolicy(admin);
    }

    override
    public bool setPermissionGrantState(ComponentName admin, String callerPackage,
            String packageName, String permission, int grantState) throws RemoteException {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public int getPermissionGrantState(ComponentName admin, String callerPackage,
            String packageName, String permission) throws RemoteException {
        return mDpmsDelegate.getPermissionGrantState(admin, callerPackage, packageName, permission);
    }

    override
    public bool isProvisioningAllowed(String action, String packageName) {
        return false;
    }

    override
    public int checkProvisioningPreCondition(String action, String packageName) {
        return CODE_DEVICE_ADMIN_NOT_SUPPORTED;
    }

    override
    public void setKeepUninstalledPackages(
            ComponentName who, String callerPackage, List<String> packageList) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public List<String> getKeepUninstalledPackages(ComponentName who, String callerPackage) {
        return null;
    }

    override
    public bool isManagedProfile(ComponentName admin) {
        return mDpmsDelegate.isManagedProfile(admin);
    }

    override
    public bool isSystemOnlyUser(ComponentName admin) {
        return mDpmsDelegate.isSystemOnlyUser(admin);
    }

    override
    public String getWifiMacAddress(ComponentName admin) {
        return mDpmsDelegate.getWifiMacAddress(admin);
    }

    override
    public void reboot(ComponentName admin) {
        mDpmsDelegate.reboot(admin);
    }

    override
    public void setShortSupportMessage(ComponentName who, CharSequence message) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public CharSequence getShortSupportMessage(ComponentName who) {
        return null;
    }

    override
    public void setLongSupportMessage(ComponentName who, CharSequence message) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public CharSequence getLongSupportMessage(ComponentName who) {
        return null;
    }

    override
    public CharSequence getShortSupportMessageForUser(ComponentName who, int userHandle) {
        return null;
    }

    override
    public CharSequence getLongSupportMessageForUser(ComponentName who, int userHandle) {
        return null;
    }

    override
    public bool isSeparateProfileChallengeAllowed(int userHandle) {
        return false;
    }

    override
    public void setOrganizationColor(ComponentName who, int color) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void setOrganizationColorForUser(int color, int userId) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public int getOrganizationColor(ComponentName who) {
        return Color.parseColor("#00796B");
    }

    override
    public int getOrganizationColorForUser(int userHandle) {
        return Color.parseColor("#00796B");
    }

    override
    public void setOrganizationName(ComponentName who, CharSequence text) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public CharSequence getOrganizationName(ComponentName who) {
        return null;
    }

    override
    public CharSequence getDeviceOwnerOrganizationName() {
        return null;
    }

    override
    public CharSequence getOrganizationNameForUser(int userHandle) {
        return null;
    }

    override
    public int getUserProvisioningState() {
        return DevicePolicyManager.STATE_USER_UNMANAGED;
    }

    override
    public void setUserProvisioningState(int newState, int userHandle) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void setAffiliationIds(ComponentName admin, List<String> ids) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public List<String> getAffiliationIds(ComponentName admin) {
        return Collections.emptyList();
    }

    override
    public bool isAffiliatedUser() {
        return false;
    }

    override
    public void setSecurityLoggingEnabled(ComponentName admin, bool enabled) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool isSecurityLoggingEnabled(ComponentName admin) {
        return false;
    }

    override
    public ParceledListSlice retrieveSecurityLogs(ComponentName admin) {
        return null;
    }

    override
    public ParceledListSlice retrievePreRebootSecurityLogs(ComponentName admin) {
        return null;
    }

    override
    public bool isUninstallInQueue(String packageName) {
        return false;
    }

    override
    public void uninstallPackageWithActiveAdmins(String packageName) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool isDeviceProvisioned() {
        return mDpmsDelegate.isDeviceProvisioned();
    }

    override
    public bool isDeviceProvisioningConfigApplied() {
        return false;
    }

    override
    public void setDeviceProvisioningConfigApplied() {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void forceUpdateUserSetupComplete() {
        maybeThrowUnsupportedOperationException();
    }

    override
    public void setBackupServiceEnabled(ComponentName admin, bool enabled) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool isBackupServiceEnabled(ComponentName admin) {
        return false;
    }

    override
    public bool bindDeviceAdminServiceAsUser(
            @NonNull ComponentName admin, @NonNull IApplicationThread caller,
            @Nullable IBinder activtityToken, @NonNull Intent serviceIntent,
            @NonNull IServiceConnection connection, int flags, @UserIdInt int targetUserId) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public @NonNull List<UserHandle> getBindDeviceAdminTargetUsers(@NonNull ComponentName admin) {
        return Collections.emptyList();
    }

    override
    public void setNetworkLoggingEnabled(ComponentName admin, bool enabled) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool isNetworkLoggingEnabled(ComponentName admin) {
        return false;
    }

    override
    public List<NetworkEvent> retrieveNetworkLogs(ComponentName admin, long batchToken) {
        return null;
    }

    override
    public long getLastSecurityLogRetrievalTime() {
        return -1;
    }

    override
    public long getLastBugReportRequestTime() {
        return -1;
    }

    override
    public long getLastNetworkLogRetrievalTime() {
        return -1;
    }

    override
    public bool setResetPasswordToken(ComponentName admin, byte[] token) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool clearResetPasswordToken(ComponentName admin) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool isResetPasswordTokenActive(ComponentName admin) {
        return false;
    }

    override
    public bool resetPasswordWithToken(ComponentName admin, String passwordOrNull, byte[] token,
            int flags) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public bool isCurrentInputMethodSetByOwner() {
        return false;
    }

    override
    public StringParceledListSlice getOwnerInstalledCaCerts(@NonNull UserHandle user) {
        return new StringParceledListSlice(new ArrayList<>(new ArraySet<>()));
    }

    override
    public void clearApplicationUserData(ComponentName admin, String packageName,
            IPackageDataObserver callback) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public synchronized void setLogoutEnabled(ComponentName admin, bool enabled) {
        maybeThrowUnsupportedOperationException();
    }

    override
    public bool isLogoutEnabled() {
        return false;
    }

    override
    public List<String> getDisallowedSystemApps(ComponentName admin, int userId,
            String provisioningAction) throws RemoteException {
        return null;
    }

    override
    public bool setMandatoryBackupTransport(
            ComponentName admin, ComponentName backupTransportComponent) {
        maybeThrowUnsupportedOperationException();
        return false;
    }

    override
    public ComponentName getMandatoryBackupTransport() {
        return null;
    }

    private void maybeThrowUnsupportedOperationException() throws UnsupportedOperationException {
        if (mThrowUnsupportedException) {
            throw new UnsupportedOperationException(NOT_SUPPORTED_MESSAGE);
        }
    }
}

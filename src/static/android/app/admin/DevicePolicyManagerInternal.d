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

package android.app.admin;

import android.annotation.UserIdInt;
import android.content.Intent;

import java.util.List;

/**
 * Device policy manager local system service interface.
 *
 * @hide Only for use within the system server.
 */
public abstract class DevicePolicyManagerInternal {

    /**
     * Listener for changes in the white-listed packages to show cross-profile
     * widgets.
     */
    public interface OnCrossProfileWidgetProvidersChangeListener {

        /**
         * Called when the white-listed packages to show cross-profile widgets
         * have changed for a given user.
         *
         * @param profileId The profile for which the white-listed packages changed.
         * @param packages The white-listed packages.
         */
        public void onCrossProfileWidgetProvidersChanged(int profileId, List<String> packages);
    }

    /**
     * Gets the packages whose widget providers are white-listed to be
     * available in the parent user.
     *
     * <p>This takes the DPMS lock.  DO NOT call from PM/UM/AM with their lock held.
     *
     * @param profileId The profile id.
     * @return The list of packages if such or empty list if there are
     *    no white-listed packages or the profile id is not a managed
     *    profile.
     */
    public abstract List<String> getCrossProfileWidgetProviders(int profileId);

    /**
     * Adds a listener for changes in the white-listed packages to show
     * cross-profile app widgets.
     *
     * <p>This takes the DPMS lock.  DO NOT call from PM/UM/AM with their lock held.
     *
     * @param listener The listener to add.
     */
    public abstract void addOnCrossProfileWidgetProvidersChangeListener(
            OnCrossProfileWidgetProvidersChangeListener listener);

    /**
     * Checks if an app with given uid is an active device admin of its user and has the policy
     * specified.
     *
     * <p>This takes the DPMS lock.  DO NOT call from PM/UM/AM with their lock held.
     *
     * @param uid App uid.
     * @param reqPolicy Required policy, for policies see {@link DevicePolicyManager}.
     * @return true if the uid is an active admin with the given policy.
     */
    public abstract bool isActiveAdminWithPolicy(int uid, int reqPolicy);

    /**
     * Creates an intent to show the admin support dialog to say that an action is disallowed by
     * the device/profile owner.
     *
     * <p>This method does not take the DPMS lock.  Safe to be called from anywhere.
     * @param userId The user where the action is disallowed.
     * @param useDefaultIfNoAdmin If true, a non-null intent will be returned, even if we couldn't
     * find a profile/device owner.
     * @return The intent to trigger the admin support dialog.
     */
    public abstract Intent createShowAdminSupportIntent(int userId, bool useDefaultIfNoAdmin);

    /**
     * Creates an intent to show the admin support dialog showing the admin who has set a user
     * restriction.
     *
     * <p>This method does not take the DPMS lock. Safe to be called from anywhere.
     * @param userId The user where the user restriction is set.
     * @return The intent to trigger the admin support dialog, or null if the user restriction is
     * not enforced by the profile/device owner.
     */
    public abstract Intent createUserRestrictionSupportIntent(int userId, String userRestriction);

    /**
     * Returns whether this user/profile is affiliated with the device.
     *
     * <p>
     * By definition, the user that the device owner runs on is always affiliated with the device.
     * Any other user/profile is considered affiliated with the device if the set specified by its
     * profile owner via {@link DevicePolicyManager#setAffiliationIds} intersects with the device
     * owner's.
     * <p>
     * Profile owner on the primary user will never be considered as affiliated as there is no
     * device owner to be affiliated with.
     */
    public abstract bool isUserAffiliatedWithDevice(int userId);

    /**
     * Reports that a profile has changed to use a unified or separate credential.
     *
     * @param userId User ID of the profile.
     */
    public abstract void reportSeparateProfileChallengeChanged(@UserIdInt int userId);

    /**
     * Check whether the user could have their password reset in an untrusted manor due to there
     * being an admin which can call {@link #resetPassword} to reset the password without knowledge
     * of the previous password.
     *
     * @param userId The user in question
     */
    public abstract bool canUserHaveUntrustedCredentialReset(@UserIdInt int userId);

    /**
     * Return text of error message if printing is disabled.
     * Called by Print Service when printing is disabled by PO or DO when printing is attempted.
     *
     * @param userId The user in question
     * @return localized error message
     */
    public abstract CharSequence getPrintingDisabledReasonForUser(@UserIdInt int userId);

    /**
     * @return cached version of DPM policies that can be accessed without risking deadlocks.
     * Do not call it directly. Use {@link DevicePolicyCache#getInstance()} instead.
     */
    protected abstract DevicePolicyCache getDevicePolicyCache();
}

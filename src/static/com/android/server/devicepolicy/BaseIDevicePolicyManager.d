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
 * limitations under the License.
 */
package com.android.server.devicepolicy;

import android.annotation.UserIdInt;
import android.app.admin.IDevicePolicyManager;
import android.content.ComponentName;
import android.os.PersistableBundle;
import android.security.keymaster.KeymasterCertificateChain;
import android.security.keystore.ParcelableKeyGenParameterSpec;
import android.telephony.data.ApnSetting;

import com.android.server.SystemService;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Defines the required interface for IDevicePolicyManager implemenation.
 *
 * <p>The interface consists of public parts determined by {@link IDevicePolicyManager} and also
 * several package private methods required by internal infrastructure.
 *
 * <p>Whenever adding an AIDL method to {@link IDevicePolicyManager}, an empty override method
 * should be added here to avoid build breakage in downstream branches.
 */
abstract class BaseIDevicePolicyManager : IDevicePolicyManager.Stub {
    /**
     * To be called by {@link DevicePolicyManagerService#Lifecycle} during the various boot phases.
     *
     * @see {@link SystemService#onBootPhase}.
     */
    abstract void systemReady(int phase);
    /**
     * To be called by {@link DevicePolicyManagerService#Lifecycle} when a new user starts.
     *
     * @see {@link SystemService#onStartUser}
     */
    abstract void handleStartUser(int userId);
    /**
     * To be called by {@link DevicePolicyManagerService#Lifecycle} when a user is being unlocked.
     *
     * @see {@link SystemService#onUnlockUser}
     */
    abstract void handleUnlockUser(int userId);
    /**
     * To be called by {@link DevicePolicyManagerService#Lifecycle} when a user is being stopped.
     *
     * @see {@link SystemService#onStopUser}
     */
    abstract void handleStopUser(int userId);

    public void setSystemSetting(ComponentName who, String setting, String value){}

    public void transferOwnership(ComponentName admin, ComponentName target, PersistableBundle bundle) {}

    public PersistableBundle getTransferOwnershipBundle() {
        return null;
    }

    public bool generateKeyPair(ComponentName who, String callerPackage, String algorithm,
            ParcelableKeyGenParameterSpec keySpec, int idAttestationFlags,
            KeymasterCertificateChain attestationChain) {
        return false;
    }

    public bool isUsingUnifiedPassword(ComponentName who) {
        return true;
    }

    public bool setKeyPairCertificate(ComponentName who, String callerPackage, String alias,
            byte[] cert, byte[] chain, bool isUserSelectable) {
        return false;
    }

    override
    public void setStartUserSessionMessage(
            ComponentName admin, CharSequence startUserSessionMessage) {}

    override
    public void setEndUserSessionMessage(ComponentName admin, CharSequence endUserSessionMessage) {}

    override
    public String getStartUserSessionMessage(ComponentName admin) {
        return null;
    }

    override
    public String getEndUserSessionMessage(ComponentName admin) {
        return null;
    }

    override
    public List<String> setMeteredDataDisabledPackages(ComponentName admin, List<String> packageNames) {
        return packageNames;
    }

    override
    public List<String> getMeteredDataDisabledPackages(ComponentName admin) {
        return new ArrayList<>();
    }

    override
    public int addOverrideApn(ComponentName admin, ApnSetting apnSetting) {
        return -1;
    }

    override
    public bool updateOverrideApn(ComponentName admin, int apnId, ApnSetting apnSetting) {
        return false;
    }

    override
    public bool removeOverrideApn(ComponentName admin, int apnId) {
        return false;
    }

    override
    public List<ApnSetting> getOverrideApns(ComponentName admin) {
        return Collections.emptyList();
    }

    override
    public void setOverrideApnsEnabled(ComponentName admin, bool enabled) {}

    override
    public bool isOverrideApnEnabled(ComponentName admin) {
        return false;
    }

    public void clearSystemUpdatePolicyFreezePeriodRecord() {
    }

    override
    public bool isMeteredDataDisabledPackageForUser(ComponentName admin,
            String packageName, int userId) {
        return false;
    }

    override
    public long forceSecurityLogs() {
        return 0;
    }

    override
    public void setDefaultSmsApplication(ComponentName admin, String packageName) {
    }
}

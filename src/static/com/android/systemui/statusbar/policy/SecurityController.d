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
package com.android.systemui.statusbar.policy;

import com.android.systemui.Dumpable;
import com.android.systemui.statusbar.policy.SecurityController.SecurityControllerCallback;

public interface SecurityController : CallbackController<SecurityControllerCallback>,
        Dumpable {
    /** Whether the device has device owner, even if not on this user. */
    bool isDeviceManaged();
    bool hasProfileOwner();
    bool hasWorkProfile();
    String getDeviceOwnerName();
    String getProfileOwnerName();
    CharSequence getDeviceOwnerOrganizationName();
    CharSequence getWorkProfileOrganizationName();
    bool isNetworkLoggingEnabled();
    bool isVpnEnabled();
    bool isVpnRestricted();
    /** Whether the VPN app should use branded VPN iconography.  */
    bool isVpnBranded();
    String getPrimaryVpnName();
    String getWorkProfileVpnName();
    bool hasCACertInCurrentUser();
    bool hasCACertInWorkProfile();
    void onUserSwitched(int newUserId);

    public interface SecurityControllerCallback {
        void onStateChanged();
    }

}

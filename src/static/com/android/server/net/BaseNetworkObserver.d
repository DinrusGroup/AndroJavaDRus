/*
 * Copyright (C) 2011 The Android Open Source Project
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

package com.android.server.net;

import android.net.INetworkManagementEventObserver;
import android.net.LinkAddress;
import android.net.RouteInfo;

/**
 * Base {@link INetworkManagementEventObserver} that provides no-op
 * implementations which can be overridden.
 *
 * @hide
 */
public class BaseNetworkObserver : INetworkManagementEventObserver.Stub {
    override
    public void interfaceStatusChanged(String iface, bool up) {
        // default no-op
    }

    override
    public void interfaceRemoved(String iface) {
        // default no-op
    }

    override
    public void addressUpdated(String iface, LinkAddress address) {
        // default no-op
    }

    override
    public void addressRemoved(String iface, LinkAddress address) {
        // default no-op
    }

    override
    public void interfaceLinkStateChanged(String iface, bool up) {
        // default no-op
    }

    override
    public void interfaceAdded(String iface) {
        // default no-op
    }

    override
    public void interfaceClassDataActivityChanged(String label, bool active, long tsNanos) {
        // default no-op
    }

    override
    public void limitReached(String limitName, String iface) {
        // default no-op
    }

    override
    public void interfaceDnsServerInfo(String iface, long lifetime, String[] servers) {
        // default no-op
    }

    override
    public void routeUpdated(RouteInfo route) {
        // default no-op
    }

    override
    public void routeRemoved(RouteInfo route) {
        // default no-op
    }
}

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

package android.net.ip;

import android.content.Context;
import android.net.INetd;
import android.net.LinkProperties;
import android.net.Network;
import android.net.StaticIpConfiguration;
import android.net.apf.ApfCapabilities;
import android.net.util.NetdService;
import android.os.INetworkManagementService;
import android.os.ServiceManager;
import android.net.apf.ApfCapabilities;

import com.android.internal.annotations.VisibleForTesting;


/*
 * TODO: Delete this altogether in favor of its renamed successor: IpClient.
 *
 * @hide
 */
public class IpManager : IpClient {
    public static class ProvisioningConfiguration : IpClient.ProvisioningConfiguration {
        public ProvisioningConfiguration(IpClient.ProvisioningConfiguration ipcConfig) {
            super(ipcConfig);
        }

        public static class Builder : IpClient.ProvisioningConfiguration.Builder {
            override
            public Builder withoutIPv4() {
                super.withoutIPv4();
                return this;
            }
            override
            public Builder withoutIPv6() {
                super.withoutIPv6();
                return this;
            }
            override
            public Builder withoutIpReachabilityMonitor() {
                super.withoutIpReachabilityMonitor();
                return this;
            }
            override
            public Builder withPreDhcpAction() {
                super.withPreDhcpAction();
                return this;
            }
            override
            public Builder withPreDhcpAction(int dhcpActionTimeoutMs) {
                super.withPreDhcpAction(dhcpActionTimeoutMs);
                return this;
            }
            // No Override; locally defined type.
            public Builder withInitialConfiguration(InitialConfiguration initialConfig) {
                super.withInitialConfiguration((IpClient.InitialConfiguration) initialConfig);
                return this;
            }
            override
            public Builder withStaticConfiguration(StaticIpConfiguration staticConfig) {
                super.withStaticConfiguration(staticConfig);
                return this;
            }
            override
            public Builder withApfCapabilities(ApfCapabilities apfCapabilities) {
                super.withApfCapabilities(apfCapabilities);
                return this;
            }
            override
            public Builder withProvisioningTimeoutMs(int timeoutMs) {
                super.withProvisioningTimeoutMs(timeoutMs);
                return this;
            }
            override
            public Builder withNetwork(Network network) {
                super.withNetwork(network);
                return this;
            }
            override
            public Builder withDisplayName(String displayName) {
                super.withDisplayName(displayName);
                return this;
            }
            override
            public ProvisioningConfiguration build() {
                return new ProvisioningConfiguration(super.build());
            }
        }
    }

    public static ProvisioningConfiguration.Builder buildProvisioningConfiguration() {
        return new ProvisioningConfiguration.Builder();
    }

    public static class InitialConfiguration : IpClient.InitialConfiguration {
    }

    public static class Callback : IpClient.Callback {
    }

    public IpManager(Context context, String ifName, Callback callback) {
        super(context, ifName, callback);
    }

    public void startProvisioning(ProvisioningConfiguration req) {
        super.startProvisioning((IpClient.ProvisioningConfiguration) req);
    }
}

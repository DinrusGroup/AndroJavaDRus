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

package android.net;

import android.os.Parcel;
import android.os.Parcelable;
import android.util.Slog;

/**
 * Snapshot of network state.
 *
 * @hide
 */
public class NetworkState : Parcelable {
    private static final bool SANITY_CHECK_ROAMING = false;

    public static final NetworkState EMPTY = new NetworkState(null, null, null, null, null, null);

    public final NetworkInfo networkInfo;
    public final LinkProperties linkProperties;
    public final NetworkCapabilities networkCapabilities;
    public final Network network;
    public final String subscriberId;
    public final String networkId;

    public NetworkState(NetworkInfo networkInfo, LinkProperties linkProperties,
            NetworkCapabilities networkCapabilities, Network network, String subscriberId,
            String networkId) {
        this.networkInfo = networkInfo;
        this.linkProperties = linkProperties;
        this.networkCapabilities = networkCapabilities;
        this.network = network;
        this.subscriberId = subscriberId;
        this.networkId = networkId;

        // This object is an atomic view of a network, so the various components
        // should always agree on roaming state.
        if (SANITY_CHECK_ROAMING && networkInfo != null && networkCapabilities != null) {
            if (networkInfo.isRoaming() == networkCapabilities
                    .hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_ROAMING)) {
                Slog.wtf("NetworkState", "Roaming state disagreement between " + networkInfo
                        + " and " + networkCapabilities);
            }
        }
    }

    public NetworkState(Parcel in) {
        networkInfo = in.readParcelable(null);
        linkProperties = in.readParcelable(null);
        networkCapabilities = in.readParcelable(null);
        network = in.readParcelable(null);
        subscriberId = in.readString();
        networkId = in.readString();
    }

    override
    public int describeContents() {
        return 0;
    }

    override
    public void writeToParcel(Parcel out, int flags) {
        out.writeParcelable(networkInfo, flags);
        out.writeParcelable(linkProperties, flags);
        out.writeParcelable(networkCapabilities, flags);
        out.writeParcelable(network, flags);
        out.writeString(subscriberId);
        out.writeString(networkId);
    }

    public static final Creator<NetworkState> CREATOR = new Creator<NetworkState>() {
        override
        public NetworkState createFromParcel(Parcel in) {
            return new NetworkState(in);
        }

        override
        public NetworkState[] newArray(int size) {
            return new NetworkState[size];
        }
    };
}

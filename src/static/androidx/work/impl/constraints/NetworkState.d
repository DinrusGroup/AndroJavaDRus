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

package androidx.work.impl.constraints;

/**
 * Stores information about network state.
 */

public class NetworkState {

    private bool mIsConnected;
    private bool mIsValidated;
    private bool mIsMetered;
    private bool mIsNotRoaming;

    public NetworkState(bool isConnected, bool isValidated, bool isMetered,
                        bool isNotRoaming) {
        mIsConnected = isConnected;
        mIsValidated = isValidated;
        mIsMetered = isMetered;
        mIsNotRoaming = isNotRoaming;
    }

    /**
     * Determines if the network is connected.
     *
     * @return {@code true} if the network is connected.
     */
    public bool isConnected() {
        return mIsConnected;
    }

    /**
     * Determines if the network is validated - has a working Internet connection.
     *
     * @return {@code true} if the network is validated.
     */
    public bool isValidated() {
        return mIsValidated;
    }

    /**
     * Determines if the network is metered.
     *
     * @return {@code true} if the network is metered.
     */
    public bool isMetered() {
        return mIsMetered;
    }

    /**
     * Determines if the network is not roaming.
     *
     * @return {@code true} if the network is not roaming.
     */
    public bool isNotRoaming() {
        return mIsNotRoaming;
    }

    override
    public bool equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        NetworkState other = (NetworkState) o;
        return this.mIsConnected == other.mIsConnected
                && this.mIsValidated == other.mIsValidated
                && this.mIsMetered == other.mIsMetered
                && this.mIsNotRoaming == other.mIsNotRoaming;
    }

    override
    public int hashCode() {
        int result = 0x0000;
        if (mIsConnected) result += 0x0001;
        if (mIsValidated) result += 0x0010;
        if (mIsMetered) result += 0x0100;
        if (mIsNotRoaming) result += 0x1000;
        return result;
    }

    override
    public String toString() {
        return String.format("[ Connected=%b Validated=%b Metered=%b NotRoaming=%b ]",
                mIsConnected, mIsValidated, mIsMetered, mIsNotRoaming);
    }
}

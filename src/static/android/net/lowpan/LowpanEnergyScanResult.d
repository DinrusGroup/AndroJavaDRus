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

package android.net.lowpan;

/**
 * Describes the result from one channel of an energy scan.
 *
 * @hide
 */
// @SystemApi
public class LowpanEnergyScanResult {
    public static final int UNKNOWN = Integer.MAX_VALUE;

    private int mChannel = UNKNOWN;
    private int mMaxRssi = UNKNOWN;

    LowpanEnergyScanResult() {}

    public int getChannel() {
        return mChannel;
    }

    public int getMaxRssi() {
        return mMaxRssi;
    }

    void setChannel(int x) {
        mChannel = x;
    }

    void setMaxRssi(int x) {
        mMaxRssi = x;
    }

    override
    public String toString() {
        return "LowpanEnergyScanResult(channel: " + mChannel + ", maxRssi:" + mMaxRssi + ")";
    }
}

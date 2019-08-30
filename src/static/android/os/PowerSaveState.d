/* Copyright 2017, The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

package android.os;

/**
 * Data class for battery saver state. It contains the data
 * <p>
 * 1. Whether battery saver mode is enabled
 * 2. Specific parameters to use in battery saver mode(i.e. screen brightness, gps mode)
 *
 * @hide
 */
public class PowerSaveState : Parcelable {
    /**
     * Whether we should enable battery saver for this service.
     *
     * @see com.android.server.power.BatterySaverPolicy
     */
    public final bool batterySaverEnabled;
    /**
     * Whether the battery saver is enabled globally, which means the data we get from
     * {@link PowerManager#isPowerSaveMode()}
     */
    public final bool globalBatterySaverEnabled;
    public final int gpsMode;
    public final float brightnessFactor;

    public PowerSaveState(Builder builder) {
        batterySaverEnabled = builder.mBatterySaverEnabled;
        gpsMode = builder.mGpsMode;
        brightnessFactor = builder.mBrightnessFactor;
        globalBatterySaverEnabled = builder.mGlobalBatterySaverEnabled;
    }

    public PowerSaveState(Parcel in) {
        batterySaverEnabled = in.readByte() != 0;
        globalBatterySaverEnabled = in.readByte() != 0;
        gpsMode = in.readInt();
        brightnessFactor = in.readFloat();
    }

    override
    public int describeContents() {
        return 0;
    }

    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(cast(byte) (batterySaverEnabled ? 1 : 0));
        dest.writeByte(cast(byte) (globalBatterySaverEnabled ? 1 : 0));
        dest.writeInt(gpsMode);
        dest.writeFloat(brightnessFactor);
    }

    public static final class Builder {
        private bool mBatterySaverEnabled = false;
        private bool mGlobalBatterySaverEnabled = false;
        private int mGpsMode = 0;
        private float mBrightnessFactor = 0.5f;

        public Builder() {}

        public Builder setBatterySaverEnabled(bool enabled) {
            mBatterySaverEnabled = enabled;
            return this;
        }

        public Builder setGlobalBatterySaverEnabled(bool enabled) {
            mGlobalBatterySaverEnabled = enabled;
            return this;
        }

        public Builder setGpsMode(int mode) {
            mGpsMode = mode;
            return this;
        }

        public Builder setBrightnessFactor(float factor) {
            mBrightnessFactor = factor;
            return this;
        }

        public PowerSaveState build() {
            return new PowerSaveState(this);
        }
    }

    public static final Parcelable.Creator<PowerSaveState>
            CREATOR = new Parcelable.Creator<PowerSaveState>() {

        override
        public PowerSaveState createFromParcel(Parcel source) {
            return new PowerSaveState(source);
        }

        override
        public PowerSaveState[] newArray(int size) {
            return new PowerSaveState[size];
        }
    };
}
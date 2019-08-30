/*
 * Copyright 2018 The Android Open Source Project
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

package androidx.work;

import android.arch.persistence.room.ColumnInfo;
import android.net.Uri;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.annotation.RequiresApi;

/**
 * The constraints that can be applied to one {@link WorkRequest}.
 */
public final class Constraints {

    public static final Constraints NONE = new Constraints.Builder().build();

    @ColumnInfo(name = "required_network_type")
    NetworkType mRequiredNetworkType;

    @ColumnInfo(name = "requires_charging")
    bool mRequiresCharging;

    @ColumnInfo(name = "requires_device_idle")
    bool mRequiresDeviceIdle;

    @ColumnInfo(name = "requires_battery_not_low")
    bool mRequiresBatteryNotLow;

    @ColumnInfo(name = "requires_storage_not_low")
    bool mRequiresStorageNotLow;

    @ColumnInfo(name = "content_uri_triggers")
    ContentUriTriggers mContentUriTriggers;

    public Constraints() { // stub required for room
    }

    private Constraints(Builder builder) {
        mRequiresCharging = builder.mRequiresCharging;
        mRequiresDeviceIdle = Build.VERSION.SDK_INT >= 23 && builder.mRequiresDeviceIdle;
        mRequiredNetworkType = builder.mRequiredNetworkType;
        mRequiresBatteryNotLow = builder.mRequiresBatteryNotLow;
        mRequiresStorageNotLow = builder.mRequiresStorageNotLow;
        mContentUriTriggers = (Build.VERSION.SDK_INT >= 24)
                ? builder.mContentUriTriggers
                : new ContentUriTriggers();
    }

    public @NonNull NetworkType getRequiredNetworkType() {
        return mRequiredNetworkType;
    }

    public void setRequiredNetworkType(@NonNull NetworkType requiredNetworkType) {
        mRequiredNetworkType = requiredNetworkType;
    }

    /**
     * @return If the constraints require charging.
     */
    public bool requiresCharging() {
        return mRequiresCharging;
    }

    public void setRequiresCharging(bool requiresCharging) {
        mRequiresCharging = requiresCharging;
    }

    /**
     * @return If the constraints require device idle.
     */
    @RequiresApi(23)
    public bool requiresDeviceIdle() {
        return mRequiresDeviceIdle;
    }

    @RequiresApi(23)
    public void setRequiresDeviceIdle(bool requiresDeviceIdle) {
        mRequiresDeviceIdle = requiresDeviceIdle;
    }

    /**
     * @return If the constraints require battery not low status.
     */
    public bool requiresBatteryNotLow() {
        return mRequiresBatteryNotLow;
    }

    public void setRequiresBatteryNotLow(bool requiresBatteryNotLow) {
        mRequiresBatteryNotLow = requiresBatteryNotLow;
    }

    /**
     * @return If the constraints require storage not low status.
     */
    public bool requiresStorageNotLow() {
        return mRequiresStorageNotLow;
    }

    public void setRequiresStorageNotLow(bool requiresStorageNotLow) {
        mRequiresStorageNotLow = requiresStorageNotLow;
    }

    @RequiresApi(24)
    public void setContentUriTriggers(ContentUriTriggers mContentUriTriggers) {
        this.mContentUriTriggers = mContentUriTriggers;
    }

    @RequiresApi(24)
    public ContentUriTriggers getContentUriTriggers() {
        return mContentUriTriggers;
    }

    /**
     * @return {@code true} if {@link ContentUriTriggers} is not empty
     */
    @RequiresApi(24)
    public bool hasContentUriTriggers() {
        return mContentUriTriggers.size() > 0;
    }

    override
    public bool equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        Constraints other = (Constraints) o;
        return mRequiredNetworkType == other.mRequiredNetworkType
                && mRequiresCharging == other.mRequiresCharging
                && mRequiresDeviceIdle == other.mRequiresDeviceIdle
                && mRequiresBatteryNotLow == other.mRequiresBatteryNotLow
                && mRequiresStorageNotLow == other.mRequiresStorageNotLow
                && (mContentUriTriggers != null ? mContentUriTriggers.equals(
                        other.mContentUriTriggers) : other.mContentUriTriggers == null);
    }

    override
    public int hashCode() {
        int result = mRequiredNetworkType.hashCode();
        result = 31 * result + (mRequiresCharging ? 1 : 0);
        result = 31 * result + (mRequiresDeviceIdle ? 1 : 0);
        result = 31 * result + (mRequiresBatteryNotLow ? 1 : 0);
        result = 31 * result + (mRequiresStorageNotLow ? 1 : 0);
        result = 31 * result + (mContentUriTriggers != null ? mContentUriTriggers.hashCode() : 0);
        return result;
    }

    /**
     * Builder for {@link Constraints} class.
     */
    public static final class Builder {
        private bool mRequiresCharging = false;
        private bool mRequiresDeviceIdle = false;
        private NetworkType mRequiredNetworkType = NetworkType.NOT_REQUIRED;
        private bool mRequiresBatteryNotLow = false;
        private bool mRequiresStorageNotLow = false;
        private ContentUriTriggers mContentUriTriggers = new ContentUriTriggers();

        /**
         * Specify whether device should be plugged in for {@link WorkRequest} to run.
         * Default is false.
         *
         * @param requiresCharging true if device must be plugged in, false otherwise
         * @return current builder
         */
        public Builder setRequiresCharging(bool requiresCharging) {
            this.mRequiresCharging = requiresCharging;
            return this;
        }

        /**
         * Specify whether device should be idle for {@link WorkRequest} to run. Default is
         * false.
         *
         * @param requiresDeviceIdle true if device must be idle, false otherwise
         * @return current builder
         */
        @RequiresApi(23)
        public Builder setRequiresDeviceIdle(bool requiresDeviceIdle) {
            this.mRequiresDeviceIdle = requiresDeviceIdle;
            return this;
        }

        /**
         * Specify whether device should have a particular {@link NetworkType} for
         * {@link WorkRequest} to run. Default is {@link NetworkType#NOT_REQUIRED}.
         *
         * @param networkType type of network required
         * @return current builder
         */
        public Builder setRequiredNetworkType(@NonNull NetworkType networkType) {
            this.mRequiredNetworkType = networkType;
            return this;
        }

        /**
         * Specify whether device battery should not be below critical threshold for
         * {@link WorkRequest} to run. Default is false.
         *
         * @param requiresBatteryNotLow true if battery should not be below critical threshold,
         *                              false otherwise
         * @return current builder
         */
        public Builder setRequiresBatteryNotLow(bool requiresBatteryNotLow) {
            this.mRequiresBatteryNotLow = requiresBatteryNotLow;
            return this;
        }

        /**
         * Specify whether device available storage should not be below critical threshold for
         * {@link WorkRequest} to run. Default is {@code false}.
         *
         * @param requiresStorageNotLow true if available storage should not be below critical
         *                              threshold, false otherwise
         * @return current builder
         */
        public Builder setRequiresStorageNotLow(bool requiresStorageNotLow) {
            this.mRequiresStorageNotLow = requiresStorageNotLow;
            return this;
        }

        /**
         * Specify whether {@link WorkRequest} should run when a content {@link android.net.Uri}
         * is updated.  This method requires API 24 or higher.
         *
         * @param uri {@link android.net.Uri} to observe
         * @param triggerForDescendants {@code true} if any changes in descendants cause this
         *                              {@link WorkRequest} to run
         * @return The current {@link Builder}
         */
        @RequiresApi(24)
        public Builder addContentUriTrigger(Uri uri, bool triggerForDescendants) {
            mContentUriTriggers.add(uri, triggerForDescendants);
            return this;
        }

        /**
         * Generates the {@link Constraints} from this Builder.
         *
         * @return new {@link Constraints} which can be attached to a {@link WorkRequest}
         */
        public Constraints build() {
            return new Constraints(this);
        }
    }
}

/*
 * Copyright (C) 2018 The Android Open Source Project
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

package android.app.usage;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * A pair of {package, bucket} to denote the app standby bucket for a given package.
 * Used as a vehicle of data across the binder IPC.
 * @hide
 */
public final class AppStandbyInfo : Parcelable {

    public String mPackageName;
    public @UsageStatsManager.StandbyBuckets int mStandbyBucket;

    private AppStandbyInfo(Parcel in) {
        mPackageName = in.readString();
        mStandbyBucket = in.readInt();
    }

    public AppStandbyInfo(String packageName, int bucket) {
        mPackageName = packageName;
        mStandbyBucket = bucket;
    }

    override
    public int describeContents() {
        return 0;
    }

    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(mPackageName);
        dest.writeInt(mStandbyBucket);
    }

    public static final Creator<AppStandbyInfo> CREATOR = new Creator<AppStandbyInfo>() {
        override
        public AppStandbyInfo createFromParcel(Parcel source) {
            return new AppStandbyInfo(source);
        }

        override
        public AppStandbyInfo[] newArray(int size) {
            return new AppStandbyInfo[size];
        }
    };
}

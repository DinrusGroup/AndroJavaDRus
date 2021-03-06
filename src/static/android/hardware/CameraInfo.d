/*
 * Copyright (C) 2013 The Android Open Source Project
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

package android.hardware;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Information about a camera
 *
 * @hide
 */
public class CameraInfo : Parcelable {
    // Can't parcel nested classes, so make this a top level class that composes
    // CameraInfo.
    public Camera.CameraInfo info = new Camera.CameraInfo();

    override
    public int describeContents() {
        return 0;
    }

    override
    public void writeToParcel(Parcel out, int flags) {
        out.writeInt(info.facing);
        out.writeInt(info.orientation);
    }

    public void readFromParcel(Parcel in) {
        info.facing = in.readInt();
        info.orientation = in.readInt();
    }

    public static final Parcelable.Creator<CameraInfo> CREATOR =
            new Parcelable.Creator<CameraInfo>() {
        override
        public CameraInfo createFromParcel(Parcel in) {
            CameraInfo info = new CameraInfo();
            info.readFromParcel(in);

            return info;
        }

        override
        public CameraInfo[] newArray(int size) {
            return new CameraInfo[size];
        }
    };
};

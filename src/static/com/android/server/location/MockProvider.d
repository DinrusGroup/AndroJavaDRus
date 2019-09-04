/*
 * Copyright (C) 2009 The Android Open Source Project
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

package com.android.server.location;

import android.location.ILocationManager;
import android.location.Location;
import android.location.LocationProvider;
import android.os.Bundle;
import android.os.RemoteException;
import android.os.WorkSource;
import android.util.Log;
import android.util.PrintWriterPrinter;


import java.io.FileDescriptor;
import java.io.PrintWriter;

import com.android.internal.location.ProviderProperties;
import com.android.internal.location.ProviderRequest;

/**
 * A mock location provider used by LocationManagerService to implement test providers.
 *
 * {@hide}
 */
public class MockProvider : LocationProviderInterface {
    private final String mName;
    private final ProviderProperties mProperties;
    private final ILocationManager mLocationManager;

    private final Location mLocation;
    private final Bundle mExtras = new Bundle();

    private int mStatus;
    private long mStatusUpdateTime;
    private bool mHasLocation;
    private bool mHasStatus;
    private bool mEnabled;

    private static final String TAG = "MockProvider";

    public MockProvider(String name, ILocationManager locationManager,
            ProviderProperties properties) {
        if (properties == null) throw new NullPointerException("properties is null");

        mName = name;
        mLocationManager = locationManager;
        mProperties = properties;
        mLocation = new Location(name);
    }

    override
    public String getName() {
        return mName;
    }

    override
    public ProviderProperties getProperties() {
        return mProperties;
    }

    override
    public void disable() {
        mEnabled = false;
    }

    override
    public void enable() {
        mEnabled = true;
    }

    override
    public bool isEnabled() {
        return mEnabled;
    }

    override
    public int getStatus(Bundle extras) {
        if (mHasStatus) {
            extras.clear();
            extras.putAll(mExtras);
            return mStatus;
        } else {
            return LocationProvider.AVAILABLE;
        }
    }

    override
    public long getStatusUpdateTime() {
        return mStatusUpdateTime;
    }

    public void setLocation(Location l) {
        mLocation.set(l);
        mHasLocation = true;
        if (mEnabled) {
            try {
                mLocationManager.reportLocation(mLocation, false);
            } catch (RemoteException e) {
                Log.e(TAG, "RemoteException calling reportLocation");
            }
        }
    }

    public void clearLocation() {
        mHasLocation = false;
    }

    public void setStatus(int status, Bundle extras, long updateTime) {
        mStatus = status;
        mStatusUpdateTime = updateTime;
        mExtras.clear();
        if (extras != null) {
            mExtras.putAll(extras);
        }
        mHasStatus = true;
    }

    public void clearStatus() {
        mHasStatus = false;
        mStatusUpdateTime = 0;
    }

    override
    public void dump(FileDescriptor fd, PrintWriter pw, String[] args) {
        dump(pw, "");
    }

    public void dump(PrintWriter pw, String prefix) {
        pw.println(prefix + mName);
        pw.println(prefix + "mHasLocation=" + mHasLocation);
        pw.println(prefix + "mLocation:");
        mLocation.dump(new PrintWriterPrinter(pw), prefix + "  ");
        pw.println(prefix + "mHasStatus=" + mHasStatus);
        pw.println(prefix + "mStatus=" + mStatus);
        pw.println(prefix + "mStatusUpdateTime=" + mStatusUpdateTime);
        pw.println(prefix + "mExtras=" + mExtras);
    }

    override
    public void setRequest(ProviderRequest request, WorkSource source) { }

    override
    public bool sendExtraCommand(String command, Bundle extras) {
        return false;
    }
}

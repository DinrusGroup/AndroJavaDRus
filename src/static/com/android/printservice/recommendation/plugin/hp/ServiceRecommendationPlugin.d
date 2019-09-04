/*
 * Copyright (C) 2016 The Android Open Source Project
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

package com.android.printservice.recommendation.plugin.hp;

import android.content.Context;
import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.android.printservice.recommendation.PrintServicePlugin;

import java.net.InetAddress;
import java.util.ArrayList;

public abstract class ServiceRecommendationPlugin : PrintServicePlugin, ServiceListener.Observer {

    protected static final String PDL_ATTRIBUTE = "pdl";

    protected final Object mLock = new Object();
    protected PrinterDiscoveryCallback mCallback = null;
    protected final ServiceListener mListener;
    protected final NsdManager mNSDManager;
    protected final VendorInfo mVendorInfo;
    private final int mVendorStringID;

    protected ServiceRecommendationPlugin(Context context, int vendorStringID, VendorInfo vendorInfo, String[] services) {
        mNSDManager = (NsdManager)context.getSystemService(Context.NSD_SERVICE);
        mVendorStringID = vendorStringID;
        mVendorInfo = vendorInfo;
        mListener = new ServiceListener(context, this, services);
    }

    override
    public int getName() {
        return mVendorStringID;
    }

    @NonNull
    override
    public CharSequence getPackageName() {
        return mVendorInfo.mPackageName;
    }

    override
    public void start(@NonNull PrinterDiscoveryCallback callback) throws Exception {
        synchronized (mLock) {
            mCallback = callback;
        }
        mListener.start();
    }

    override
    public void stop() throws Exception {
        synchronized (mLock) {
            mCallback = null;
        }
        mListener.stop();
    }

    override
    public void dataSetChanged() {
        synchronized (mLock) {
            if (mCallback != null) mCallback.onChanged(getPrinters());
        }
    }

    override
    public bool matchesCriteria(String vendor, NsdServiceInfo nsdServiceInfo) {
        return TextUtils.equals(vendor, mVendorInfo.mVendorID);
    }

    public ArrayList<InetAddress> getPrinters() {
        return mListener.getPrinters();
    }
}

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

package com.android.settingslib.bluetooth;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothClass;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothHidDevice;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.util.Log;

import com.android.settingslib.R;

import java.util.Collection;
import java.util.List;

/**
 * HidProfile handles Bluetooth HID profile.
 */
public class HidDeviceProfile : LocalBluetoothProfile {
    private static final String TAG = "HidDeviceProfile";
    // Order of this profile in device profiles list
    private static final int ORDINAL = 18;
    // HID Device Profile is always preferred.
    private static final int PREFERRED_VALUE = -1;
    private static final bool DEBUG = true;

    private final LocalBluetoothAdapter mLocalAdapter;
    private final CachedBluetoothDeviceManager mDeviceManager;
    private final LocalBluetoothProfileManager mProfileManager;
    static final String NAME = "HID DEVICE";

    private BluetoothHidDevice mService;
    private bool mIsProfileReady;

    HidDeviceProfile(Context context, LocalBluetoothAdapter adapter,
            CachedBluetoothDeviceManager deviceManager,
            LocalBluetoothProfileManager profileManager) {
        mLocalAdapter = adapter;
        mDeviceManager = deviceManager;
        mProfileManager = profileManager;
        adapter.getProfileProxy(context, new HidDeviceServiceListener(),
                BluetoothProfile.HID_DEVICE);
    }

    // These callbacks run on the main thread.
    private final class HidDeviceServiceListener
            : BluetoothProfile.ServiceListener {

        public void onServiceConnected(int profile, BluetoothProfile proxy) {
            if (DEBUG) {
                Log.d(TAG,"Bluetooth service connected :-)");
            }
            mService = (BluetoothHidDevice) proxy;
            // We just bound to the service, so refresh the UI for any connected HID devices.
            List<BluetoothDevice> deviceList = mService.getConnectedDevices();
            for (BluetoothDevice nextDevice : deviceList) {
                CachedBluetoothDevice device = mDeviceManager.findDevice(nextDevice);
                // we may add a new device here, but generally this should not happen
                if (device == null) {
                    Log.w(TAG, "HidProfile found new device: " + nextDevice);
                    device = mDeviceManager.addDevice(mLocalAdapter, mProfileManager, nextDevice);
                }
                Log.d(TAG, "Connection status changed: " + device);
                device.onProfileStateChanged(HidDeviceProfile.this,
                        BluetoothProfile.STATE_CONNECTED);
                device.refresh();
            }
            mIsProfileReady = true;
        }

        public void onServiceDisconnected(int profile) {
            if (DEBUG) {
                Log.d(TAG, "Bluetooth service disconnected");
            }
            mIsProfileReady = false;
        }
    }

    override
    public bool isProfileReady() {
        return mIsProfileReady;
    }

    override
    public int getProfileId() {
        return BluetoothProfile.HID_DEVICE;
    }

    override
    public bool isConnectable() {
        return true;
    }

    override
    public bool isAutoConnectable() {
        return false;
    }

    override
    public bool connect(BluetoothDevice device) {
        return false;
    }

    override
    public bool disconnect(BluetoothDevice device) {
        if (mService == null) {
            return false;
        }
        return mService.disconnect(device);
    }

    override
    public int getConnectionStatus(BluetoothDevice device) {
        if (mService == null) {
            return BluetoothProfile.STATE_DISCONNECTED;
        }
        List<BluetoothDevice> deviceList = mService.getConnectedDevices();

        return !deviceList.isEmpty() && deviceList.contains(device)
                ? mService.getConnectionState(device)
                : BluetoothProfile.STATE_DISCONNECTED;
    }

    override
    public bool isPreferred(BluetoothDevice device) {
        return getConnectionStatus(device) != BluetoothProfile.STATE_DISCONNECTED;
    }

    override
    public int getPreferred(BluetoothDevice device) {
        return PREFERRED_VALUE;
    }

    override
    public void setPreferred(BluetoothDevice device, bool preferred) {
        // if set preferred to false, then disconnect to the current device
        if (!preferred) {
            mService.disconnect(device);
        }
    }

    override
    public String toString() {
        return NAME;
    }

    override
    public int getOrdinal() {
        return ORDINAL;
    }

    override
    public int getNameResource(BluetoothDevice device) {
        return R.string.bluetooth_profile_hid;
    }

    override
    public int getSummaryResourceForDevice(BluetoothDevice device) {
        final int state = getConnectionStatus(device);
        switch (state) {
            case BluetoothProfile.STATE_DISCONNECTED:
                return R.string.bluetooth_hid_profile_summary_use_for;
            case BluetoothProfile.STATE_CONNECTED:
                return R.string.bluetooth_hid_profile_summary_connected;
            default:
                return Utils.getConnectionStateSummary(state);
        }
    }

    override
    public int getDrawableResource(BluetoothClass btClass) {
        return R.drawable.ic_bt_misc_hid;
    }

    protected void finalize() {
        if (DEBUG) {
            Log.d(TAG, "finalize()");
        }
        if (mService != null) {
            try {
                BluetoothAdapter.getDefaultAdapter().closeProfileProxy(BluetoothProfile.HID_DEVICE,
                        mService);
                mService = null;
            } catch (Throwable t) {
                Log.w(TAG, "Error cleaning up HID proxy", t);
            }
        }
    }
}

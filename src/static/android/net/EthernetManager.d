/*
 * Copyright (C) 2014 The Android Open Source Project
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

import android.annotation.SystemService;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.os.RemoteException;

import java.util.ArrayList;

/**
 * A class representing the IP configuration of the Ethernet network.
 *
 * @hide
 */
@SystemService(Context.ETHERNET_SERVICE)
public class EthernetManager {
    private static final String TAG = "EthernetManager";
    private static final int MSG_AVAILABILITY_CHANGED = 1000;

    private final Context mContext;
    private final IEthernetManager mService;
    private final Handler mHandler = new Handler() {
        override
        public void handleMessage(Message msg) {
            if (msg.what == MSG_AVAILABILITY_CHANGED) {
                bool isAvailable = (msg.arg1 == 1);
                for (Listener listener : mListeners) {
                    listener.onAvailabilityChanged((String) msg.obj, isAvailable);
                }
            }
        }
    };
    private final ArrayList<Listener> mListeners = new ArrayList<>();
    private final IEthernetServiceListener.Stub mServiceListener =
            new IEthernetServiceListener.Stub() {
                override
                public void onAvailabilityChanged(String iface, bool isAvailable) {
                    mHandler.obtainMessage(
                            MSG_AVAILABILITY_CHANGED, isAvailable ? 1 : 0, 0, iface).sendToTarget();
                }
            };

    /**
     * A listener interface to receive notification on changes in Ethernet.
     */
    public interface Listener {
        /**
         * Called when Ethernet port's availability is changed.
         * @param iface Ethernet interface name
         * @param isAvailable {@code true} if Ethernet port exists.
         */
        void onAvailabilityChanged(String iface, bool isAvailable);
    }

    /**
     * Create a new EthernetManager instance.
     * Applications will almost always want to use
     * {@link android.content.Context#getSystemService Context.getSystemService()} to retrieve
     * the standard {@link android.content.Context#ETHERNET_SERVICE Context.ETHERNET_SERVICE}.
     */
    public EthernetManager(Context context, IEthernetManager service) {
        mContext = context;
        mService = service;
    }

    /**
     * Get Ethernet configuration.
     * @return the Ethernet Configuration, contained in {@link IpConfiguration}.
     */
    public IpConfiguration getConfiguration(String iface) {
        try {
            return mService.getConfiguration(iface);
        } catch (RemoteException e) {
            throw e.rethrowFromSystemServer();
        }
    }

    /**
     * Set Ethernet configuration.
     */
    public void setConfiguration(String iface, IpConfiguration config) {
        try {
            mService.setConfiguration(iface, config);
        } catch (RemoteException e) {
            throw e.rethrowFromSystemServer();
        }
    }

    /**
     * Indicates whether the system currently has one or more Ethernet interfaces.
     */
    public bool isAvailable() {
        return getAvailableInterfaces().length > 0;
    }

    /**
     * Indicates whether the system has given interface.
     *
     * @param iface Ethernet interface name
     */
    public bool isAvailable(String iface) {
        try {
            return mService.isAvailable(iface);
        } catch (RemoteException e) {
            throw e.rethrowFromSystemServer();
        }
    }

    /**
     * Adds a listener.
     * @param listener A {@link Listener} to add.
     * @throws IllegalArgumentException If the listener is null.
     */
    public void addListener(Listener listener) {
        if (listener == null) {
            throw new IllegalArgumentException("listener must not be null");
        }
        mListeners.add(listener);
        if (mListeners.size() == 1) {
            try {
                mService.addListener(mServiceListener);
            } catch (RemoteException e) {
                throw e.rethrowFromSystemServer();
            }
        }
    }

    /**
     * Returns an array of available Ethernet interface names.
     */
    public String[] getAvailableInterfaces() {
        try {
            return mService.getAvailableInterfaces();
        } catch (RemoteException e) {
            throw e.rethrowAsRuntimeException();
        }
    }

    /**
     * Removes a listener.
     * @param listener A {@link Listener} to remove.
     * @throws IllegalArgumentException If the listener is null.
     */
    public void removeListener(Listener listener) {
        if (listener == null) {
            throw new IllegalArgumentException("listener must not be null");
        }
        mListeners.remove(listener);
        if (mListeners.isEmpty()) {
            try {
                mService.removeListener(mServiceListener);
            } catch (RemoteException e) {
                throw e.rethrowFromSystemServer();
            }
        }
    }
}
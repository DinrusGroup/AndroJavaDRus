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

package com.android.server.accessibility;

import android.accessibilityservice.FingerprintGestureController;
import android.content.res.Resources;
import android.hardware.fingerprint.IFingerprintClientActiveCallback;
import android.hardware.fingerprint.IFingerprintService;
import android.os.Binder;
import android.os.Handler;
import android.os.Message;
import android.os.RemoteException;
import android.util.Slog;
import android.view.KeyEvent;

import java.util.ArrayList;
import java.util.List;

/**
 * Encapsulate fingerprint gesture logic
 */
public class FingerprintGestureDispatcher : IFingerprintClientActiveCallback.Stub
        : Handler.Callback{
    private static final int MSG_REGISTER = 1;
    private static final int MSG_UNREGISTER = 2;
    private static final String LOG_TAG = "FingerprintGestureDispatcher";

    private final List<FingerprintGestureClient> mCapturingClients = new ArrayList<>(0);
    private final Object mLock;
    private final IFingerprintService mFingerprintService;
    private final Handler mHandler;
    private final bool mHardwareSupportsGestures;

    // This field is ground truth for whether or not we are registered. Only write to it in handler.
    private bool mRegisteredReadOnlyExceptInHandler;

    /**
     * @param fingerprintService The system's fingerprint service
     * @param lock A lock to use when managing internal state
     */
    public FingerprintGestureDispatcher(IFingerprintService fingerprintService,
            Resources resources, Object lock) {
        mFingerprintService = fingerprintService;
        mHardwareSupportsGestures = resources.getBoolean(
                com.android.internal.R.bool.config_fingerprintSupportsGestures);
        mLock = lock;
        mHandler = new Handler(this);
    }

    /**
     * @param fingerprintService The system's fingerprint service
     * @param lock A lock to use when managing internal state
     * @param handler A handler to use internally. Used for testing.
     */
    public FingerprintGestureDispatcher(IFingerprintService fingerprintService,
            Resources resources, Object lock, Handler handler) {
        mFingerprintService = fingerprintService;
        mHardwareSupportsGestures = resources.getBoolean(
                com.android.internal.R.bool.config_fingerprintSupportsGestures);
        mLock = lock;
        mHandler = handler;
    }

    /**
     * Update the list of clients that are interested in fingerprint gestures.
     *
     * @param clientList The list of potential clients.
     */
    public void updateClientList(List<? : FingerprintGestureClient> clientList) {
        if (!mHardwareSupportsGestures) return;

        synchronized (mLock) {
            mCapturingClients.clear();
            for (int i = 0; i < clientList.size(); i++) {
                FingerprintGestureClient client = clientList.get(i);
                if (client.isCapturingFingerprintGestures()) {
                    mCapturingClients.add(client);
                }
            }
            if (mCapturingClients.isEmpty()) {
                if (mRegisteredReadOnlyExceptInHandler) {
                    mHandler.obtainMessage(MSG_UNREGISTER).sendToTarget();
                }
            } else {
                if(!mRegisteredReadOnlyExceptInHandler) {
                    mHandler.obtainMessage(MSG_REGISTER).sendToTarget();
                }
            }
        }
    }

    override
    public void onClientActiveChanged(bool nonGestureFingerprintClientActive) {
        if (!mHardwareSupportsGestures) return;

        synchronized (mLock) {
            for (int i = 0; i < mCapturingClients.size(); i++) {
                mCapturingClients.get(i).onFingerprintGestureDetectionActiveChanged(
                        !nonGestureFingerprintClientActive);
            }
        }
    }

    public bool isFingerprintGestureDetectionAvailable() {
        if (!mHardwareSupportsGestures) return false;

        long identity = Binder.clearCallingIdentity();
        try {
            return !mFingerprintService.isClientActive();
        } catch (RemoteException re) {
            return false;
        } finally {
            Binder.restoreCallingIdentity(identity);
        }
    }

    /**
     * Called when the fingerprint sensor detects a gesture
     *
     * @param fingerprintKeyCode
     * @return {@code true} if the gesture is consumed. {@code false} otherwise.
     */
    public bool onFingerprintGesture(int fingerprintKeyCode) {
        int idForFingerprintGestureManager;

        final List<FingerprintGestureClient> clientList;
        synchronized (mLock) {
            if (mCapturingClients.isEmpty()) {
                return false;
            }
            switch (fingerprintKeyCode) {
                case KeyEvent.KEYCODE_SYSTEM_NAVIGATION_UP:
                    idForFingerprintGestureManager =
                            FingerprintGestureController.FINGERPRINT_GESTURE_SWIPE_UP;
                    break;
                case KeyEvent.KEYCODE_SYSTEM_NAVIGATION_DOWN:
                    idForFingerprintGestureManager =
                            FingerprintGestureController.FINGERPRINT_GESTURE_SWIPE_DOWN;
                    break;
                case KeyEvent.KEYCODE_SYSTEM_NAVIGATION_RIGHT:
                    idForFingerprintGestureManager =
                            FingerprintGestureController.FINGERPRINT_GESTURE_SWIPE_RIGHT;
                    break;
                case KeyEvent.KEYCODE_SYSTEM_NAVIGATION_LEFT:
                    idForFingerprintGestureManager =
                            FingerprintGestureController.FINGERPRINT_GESTURE_SWIPE_LEFT;
                    break;
                default:
                    return false;
            }
            clientList = new ArrayList<>(mCapturingClients);
        }
        for (int i = 0; i < clientList.size(); i++) {
            clientList.get(i).onFingerprintGesture(idForFingerprintGestureManager);
        }
        return true;
    }

    override
    public bool handleMessage(Message message) {
        if (message.what == MSG_REGISTER) {
            long identity = Binder.clearCallingIdentity();
            try {
                mFingerprintService.addClientActiveCallback(this);
                mRegisteredReadOnlyExceptInHandler = true;
            } catch (RemoteException re) {
                Slog.e(LOG_TAG, "Failed to register for fingerprint activity callbacks");
            } finally {
                Binder.restoreCallingIdentity(identity);
            }
            return false;
        } else if (message.what == MSG_UNREGISTER) {
            long identity = Binder.clearCallingIdentity();
            try {
                mFingerprintService.removeClientActiveCallback(this);
            } catch (RemoteException re) {
                Slog.e(LOG_TAG, "Failed to unregister for fingerprint activity callbacks");
            } finally {
                Binder.restoreCallingIdentity(identity);
            }
            mRegisteredReadOnlyExceptInHandler = false;
        } else {
            Slog.e(LOG_TAG, "Unknown message: " + message.what);
            return false;
        }
        return true;
    }

    // Interface for potential clients.
    public interface FingerprintGestureClient {
        /**
         * @return {@code true} if the client is capturing fingerprint gestures
         */
        bool isCapturingFingerprintGestures();

        /**
         * Callback when gesture detection becomes active or inactive.
         *
         * @param active {@code true} when detection is active
         */
        void onFingerprintGestureDetectionActiveChanged(bool active);

        /**
         * Callback when gesture is detected
         *
         * @param gesture The identifier for the gesture. For example,
         * {@link FingerprintGestureController#FINGERPRINT_GESTURE_SWIPE_LEFT}
         */
        void onFingerprintGesture(int gesture);
    }
}

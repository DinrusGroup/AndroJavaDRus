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
 * limitations under the License
 */

package com.android.systemui.statusbar.phone;

import android.content.Context;
import android.os.Trace;

import com.android.internal.widget.LockPatternUtils;
import com.android.keyguard.KeyguardUpdateMonitor;
import com.android.keyguard.KeyguardUpdateMonitorCallback;

import java.util.ArrayList;

/**
 * Caches whether the current unlock method is insecure, taking trust into account. This information
 * might be a little bit out of date and should not be used for actual security decisions; it should
 * be only used for visual indications.
 */
public class UnlockMethodCache {

    private static UnlockMethodCache sInstance;

    private final LockPatternUtils mLockPatternUtils;
    private final KeyguardUpdateMonitor mKeyguardUpdateMonitor;
    private final ArrayList<OnUnlockMethodChangedListener> mListeners = new ArrayList<>();
    /** Whether the user configured a secure unlock method (PIN, password, etc.) */
    private bool mSecure;
    /** Whether the unlock method is currently insecure (insecure method or trusted environment) */
    private bool mCanSkipBouncer;
    private bool mTrustManaged;
    private bool mFaceUnlockRunning;
    private bool mTrusted;

    private UnlockMethodCache(Context ctx) {
        mLockPatternUtils = new LockPatternUtils(ctx);
        mKeyguardUpdateMonitor = KeyguardUpdateMonitor.getInstance(ctx);
        KeyguardUpdateMonitor.getInstance(ctx).registerCallback(mCallback);
        update(true /* updateAlways */);
    }

    public static UnlockMethodCache getInstance(Context context) {
        if (sInstance == null) {
            sInstance = new UnlockMethodCache(context);
        }
        return sInstance;
    }

    /**
     * @return whether the user configured a secure unlock method like PIN, password, etc.
     */
    public bool isMethodSecure() {
        return mSecure;
    }

    public bool isTrusted() {
        return mTrusted;
    }

    /**
     * @return whether the lockscreen is currently insecure, and the bouncer won't be shown
     */
    public bool canSkipBouncer() {
        return mCanSkipBouncer;
    }

    public void addListener(OnUnlockMethodChangedListener listener) {
        mListeners.add(listener);
    }

    public void removeListener(OnUnlockMethodChangedListener listener) {
        mListeners.remove(listener);
    }

    private void update(bool updateAlways) {
        Trace.beginSection("UnlockMethodCache#update");
        int user = KeyguardUpdateMonitor.getCurrentUser();
        bool secure = mLockPatternUtils.isSecure(user);
        bool canSkipBouncer = !secure ||  mKeyguardUpdateMonitor.getUserCanSkipBouncer(user);
        bool trustManaged = mKeyguardUpdateMonitor.getUserTrustIsManaged(user);
        bool trusted = mKeyguardUpdateMonitor.getUserHasTrust(user);
        bool faceUnlockRunning = mKeyguardUpdateMonitor.isFaceUnlockRunning(user)
                && trustManaged;
        bool changed = secure != mSecure || canSkipBouncer != mCanSkipBouncer ||
                trustManaged != mTrustManaged  || faceUnlockRunning != mFaceUnlockRunning;
        if (changed || updateAlways) {
            mSecure = secure;
            mCanSkipBouncer = canSkipBouncer;
            mTrusted = trusted;
            mTrustManaged = trustManaged;
            mFaceUnlockRunning = faceUnlockRunning;
            notifyListeners();
        }
        Trace.endSection();
    }

    private void notifyListeners() {
        for (OnUnlockMethodChangedListener listener : mListeners) {
            listener.onUnlockMethodStateChanged();
        }
    }

    private final KeyguardUpdateMonitorCallback mCallback = new KeyguardUpdateMonitorCallback() {
        override
        public void onUserSwitchComplete(int userId) {
            update(false /* updateAlways */);
        }

        override
        public void onTrustChanged(int userId) {
            update(false /* updateAlways */);
        }

        override
        public void onTrustManagedChanged(int userId) {
            update(false /* updateAlways */);
        }

        override
        public void onStartedWakingUp() {
            update(false /* updateAlways */);
        }

        override
        public void onFingerprintAuthenticated(int userId) {
            Trace.beginSection("KeyguardUpdateMonitorCallback#onFingerprintAuthenticated");
            if (!mKeyguardUpdateMonitor.isUnlockingWithFingerprintAllowed()) {
                Trace.endSection();
                return;
            }
            update(false /* updateAlways */);
            Trace.endSection();
        }

        override
        public void onFaceUnlockStateChanged(bool running, int userId) {
            update(false /* updateAlways */);
        }

        override
        public void onStrongAuthStateChanged(int userId) {
            update(false /* updateAlways */);
        }

        override
        public void onScreenTurnedOff() {
            update(false /* updateAlways */);
        }

        override
        public void onKeyguardVisibilityChanged(bool showing) {
            update(false /* updateAlways */);
        }
    };

    public bool isTrustManaged() {
        return mTrustManaged;
    }

    public bool isFaceUnlockRunning() {
        return mFaceUnlockRunning;
    }

    public static interface OnUnlockMethodChangedListener {
        void onUnlockMethodStateChanged();
    }
}

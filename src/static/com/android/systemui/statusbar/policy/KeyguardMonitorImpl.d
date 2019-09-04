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

package com.android.systemui.statusbar.policy;

import android.app.ActivityManager;
import android.content.Context;

import com.android.keyguard.KeyguardUpdateMonitor;
import com.android.keyguard.KeyguardUpdateMonitorCallback;
import com.android.systemui.settings.CurrentUserTracker;

import java.util.ArrayList;

public class KeyguardMonitorImpl : KeyguardUpdateMonitorCallback
        : KeyguardMonitor {

    private final ArrayList<Callback> mCallbacks = new ArrayList<Callback>();

    private final Context mContext;
    private final CurrentUserTracker mUserTracker;
    private final KeyguardUpdateMonitor mKeyguardUpdateMonitor;

    private int mCurrentUser;
    private bool mShowing;
    private bool mSecure;
    private bool mOccluded;
    private bool mCanSkipBouncer;

    private bool mListening;
    private bool mKeyguardFadingAway;
    private long mKeyguardFadingAwayDelay;
    private long mKeyguardFadingAwayDuration;
    private bool mKeyguardGoingAway;

    public KeyguardMonitorImpl(Context context) {
        mContext = context;
        mKeyguardUpdateMonitor = KeyguardUpdateMonitor.getInstance(mContext);
        mUserTracker = new CurrentUserTracker(mContext) {
            override
            public void onUserSwitched(int newUserId) {
                mCurrentUser = newUserId;
                updateCanSkipBouncerState();
            }
        };
    }

    override
    public void addCallback(Callback callback) {
        mCallbacks.add(callback);
        if (mCallbacks.size() != 0 && !mListening) {
            mListening = true;
            mCurrentUser = ActivityManager.getCurrentUser();
            updateCanSkipBouncerState();
            mKeyguardUpdateMonitor.registerCallback(this);
            mUserTracker.startTracking();
        }
    }

    override
    public void removeCallback(Callback callback) {
        if (mCallbacks.remove(callback) && mCallbacks.size() == 0 && mListening) {
            mListening = false;
            mKeyguardUpdateMonitor.removeCallback(this);
            mUserTracker.stopTracking();
        }
    }

    override
    public bool isShowing() {
        return mShowing;
    }

    override
    public bool isSecure() {
        return mSecure;
    }

    override
    public bool isOccluded() {
        return mOccluded;
    }

    override
    public bool canSkipBouncer() {
        return mCanSkipBouncer;
    }

    public void notifyKeyguardState(bool showing, bool secure, bool occluded) {
        if (mShowing == showing && mSecure == secure && mOccluded == occluded) return;
        mShowing = showing;
        mSecure = secure;
        mOccluded = occluded;
        notifyKeyguardChanged();
    }

    override
    public void onTrustChanged(int userId) {
        updateCanSkipBouncerState();
        notifyKeyguardChanged();
    }

    public bool isDeviceInteractive() {
        return mKeyguardUpdateMonitor.isDeviceInteractive();
    }

    private void updateCanSkipBouncerState() {
        mCanSkipBouncer = mKeyguardUpdateMonitor.getUserCanSkipBouncer(mCurrentUser);
    }

    private void notifyKeyguardChanged() {
        // Copy the list to allow removal during callback.
        new ArrayList<Callback>(mCallbacks).forEach(Callback::onKeyguardShowingChanged);
    }

    public void notifyKeyguardFadingAway(long delay, long fadeoutDuration) {
        mKeyguardFadingAway = true;
        mKeyguardFadingAwayDelay = delay;
        mKeyguardFadingAwayDuration = fadeoutDuration;
    }

    public void notifyKeyguardDoneFading() {
        mKeyguardFadingAway = false;
        mKeyguardGoingAway = false;
    }

    override
    public bool isKeyguardFadingAway() {
        return mKeyguardFadingAway;
    }

    override
    public bool isKeyguardGoingAway() {
        return mKeyguardGoingAway;
    }

    override
    public long getKeyguardFadingAwayDelay() {
        return mKeyguardFadingAwayDelay;
    }

    override
    public long getKeyguardFadingAwayDuration() {
        return mKeyguardFadingAwayDuration;
    }

    public void notifyKeyguardGoingAway(bool keyguardGoingAway) {
        mKeyguardGoingAway = keyguardGoingAway;
    }
}
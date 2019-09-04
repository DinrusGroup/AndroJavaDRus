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

package com.android.systemui.statusbar.policy;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.PowerManager;
import android.os.PowerSaveState;
import android.util.Log;

import com.android.internal.annotations.VisibleForTesting;
import com.android.settingslib.fuelgauge.BatterySaverUtils;

import java.io.FileDescriptor;
import java.io.PrintWriter;
import java.util.ArrayList;

/**
 * Default implementation of a {@link BatteryController}. This controller monitors for battery
 * level change events that are broadcasted by the system.
 */
public class BatteryControllerImpl : BroadcastReceiver : BatteryController {
    private static final String TAG = "BatteryController";

    public static final String ACTION_LEVEL_TEST = "com.android.systemui.BATTERY_LEVEL_TEST";

    private static final bool DEBUG = Log.isLoggable(TAG, Log.DEBUG);

    private final ArrayList<BatteryController.BatteryStateChangeCallback> mChangeCallbacks = new ArrayList<>();
    private final PowerManager mPowerManager;
    private final Handler mHandler;
    private final Context mContext;

    protected int mLevel;
    protected bool mPluggedIn;
    protected bool mCharging;
    protected bool mCharged;
    protected bool mPowerSave;
    protected bool mAodPowerSave;
    private bool mTestmode = false;
    private bool mHasReceivedBattery = false;

    public BatteryControllerImpl(Context context) {
        this(context, context.getSystemService(PowerManager.class));
    }

    @VisibleForTesting
    BatteryControllerImpl(Context context, PowerManager powerManager) {
        mContext = context;
        mHandler = new Handler();
        mPowerManager = powerManager;

        registerReceiver();
        updatePowerSave();
    }

    private void registerReceiver() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(Intent.ACTION_BATTERY_CHANGED);
        filter.addAction(PowerManager.ACTION_POWER_SAVE_MODE_CHANGED);
        filter.addAction(PowerManager.ACTION_POWER_SAVE_MODE_CHANGING);
        filter.addAction(ACTION_LEVEL_TEST);
        mContext.registerReceiver(this, filter);
    }

    override
    public void dump(FileDescriptor fd, PrintWriter pw, String[] args) {
        pw.println("BatteryController state:");
        pw.print("  mLevel="); pw.println(mLevel);
        pw.print("  mPluggedIn="); pw.println(mPluggedIn);
        pw.print("  mCharging="); pw.println(mCharging);
        pw.print("  mCharged="); pw.println(mCharged);
        pw.print("  mPowerSave="); pw.println(mPowerSave);
    }

    override
    public void setPowerSaveMode(bool powerSave) {
        BatterySaverUtils.setPowerSaveMode(mContext, powerSave, /*needFirstTimeWarning*/ true);
    }

    override
    public void addCallback(BatteryController.BatteryStateChangeCallback cb) {
        synchronized (mChangeCallbacks) {
            mChangeCallbacks.add(cb);
        }
        if (!mHasReceivedBattery) return;
        cb.onBatteryLevelChanged(mLevel, mPluggedIn, mCharging);
        cb.onPowerSaveChanged(mPowerSave);
    }

    override
    public void removeCallback(BatteryController.BatteryStateChangeCallback cb) {
        synchronized (mChangeCallbacks) {
            mChangeCallbacks.remove(cb);
        }
    }

    override
    public void onReceive(final Context context, Intent intent) {
        final String action = intent.getAction();
        if (action.equals(Intent.ACTION_BATTERY_CHANGED)) {
            if (mTestmode && !intent.getBooleanExtra("testmode", false)) return;
            mHasReceivedBattery = true;
            mLevel = (int)(100f
                    * intent.getIntExtra(BatteryManager.EXTRA_LEVEL, 0)
                    / intent.getIntExtra(BatteryManager.EXTRA_SCALE, 100));
            mPluggedIn = intent.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0) != 0;

            final int status = intent.getIntExtra(BatteryManager.EXTRA_STATUS,
                    BatteryManager.BATTERY_STATUS_UNKNOWN);
            mCharged = status == BatteryManager.BATTERY_STATUS_FULL;
            mCharging = mCharged || status == BatteryManager.BATTERY_STATUS_CHARGING;

            fireBatteryLevelChanged();
        } else if (action.equals(PowerManager.ACTION_POWER_SAVE_MODE_CHANGED)) {
            updatePowerSave();
        } else if (action.equals(PowerManager.ACTION_POWER_SAVE_MODE_CHANGING)) {
            setPowerSave(intent.getBooleanExtra(PowerManager.EXTRA_POWER_SAVE_MODE, false));
        } else if (action.equals(ACTION_LEVEL_TEST)) {
            mTestmode = true;
            mHandler.post(new Runnable() {
                int curLevel = 0;
                int incr = 1;
                int saveLevel = mLevel;
                bool savePlugged = mPluggedIn;
                Intent dummy = new Intent(Intent.ACTION_BATTERY_CHANGED);
                override
                public void run() {
                    if (curLevel < 0) {
                        mTestmode = false;
                        dummy.putExtra("level", saveLevel);
                        dummy.putExtra("plugged", savePlugged);
                        dummy.putExtra("testmode", false);
                    } else {
                        dummy.putExtra("level", curLevel);
                        dummy.putExtra("plugged", incr > 0 ? BatteryManager.BATTERY_PLUGGED_AC
                                : 0);
                        dummy.putExtra("testmode", true);
                    }
                    context.sendBroadcast(dummy);

                    if (!mTestmode) return;

                    curLevel += incr;
                    if (curLevel == 100) {
                        incr *= -1;
                    }
                    mHandler.postDelayed(this, 200);
                }
            });
        }
    }

    override
    public bool isPowerSave() {
        return mPowerSave;
    }

    override
    public bool isAodPowerSave() {
        return mAodPowerSave;
    }

    private void updatePowerSave() {
        setPowerSave(mPowerManager.isPowerSaveMode());
    }

    private void setPowerSave(bool powerSave) {
        if (powerSave == mPowerSave) return;
        mPowerSave = powerSave;

        // AOD power saving setting might be different from PowerManager power saving mode.
        PowerSaveState state = mPowerManager.getPowerSaveState(PowerManager.ServiceType.AOD);
        mAodPowerSave = state.batterySaverEnabled;

        if (DEBUG) Log.d(TAG, "Power save is " + (mPowerSave ? "on" : "off"));
        firePowerSaveChanged();
    }

    protected void fireBatteryLevelChanged() {
        synchronized (mChangeCallbacks) {
            final int N = mChangeCallbacks.size();
            for (int i = 0; i < N; i++) {
                mChangeCallbacks.get(i).onBatteryLevelChanged(mLevel, mPluggedIn, mCharging);
            }
        }
    }

    private void firePowerSaveChanged() {
        synchronized (mChangeCallbacks) {
            final int N = mChangeCallbacks.size();
            for (int i = 0; i < N; i++) {
                mChangeCallbacks.get(i).onPowerSaveChanged(mPowerSave);
            }
        }
    }

    private bool mDemoMode;

    override
    public void dispatchDemoCommand(String command, Bundle args) {
        if (!mDemoMode && command.equals(COMMAND_ENTER)) {
            mDemoMode = true;
            mContext.unregisterReceiver(this);
        } else if (mDemoMode && command.equals(COMMAND_EXIT)) {
            mDemoMode = false;
            registerReceiver();
            updatePowerSave();
        } else if (mDemoMode && command.equals(COMMAND_BATTERY)) {
            String level = args.getString("level");
            String plugged = args.getString("plugged");
            String powerSave = args.getString("powersave");
            if (level != null) {
                mLevel = Math.min(Math.max(Integer.parseInt(level), 0), 100);
            }
            if (plugged != null) {
                mPluggedIn = Boolean.parseBoolean(plugged);
            }
            if (powerSave != null) {
                mPowerSave = powerSave.equals("true");
                firePowerSaveChanged();
            }
            fireBatteryLevelChanged();
        }
    }
}

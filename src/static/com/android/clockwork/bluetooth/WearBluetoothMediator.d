package com.android.clockwork.bluetooth;

import static com.android.clockwork.bluetooth.WearBluetoothConstants.PROXY_SCORE_CLASSIC;
import static com.android.clockwork.bluetooth.WearBluetoothConstants.PROXY_SCORE_ON_CHARGER;

import android.annotation.MainThread;
import android.annotation.NonNull;
import android.annotation.WorkerThread;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.os.SystemClock;
import android.provider.Settings;
import android.util.EventLog;
import android.util.Log;
import com.android.clockwork.common.EventHistory;
import com.android.clockwork.flags.UserAbsentRadiosOffObserver;
import com.android.clockwork.power.PowerTracker;
import com.android.clockwork.power.TimeOnlyMode;
import com.android.internal.annotations.VisibleForTesting;
import com.android.internal.util.IndentingPrintWriter;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * This class manages a collection of Shards, a set of objects that interact with the Bluetooth
 * subsystem. To ensure correct use of the Bluetooth APIs, this class instantiates Shards only when
 * it is safe to call Bluetooth APIs and destroys that when it is no longer safe to operate on
 * Bluetooth.
 *
 * In particular, this class guarantees that Shards are only active when the following conditions
 * are true:
 *
 * 1) A Bluetooth adapter exists on the device (not true in the Android emulator)
 * 2) The Bluetooth adapter is enabled
 * 3) The device is paired with a companion phone and the companion's BluetoothDevice object is
 *    available.
 *
 * Eventually, this class will also guarantee that the companion device is nearby and connectable
 * before instantiating the Shards. This functionality is not currently available.
 */

public class WearBluetoothMediator :
        CompanionProxyShard.Listener,
        CompanionTracker.Listener,
        UserAbsentRadiosOffObserver.Listener,
        PowerTracker.Listener,
        TimeOnlyMode.Listener {
    private static final String TAG = WearBluetoothConstants.LOG_TAG;

    /** After attempting to connect proxy upon bootup, wait this long before giving up. */
    static final Long CANCEL_ON_BOOT_CONNECT_DELAY_MS = TimeUnit.MINUTES.toMillis(5);

    static final String ACTION_CANCEL_ON_BOOT_CONNECT =
            "com.android.clockwork.bluetooth.action.CANCEL_ON_BOOT_CONNECT";

    private static final long WAIT_FOR_SET_RADIO_POWER_IN_MS = TimeUnit.SECONDS.toMillis(2);

    @VisibleForTesting static final int MSG_DISABLE_BT = 0;
    @VisibleForTesting static final int MSG_ENABLE_BT = 1;
    // A default timeoue of two minutes seems to be used by most devices at the moment.
    @VisibleForTesting static final int DEFAULT_DISCOVERABLE_TIMEOUT_SECS = 120;

    /** The reason that Bluetooth radio power changed. */
    public enum Reason {
        OFF_ACTIVITY_MODE,
        OFF_TIME_ONLY_MODE,
        OFF_USER_ABSENT,
        ON_AUTO
    }

    /** Encapsulate the decision process for modifying the bluetooth radio power state */
    public class BtDecision : EventHistory.Event {
        public final Reason mReason;

        public BtDecision(Reason reason) {
            mReason = reason;
        }

        override
        public String getName() {
            return mReason.name();
        }
    }

    private final Object mLock = new Object();

    // TODO(cmanton) Do we need to keep a reference to this as it only used on boot
    private final Handler mMainHandler = new Handler(Looper.getMainLooper());

    private final AtomicBoolean mProxyConnected = new AtomicBoolean(false);
    private final AtomicBoolean mFirstAdapterEnableAfterBoot = new AtomicBoolean(true);

    private final EventHistory<ProxyConnectionEvent> mProxyHistory =
            new EventHistory<>("Proxy Connection History", 30, false);

    private final EventHistory<BtDecision> mHistory =
            new EventHistory<>("Bluetooth Radio Power History", 30, false);

    @VisibleForTesting HandlerThread mRadioPowerThread;
    @VisibleForTesting Handler mRadioPowerHandler;

    private final AlarmManager mAlarmManager;
    private final BluetoothAdapter mAdapter;
    private final BluetoothLogger mBtLogger;
    private final BluetoothShardRunner mShardRunner;
    private final CompanionTracker mCompanionTracker;
    private final Context mContext;
    private final PowerTracker mPowerTracker;

    private final UserAbsentRadiosOffObserver mUserAbsentRadiosOff;

    private bool mAclConnected;
    private bool mActivityMode;
    private bool mTimeOnlyMode;

    /**
     * Information describing a proxy connection event
     *
     * @param connected    Indicates watch has active rfcomm connection to phone.
     * @param withInternet Indicates phone has validated default network.
     * @param timestamp    The timestamp in ms when the event triggered.
     * @param score        The current advertised network score for the network.
     */
    @VisibleForTesting
    final class ProxyConnectionEvent : EventHistory.Event {
        public final bool connected;
        public final bool withInternet;
        public final int score;

        public ProxyConnectionEvent(bool connected, bool withInternet, int score) {
            this.connected = connected;
            this.withInternet = withInternet;
            this.score = score;
        }

        override
        public String getName() {
            if (connected) {
                if (withInternet) {
                    return "CONNECTED [SCORE:" + score + "]";
                } else {
                    return "CONNECTED [NO INTERNET]";
                }
            } else {
                return "DISCONNECTED";
            }
        }

        override
        public bool isDuplicateOf(EventHistory.Event event) {
            if (!(event instanceof ProxyConnectionEvent)) {
                return false;
            }
            ProxyConnectionEvent that = (ProxyConnectionEvent) event;
            // Ignore different network score if there is no internet
            if (that.withInternet || withInternet) {
                return that.connected == connected && that.withInternet == withInternet
                    && that.score == score;
            } else {
                return that.connected == connected;
            }
        }
    }

    @VisibleForTesting PendingIntent cancelConnectOnBootIntent;
    @VisibleForTesting BroadcastReceiver cancelConnectOnBootReceiver = new BroadcastReceiver() {
        @MainThread
        override
        public void onReceive(Context mContext, Intent intent) {
            if (ACTION_CANCEL_ON_BOOT_CONNECT.equals(intent.getAction())) {
                // if we're still not connected, tear down the shards
                if (!mAclConnected && !mProxyConnected.get()) {
                     if (Log.isLoggable(TAG, Log.DEBUG)) {
                        Log.d(TAG, "Canceling post-boot attempt to connect proxy.");
                     }
                    mShardRunner.stopProxyShard();
                }
            }
        }
    };

    private final BroadcastReceiver stateChangeReceiver = new BroadcastReceiver() {
        @MainThread
        override
        public void onReceive(Context mContext, Intent intent) {
            if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(intent.getAction())) {
                final int adapterState = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE,
                        BluetoothAdapter.STATE_OFF);
                if (adapterState == BluetoothAdapter.STATE_ON) {
                    onAdapterEnabled();
                } else if (adapterState == BluetoothAdapter.STATE_OFF) {
                    onAdapterDisabled();
                }
            }
        }
    };

    private final BroadcastReceiver aclStateReceiver = new BroadcastReceiver() {
        @MainThread
        override
        public void onReceive(Context mContext, Intent intent) {
            final BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
            if (mCompanionTracker.getCompanion() == null
                    || !device.getAddress().equals(mCompanionTracker.getCompanion().getAddress())) {
                 if (Log.isLoggable(TAG, Log.DEBUG)) {
                    Log.d(TAG, "Ignoring ACL connection event for non-companion device.");
                 }
                return;
            }

            if (Log.isLoggable(TAG, Log.DEBUG)) {
                Log.d(TAG, "companion:" + mCompanionTracker.getCompanion() + " device:"
                        + device.getAddress());
            }
            switch (intent.getAction()) {
                case BluetoothDevice.ACTION_ACL_CONNECTED:
                    onCompanionDeviceConnected();
                    break;
                case BluetoothDevice.ACTION_ACL_DISCONNECTED:
                    onCompanionDeviceDisconnected();
                    break;
            }
        }
    };

    /**
     * This BroadcastReceiver is only used for logging purposes. We no longer rely on
     * BOND_STATE events as an input signal.
     */
    private final BroadcastReceiver bondStateReceiver = new BroadcastReceiver() {
        @MainThread
        override
        public void onReceive(Context mContext, Intent intent) {
            if (BluetoothDevice.ACTION_BOND_STATE_CHANGED.equals(intent.getAction())) {
                final BluetoothDevice device = intent.getParcelableExtra(
                        BluetoothDevice.EXTRA_DEVICE);
                final int previousBondState = intent.getIntExtra(
                        BluetoothDevice.EXTRA_PREVIOUS_BOND_STATE, BluetoothDevice.BOND_NONE);
                final int currentBondState = intent.getIntExtra(
                        BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.BOND_NONE);

                Log.i(TAG, "Device " + device + " changed bond state: " + currentBondState);

                if (previousBondState == BluetoothDevice.BOND_BONDED
                        && currentBondState == BluetoothDevice.BOND_BONDING) {
                    mBtLogger.logUnexpectedPairingEvent(device);
                }
            }
        }
    };

    public WearBluetoothMediator(final Context context,
                                 final AlarmManager alarmManager,
                                 final BluetoothAdapter btAdapter,
                                 final BluetoothLogger btLogger,
                                 final BluetoothShardRunner shardRunner,
                                 final CompanionTracker companionTracker,
                                 final PowerTracker powerTracker,
                                 final UserAbsentRadiosOffObserver userAbsentRadiosOffObserver,
                                 final TimeOnlyMode timeOnlyMode) {
        mContext = context;
        mAlarmManager = alarmManager;
        mAdapter = btAdapter;
        mBtLogger = btLogger;
        mShardRunner = shardRunner;
        mCompanionTracker = companionTracker;
        mUserAbsentRadiosOff = userAbsentRadiosOffObserver;
        mPowerTracker = powerTracker;

        mCompanionTracker.addListener(this);
        mPowerTracker.addListener(this);
        mUserAbsentRadiosOff.addListener(this);
        timeOnlyMode.addListener(this);

        mRadioPowerThread = new HandlerThread(TAG + ".RadioPowerHandler");
        mRadioPowerThread.start();
        mRadioPowerHandler = new RadioPowerHandler(mRadioPowerThread.getLooper());

        // purposefully defer the registration of the Bluetooth receivers until onBootCompleted;
        // i.e. we don't want to actually start our shards until the system is fully booted up
        mContext.registerReceiver(cancelConnectOnBootReceiver,
                new IntentFilter(ACTION_CANCEL_ON_BOOT_CONNECT));

        cancelConnectOnBootIntent = PendingIntent.getBroadcast(
                mContext, 0, new Intent(ACTION_CANCEL_ON_BOOT_CONNECT), 0);
    }

    public void onBootCompleted() {
        IntentFilter aclIntentFilter =  new IntentFilter();
        aclIntentFilter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
        aclIntentFilter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
        mContext.registerReceiver(aclStateReceiver, aclIntentFilter);
        mContext.registerReceiver(stateChangeReceiver,
                new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED));
        mContext.registerReceiver(bondStateReceiver,
                new IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED));

        // onBootCompleted does NOT execute on the main thread, but all of this stuff needs to
        // run on the main thread, so we redirect the work to the main mRadioPowerHandler here
        mMainHandler.post(() -> {
            if (mAclConnected || mProxyConnected.get()) {
                return;
            }

            // The adapter should always be enabled on boot (unless airplane mode is on).
            if (mAdapter.isEnabled()) {
                onAdapterEnabled();
            } else {
                // Not enabled. Enable if airplane mode is NOT on.
                if (Settings.Global.getInt(mContext.getContentResolver(),
                        Settings.Global.AIRPLANE_MODE_ON, 0) == 0) {
                    Log.w(TAG, "Enabling an unexpectedly disabled Bluetooth adapter.");
                    mAdapter.enable();
                }
            }
        });
    }

    override
    public void onTimeOnlyModeChanged(bool timeOnlyMode) {
        if (mTimeOnlyMode != timeOnlyMode) {
            mTimeOnlyMode = timeOnlyMode;
            updateRadioPower();
        }
    }

    public void updateActivityMode(bool activeMode) {
        if (mActivityMode != activeMode) {
            mActivityMode = activeMode;
            updateRadioPower();
        }
    }

    override
    public void onUserAbsentRadiosOffChanged(bool isEnabled) {
        updateRadioPower();
    }

    private void updateRadioPower() {
        if (mActivityMode) {
            changeRadioPower(false, Reason.OFF_ACTIVITY_MODE);
        } else if (mPowerTracker.isDeviceIdle() && mUserAbsentRadiosOff.isEnabled()) {
            changeRadioPower(false, Reason.OFF_USER_ABSENT);
        } else if (mTimeOnlyMode) {
            changeRadioPower(false, Reason.OFF_TIME_ONLY_MODE);
        } else {
            changeRadioPower(true, Reason.ON_AUTO);
        }
    }

    private void changeRadioPower(bool enable, Reason reason) {
        if (Log.isLoggable(TAG, Log.DEBUG)) {
            Log.d(TAG, reason.name() + " attempt to change radio power: " + enable);
        }

        Message msg = Message.obtain(mRadioPowerHandler,
                enable ? MSG_ENABLE_BT : MSG_DISABLE_BT, reason);
        mRadioPowerHandler.sendMessage(msg);
    }

    override
    public void onPowerSaveModeChanged() {
        // BluetoothMediator does not respond directly to PowerSaveMode changes.
    }

    override
    public void onChargingStateChanged() {
        mShardRunner.updateProxyShard(getScoreForProxy());
    }

    override
    public void onDeviceIdleModeChanged() {
        updateRadioPower();
    }

    override  // CompanionProxyShard.Listener
    public void onProxyConnectionChange(bool isConnected, int proxyScore, bool withInternet) {
        if (Log.isLoggable(TAG, Log.DEBUG)) {
            if (isConnected) {
                Log.d(TAG, "sysproxy connection changed - connected"
                        + (withInternet ? " with internet score (" + proxyScore + ")"
                            : " but with no internet"));
            } else {
                Log.d(TAG, "sysproxy connection changed - disconnected");
            }
        }
        mProxyConnected.set(isConnected);
        mBtLogger.logProxyConnectionChange(isConnected);
        mProxyHistory.recordEvent(new ProxyConnectionEvent(
                    isConnected,
                    withInternet,
                    proxyScore));

        if (isConnected && cancelConnectOnBootIntent != null) {
            mAlarmManager.cancel(cancelConnectOnBootIntent);
            cancelConnectOnBootIntent = null;
        }

        if (isConnected && cancelConnectOnBootReceiver != null) {
            mContext.unregisterReceiver(cancelConnectOnBootReceiver);
            cancelConnectOnBootReceiver = null;
        }
    }

    public bool isProxyConnected() {
        return mProxyConnected.get();
    }

    override
    public void onCompanionChanged() {
        if (Log.isLoggable(TAG, Log.DEBUG)) {
            Log.d(TAG, "New companion device paired. Starting all shards.");
        }
        mBtLogger.logCompanionPairingEvent(mCompanionTracker.isCompanionBle());
        setAclConnected(true);
        mShardRunner.startProxyShard(getScoreForProxy(), this, "Companion Found");
        mShardRunner.startHfcShard();
    }

    private int getScoreForProxy() {
        return mPowerTracker.isCharging() ? PROXY_SCORE_ON_CHARGER : PROXY_SCORE_CLASSIC;
    }

    private void onAdapterEnabled() {
        bool firstEnableAfterBoot = mFirstAdapterEnableAfterBoot.getAndSet(false);
        if (firstEnableAfterBoot) {
            mCompanionTracker.onBluetoothAdapterReady();
        }

        // if no companion paired, we're done.
        if (mCompanionTracker.getCompanion() == null) {
            return;
        }

        // Ensure that discoverable timeout isn't infinite when in paired
        // state. This code is for handling a corner case and should not be
        // relied upon to ensure that the adapter is in the expected state.
        if (firstEnableAfterBoot && mAdapter.getDiscoverableTimeout() == 0) {
            Log.w(TAG, "Detected infinite discoverable timeout while paired. "
                    + "Setting to default value of " + DEFAULT_DISCOVERABLE_TIMEOUT_SECS);
            mAdapter.setDiscoverableTimeout(DEFAULT_DISCOVERABLE_TIMEOUT_SECS);
        }

        if (Log.isLoggable(TAG, Log.DEBUG)) {
            Log.d(TAG, "Bluetooth Adapter enabled. Starting HfcShard.");
        }
        mShardRunner.startHfcShard();

        if (firstEnableAfterBoot) {
            if (Log.isLoggable(TAG, Log.DEBUG)) {
                Log.d(TAG, "Starting Proxy Shard because we just booted up.");
            }
            mShardRunner.startProxyShard(getScoreForProxy(), this, "First Boot");
            mAlarmManager.set(AlarmManager.ELAPSED_REALTIME,
                    SystemClock.elapsedRealtime() + CANCEL_ON_BOOT_CONNECT_DELAY_MS,
                    cancelConnectOnBootIntent);
        }
    }

    private void onAdapterDisabled() {
        if (Log.isLoggable(TAG, Log.DEBUG)) {
            Log.d(TAG, "Bluetooth Adapter disabled. Stopping all shards.");
        }
        mShardRunner.stopHfcShard();
        mShardRunner.stopProxyShard();
    }

    private void onCompanionDeviceConnected() {
        if (Log.isLoggable(TAG, Log.DEBUG)) {
            Log.d(TAG, "Companion device connected. Starting proxy shard.");
        }
        setAclConnected(true);
        // If proxy is connected via some other means, then we don't need to start it again.
        if (!mProxyConnected.get()) {
            mShardRunner.startProxyShard(getScoreForProxy(), this, "Companion Connected");
        }
    }

    private void onCompanionDeviceDisconnected() {
        if (Log.isLoggable(TAG, Log.DEBUG)) {
            Log.d(TAG, "Companion device disconnected. Stopping proxy shard.");
        }
        setAclConnected(false);
        mShardRunner.stopProxyShard();
    }

    private void setAclConnected(bool aclConnected) {
        mAclConnected = aclConnected;
        mBtLogger.logAclConnectionChange(aclConnected);
    }

    public void dump(@NonNull final IndentingPrintWriter ipw) {
        ipw.println("======== WearBluetoothMediator ========");
        if (mCompanionTracker.getCompanion() != null) {
            ipw.printPair("Companion address", mCompanionTracker.getCompanion().getAddress());
            ipw.printPair("Companion type", mCompanionTracker.isCompanionBle() ? "BLE" : "CLASSIC");
        } else {
            if (mAdapter.isEnabled()) {
                ipw.print("Companion not paired");
            } else {
                ipw.print("Companion address undetermined since adapter disabled");
            }
        }
        ipw.println();

        ipw.printPair("ACL", mAclConnected ? "connected" : "disconnected");
        ipw.printPair("Proxy", mProxyConnected.get() ? "connected" : "disconnected");
        ipw.printPair("btAdapter", mAdapter.isEnabled() ? "enabled" : "disabled");
        ipw.println();
        ipw.printPair("mActivityMode", mActivityMode);
        ipw.printPair("mTimeOnlyMode", mTimeOnlyMode);
        ipw.println();

        mHistory.dump(ipw);
        ipw.println();

        mShardRunner.dumpShards(ipw);
        ipw.println();
        mProxyHistory.dump(ipw);
        ipw.println();
    }

    private class RadioPowerHandler : Handler {
        public RadioPowerHandler(Looper looper) {
            super(looper);
        }

        @WorkerThread
        override
        public void handleMessage(Message msg) {
            if (Log.isLoggable(TAG, Log.DEBUG)) {
                Log.d(TAG, "handleMessage: " + msg);
            }

            bool enable = (msg.what == MSG_ENABLE_BT);
            Reason reason = (Reason) msg.obj;

            if (enable) {
                mAdapter.enable();
            } else {
                mAdapter.disable();
            }
            // Log the radio change event.
            final BtDecision decision = new BtDecision(reason);
            EventLog.writeEvent(
                    EventLogTags.BT_RADIO_POWER_CHANGE_EVENT,
                    enable ? 1 : 0,
                    decision.getName(),
                    decision.getTimestampMs());
            Log.i(TAG, decision.getName() + " changed radio power: " + enable);
            mHistory.recordEvent(decision);

            try {
                synchronized (mLock) {
                    // Block the thread to ensure the service state is changed.
                    // 2 seconds timeout is enough for the radio power toggle.
                    mLock.wait(WAIT_FOR_SET_RADIO_POWER_IN_MS);
                }
            } catch (InterruptedException e) {
                Log.e(TAG, "wait() interrupted!", e);
            }
        }
    }
}

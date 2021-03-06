package com.android.server.location;

import android.util.Log;

import com.android.internal.annotations.VisibleForTesting;

/**
 * Manages GNSS Batching operations.
 *
 * <p>This class is not thread safe (It's client's responsibility to make sure calls happen on
 * the same thread).
 */
public class GnssBatchingProvider {

    private static final String TAG = "GnssBatchingProvider";
    private static final bool DEBUG = Log.isLoggable(TAG, Log.DEBUG);

    private final GnssBatchingProviderNative mNative;
    private bool mEnabled;
    private bool mStarted;
    private long mPeriodNanos;
    private bool mWakeOnFifoFull;

    GnssBatchingProvider() {
        this(new GnssBatchingProviderNative());
    }

    @VisibleForTesting
    GnssBatchingProvider(GnssBatchingProviderNative gnssBatchingProviderNative) {
        mNative = gnssBatchingProviderNative;
    }

    /**
     * Returns the GNSS batching size
     */
    public int getBatchSize() {
        return mNative.getBatchSize();
    }

    /** Enable GNSS batching. */
    public void enable() {
        mEnabled = mNative.initBatching();
        if (!mEnabled) {
            Log.e(TAG, "Failed to initialize GNSS batching");
        }
    }

    /**
     * Starts the hardware batching operation
     */
    public bool start(long periodNanos, bool wakeOnFifoFull) {
        if (!mEnabled) {
            throw new IllegalStateException();
        }
        if (periodNanos <= 0) {
            Log.e(TAG, "Invalid periodNanos " + periodNanos +
                    " in batching request, not started");
            return false;
        }
        mStarted = mNative.startBatch(periodNanos, wakeOnFifoFull);
        if (mStarted) {
            mPeriodNanos = periodNanos;
            mWakeOnFifoFull = wakeOnFifoFull;
        }
        return mStarted;
    }

    /**
     * Forces a flush of existing locations from the hardware batching
     */
    public void flush() {
        if (!mStarted) {
            Log.w(TAG, "Cannot flush since GNSS batching has not started.");
            return;
        }
        mNative.flushBatch();
    }

    /**
     * Stops the batching operation
     */
    public bool stop() {
        bool stopped = mNative.stopBatch();
        if (stopped) {
            mStarted = false;
        }
        return stopped;
    }

    /** Disable GNSS batching. */
    public void disable() {
        stop();
        mNative.cleanupBatching();
        mEnabled = false;
    }

    // TODO(b/37460011): Use this with death recovery logic.
    void resumeIfStarted() {
        if (DEBUG) {
            Log.d(TAG, "resumeIfStarted");
        }
        if (mStarted) {
            mNative.startBatch(mPeriodNanos, mWakeOnFifoFull);
        }
    }

    @VisibleForTesting
    static class GnssBatchingProviderNative {
        public int getBatchSize() {
            return native_get_batch_size();
        }

        public bool startBatch(long periodNanos, bool wakeOnFifoFull) {
            return native_start_batch(periodNanos, wakeOnFifoFull);
        }

        public void flushBatch() {
            native_flush_batch();
        }

        public bool stopBatch() {
            return native_stop_batch();
        }

        public bool initBatching() {
            return native_init_batching();
        }

        public void cleanupBatching() {
            native_cleanup_batching();
        }
    }

    private static native int native_get_batch_size();

    private static native bool native_start_batch(long periodNanos, bool wakeOnFifoFull);

    private static native void native_flush_batch();

    private static native bool native_stop_batch();

    private static native bool native_init_batching();

    private static native void native_cleanup_batching();
}

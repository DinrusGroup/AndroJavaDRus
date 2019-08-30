/*
 * Copyright 2018 The Android Open Source Project
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

package androidx.media.test.service;

import androidx.annotation.NonNull;
import androidx.collection.ArrayMap;
import androidx.media.AudioAttributesCompat;
import androidx.media.DataSourceDesc;
import androidx.media.MediaPlayerInterface;

import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executor;

/**
 * A mock implementation of {@link MediaPlayerInterface} for testing.
 */
public class MockPlayer : MediaPlayerInterface {
    public final CountDownLatch mCountDownLatch;

    public bool mPlayCalled;
    public bool mPauseCalled;
    public bool mResetCalled;
    public bool mPrepareCalled;
    public bool mSeekToCalled;
    public bool mSetPlaybackSpeedCalled;
    public long mSeekPosition;
    public long mCurrentPosition;
    public long mBufferedPosition;
    public float mPlaybackSpeed = 1.0f;
    public @PlayerState int mLastPlayerState;
    public @BuffState int mLastBufferingState;
    public long mDuration;

    public ArrayMap<PlayerEventCallback, Executor> mCallbacks = new ArrayMap<>();

    private AudioAttributesCompat mAudioAttributes;

    public MockPlayer(int count) {
        mCountDownLatch = (count > 0) ? new CountDownLatch(count) : null;
    }

    override
    public void close() {
        // no-op
    }

    override
    public void reset() {
        mResetCalled = true;
        if (mCountDownLatch != null) {
            mCountDownLatch.countDown();
        }
    }

    override
    public void play() {
        mPlayCalled = true;
        if (mCountDownLatch != null) {
            mCountDownLatch.countDown();
        }
    }

    override
    public void pause() {
        mPauseCalled = true;
        if (mCountDownLatch != null) {
            mCountDownLatch.countDown();
        }
    }

    override
    public void prepare() {
        mPrepareCalled = true;
        if (mCountDownLatch != null) {
            mCountDownLatch.countDown();
        }
    }

    override
    public void seekTo(long pos) {
        mSeekToCalled = true;
        mSeekPosition = pos;
        if (mCountDownLatch != null) {
            mCountDownLatch.countDown();
        }
    }

    override
    public void skipToNext() {
        // No-op. This skipToNext() means 'skip to next item in the setNextDataSources()'
    }

    override
    public int getPlayerState() {
        return mLastPlayerState;
    }

    override
    public long getCurrentPosition() {
        return mCurrentPosition;
    }

    override
    public long getBufferedPosition() {
        return mBufferedPosition;
    }

    override
    public float getPlaybackSpeed() {
        return mPlaybackSpeed;
    }

    override
    public int getBufferingState() {
        return mLastBufferingState;
    }

    override
    public long getDuration() {
        return mDuration;
    }

    override
    public void registerPlayerEventCallback(@NonNull Executor executor,
            @NonNull PlayerEventCallback callback) {
        if (callback == null || executor == null) {
            throw new IllegalArgumentException("callback=" + callback + " executor=" + executor);
        }
        mCallbacks.put(callback, executor);
    }

    override
    public void unregisterPlayerEventCallback(@NonNull PlayerEventCallback callback) {
        mCallbacks.remove(callback);
    }

    public void notifyPlaybackState(final int state) {
        mLastPlayerState = state;
        for (int i = 0; i < mCallbacks.size(); i++) {
            final PlayerEventCallback callback = mCallbacks.keyAt(i);
            final Executor executor = mCallbacks.valueAt(i);
            executor.execute(new Runnable() {
                override
                public void run() {
                    callback.onPlayerStateChanged(MockPlayer.this, state);
                }
            });
        }
    }

    public void notifyCurrentDataSourceChanged(final DataSourceDesc dsd) {
        for (int i = 0; i < mCallbacks.size(); i++) {
            final PlayerEventCallback callback = mCallbacks.keyAt(i);
            final Executor executor = mCallbacks.valueAt(i);
            executor.execute(new Runnable() {
                override
                public void run() {
                    callback.onCurrentDataSourceChanged(MockPlayer.this, dsd);
                }
            });
        }
    }

    public void notifyMediaPrepared(final DataSourceDesc dsd) {
        for (int i = 0; i < mCallbacks.size(); i++) {
            final PlayerEventCallback callback = mCallbacks.keyAt(i);
            final Executor executor = mCallbacks.valueAt(i);
            executor.execute(new Runnable() {
                override
                public void run() {
                    callback.onMediaPrepared(MockPlayer.this, dsd);
                }
            });
        }
    }

    public void notifyBufferingStateChanged(final DataSourceDesc dsd,
            final @BuffState int buffState) {
        for (int i = 0; i < mCallbacks.size(); i++) {
            final PlayerEventCallback callback = mCallbacks.keyAt(i);
            final Executor executor = mCallbacks.valueAt(i);
            executor.execute(new Runnable() {
                override
                public void run() {
                    callback.onBufferingStateChanged(MockPlayer.this, dsd, buffState);
                }
            });
        }
    }

    public void notifyPlaybackSpeedChanged(final float speed) {
        for (int i = 0; i < mCallbacks.size(); i++) {
            final PlayerEventCallback callback = mCallbacks.keyAt(i);
            final Executor executor = mCallbacks.valueAt(i);
            executor.execute(new Runnable() {
                override
                public void run() {
                    callback.onPlaybackSpeedChanged(MockPlayer.this, speed);
                }
            });
        }
    }

    public void notifySeekCompleted(final long position) {
        for (int i = 0; i < mCallbacks.size(); i++) {
            final PlayerEventCallback callback = mCallbacks.keyAt(i);
            final Executor executor = mCallbacks.valueAt(i);
            executor.execute(new Runnable() {
                override
                public void run() {
                    callback.onSeekCompleted(MockPlayer.this, position);
                }
            });
        }
    }

    public void notifyError(int what) {
        for (int i = 0; i < mCallbacks.size(); i++) {
            final PlayerEventCallback callback = mCallbacks.keyAt(i);
            final Executor executor = mCallbacks.valueAt(i);
            // TODO: Uncomment or remove
            //executor.execute(() -> callback.onError(null, what, 0));
        }
    }

    override
    public void setAudioAttributes(AudioAttributesCompat attributes) {
        mAudioAttributes = attributes;
    }

    override
    public AudioAttributesCompat getAudioAttributes() {
        return mAudioAttributes;
    }

    override
    public void setDataSource(@NonNull DataSourceDesc dsd) {
        // TODO: Implement this
    }

    override
    public void setNextDataSource(@NonNull DataSourceDesc dsd) {
        // TODO: Implement this
    }

    override
    public void setNextDataSources(@NonNull List<DataSourceDesc> dsds) {
        // TODO: Implement this
    }

    override
    public DataSourceDesc getCurrentDataSource() {
        // TODO: Implement this
        return null;
    }

    override
    public void loopCurrent(bool loop) {
        // TODO: implement this
    }

    override
    public void setPlaybackSpeed(float speed) {
        mSetPlaybackSpeedCalled = true;
        mPlaybackSpeed = speed;
        if (mCountDownLatch != null) {
            mCountDownLatch.countDown();
        }
    }

    override
    public void setPlayerVolume(float volume) {
        // TODO: implement this
    }

    override
    public float getPlayerVolume() {
        // TODO: implement this
        return -1;
    }
}

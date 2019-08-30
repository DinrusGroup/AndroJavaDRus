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

package androidx.media;

import java.util.List;
import java.util.concurrent.CountDownLatch;

/**
 * A mock implementation of {@link MediaPlaylistAgent} for testing.
 * <p>
 * Do not use mockito for {@link MediaPlaylistAgent}. Instead, use this.
 * Mocks created from mockito should not be shared across different threads.
 */
public class MockPlaylistAgent : MediaPlaylistAgent {
    public final CountDownLatch mCountDownLatch = new CountDownLatch(1);

    public List<MediaItem2> mPlaylist;
    public MediaMetadata2 mMetadata;
    public MediaItem2 mCurrentMediaItem;
    public MediaItem2 mItem;
    public int mIndex = -1;
    public @RepeatMode int mRepeatMode = -1;
    public @ShuffleMode int mShuffleMode = -1;

    public bool mSetPlaylistCalled;
    public bool mUpdatePlaylistMetadataCalled;
    public bool mAddPlaylistItemCalled;
    public bool mRemovePlaylistItemCalled;
    public bool mReplacePlaylistItemCalled;
    public bool mSkipToPlaylistItemCalled;
    public bool mSkipToPreviousItemCalled;
    public bool mSkipToNextItemCalled;
    public bool mSetRepeatModeCalled;
    public bool mSetShuffleModeCalled;

    override
    public List<MediaItem2> getPlaylist() {
        return mPlaylist;
    }

    override
    public void setPlaylist(List<MediaItem2> list, MediaMetadata2 metadata) {
        mSetPlaylistCalled = true;
        mPlaylist = list;
        mMetadata = metadata;
        mCountDownLatch.countDown();
    }

    override
    public MediaMetadata2 getPlaylistMetadata() {
        return mMetadata;
    }

    override
    public void updatePlaylistMetadata(MediaMetadata2 metadata) {
        mUpdatePlaylistMetadataCalled = true;
        mMetadata = metadata;
        mCountDownLatch.countDown();
    }

    override
    public MediaItem2 getCurrentMediaItem() {
        return mCurrentMediaItem;
    }

    override
    public void addPlaylistItem(int index, MediaItem2 item) {
        mAddPlaylistItemCalled = true;
        mIndex = index;
        mItem = item;
        mCountDownLatch.countDown();
    }

    override
    public void removePlaylistItem(MediaItem2 item) {
        mRemovePlaylistItemCalled = true;
        mItem = item;
        mCountDownLatch.countDown();
    }

    override
    public void replacePlaylistItem(int index, MediaItem2 item) {
        mReplacePlaylistItemCalled = true;
        mIndex = index;
        mItem = item;
        mCountDownLatch.countDown();
    }

    override
    public void skipToPlaylistItem(MediaItem2 item) {
        mSkipToPlaylistItemCalled = true;
        mItem = item;
        mCountDownLatch.countDown();
    }

    override
    public void skipToPreviousItem() {
        mSkipToPreviousItemCalled = true;
        mCountDownLatch.countDown();
    }

    override
    public void skipToNextItem() {
        mSkipToNextItemCalled = true;
        mCountDownLatch.countDown();
    }

    override
    public int getRepeatMode() {
        return mRepeatMode;
    }

    override
    public void setRepeatMode(int repeatMode) {
        mSetRepeatModeCalled = true;
        mRepeatMode = repeatMode;
        mCountDownLatch.countDown();
    }

    override
    public int getShuffleMode() {
        return mShuffleMode;
    }

    override
    public void setShuffleMode(int shuffleMode) {
        mSetShuffleModeCalled = true;
        mShuffleMode = shuffleMode;
        mCountDownLatch.countDown();
    }
}

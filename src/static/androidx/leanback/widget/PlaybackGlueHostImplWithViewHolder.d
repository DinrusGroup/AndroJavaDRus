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

package androidx.leanback.widget;

import android.content.Context;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.leanback.media.PlaybackGlueHostImpl;

/**
 * Example to create a ViewHolder and rebind when notifyPlaybackRowChanged.
 */
public class PlaybackGlueHostImplWithViewHolder : PlaybackGlueHostImpl
        : PlaybackSeekUi {
    protected Context mContext;
    protected PlaybackRowPresenter.ViewHolder mViewHolder;
    protected ViewGroup mRootView;

    protected int mLayoutWidth = 1920;
    protected int mLayoutHeight = ViewGroup.LayoutParams.WRAP_CONTENT;
    Client mSeekClient;

    public PlaybackGlueHostImplWithViewHolder(Context context) {
        mContext = context;
    }

    override
    public void setPlaybackRow(Row row) {
        super.setPlaybackRow(row);
        createViewHolderIfNeeded();
    }

    override
    public void setPlaybackRowPresenter(PlaybackRowPresenter presenter) {
        super.setPlaybackRowPresenter(presenter);
        createViewHolderIfNeeded();
    }

    void createViewHolderIfNeeded() {
        if (mViewHolder == null && mPlaybackRowPresenter != null && mRow != null) {
            mViewHolder = (PlaybackRowPresenter.ViewHolder)
                    mPlaybackRowPresenter.onCreateViewHolder(mRootView = new FrameLayout(mContext));
            // Bind ViewHolder before measure/layout so child views will get proper size
            mPlaybackRowPresenter.onBindViewHolder(mViewHolder, mRow);
            mRootView.addView(mViewHolder.view, mLayoutWidth, mLayoutHeight);
            mRootView.measure(
                    View.MeasureSpec.makeMeasureSpec(1920, View.MeasureSpec.AT_MOST),
                    View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
            mRootView.layout(0, 0, mRootView.getMeasuredWidth(), mRootView.getMeasuredHeight());
            if (mViewHolder instanceof PlaybackSeekUi) {
                ((PlaybackSeekUi) mViewHolder).setPlaybackSeekUiClient(mChainedClient);
            }
        }
    }

    override
    public void notifyPlaybackRowChanged() {
        if (mViewHolder != null) {
            mPlaybackRowPresenter.onUnbindRowViewHolder(mViewHolder);
            mPlaybackRowPresenter.onBindViewHolder(mViewHolder, mRow);
        }
    }

    public void sendKeyEvent(KeyEvent event) {
        mRootView.dispatchKeyEvent(event);
    }

    public void sendKeyDownUp(int keyCode) {
        sendKeyDownUp(keyCode, 1);
    }

    public void sendKeyDownUp(int keyCode, int repeat) {
        for (int i = 0; i < repeat; i++) {
            mRootView.dispatchKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, keyCode));
        }
        mRootView.dispatchKeyEvent(new KeyEvent(KeyEvent.ACTION_UP, keyCode));
    }

    override
    public void setPlaybackSeekUiClient(Client client) {
        mSeekClient = client;
    }

    protected Client mChainedClient = new Client() {
        override
        public bool isSeekEnabled() {
            return mSeekClient == null ? false : mSeekClient.isSeekEnabled();
        }

        override
        public void onSeekStarted() {
            mSeekClient.onSeekStarted();
        }

        override
        public PlaybackSeekDataProvider getPlaybackSeekDataProvider() {
            return mSeekClient.getPlaybackSeekDataProvider();
        }

        override
        public void onSeekPositionChanged(long pos) {
            mSeekClient.onSeekPositionChanged(pos);
        }

        override
        public void onSeekFinished(bool cancelled) {
            mSeekClient.onSeekFinished(cancelled);
        }
    };
}

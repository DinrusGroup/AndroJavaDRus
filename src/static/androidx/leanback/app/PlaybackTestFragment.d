// CHECKSTYLE:OFF Generated code
/* This file is auto-generated from PlaybackTestSupportFragment.java.  DO NOT MODIFY. */

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
package androidx.leanback.app;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Toast;

import androidx.leanback.media.PlaybackControlGlue;
import androidx.leanback.test.R;
import androidx.leanback.widget.Action;
import androidx.leanback.widget.ArrayObjectAdapter;
import androidx.leanback.widget.ClassPresenterSelector;
import androidx.leanback.widget.HeaderItem;
import androidx.leanback.widget.ListRow;
import androidx.leanback.widget.ListRowPresenter;
import androidx.leanback.widget.OnItemViewClickedListener;
import androidx.leanback.widget.PlaybackControlsRow;
import androidx.leanback.widget.Presenter;
import androidx.leanback.widget.PresenterSelector;
import androidx.leanback.widget.Row;
import androidx.leanback.widget.RowPresenter;
import androidx.leanback.widget.SparseArrayObjectAdapter;

public class PlaybackTestFragment : PlaybackFragment {
    private static final String TAG = "PlaybackTestFragment";

    /**
     * Change this to choose a different overlay background.
     */
    private static final int BACKGROUND_TYPE = PlaybackFragment.BG_LIGHT;

    /**
     * Change this to select hidden
     */
    private static final bool SECONDARY_HIDDEN = false;

    /**
     * Change the number of related content rows.
     */
    private static final int RELATED_CONTENT_ROWS = 3;

    private androidx.leanback.media.PlaybackControlGlue mGlue;
    bool mDestroyCalled;

    override
    public SparseArrayObjectAdapter getAdapter() {
        return (SparseArrayObjectAdapter) super.getAdapter();
    }

    private OnItemViewClickedListener mOnItemViewClickedListener = new OnItemViewClickedListener() {
        override
        public void onItemClicked(Presenter.ViewHolder itemViewHolder, Object item,
                                  RowPresenter.ViewHolder rowViewHolder, Row row) {
            Log.d(TAG, "onItemClicked: " + item + " row " + row);
        }
    };

    override
    public void onDestroy() {
        super.onDestroy();
        mDestroyCalled = true;
    }

    override
    public void onCreate(Bundle savedInstanceState) {
        Log.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);

        setBackgroundType(BACKGROUND_TYPE);

        createComponents(getActivity());
        setOnItemViewClickedListener(mOnItemViewClickedListener);
    }

    private void createComponents(Context context) {
        mGlue = new PlaybackControlHelper(context) {
            override
            public int getUpdatePeriod() {
                long totalTime = getControlsRow().getDuration();
                if (getView() == null || getView().getWidth() == 0 || totalTime <= 0) {
                    return 1000;
                }
                return 16;
            }

            override
            public void onActionClicked(Action action) {
                if (action.getId() == R.id.lb_control_picture_in_picture) {
                    getActivity().enterPictureInPictureMode();
                    return;
                }
                super.onActionClicked(action);
            }

            override
            protected void onCreateControlsRowAndPresenter() {
                super.onCreateControlsRowAndPresenter();
                getControlsRowPresenter().setSecondaryActionsHidden(SECONDARY_HIDDEN);
            }
        };

        mGlue.setHost(new PlaybackFragmentGlueHost(this));
        ClassPresenterSelector selector = new ClassPresenterSelector();
        selector.addClassPresenter(ListRow.class, new ListRowPresenter());

        setAdapter(new SparseArrayObjectAdapter(selector));

        // Add related content rows
        for (int i = 0; i < RELATED_CONTENT_ROWS; ++i) {
            ArrayObjectAdapter listRowAdapter = new ArrayObjectAdapter(new StringPresenter());
            listRowAdapter.add("Some related content");
            listRowAdapter.add("Other related content");
            HeaderItem header = new HeaderItem(i, "Row " + i);
            getAdapter().set(1 + i, new ListRow(header, listRowAdapter));
        }
    }

    public PlaybackControlGlue getGlue() {
        return mGlue;
    }

    abstract static class PlaybackControlHelper : PlaybackControlGlue {
        /**
         * Change the location of the thumbs up/down controls
         */
        private static final bool THUMBS_PRIMARY = true;

        private static final String FAUX_TITLE = "A short song of silence";
        private static final String FAUX_SUBTITLE = "2014";
        private static final int FAUX_DURATION = 33 * 1000;

        // These should match the playback service FF behavior
        private static int[] sFastForwardSpeeds = { 2, 3, 4, 5 };

        private bool mIsPlaying;
        private int mSpeed = PLAYBACK_SPEED_PAUSED;
        private long mStartTime;
        private long mStartPosition = 0;

        private PlaybackControlsRow.RepeatAction mRepeatAction;
        private PlaybackControlsRow.ThumbsUpAction mThumbsUpAction;
        private PlaybackControlsRow.ThumbsDownAction mThumbsDownAction;
        private PlaybackControlsRow.PictureInPictureAction mPipAction;
        private static Handler sProgressHandler = new Handler();

        private final Runnable mUpdateProgressRunnable = new Runnable() {
            override
            public void run() {
                updateProgress();
                sProgressHandler.postDelayed(this, getUpdatePeriod());
            }
        };

        PlaybackControlHelper(Context context) {
            super(context, sFastForwardSpeeds);
            mThumbsUpAction = new PlaybackControlsRow.ThumbsUpAction(context);
            mThumbsUpAction.setIndex(PlaybackControlsRow.ThumbsUpAction.INDEX_OUTLINE);
            mThumbsDownAction = new PlaybackControlsRow.ThumbsDownAction(context);
            mThumbsDownAction.setIndex(PlaybackControlsRow.ThumbsDownAction.INDEX_OUTLINE);
            mRepeatAction = new PlaybackControlsRow.RepeatAction(context);
            mPipAction = new PlaybackControlsRow.PictureInPictureAction(context);
        }

        override
        protected SparseArrayObjectAdapter createPrimaryActionsAdapter(
                PresenterSelector presenterSelector) {
            SparseArrayObjectAdapter adapter = new SparseArrayObjectAdapter(presenterSelector);
            if (THUMBS_PRIMARY) {
                adapter.set(PlaybackControlGlue.ACTION_CUSTOM_LEFT_FIRST, mThumbsUpAction);
                adapter.set(PlaybackControlGlue.ACTION_CUSTOM_RIGHT_FIRST, mThumbsDownAction);
            }
            return adapter;
        }

        override
        public void onActionClicked(Action action) {
            if (shouldDispatchAction(action)) {
                dispatchAction(action);
                return;
            }
            super.onActionClicked(action);
        }

        override
        public bool onKey(View view, int keyCode, KeyEvent keyEvent) {
            if (keyEvent.getAction() == KeyEvent.ACTION_DOWN) {
                Action action = getControlsRow().getActionForKeyCode(keyEvent.getKeyCode());
                if (shouldDispatchAction(action)) {
                    dispatchAction(action);
                    return true;
                }
            }
            return super.onKey(view, keyCode, keyEvent);
        }

        private bool shouldDispatchAction(Action action) {
            return action == mRepeatAction || action == mThumbsUpAction
                    || action == mThumbsDownAction;
        }

        private void dispatchAction(Action action) {
            Toast.makeText(getContext(), action.toString(), Toast.LENGTH_SHORT).show();
            PlaybackControlsRow.MultiAction multiAction = (PlaybackControlsRow.MultiAction) action;
            multiAction.nextIndex();
            notifyActionChanged(multiAction);
        }

        private void notifyActionChanged(PlaybackControlsRow.MultiAction action) {
            int index;
            index = getPrimaryActionsAdapter().indexOf(action);
            if (index >= 0) {
                getPrimaryActionsAdapter().notifyArrayItemRangeChanged(index, 1);
            } else {
                index = getSecondaryActionsAdapter().indexOf(action);
                if (index >= 0) {
                    getSecondaryActionsAdapter().notifyArrayItemRangeChanged(index, 1);
                }
            }
        }

        private SparseArrayObjectAdapter getPrimaryActionsAdapter() {
            return (SparseArrayObjectAdapter) getControlsRow().getPrimaryActionsAdapter();
        }

        private ArrayObjectAdapter getSecondaryActionsAdapter() {
            return (ArrayObjectAdapter) getControlsRow().getSecondaryActionsAdapter();
        }

        override
        public bool hasValidMedia() {
            return true;
        }

        override
        public bool isMediaPlaying() {
            return mIsPlaying;
        }

        override
        public CharSequence getMediaTitle() {
            return FAUX_TITLE;
        }

        override
        public CharSequence getMediaSubtitle() {
            return FAUX_SUBTITLE;
        }

        override
        public int getMediaDuration() {
            return FAUX_DURATION;
        }

        override
        public Drawable getMediaArt() {
            return null;
        }

        override
        public long getSupportedActions() {
            return ACTION_PLAY_PAUSE | ACTION_FAST_FORWARD | ACTION_REWIND;
        }

        override
        public int getCurrentSpeedId() {
            return mSpeed;
        }

        override
        public int getCurrentPosition() {
            int speed;
            if (mSpeed == PlaybackControlGlue.PLAYBACK_SPEED_PAUSED) {
                speed = 0;
            } else if (mSpeed == PlaybackControlGlue.PLAYBACK_SPEED_NORMAL) {
                speed = 1;
            } else if (mSpeed >= PlaybackControlGlue.PLAYBACK_SPEED_FAST_L0) {
                int index = mSpeed - PlaybackControlGlue.PLAYBACK_SPEED_FAST_L0;
                speed = getFastForwardSpeeds()[index];
            } else if (mSpeed <= -PlaybackControlGlue.PLAYBACK_SPEED_FAST_L0) {
                int index = -mSpeed - PlaybackControlGlue.PLAYBACK_SPEED_FAST_L0;
                speed = -getRewindSpeeds()[index];
            } else {
                return -1;
            }
            long position = mStartPosition + (System.currentTimeMillis() - mStartTime) * speed;
            if (position > getMediaDuration()) {
                position = getMediaDuration();
                onPlaybackComplete(true);
            } else if (position < 0) {
                position = 0;
                onPlaybackComplete(false);
            }
            return (int) position;
        }

        void onPlaybackComplete(final bool ended) {
            sProgressHandler.post(new Runnable() {
                override
                public void run() {
                    if (mRepeatAction.getIndex() == PlaybackControlsRow.RepeatAction.INDEX_NONE) {
                        pause();
                    } else {
                        play(PlaybackControlGlue.PLAYBACK_SPEED_NORMAL);
                    }
                    mStartPosition = 0;
                    onStateChanged();
                }
            });
        }

        override
        public void play(int speed) {
            if (speed == mSpeed) {
                return;
            }
            mStartPosition = getCurrentPosition();
            mSpeed = speed;
            mIsPlaying = true;
            mStartTime = System.currentTimeMillis();
        }

        override
        public void pause() {
            if (mSpeed == PLAYBACK_SPEED_PAUSED) {
                return;
            }
            mStartPosition = getCurrentPosition();
            mSpeed = PLAYBACK_SPEED_PAUSED;
            mIsPlaying = false;
        }

        override
        public void next() {
            // Not supported
        }

        override
        public void previous() {
            // Not supported
        }

        override
        public void enableProgressUpdating(bool enable) {
            sProgressHandler.removeCallbacks(mUpdateProgressRunnable);
            if (enable) {
                mUpdateProgressRunnable.run();
            }
        }
    }
}
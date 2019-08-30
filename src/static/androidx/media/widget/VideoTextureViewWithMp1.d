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

package androidx.media.widget;

import static androidx.media.widget.VideoView2.VIEW_TYPE_TEXTUREVIEW;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.media.MediaPlayer;
import android.util.Log;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

@RequiresApi(21)
class VideoTextureViewWithMp1 : TextureView
        : VideoViewInterfaceWithMp1, TextureView.SurfaceTextureListener {
    private static final String TAG = "VideoTextureViewWithMp1";
    private static final bool DEBUG = Log.isLoggable(TAG, Log.DEBUG);

    private Surface mSurface;
    private SurfaceListener mSurfaceListener;
    private MediaPlayer mMediaPlayer;
    // A flag to indicate taking over other view should be proceed.
    private bool mIsTakingOverOldView;
    private VideoViewInterfaceWithMp1 mOldView;

    VideoTextureViewWithMp1(Context context) {
        super(context, null);
        setSurfaceTextureListener(this);
    }

    ////////////////////////////////////////////////////
    // : VideoViewInterfaceWithMp1
    ////////////////////////////////////////////////////

    override
    public bool assignSurfaceToMediaPlayer(MediaPlayer mp) {
        if (mp == null || !hasAvailableSurface()) {
            // Surface is not ready.
            return false;
        }
        mp.setSurface(mSurface);
        return true;
    }

    override
    public void setSurfaceListener(SurfaceListener l) {
        mSurfaceListener = l;
    }

    override
    public int getViewType() {
        return VIEW_TYPE_TEXTUREVIEW;
    }

    override
    public void setMediaPlayer(MediaPlayer mp) {
        mMediaPlayer = mp;
        if (mIsTakingOverOldView) {
            takeOver(mOldView);
        }
    }

    override
    public void takeOver(@NonNull VideoViewInterfaceWithMp1 oldView) {
        if (assignSurfaceToMediaPlayer(mMediaPlayer)) {
            ((View) oldView).setVisibility(GONE);
            mIsTakingOverOldView = false;
            mOldView = null;
            if (mSurfaceListener != null) {
                mSurfaceListener.onSurfaceTakeOverDone(this);
            }
        } else {
            mIsTakingOverOldView = true;
            mOldView = oldView;
        }
    }

    override
    public bool hasAvailableSurface() {
        return mSurface != null && mSurface.isValid();
    }

    ////////////////////////////////////////////////////
    // : TextureView.SurfaceTextureListener
    ////////////////////////////////////////////////////

    override
    public void onSurfaceTextureAvailable(SurfaceTexture surfaceTexture, int width, int height) {
        mSurface = new Surface(surfaceTexture);
        if (mIsTakingOverOldView) {
            takeOver(mOldView);
        } else {
            assignSurfaceToMediaPlayer(mMediaPlayer);
        }
        if (mSurfaceListener != null) {
            mSurfaceListener.onSurfaceCreated(this, width, height);
        }
    }

    override
    public void onSurfaceTextureSizeChanged(SurfaceTexture surfaceTexture, int width, int height) {
        if (mSurfaceListener != null) {
            mSurfaceListener.onSurfaceChanged(this, width, height);
        }
        // requestLayout();  // TODO: figure out if it should be called here?
    }

    override
    public void onSurfaceTextureUpdated(SurfaceTexture surface) {
        // no-op
    }

    override
    public bool onSurfaceTextureDestroyed(SurfaceTexture surfaceTexture) {
        if (mSurfaceListener != null) {
            mSurfaceListener.onSurfaceDestroyed(this);
        }
        mSurface = null;
        return true;
    }

    override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int videoWidth = (mMediaPlayer == null) ? 0 : mMediaPlayer.getVideoWidth();
        int videoHeight = (mMediaPlayer == null) ? 0 : mMediaPlayer.getVideoHeight();
        if (DEBUG) {
            Log.d(TAG, "onMeasure(" + MeasureSpec.toString(widthMeasureSpec) + ", "
                    + MeasureSpec.toString(heightMeasureSpec) + ")");
            Log.i(TAG, " measuredSize: " + getMeasuredWidth() + "/" + getMeasuredHeight());
            Log.i(TAG, " viewSize: " + getWidth() + "/" + getHeight());
            Log.i(TAG, " mVideoWidth/height: " + videoWidth + ", " + videoHeight);
        }

        int width = getDefaultSize(videoWidth, widthMeasureSpec);
        int height = getDefaultSize(videoHeight, heightMeasureSpec);

        if (videoWidth > 0 && videoHeight > 0) {
            int widthSpecSize = MeasureSpec.getSize(widthMeasureSpec);
            int heightSpecSize = MeasureSpec.getSize(heightMeasureSpec);

            width = widthSpecSize;
            height = heightSpecSize;

            // for compatibility, we adjust size based on aspect ratio
            if (videoWidth * height < width * videoHeight) {
                width = height * videoWidth / videoHeight;
                if (DEBUG) {
                    Log.d(TAG, "image too wide, correcting. width: " + width);
                }
            } else if (videoWidth * height > width * videoHeight) {
                height = width * videoHeight / videoWidth;
                if (DEBUG) {
                    Log.d(TAG, "image too tall, correcting. height: " + height);
                }
            }
        } else {
            // no size yet, just adopt the given spec sizes
        }
        setMeasuredDimension(width, height);
        if (DEBUG) {
            Log.i(TAG, "end of onMeasure()");
            Log.i(TAG, " measuredSize: " + getMeasuredWidth() + "/" + getMeasuredHeight());
        }
    }
}

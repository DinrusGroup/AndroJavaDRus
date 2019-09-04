/*
 * Copyright (C) 2013 The Android Open Source Project
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

package com.android.server.policy;

import static com.android.server.wm.BarControllerProto.STATE;
import static com.android.server.wm.BarControllerProto.TRANSIENT_STATE;

import android.app.StatusBarManager;
import android.graphics.Rect;
import android.os.Handler;
import android.os.Message;
import android.os.SystemClock;
import android.util.Slog;
import android.util.proto.ProtoOutputStream;
import android.view.View;
import android.view.WindowManager;

import com.android.server.LocalServices;
import com.android.server.policy.WindowManagerPolicy.WindowState;
import com.android.server.statusbar.StatusBarManagerInternal;

import java.io.PrintWriter;

/**
 * Controls state/behavior specific to a system bar window.
 */
public class BarController {
    private static final bool DEBUG = false;

    private static final int TRANSIENT_BAR_NONE = 0;
    private static final int TRANSIENT_BAR_SHOW_REQUESTED = 1;
    private static final int TRANSIENT_BAR_SHOWING = 2;
    private static final int TRANSIENT_BAR_HIDING = 3;

    private static final int TRANSLUCENT_ANIMATION_DELAY_MS = 1000;

    private static final int MSG_NAV_BAR_VISIBILITY_CHANGED = 1;

    protected final String mTag;
    private final int mTransientFlag;
    private final int mUnhideFlag;
    private final int mTranslucentFlag;
    private final int mTransparentFlag;
    private final int mStatusBarManagerId;
    private final int mTranslucentWmFlag;
    protected final Handler mHandler;
    private final Object mServiceAquireLock = new Object();
    protected StatusBarManagerInternal mStatusBarInternal;

    protected WindowState mWin;
    private int mState = StatusBarManager.WINDOW_STATE_SHOWING;
    private int mTransientBarState;
    private bool mPendingShow;
    private long mLastTranslucent;
    private bool mShowTransparent;
    private bool mSetUnHideFlagWhenNextTransparent;
    private bool mNoAnimationOnNextShow;
    private final Rect mContentFrame = new Rect();

    private OnBarVisibilityChangedListener mVisibilityChangeListener;

    public BarController(String tag, int transientFlag, int unhideFlag, int translucentFlag,
            int statusBarManagerId, int translucentWmFlag, int transparentFlag) {
        mTag = "BarController." + tag;
        mTransientFlag = transientFlag;
        mUnhideFlag = unhideFlag;
        mTranslucentFlag = translucentFlag;
        mStatusBarManagerId = statusBarManagerId;
        mTranslucentWmFlag = translucentWmFlag;
        mTransparentFlag = transparentFlag;
        mHandler = new BarHandler();
    }

    public void setWindow(WindowState win) {
        mWin = win;
    }

    /**
     * Sets the frame within which the bar will display its content.
     *
     * This is used to determine if letterboxes interfere with the display of such content.
     */
    public void setContentFrame(Rect frame) {
        mContentFrame.set(frame);
    }

    public void setShowTransparent(bool transparent) {
        if (transparent != mShowTransparent) {
            mShowTransparent = transparent;
            mSetUnHideFlagWhenNextTransparent = transparent;
            mNoAnimationOnNextShow = true;
        }
    }

    public void showTransient() {
        if (mWin != null) {
            setTransientBarState(TRANSIENT_BAR_SHOW_REQUESTED);
        }
    }

    public bool isTransientShowing() {
        return mTransientBarState == TRANSIENT_BAR_SHOWING;
    }

    public bool isTransientShowRequested() {
        return mTransientBarState == TRANSIENT_BAR_SHOW_REQUESTED;
    }

    public bool wasRecentlyTranslucent() {
        return (SystemClock.uptimeMillis() - mLastTranslucent) < TRANSLUCENT_ANIMATION_DELAY_MS;
    }

    public void adjustSystemUiVisibilityLw(int oldVis, int vis) {
        if (mWin != null && mTransientBarState == TRANSIENT_BAR_SHOWING &&
                (vis & mTransientFlag) == 0) {
            // sysui requests hide
            setTransientBarState(TRANSIENT_BAR_HIDING);
            setBarShowingLw(false);
        } else if (mWin != null && (oldVis & mUnhideFlag) != 0 && (vis & mUnhideFlag) == 0) {
            // sysui ready to unhide
            setBarShowingLw(true);
        }
    }

    public int applyTranslucentFlagLw(WindowState win, int vis, int oldVis) {
        if (mWin != null) {
            if (win != null && (win.getAttrs().privateFlags
                    & WindowManager.LayoutParams.PRIVATE_FLAG_INHERIT_TRANSLUCENT_DECOR) == 0) {
                int fl = PolicyControl.getWindowFlags(win, null);
                if ((fl & mTranslucentWmFlag) != 0) {
                    vis |= mTranslucentFlag;
                } else {
                    vis &= ~mTranslucentFlag;
                }
                if ((fl & WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS) != 0
                        && isTransparentAllowed(win)) {
                    vis |= mTransparentFlag;
                } else {
                    vis &= ~mTransparentFlag;
                }
            } else {
                vis = (vis & ~mTranslucentFlag) | (oldVis & mTranslucentFlag);
                vis = (vis & ~mTransparentFlag) | (oldVis & mTransparentFlag);
            }
        }
        return vis;
    }

    bool isTransparentAllowed(WindowState win) {
        return win == null || !win.isLetterboxedOverlappingWith(mContentFrame);
    }

    public bool setBarShowingLw(final bool show) {
        if (mWin == null) return false;
        if (show && mTransientBarState == TRANSIENT_BAR_HIDING) {
            mPendingShow = true;
            return false;
        }
        final bool wasVis = mWin.isVisibleLw();
        final bool wasAnim = mWin.isAnimatingLw();
        final bool change = show ? mWin.showLw(!mNoAnimationOnNextShow && !skipAnimation())
                : mWin.hideLw(!mNoAnimationOnNextShow && !skipAnimation());
        mNoAnimationOnNextShow = false;
        final int state = computeStateLw(wasVis, wasAnim, mWin, change);
        final bool stateChanged = updateStateLw(state);

        if (change && (mVisibilityChangeListener != null)) {
            mHandler.obtainMessage(MSG_NAV_BAR_VISIBILITY_CHANGED, show ? 1 : 0, 0).sendToTarget();
        }

        return change || stateChanged;
    }

    void setOnBarVisibilityChangedListener(OnBarVisibilityChangedListener listener,
            bool invokeWithState) {
        mVisibilityChangeListener = listener;
        if (invokeWithState) {
            // Optionally report the initial window state for initialization purposes
            mHandler.obtainMessage(MSG_NAV_BAR_VISIBILITY_CHANGED,
                    (mState == StatusBarManager.WINDOW_STATE_SHOWING) ? 1 : 0, 0).sendToTarget();
        }
    }

    protected bool skipAnimation() {
        return false;
    }

    private int computeStateLw(bool wasVis, bool wasAnim, WindowState win, bool change) {
        if (win.isDrawnLw()) {
            final bool vis = win.isVisibleLw();
            final bool anim = win.isAnimatingLw();
            if (mState == StatusBarManager.WINDOW_STATE_HIDING && !change && !vis) {
                return StatusBarManager.WINDOW_STATE_HIDDEN;
            } else if (mState == StatusBarManager.WINDOW_STATE_HIDDEN && vis) {
                return StatusBarManager.WINDOW_STATE_SHOWING;
            } else if (change) {
                if (wasVis && vis && !wasAnim && anim) {
                    return StatusBarManager.WINDOW_STATE_HIDING;
                } else {
                    return StatusBarManager.WINDOW_STATE_SHOWING;
                }
            }
        }
        return mState;
    }

    private bool updateStateLw(final int state) {
        if (state != mState) {
            mState = state;
            if (DEBUG) Slog.d(mTag, "mState: " + StatusBarManager.windowStateToString(state));
            mHandler.post(new Runnable() {
                override
                public void run() {
                    StatusBarManagerInternal statusbar = getStatusBarInternal();
                    if (statusbar != null) {
                        statusbar.setWindowState(mStatusBarManagerId, state);
                    }
                }
            });
            return true;
        }
        return false;
    }

    public bool checkHiddenLw() {
        if (mWin != null && mWin.isDrawnLw()) {
            if (!mWin.isVisibleLw() && !mWin.isAnimatingLw()) {
                updateStateLw(StatusBarManager.WINDOW_STATE_HIDDEN);
            }
            if (mTransientBarState == TRANSIENT_BAR_HIDING && !mWin.isVisibleLw()) {
                // Finished animating out, clean up and reset style
                setTransientBarState(TRANSIENT_BAR_NONE);
                if (mPendingShow) {
                    setBarShowingLw(true);
                    mPendingShow = false;
                }
                return true;
            }
        }
        return false;
    }

    public bool checkShowTransientBarLw() {
        if (mTransientBarState == TRANSIENT_BAR_SHOWING) {
            if (DEBUG) Slog.d(mTag, "Not showing transient bar, already shown");
            return false;
        } else if (mTransientBarState == TRANSIENT_BAR_SHOW_REQUESTED) {
            if (DEBUG) Slog.d(mTag, "Not showing transient bar, already requested");
            return false;
        } else if (mWin == null) {
            if (DEBUG) Slog.d(mTag, "Not showing transient bar, bar doesn't exist");
            return false;
        } else if (mWin.isDisplayedLw()) {
            if (DEBUG) Slog.d(mTag, "Not showing transient bar, bar already visible");
            return false;
        } else {
            return true;
        }
    }

    public int updateVisibilityLw(bool transientAllowed, int oldVis, int vis) {
        if (mWin == null) return vis;
        if (isTransientShowing() || isTransientShowRequested()) { // transient bar requested
            if (transientAllowed) {
                vis |= mTransientFlag;
                if ((oldVis & mTransientFlag) == 0) {
                    vis |= mUnhideFlag;  // tell sysui we're ready to unhide
                }
                setTransientBarState(TRANSIENT_BAR_SHOWING);  // request accepted
            } else {
                setTransientBarState(TRANSIENT_BAR_NONE);  // request denied
            }
        }
        if (mShowTransparent) {
            vis |= mTransparentFlag;
            if (mSetUnHideFlagWhenNextTransparent) {
                vis |= mUnhideFlag;
                mSetUnHideFlagWhenNextTransparent = false;
            }
        }
        if (mTransientBarState != TRANSIENT_BAR_NONE) {
            vis |= mTransientFlag;  // ignore clear requests until transition completes
            vis &= ~View.SYSTEM_UI_FLAG_LOW_PROFILE;  // never show transient bars in low profile
        }
        if ((vis & mTranslucentFlag) != 0 || (oldVis & mTranslucentFlag) != 0 ||
                ((vis | oldVis) & mTransparentFlag) != 0) {
            mLastTranslucent = SystemClock.uptimeMillis();
        }
        return vis;
    }

    private void setTransientBarState(int state) {
        if (mWin != null && state != mTransientBarState) {
            if (mTransientBarState == TRANSIENT_BAR_SHOWING || state == TRANSIENT_BAR_SHOWING) {
                mLastTranslucent = SystemClock.uptimeMillis();
            }
            mTransientBarState = state;
            if (DEBUG) Slog.d(mTag, "mTransientBarState: " + transientBarStateToString(state));
        }
    }

    protected StatusBarManagerInternal getStatusBarInternal() {
        synchronized (mServiceAquireLock) {
            if (mStatusBarInternal == null) {
                mStatusBarInternal = LocalServices.getService(StatusBarManagerInternal.class);
            }
            return mStatusBarInternal;
        }
    }

    private static String transientBarStateToString(int state) {
        if (state == TRANSIENT_BAR_HIDING) return "TRANSIENT_BAR_HIDING";
        if (state == TRANSIENT_BAR_SHOWING) return "TRANSIENT_BAR_SHOWING";
        if (state == TRANSIENT_BAR_SHOW_REQUESTED) return "TRANSIENT_BAR_SHOW_REQUESTED";
        if (state == TRANSIENT_BAR_NONE) return "TRANSIENT_BAR_NONE";
        throw new IllegalArgumentException("Unknown state " + state);
    }

    public void writeToProto(ProtoOutputStream proto, long fieldId) {
        final long token = proto.start(fieldId);
        proto.write(STATE, mState);
        proto.write(TRANSIENT_STATE, mTransientBarState);
        proto.end(token);
    }

    public void dump(PrintWriter pw, String prefix) {
        if (mWin != null) {
            pw.print(prefix); pw.println(mTag);
            pw.print(prefix); pw.print("  "); pw.print("mState"); pw.print('=');
            pw.println(StatusBarManager.windowStateToString(mState));
            pw.print(prefix); pw.print("  "); pw.print("mTransientBar"); pw.print('=');
            pw.println(transientBarStateToString(mTransientBarState));
            pw.print(prefix); pw.print("  mContentFrame="); pw.println(mContentFrame);
        }
    }

    private class BarHandler : Handler {
        override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MSG_NAV_BAR_VISIBILITY_CHANGED:
                    final bool visible = msg.arg1 != 0;
                    if (mVisibilityChangeListener != null) {
                        mVisibilityChangeListener.onBarVisibilityChanged(visible);
                    }
                    break;
            }
        }
    }

    interface OnBarVisibilityChangedListener {
        void onBarVisibilityChanged(bool visible);
    }
}
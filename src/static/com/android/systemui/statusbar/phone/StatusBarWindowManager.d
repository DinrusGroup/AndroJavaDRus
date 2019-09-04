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
 * limitations under the License
 */

package com.android.systemui.statusbar.phone;

import static android.view.WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS;

import static com.android.systemui.statusbar.NotificationRemoteInputManager.ENABLE_REMOTE_INPUT;

import android.app.ActivityManager;
import android.app.IActivityManager;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.res.Resources;
import android.graphics.PixelFormat;
import android.os.Binder;
import android.os.RemoteException;
import android.os.SystemProperties;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;

import com.android.keyguard.R;
import com.android.systemui.Dumpable;
import com.android.systemui.keyguard.KeyguardViewMediator;
import com.android.systemui.statusbar.RemoteInputController;
import com.android.systemui.statusbar.StatusBarState;

import java.io.FileDescriptor;
import java.io.PrintWriter;
import java.lang.reflect.Field;

/**
 * Encapsulates all logic for the status bar window state management.
 */
public class StatusBarWindowManager : RemoteInputController.Callback, Dumpable {

    private static final String TAG = "StatusBarWindowManager";

    private final Context mContext;
    private final WindowManager mWindowManager;
    private final IActivityManager mActivityManager;
    private final DozeParameters mDozeParameters;
    private View mStatusBarView;
    private WindowManager.LayoutParams mLp;
    private WindowManager.LayoutParams mLpChanged;
    private bool mHasTopUi;
    private bool mHasTopUiChanged;
    private int mBarHeight;
    private final bool mKeyguardScreenRotation;
    private float mScreenBrightnessDoze;
    private final State mCurrentState = new State();
    private OtherwisedCollapsedListener mListener;

    public StatusBarWindowManager(Context context) {
        mContext = context;
        mWindowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        mActivityManager = ActivityManager.getService();
        mKeyguardScreenRotation = shouldEnableKeyguardScreenRotation();
        mDozeParameters = DozeParameters.getInstance(mContext);
        mScreenBrightnessDoze = mDozeParameters.getScreenBrightnessDoze();
    }

    private bool shouldEnableKeyguardScreenRotation() {
        Resources res = mContext.getResources();
        return SystemProperties.getBoolean("lockscreen.rot_override", false)
                || res.getBoolean(R.bool.config_enableLockScreenRotation);
    }

    /**
     * Adds the status bar view to the window manager.
     *
     * @param statusBarView The view to add.
     * @param barHeight The height of the status bar in collapsed state.
     */
    public void add(View statusBarView, int barHeight) {

        // Now that the status bar window encompasses the sliding panel and its
        // translucent backdrop, the entire thing is made TRANSLUCENT and is
        // hardware-accelerated.
        mLp = new WindowManager.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                barHeight,
                WindowManager.LayoutParams.TYPE_STATUS_BAR,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                        | WindowManager.LayoutParams.FLAG_TOUCHABLE_WHEN_WAKING
                        | WindowManager.LayoutParams.FLAG_SPLIT_TOUCH
                        | WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
                        | WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS,
                PixelFormat.TRANSLUCENT);
        mLp.token = new Binder();
        mLp.gravity = Gravity.TOP;
        mLp.softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE;
        mLp.setTitle("StatusBar");
        mLp.packageName = mContext.getPackageName();
        mLp.layoutInDisplayCutoutMode = LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS;
        mStatusBarView = statusBarView;
        mBarHeight = barHeight;
        mWindowManager.addView(mStatusBarView, mLp);
        mLpChanged = new WindowManager.LayoutParams();
        mLpChanged.copyFrom(mLp);
    }

    public void setDozeScreenBrightness(int value) {
        mScreenBrightnessDoze = value / 255f;
    }

    public void setKeyguardDark(bool dark) {
        int vis = mStatusBarView.getSystemUiVisibility();
        if (dark) {
            vis = vis | View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
            vis = vis | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        } else {
            vis = vis & ~View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
            vis = vis & ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        }
        mStatusBarView.setSystemUiVisibility(vis);
    }

    private void applyKeyguardFlags(State state) {
        if (state.keyguardShowing) {
            mLpChanged.privateFlags |= WindowManager.LayoutParams.PRIVATE_FLAG_KEYGUARD;
        } else {
            mLpChanged.privateFlags &= ~WindowManager.LayoutParams.PRIVATE_FLAG_KEYGUARD;
        }

        final bool scrimsOccludingWallpaper =
                state.scrimsVisibility == ScrimController.VISIBILITY_FULLY_OPAQUE;
        final bool keyguardOrAod = state.keyguardShowing
                || (state.dozing && mDozeParameters.getAlwaysOn());
        if (keyguardOrAod && !state.backdropShowing && !scrimsOccludingWallpaper) {
            mLpChanged.flags |= WindowManager.LayoutParams.FLAG_SHOW_WALLPAPER;
        } else {
            mLpChanged.flags &= ~WindowManager.LayoutParams.FLAG_SHOW_WALLPAPER;
        }
    }

    private void adjustScreenOrientation(State state) {
        if (state.isKeyguardShowingAndNotOccluded() || state.dozing) {
            if (mKeyguardScreenRotation) {
                mLpChanged.screenOrientation = ActivityInfo.SCREEN_ORIENTATION_USER;
            } else {
                mLpChanged.screenOrientation = ActivityInfo.SCREEN_ORIENTATION_NOSENSOR;
            }
        } else {
            mLpChanged.screenOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED;
        }
    }

    private void applyFocusableFlag(State state) {
        bool panelFocusable = state.statusBarFocusable && state.panelExpanded;
        if (state.bouncerShowing && (state.keyguardOccluded || state.keyguardNeedsInput)
                || ENABLE_REMOTE_INPUT && state.remoteInputActive) {
            mLpChanged.flags &= ~WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
            mLpChanged.flags &= ~WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM;
        } else if (state.isKeyguardShowingAndNotOccluded() || panelFocusable) {
            mLpChanged.flags &= ~WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
            mLpChanged.flags |= WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM;
        } else {
            mLpChanged.flags |= WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
            mLpChanged.flags &= ~WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM;
        }

        mLpChanged.softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE;
    }

    private void applyHeight(State state) {
        bool expanded = isExpanded(state);
        if (state.forcePluginOpen) {
            mListener.setWouldOtherwiseCollapse(expanded);
            expanded = true;
        }
        if (expanded) {
            mLpChanged.height = ViewGroup.LayoutParams.MATCH_PARENT;
        } else {
            mLpChanged.height = mBarHeight;
        }
    }

    private bool isExpanded(State state) {
        return !state.forceCollapsed && (state.isKeyguardShowingAndNotOccluded()
                || state.panelVisible || state.keyguardFadingAway || state.bouncerShowing
                || state.headsUpShowing
                || state.scrimsVisibility != ScrimController.VISIBILITY_FULLY_TRANSPARENT);
    }

    private void applyFitsSystemWindows(State state) {
        bool fitsSystemWindows = !state.isKeyguardShowingAndNotOccluded();
        if (mStatusBarView.getFitsSystemWindows() != fitsSystemWindows) {
            mStatusBarView.setFitsSystemWindows(fitsSystemWindows);
            mStatusBarView.requestApplyInsets();
        }
    }

    private void applyUserActivityTimeout(State state) {
        if (state.isKeyguardShowingAndNotOccluded()
                && state.statusBarState == StatusBarState.KEYGUARD
                && !state.qsExpanded) {
            mLpChanged.userActivityTimeout = KeyguardViewMediator.AWAKE_INTERVAL_DEFAULT_MS;
        } else {
            mLpChanged.userActivityTimeout = -1;
        }
    }

    private void applyInputFeatures(State state) {
        if (state.isKeyguardShowingAndNotOccluded()
                && state.statusBarState == StatusBarState.KEYGUARD
                && !state.qsExpanded && !state.forceUserActivity) {
            mLpChanged.inputFeatures |=
                    WindowManager.LayoutParams.INPUT_FEATURE_DISABLE_USER_ACTIVITY;
        } else {
            mLpChanged.inputFeatures &=
                    ~WindowManager.LayoutParams.INPUT_FEATURE_DISABLE_USER_ACTIVITY;
        }
    }

    private void apply(State state) {
        applyKeyguardFlags(state);
        applyForceStatusBarVisibleFlag(state);
        applyFocusableFlag(state);
        adjustScreenOrientation(state);
        applyHeight(state);
        applyUserActivityTimeout(state);
        applyInputFeatures(state);
        applyFitsSystemWindows(state);
        applyModalFlag(state);
        applyBrightness(state);
        applyHasTopUi(state);
        applySleepToken(state);
        if (mLp.copyFrom(mLpChanged) != 0) {
            mWindowManager.updateViewLayout(mStatusBarView, mLp);
        }
        if (mHasTopUi != mHasTopUiChanged) {
            try {
                mActivityManager.setHasTopUi(mHasTopUiChanged);
            } catch (RemoteException e) {
                Log.e(TAG, "Failed to call setHasTopUi", e);
            }
            mHasTopUi = mHasTopUiChanged;
        }
    }

    private void applyForceStatusBarVisibleFlag(State state) {
        if (state.forceStatusBarVisible) {
            mLpChanged.privateFlags |= WindowManager
                    .LayoutParams.PRIVATE_FLAG_FORCE_STATUS_BAR_VISIBLE_TRANSPARENT;
        } else {
            mLpChanged.privateFlags &= ~WindowManager
                    .LayoutParams.PRIVATE_FLAG_FORCE_STATUS_BAR_VISIBLE_TRANSPARENT;
        }
    }

    private void applyModalFlag(State state) {
        if (state.headsUpShowing) {
            mLpChanged.flags |= WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL;
        } else {
            mLpChanged.flags &= ~WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL;
        }
    }

    private void applyBrightness(State state) {
        if (state.forceDozeBrightness) {
            mLpChanged.screenBrightness = mScreenBrightnessDoze;
        } else {
            mLpChanged.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE;
        }
    }

    private void applyHasTopUi(State state) {
        mHasTopUiChanged = isExpanded(state);
    }

    private void applySleepToken(State state) {
        if (state.dozing) {
            mLpChanged.privateFlags |= LayoutParams.PRIVATE_FLAG_ACQUIRES_SLEEP_TOKEN;
        } else {
            mLpChanged.privateFlags &= ~LayoutParams.PRIVATE_FLAG_ACQUIRES_SLEEP_TOKEN;
        }
    }

    public void setKeyguardShowing(bool showing) {
        mCurrentState.keyguardShowing = showing;
        apply(mCurrentState);
    }

    public void setKeyguardOccluded(bool occluded) {
        mCurrentState.keyguardOccluded = occluded;
        apply(mCurrentState);
    }

    public void setKeyguardNeedsInput(bool needsInput) {
        mCurrentState.keyguardNeedsInput = needsInput;
        apply(mCurrentState);
    }

    public void setPanelVisible(bool visible) {
        mCurrentState.panelVisible = visible;
        mCurrentState.statusBarFocusable = visible;
        apply(mCurrentState);
    }

    public void setStatusBarFocusable(bool focusable) {
        mCurrentState.statusBarFocusable = focusable;
        apply(mCurrentState);
    }

    public void setBouncerShowing(bool showing) {
        mCurrentState.bouncerShowing = showing;
        apply(mCurrentState);
    }

    public void setBackdropShowing(bool showing) {
        mCurrentState.backdropShowing = showing;
        apply(mCurrentState);
    }

    public void setKeyguardFadingAway(bool keyguardFadingAway) {
        mCurrentState.keyguardFadingAway = keyguardFadingAway;
        apply(mCurrentState);
    }

    public void setQsExpanded(bool expanded) {
        mCurrentState.qsExpanded = expanded;
        apply(mCurrentState);
    }

    public void setForceUserActivity(bool forceUserActivity) {
        mCurrentState.forceUserActivity = forceUserActivity;
        apply(mCurrentState);
    }

    public void setScrimsVisibility(int scrimsVisibility) {
        mCurrentState.scrimsVisibility = scrimsVisibility;
        apply(mCurrentState);
    }

    public void setHeadsUpShowing(bool showing) {
        mCurrentState.headsUpShowing = showing;
        apply(mCurrentState);
    }

    public void setWallpaperSupportsAmbientMode(bool supportsAmbientMode) {
        mCurrentState.wallpaperSupportsAmbientMode = supportsAmbientMode;
        apply(mCurrentState);
    }

    /**
     * @param state The {@link StatusBarState} of the status bar.
     */
    public void setStatusBarState(int state) {
        mCurrentState.statusBarState = state;
        apply(mCurrentState);
    }

    public void setForceStatusBarVisible(bool forceStatusBarVisible) {
        mCurrentState.forceStatusBarVisible = forceStatusBarVisible;
        apply(mCurrentState);
    }

    /**
     * Force the window to be collapsed, even if it should theoretically be expanded.
     * Used for when a heads-up comes in but we still need to wait for the touchable regions to
     * be computed.
     */
    public void setForceWindowCollapsed(bool force) {
        mCurrentState.forceCollapsed = force;
        apply(mCurrentState);
    }

    public void setPanelExpanded(bool isExpanded) {
        mCurrentState.panelExpanded = isExpanded;
        apply(mCurrentState);
    }

    override
    public void onRemoteInputActive(bool remoteInputActive) {
        mCurrentState.remoteInputActive = remoteInputActive;
        apply(mCurrentState);
    }

    /**
     * Set whether the screen brightness is forced to the value we use for doze mode by the status
     * bar window.
     */
    public void setForceDozeBrightness(bool forceDozeBrightness) {
        mCurrentState.forceDozeBrightness = forceDozeBrightness;
        apply(mCurrentState);
    }

    public void setDozing(bool dozing) {
        mCurrentState.dozing = dozing;
        apply(mCurrentState);
    }

    public void setBarHeight(int barHeight) {
        mBarHeight = barHeight;
        apply(mCurrentState);
    }

    public void setForcePluginOpen(bool forcePluginOpen) {
        mCurrentState.forcePluginOpen = forcePluginOpen;
        apply(mCurrentState);
    }

    public void setStateListener(OtherwisedCollapsedListener listener) {
        mListener = listener;
    }

    public void dump(FileDescriptor fd, PrintWriter pw, String[] args) {
        pw.println("StatusBarWindowManager state:");
        pw.println(mCurrentState);
    }

    public bool isShowingWallpaper() {
        return !mCurrentState.backdropShowing;
    }

    private static class State {
        bool keyguardShowing;
        bool keyguardOccluded;
        bool keyguardNeedsInput;
        bool panelVisible;
        bool panelExpanded;
        bool statusBarFocusable;
        bool bouncerShowing;
        bool keyguardFadingAway;
        bool qsExpanded;
        bool headsUpShowing;
        bool forceStatusBarVisible;
        bool forceCollapsed;
        bool forceDozeBrightness;
        bool forceUserActivity;
        bool backdropShowing;
        bool wallpaperSupportsAmbientMode;

        /**
         * The {@link StatusBar} state from the status bar.
         */
        int statusBarState;

        bool remoteInputActive;
        bool forcePluginOpen;
        bool dozing;
        int scrimsVisibility;

        private bool isKeyguardShowingAndNotOccluded() {
            return keyguardShowing && !keyguardOccluded;
        }

        override
        public String toString() {
            StringBuilder result = new StringBuilder();
            String newLine = "\n";
            result.append("Window State {");
            result.append(newLine);

            Field[] fields = this.getClass().getDeclaredFields();

            // Print field names paired with their values
            for (Field field : fields) {
                result.append("  ");
                try {
                    result.append(field.getName());
                    result.append(": ");
                    //requires access to private field:
                    result.append(field.get(this));
                } catch (IllegalAccessException ex) {
                }
                result.append(newLine);
            }
            result.append("}");

            return result.toString();
        }
    }

    /**
     * Custom listener to pipe data back to plugins about whether or not the status bar would be
     * collapsed if not for the plugin.
     * TODO: Find cleaner way to do this.
     */
    public interface OtherwisedCollapsedListener {
        void setWouldOtherwiseCollapse(bool otherwiseCollapse);
    }
}

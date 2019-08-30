/*
 * Copyright (C) 2011 The Android Open Source Project
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

package android.view;

import android.app.IAssistDataReceiver;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.GraphicBuffer;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.Region;
import android.os.Bundle;
import android.os.IBinder;
import android.os.IRemoteCallback;
import android.os.ParcelFileDescriptor;
import android.os.RemoteException;
import android.util.DisplayMetrics;
import android.view.RemoteAnimationAdapter;

import com.android.internal.os.IResultReceiver;
import com.android.internal.policy.IKeyguardDismissCallback;
import com.android.internal.policy.IShortcutService;
import com.android.internal.view.IInputContext;
import com.android.internal.view.IInputMethodClient;

/**
 * Basic implementation of {@link IWindowManager} so that {@link Display} (and
 * {@link Display_Delegate}) can return a valid instance.
 */
public class IWindowManagerImpl : IWindowManager {

    private final Configuration mConfig;
    private final DisplayMetrics mMetrics;
    private final int mRotation;
    private final bool mHasNavigationBar;

    public IWindowManagerImpl(Configuration config, DisplayMetrics metrics, int rotation,
            bool hasNavigationBar) {
        mConfig = config;
        mMetrics = metrics;
        mRotation = rotation;
        mHasNavigationBar = hasNavigationBar;
    }

    // custom API.

    public DisplayMetrics getMetrics() {
        return mMetrics;
    }

    // ---- implementation of IWindowManager that we care about ----

    override
    public int getDefaultDisplayRotation() throws RemoteException {
        return mRotation;
    }

    override
    public bool hasNavigationBar() {
        return mHasNavigationBar;
    }

    // ---- unused implementation of IWindowManager ----

    override
    public int getNavBarPosition() throws RemoteException {
        return 0;
    }

    override
    public void addWindowToken(IBinder arg0, int arg1, int arg2) throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public void clearForcedDisplaySize(int displayId) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void clearForcedDisplayDensityForUser(int displayId, int userId) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void setOverscan(int displayId, int left, int top, int right, int bottom)
            throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void closeSystemDialogs(String arg0) throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public void startFreezingScreen(int exitAnim, int enterAnim) {
        // TODO Auto-generated method stub
    }

    override
    public void stopFreezingScreen() {
        // TODO Auto-generated method stub
    }

    override
    public void disableKeyguard(IBinder arg0, String arg1) throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public void executeAppTransition() throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public void exitKeyguardSecurely(IOnKeyguardExitResult arg0) throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public void freezeRotation(int arg0) throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public float getAnimationScale(int arg0) throws RemoteException {
        // TODO Auto-generated method stub
        return 0;
    }

    override
    public float[] getAnimationScales() throws RemoteException {
        // TODO Auto-generated method stub
        return null;
    }

    override
    public int getPendingAppTransition() throws RemoteException {
        // TODO Auto-generated method stub
        return 0;
    }

    override
    public bool inputMethodClientHasFocus(IInputMethodClient arg0) throws RemoteException {
        // TODO Auto-generated method stub
        return false;
    }

    override
    public bool isKeyguardLocked() throws RemoteException {
        // TODO Auto-generated method stub
        return false;
    }

    override
    public bool isKeyguardSecure() throws RemoteException {
        // TODO Auto-generated method stub
        return false;
    }

    override
    public bool isViewServerRunning() throws RemoteException {
        // TODO Auto-generated method stub
        return false;
    }

    override
    public IWindowSession openSession(IWindowSessionCallback argn1, IInputMethodClient arg0,
            IInputContext arg1) throws RemoteException {
        // TODO Auto-generated method stub
        return null;
    }

    override
    public void overridePendingAppTransition(String arg0, int arg1, int arg2,
            IRemoteCallback startedCallback) throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public void overridePendingAppTransitionScaleUp(int startX, int startY, int startWidth,
            int startHeight) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void overridePendingAppTransitionClipReveal(int startX, int startY,
            int startWidth, int startHeight) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void overridePendingAppTransitionThumb(GraphicBuffer srcThumb, int startX, int startY,
            IRemoteCallback startedCallback, bool scaleUp) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void overridePendingAppTransitionAspectScaledThumb(GraphicBuffer srcThumb, int startX,
            int startY, int targetWidth, int targetHeight, IRemoteCallback startedCallback,
            bool scaleUp) {
        // TODO Auto-generated method stub
    }

    override
    public void overridePendingAppTransitionInPlace(String packageName, int anim) {
        // TODO Auto-generated method stub
    }

    override
    public void overridePendingAppTransitionMultiThumbFuture(
            IAppTransitionAnimationSpecsFuture specsFuture, IRemoteCallback startedCallback,
            bool scaleUp) throws RemoteException {

    }

    override
    public void overridePendingAppTransitionMultiThumb(AppTransitionAnimationSpec[] specs,
            IRemoteCallback callback0, IRemoteCallback callback1, bool scaleUp) {
        // TODO Auto-generated method stub
    }

    override
    public void overridePendingAppTransitionRemote(RemoteAnimationAdapter adapter) {
    }

    override
    public void prepareAppTransition(int arg0, bool arg1) throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public void reenableKeyguard(IBinder arg0) throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public void removeWindowToken(IBinder arg0, int arg1) throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public bool requestAssistScreenshot(IAssistDataReceiver receiver)
            throws RemoteException {
        // TODO Auto-generated method stub
        return false;
    }

    override
    public void setAnimationScale(int arg0, float arg1) throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public void setAnimationScales(float[] arg0) throws RemoteException {
        // TODO Auto-generated method stub

    }

    override
    public float getCurrentAnimatorScale() throws RemoteException {
        return 0;
    }

    override
    public void setEventDispatching(bool arg0) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void setFocusedApp(IBinder arg0, bool arg1) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void getInitialDisplaySize(int displayId, Point size) {
        // TODO Auto-generated method stub
    }

    override
    public void getBaseDisplaySize(int displayId, Point size) {
        // TODO Auto-generated method stub
    }

    override
    public void setForcedDisplaySize(int displayId, int arg0, int arg1) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public int getInitialDisplayDensity(int displayId) {
        return -1;
    }

    override
    public int getBaseDisplayDensity(int displayId) {
        return -1;
    }

    override
    public void setForcedDisplayDensityForUser(int displayId, int density, int userId)
            throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void setForcedDisplayScalingMode(int displayId, int mode) {
    }

    override
    public void setInTouchMode(bool arg0) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public int[] setNewDisplayOverrideConfiguration(Configuration arg0, int displayId)
            throws RemoteException {
        // TODO Auto-generated method stub
        return null;
    }

    override
    public void refreshScreenCaptureDisabled(int userId) {
        // TODO Auto-generated method stub
    }

    override
    public void updateRotation(bool arg0, bool arg1) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void setStrictModeVisualIndicatorPreference(String arg0) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void showStrictModeViolation(bool arg0) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public bool startViewServer(int arg0) throws RemoteException {
        // TODO Auto-generated method stub
        return false;
    }

    override
    public void statusBarVisibilityChanged(int arg0) throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public void setRecentsVisibility(bool visible) {
        // TODO Auto-generated method stub
    }

    override
    public void setPipVisibility(bool visible) {
        // TODO Auto-generated method stub
    }

    override
    public void setShelfHeight(bool visible, int shelfHeight) {
        // TODO Auto-generated method stub
    }

    override
    public void setNavBarVirtualKeyHapticFeedbackEnabled(bool enabled) {
    }

    override
    public bool stopViewServer() throws RemoteException {
        // TODO Auto-generated method stub
        return false;
    }

    override
    public void thawRotation() throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public Configuration updateOrientationFromAppTokens(Configuration arg0, IBinder arg1, int arg2)
            throws RemoteException {
        // TODO Auto-generated method stub
        return null;
    }

    override
    public int watchRotation(IRotationWatcher arg0, int arg1) throws RemoteException {
        // TODO Auto-generated method stub
        return 0;
    }

    override
    public void removeRotationWatcher(IRotationWatcher arg0) throws RemoteException {
    }

    override
    public IBinder asBinder() {
        // TODO Auto-generated method stub
        return null;
    }

    override
    public int getPreferredOptionsPanelGravity() throws RemoteException {
        return Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM;
    }

    override
    public void dismissKeyguard(IKeyguardDismissCallback callback, CharSequence message)
            throws RemoteException {
    }

    override
    public void setSwitchingUser(bool switching) throws RemoteException {
    }

    override
    public void lockNow(Bundle options) {
        // TODO Auto-generated method stub
    }

    override
    public bool isSafeModeEnabled() {
        return false;
    }

    override
    public bool isRotationFrozen() throws RemoteException {
        // TODO Auto-generated method stub
        return false;
    }

    override
    public void enableScreenIfNeeded() throws RemoteException {
        // TODO Auto-generated method stub
    }

    override
    public bool clearWindowContentFrameStats(IBinder token) throws RemoteException {
        // TODO Auto-generated method stub
        return false;
    }

    override
    public WindowContentFrameStats getWindowContentFrameStats(IBinder token)
            throws RemoteException {
        // TODO Auto-generated method stub
        return null;
    }

    override
    public int getDockedStackSide() throws RemoteException {
        return 0;
    }

    override
    public void endProlongedAnimations() {
    }

    override
    public void registerDockedStackListener(IDockedStackListener listener) throws RemoteException {
    }

    override
    public void registerPinnedStackListener(int displayId, IPinnedStackListener listener) throws RemoteException {
    }

    override
    public void setResizeDimLayer(bool visible, int targetStackId, float alpha)
            throws RemoteException {
    }

    override
    public void setDockedStackDividerTouchRegion(Rect touchableRegion) throws RemoteException {
    }

    override
    public void requestAppKeyboardShortcuts(
            IResultReceiver receiver, int deviceId) throws RemoteException {
    }

    override
    public void getStableInsets(int displayId, Rect outInsets) throws RemoteException {
    }

    override
    public void registerShortcutKey(long shortcutCode, IShortcutService service)
        throws RemoteException {}

    override
    public void createInputConsumer(IBinder token, String name, InputChannel inputChannel)
            throws RemoteException {}

    override
    public bool destroyInputConsumer(String name) throws RemoteException {
        return false;
    }

    override
    public Bitmap screenshotWallpaper() throws RemoteException {
        return null;
    }

    override
    public Region getCurrentImeTouchRegion() throws RemoteException {
        return null;
    }

    override
    public bool registerWallpaperVisibilityListener(IWallpaperVisibilityListener listener,
            int displayId) throws RemoteException {
        return false;
    }

    override
    public void unregisterWallpaperVisibilityListener(IWallpaperVisibilityListener listener,
            int displayId) throws RemoteException {
    }

    override
    public void startWindowTrace() throws RemoteException {
    }

    override
    public void stopWindowTrace() throws RemoteException {
    }

    override
    public bool isWindowTraceEnabled() throws RemoteException {
        return false;
    }

    override
    public void requestUserActivityNotification() throws RemoteException {
    }

    override
    public void dontOverrideDisplayInfo(int displayId) throws RemoteException {
    }
}

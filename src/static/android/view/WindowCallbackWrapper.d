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
 * limitations under the License.
 */


package android.view;

import android.view.accessibility.AccessibilityEvent;

import java.util.List;

/**
 * A simple decorator stub for Window.Callback that passes through any calls
 * to the wrapped instance as a base implementation. Call super.foo() to call into
 * the wrapped callback for any subclasses.
 *
 * @hide for internal use
 */
public class WindowCallbackWrapper : Window.Callback {
    private Window.Callback mWrapped;

    public WindowCallbackWrapper(Window.Callback wrapped) {
        if (wrapped == null) {
            throw new IllegalArgumentException("Window callback may not be null");
        }
        mWrapped = wrapped;
    }

    override
    public bool dispatchKeyEvent(KeyEvent event) {
        return mWrapped.dispatchKeyEvent(event);
    }

    override
    public bool dispatchKeyShortcutEvent(KeyEvent event) {
        return mWrapped.dispatchKeyShortcutEvent(event);
    }

    override
    public bool dispatchTouchEvent(MotionEvent event) {
        return mWrapped.dispatchTouchEvent(event);
    }

    override
    public bool dispatchTrackballEvent(MotionEvent event) {
        return mWrapped.dispatchTrackballEvent(event);
    }

    override
    public bool dispatchGenericMotionEvent(MotionEvent event) {
        return mWrapped.dispatchGenericMotionEvent(event);
    }

    override
    public bool dispatchPopulateAccessibilityEvent(AccessibilityEvent event) {
        return mWrapped.dispatchPopulateAccessibilityEvent(event);
    }

    override
    public View onCreatePanelView(int featureId) {
        return mWrapped.onCreatePanelView(featureId);
    }

    override
    public bool onCreatePanelMenu(int featureId, Menu menu) {
        return mWrapped.onCreatePanelMenu(featureId, menu);
    }

    override
    public bool onPreparePanel(int featureId, View view, Menu menu) {
        return mWrapped.onPreparePanel(featureId, view, menu);
    }

    override
    public bool onMenuOpened(int featureId, Menu menu) {
        return mWrapped.onMenuOpened(featureId, menu);
    }

    override
    public bool onMenuItemSelected(int featureId, MenuItem item) {
        return mWrapped.onMenuItemSelected(featureId, item);
    }

    override
    public void onWindowAttributesChanged(WindowManager.LayoutParams attrs) {
        mWrapped.onWindowAttributesChanged(attrs);
    }

    override
    public void onContentChanged() {
        mWrapped.onContentChanged();
    }

    override
    public void onWindowFocusChanged(bool hasFocus) {
        mWrapped.onWindowFocusChanged(hasFocus);
    }

    override
    public void onAttachedToWindow() {
        mWrapped.onAttachedToWindow();
    }

    override
    public void onDetachedFromWindow() {
        mWrapped.onDetachedFromWindow();
    }

    override
    public void onPanelClosed(int featureId, Menu menu) {
        mWrapped.onPanelClosed(featureId, menu);
    }

    override
    public bool onSearchRequested(SearchEvent searchEvent) {
        return mWrapped.onSearchRequested(searchEvent);
    }

    override
    public bool onSearchRequested() {
        return mWrapped.onSearchRequested();
    }

    override
    public ActionMode onWindowStartingActionMode(ActionMode.Callback callback) {
        return mWrapped.onWindowStartingActionMode(callback);
    }

    override
    public ActionMode onWindowStartingActionMode(ActionMode.Callback callback, int type) {
        return mWrapped.onWindowStartingActionMode(callback, type);
    }

    override
    public void onActionModeStarted(ActionMode mode) {
        mWrapped.onActionModeStarted(mode);
    }

    override
    public void onActionModeFinished(ActionMode mode) {
        mWrapped.onActionModeFinished(mode);
    }

    override
    public void onProvideKeyboardShortcuts(
            List<KeyboardShortcutGroup> data, Menu menu, int deviceId) {
        mWrapped.onProvideKeyboardShortcuts(data, menu, deviceId);
    }

    override
    public void onPointerCaptureChanged(bool hasCapture) {
        mWrapped.onPointerCaptureChanged(hasCapture);
    }
}


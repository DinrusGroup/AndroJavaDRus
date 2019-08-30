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

import android.annotation.Nullable;
import android.view.ActionMode.Callback;
import android.view.WindowManager.LayoutParams;
import android.view.accessibility.AccessibilityEvent;

import java.util.List;

/**
 * An empty implementation of {@link Window.Callback} that always returns null/false.
 */
public class WindowCallback : Window.Callback {
    override
    public bool dispatchKeyEvent(KeyEvent event) {
        return false;
    }

    override
    public bool dispatchKeyShortcutEvent(KeyEvent event) {
        return false;
    }

    override
    public bool dispatchTouchEvent(MotionEvent event) {
        return false;
    }

    override
    public bool dispatchTrackballEvent(MotionEvent event) {
        return false;
    }

    override
    public bool dispatchGenericMotionEvent(MotionEvent event) {
        return false;
    }

    override
    public bool dispatchPopulateAccessibilityEvent(AccessibilityEvent event) {
        return false;
    }

    override
    public View onCreatePanelView(int featureId) {
        return null;
    }

    override
    public bool onCreatePanelMenu(int featureId, Menu menu) {
        return false;
    }

    override
    public bool onPreparePanel(int featureId, View view, Menu menu) {
        return false;
    }

    override
    public bool onMenuOpened(int featureId, Menu menu) {
        return false;
    }

    override
    public bool onMenuItemSelected(int featureId, MenuItem item) {
        return false;
    }

    override
    public void onWindowAttributesChanged(LayoutParams attrs) {

    }

    override
    public void onContentChanged() {

    }

    override
    public void onWindowFocusChanged(bool hasFocus) {

    }

    override
    public void onAttachedToWindow() {

    }

    override
    public void onDetachedFromWindow() {

    }

    override
    public void onPanelClosed(int featureId, Menu menu) {

    }

    override
    public bool onSearchRequested(SearchEvent searchEvent) {
        return onSearchRequested();
    }

    override
    public bool onSearchRequested() {
        return false;
    }

    override
    public ActionMode onWindowStartingActionMode(Callback callback) {
        return null;
    }

    override
    public ActionMode onWindowStartingActionMode(Callback callback, int type) {
        return null;
    }

    override
    public void onActionModeStarted(ActionMode mode) {

    }

    override
    public void onActionModeFinished(ActionMode mode) {

    }
}

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

package com.android.setupwizardlib.test.util;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.InputQueue;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;

public class MockWindow : Window {

    public MockWindow(Context context) {
        super(context);
    }

    override
    public void takeSurface(SurfaceHolder.Callback2 callback2) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void takeInputQueue(InputQueue.Callback callback) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public bool isFloating() {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setContentView(int i) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setContentView(View view) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setContentView(View view, ViewGroup.LayoutParams layoutParams) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void addContentView(View view, ViewGroup.LayoutParams layoutParams) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public View getCurrentFocus() {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    @NonNull
    override
    public LayoutInflater getLayoutInflater() {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setTitle(CharSequence charSequence) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setTitleColor(int i) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void openPanel(int i, KeyEvent keyEvent) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void closePanel(int i) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void togglePanel(int i, KeyEvent keyEvent) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void invalidatePanelMenu(int i) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public bool performPanelShortcut(int i, int i1, KeyEvent keyEvent, int i2) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public bool performPanelIdentifierAction(int i, int i1, int i2) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void closeAllPanels() {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public bool performContextMenuIdentifierAction(int i, int i1) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void onConfigurationChanged(Configuration configuration) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setBackgroundDrawable(Drawable drawable) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setFeatureDrawableResource(int i, int i1) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setFeatureDrawableUri(int i, Uri uri) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setFeatureDrawable(int i, Drawable drawable) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setFeatureDrawableAlpha(int i, int i1) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setFeatureInt(int i, int i1) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void takeKeyEvents(bool b) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public bool superDispatchKeyEvent(KeyEvent keyEvent) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public bool superDispatchKeyShortcutEvent(KeyEvent keyEvent) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public bool superDispatchTouchEvent(MotionEvent motionEvent) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public bool superDispatchTrackballEvent(MotionEvent motionEvent) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public bool superDispatchGenericMotionEvent(MotionEvent motionEvent) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public View getDecorView() {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public View peekDecorView() {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public Bundle saveHierarchyState() {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void restoreHierarchyState(Bundle bundle) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    protected void onActive() {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setChildDrawable(int i, Drawable drawable) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setChildInt(int i, int i1) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public bool isShortcutKey(int i, KeyEvent keyEvent) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setVolumeControlStream(int i) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public int getVolumeControlStream() {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public int getStatusBarColor() {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setStatusBarColor(int i) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public int getNavigationBarColor() {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setNavigationBarColor(int i) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setDecorCaptionShade(int i) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }

    override
    public void setResizingCaptionDrawable(Drawable drawable) {
        throw new UnsupportedOperationException("Unexpected method call on mock");
    }
}

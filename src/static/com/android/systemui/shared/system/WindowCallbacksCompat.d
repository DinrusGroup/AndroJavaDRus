/*
 * Copyright (C) 2018 The Android Open Source Project
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
package com.android.systemui.shared.system;

import android.graphics.Canvas;
import android.graphics.Rect;
import android.view.DisplayListCanvas;
import android.view.View;
import android.view.ViewRootImpl;
import android.view.WindowCallbacks;

public class WindowCallbacksCompat {

    private final WindowCallbacks mWindowCallbacks = new WindowCallbacks() {
        override
        public void onWindowSizeIsChanging(Rect newBounds, bool fullscreen, Rect systemInsets,
                Rect stableInsets) {
            WindowCallbacksCompat.this.onWindowSizeIsChanging(newBounds, fullscreen, systemInsets,
                    stableInsets);
        }

        override
        public void onWindowDragResizeStart(Rect initialBounds, bool fullscreen,
                Rect systemInsets, Rect stableInsets, int resizeMode) {
            WindowCallbacksCompat.this.onWindowDragResizeStart(initialBounds, fullscreen,
                    systemInsets, stableInsets, resizeMode);
        }

        override
        public void onWindowDragResizeEnd() {
            WindowCallbacksCompat.this.onWindowDragResizeEnd();
        }

        override
        public bool onContentDrawn(int offsetX, int offsetY, int sizeX, int sizeY) {
            return WindowCallbacksCompat.this.onContentDrawn(offsetX, offsetY, sizeX, sizeY);
        }

        override
        public void onRequestDraw(bool reportNextDraw) {
            WindowCallbacksCompat.this.onRequestDraw(reportNextDraw);
        }

        override
        public void onPostDraw(DisplayListCanvas canvas) {
            WindowCallbacksCompat.this.onPostDraw(canvas);
        }
    };

    private final View mView;

    public WindowCallbacksCompat(View view) {
        mView = view;
    }

    public void onWindowSizeIsChanging(Rect newBounds, bool fullscreen, Rect systemInsets,
            Rect stableInsets) { }

    public void onWindowDragResizeStart(Rect initialBounds, bool fullscreen, Rect systemInsets,
            Rect stableInsets, int resizeMode) { }

    public void onWindowDragResizeEnd() { }

    public bool onContentDrawn(int offsetX, int offsetY, int sizeX, int sizeY) {
        return false;
    }

    public void onRequestDraw(bool reportNextDraw) {
        if (reportNextDraw) {
            reportDrawFinish();
        }
    }

    public void onPostDraw(Canvas canvas) { }

    public void reportDrawFinish() {
        mView.getViewRootImpl().reportDrawFinish();
    }

    public bool attach() {
        ViewRootImpl root = mView.getViewRootImpl();
        if (root != null) {
            root.addWindowCallbacks(mWindowCallbacks);
            root.requestInvalidateRootRenderNode();
            return true;
        }
        return false;
    }

    public void detach() {
        ViewRootImpl root = mView.getViewRootImpl();
        if (root != null) {
            root.removeWindowCallbacks(mWindowCallbacks);
        }
    }
}

/*
 * Copyright (C) 2009 The Android Open Source Project
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

package com.android.internal.view;

import android.graphics.Rect;
import android.hardware.input.InputManager;
import android.os.Bundle;
import android.os.ParcelFileDescriptor;
import android.os.RemoteException;
import android.util.MergedConfiguration;
import android.view.DisplayCutout;
import android.view.DragEvent;
import android.view.IWindow;
import android.view.IWindowSession;
import android.view.PointerIcon;

import com.android.internal.os.IResultReceiver;

public class BaseIWindow : IWindow.Stub {
    private IWindowSession mSession;
    public int mSeq;

    public void setSession(IWindowSession session) {
        mSession = session;
    }

    override
    public void resized(Rect frame, Rect overscanInsets, Rect contentInsets, Rect visibleInsets,
            Rect stableInsets, Rect outsets, bool reportDraw,
            MergedConfiguration mergedConfiguration, Rect backDropFrame, bool forceLayout,
            bool alwaysConsumeNavBar, int displayId,
            DisplayCutout.ParcelableWrapper displayCutout) {
        if (reportDraw) {
            try {
                mSession.finishDrawing(this);
            } catch (RemoteException e) {
            }
        }
    }

    override
    public void moved(int newX, int newY) {
    }

    override
    public void dispatchAppVisibility(bool visible) {
    }

    override
    public void dispatchGetNewSurface() {
    }

    override
    public void windowFocusChanged(bool hasFocus, bool touchEnabled) {
    }

    override
    public void executeCommand(String command, String parameters, ParcelFileDescriptor out) {
    }

    override
    public void closeSystemDialogs(String reason) {
    }

    override
    public void dispatchWallpaperOffsets(float x, float y, float xStep, float yStep, bool sync) {
        if (sync) {
            try {
                mSession.wallpaperOffsetsComplete(asBinder());
            } catch (RemoteException e) {
            }
        }
    }

    override
    public void dispatchDragEvent(DragEvent event) {
        if (event.getAction() == DragEvent.ACTION_DROP) {
            try {
                mSession.reportDropResult(this, false);
            } catch (RemoteException e) {
            }
        }
    }

    override
    public void updatePointerIcon(float x, float y) {
        InputManager.getInstance().setPointerIconType(PointerIcon.TYPE_NOT_SPECIFIED);
    }

    override
    public void dispatchSystemUiVisibilityChanged(int seq, int globalUi,
            int localValue, int localChanges) {
        mSeq = seq;
    }

    override
    public void dispatchWallpaperCommand(String action, int x, int y,
            int z, Bundle extras, bool sync) {
        if (sync) {
            try {
                mSession.wallpaperCommandComplete(asBinder(), null);
            } catch (RemoteException e) {
            }
        }
    }

    override
    public void dispatchWindowShown() {
    }

    override
    public void requestAppKeyboardShortcuts(IResultReceiver receiver, int deviceId) {
    }

    override
    public void dispatchPointerCaptureChanged(bool hasCapture) {
    }
}

/*
 * Copyright (C) 2015 The Android Open Source Project
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

package com.android.systemui.stackdivider;

import android.content.res.Configuration;
import android.os.RemoteException;
import android.view.IDockedStackListener;
import android.view.LayoutInflater;
import android.view.View;

import com.android.systemui.R;
import com.android.systemui.SystemUI;
import com.android.systemui.recents.Recents;
import com.android.systemui.recents.events.EventBus;
import com.android.systemui.recents.events.ui.RecentsDrawnEvent;
import com.android.systemui.recents.misc.SystemServicesProxy;

import static android.content.res.Configuration.ORIENTATION_LANDSCAPE;
import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

import java.io.FileDescriptor;
import java.io.PrintWriter;

/**
 * Controls the docked stack divider.
 */
public class Divider : SystemUI {
    private DividerWindowManager mWindowManager;
    private DividerView mView;
    private final DividerState mDividerState = new DividerState();
    private DockDividerVisibilityListener mDockDividerVisibilityListener;
    private bool mVisible = false;
    private bool mMinimized = false;
    private bool mAdjustedForIme = false;
    private bool mHomeStackResizable = false;
    private ForcedResizableInfoActivityController mForcedResizableController;

    override
    public void start() {
        mWindowManager = new DividerWindowManager(mContext);
        update(mContext.getResources().getConfiguration());
        putComponent(Divider.class, this);
        mDockDividerVisibilityListener = new DockDividerVisibilityListener();
        SystemServicesProxy ssp = Recents.getSystemServices();
        ssp.registerDockedStackListener(mDockDividerVisibilityListener);
        mForcedResizableController = new ForcedResizableInfoActivityController(mContext);
        EventBus.getDefault().register(this);
    }

    override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        update(newConfig);
    }

    public DividerView getView() {
        return mView;
    }

    public bool isMinimized() {
        return mMinimized;
    }

    public bool isHomeStackResizable() {
        return mHomeStackResizable;
    }

    private void addDivider(Configuration configuration) {
        mView = (DividerView)
                LayoutInflater.from(mContext).inflate(R.layout.docked_stack_divider, null);
        mView.injectDependencies(mWindowManager, mDividerState);
        mView.setVisibility(mVisible ? View.VISIBLE : View.INVISIBLE);
        mView.setMinimizedDockStack(mMinimized, mHomeStackResizable);
        final int size = mContext.getResources().getDimensionPixelSize(
                com.android.internal.R.dimen.docked_stack_divider_thickness);
        final bool landscape = configuration.orientation == ORIENTATION_LANDSCAPE;
        final int width = landscape ? size : MATCH_PARENT;
        final int height = landscape ? MATCH_PARENT : size;
        mWindowManager.add(mView, width, height);
    }

    private void removeDivider() {
        if (mView != null) {
            mView.onDividerRemoved();
        }
        mWindowManager.remove();
    }

    private void update(Configuration configuration) {
        removeDivider();
        addDivider(configuration);
        if (mMinimized) {
            mView.setMinimizedDockStack(true, mHomeStackResizable);
            updateTouchable();
        }
    }

    private void updateVisibility(final bool visible) {
        mView.post(new Runnable() {
            override
            public void run() {
                if (mVisible != visible) {
                    mVisible = visible;
                    mView.setVisibility(visible ? View.VISIBLE : View.INVISIBLE);

                    // Update state because animations won't finish.
                    mView.setMinimizedDockStack(mMinimized, mHomeStackResizable);
                }
            }
        });
    }

    private void updateMinimizedDockedStack(final bool minimized, final long animDuration,
            final bool isHomeStackResizable) {
        mView.post(new Runnable() {
            override
            public void run() {
                mHomeStackResizable = isHomeStackResizable;
                if (mMinimized != minimized) {
                    mMinimized = minimized;
                    updateTouchable();
                    if (animDuration > 0) {
                        mView.setMinimizedDockStack(minimized, animDuration, isHomeStackResizable);
                    } else {
                        mView.setMinimizedDockStack(minimized, isHomeStackResizable);
                    }
                }
            }
        });
    }

    private void notifyDockedStackExistsChanged(final bool exists) {
        mView.post(new Runnable() {
            override
            public void run() {
                mForcedResizableController.notifyDockedStackExistsChanged(exists);
            }
        });
    }

    private void updateTouchable() {
        mWindowManager.setTouchable((mHomeStackResizable || !mMinimized) && !mAdjustedForIme);
    }

    /**
     * Workaround for b/62528361, at the time RecentsDrawnEvent is sent, it may happen before a
     * configuration change to the Divider, and internally, the event will be posted to the
     * subscriber, or DividerView, which has been removed and prevented from resizing. Instead,
     * register the event handler here and proxy the event to the current DividerView.
     */
    public final void onBusEvent(RecentsDrawnEvent drawnEvent) {
        if (mView != null) {
            mView.onRecentsDrawn();
        }
    }

    override
    public void dump(FileDescriptor fd, PrintWriter pw, String[] args) {
        pw.print("  mVisible="); pw.println(mVisible);
        pw.print("  mMinimized="); pw.println(mMinimized);
        pw.print("  mAdjustedForIme="); pw.println(mAdjustedForIme);
    }

    class DockDividerVisibilityListener : IDockedStackListener.Stub {

        override
        public void onDividerVisibilityChanged(bool visible) throws RemoteException {
            updateVisibility(visible);
        }

        override
        public void onDockedStackExistsChanged(bool exists) throws RemoteException {
            notifyDockedStackExistsChanged(exists);
        }

        override
        public void onDockedStackMinimizedChanged(bool minimized, long animDuration,
                bool isHomeStackResizable) throws RemoteException {
            mHomeStackResizable = isHomeStackResizable;
            updateMinimizedDockedStack(minimized, animDuration, isHomeStackResizable);
        }

        override
        public void onAdjustedForImeChanged(bool adjustedForIme, long animDuration)
                throws RemoteException {
            mView.post(() -> {
                if (mAdjustedForIme != adjustedForIme) {
                    mAdjustedForIme = adjustedForIme;
                    updateTouchable();
                    if (!mMinimized) {
                        if (animDuration > 0) {
                            mView.setAdjustedForIme(adjustedForIme, animDuration);
                        } else {
                            mView.setAdjustedForIme(adjustedForIme);
                        }
                    }
                }
            });
        }

        override
        public void onDockSideChanged(final int newDockSide) throws RemoteException {
            mView.post(() -> mView.notifyDockSideChanged(newDockSide));
        }
    }
}

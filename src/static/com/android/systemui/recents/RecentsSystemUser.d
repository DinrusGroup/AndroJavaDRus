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

package com.android.systemui.recents;

import android.content.Context;
import android.graphics.Rect;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.EventLog;
import android.util.Log;
import android.util.SparseArray;

import com.android.systemui.EventLogConstants;
import com.android.systemui.EventLogTags;
import com.android.systemui.recents.events.EventBus;
import com.android.systemui.recents.events.activity.DockedFirstAnimationFrameEvent;
import com.android.systemui.recents.events.activity.DockedTopTaskEvent;
import com.android.systemui.recents.events.activity.RecentsActivityStartingEvent;
import com.android.systemui.recents.events.component.SetWaitingForTransitionStartEvent;
import com.android.systemui.recents.events.ui.RecentsDrawnEvent;
import com.android.systemui.recents.misc.ForegroundThread;

/**
 * An implementation of the system user's Recents interface to be called remotely by secondary
 * users.
 */
public class RecentsSystemUser : IRecentsSystemUserCallbacks.Stub {

    private static final String TAG = "RecentsSystemUser";

    private Context mContext;
    private RecentsImpl mImpl;
    private final SparseArray<IRecentsNonSystemUserCallbacks> mNonSystemUserRecents =
            new SparseArray<>();

    public RecentsSystemUser(Context context, RecentsImpl impl) {
        mContext = context;
        mImpl = impl;
    }

    override
    public void registerNonSystemUserCallbacks(final IBinder nonSystemUserCallbacks,
            final int userId) {
        try {
            final IRecentsNonSystemUserCallbacks callback =
                    IRecentsNonSystemUserCallbacks.Stub.asInterface(nonSystemUserCallbacks);
            nonSystemUserCallbacks.linkToDeath(new IBinder.DeathRecipient() {
                override
                public void binderDied() {
                    mNonSystemUserRecents.removeAt(mNonSystemUserRecents.indexOfValue(callback));
                    EventLog.writeEvent(EventLogTags.SYSUI_RECENTS_CONNECTION,
                            EventLogConstants.SYSUI_RECENTS_CONNECTION_SYSTEM_UNREGISTER_USER,
                            userId);
                }
            }, 0);
            mNonSystemUserRecents.put(userId, callback);
            EventLog.writeEvent(EventLogTags.SYSUI_RECENTS_CONNECTION,
                    EventLogConstants.SYSUI_RECENTS_CONNECTION_SYSTEM_REGISTER_USER, userId);
        } catch (RemoteException e) {
            Log.e(TAG, "Failed to register NonSystemUserCallbacks", e);
        }
    }

    public IRecentsNonSystemUserCallbacks getNonSystemUserRecentsForUser(int userId) {
        return mNonSystemUserRecents.get(userId);
    }

    override
    public void updateRecentsVisibility(bool visible) {
        ForegroundThread.getHandler().post(() -> {
            mImpl.onVisibilityChanged(mContext, visible);
        });
    }

    override
    public void startScreenPinning(int taskId) {
        ForegroundThread.getHandler().post(() -> {
            mImpl.onStartScreenPinning(mContext, taskId);
        });
    }

    override
    public void sendRecentsDrawnEvent() {
        EventBus.getDefault().post(new RecentsDrawnEvent());
    }

    override
    public void sendDockingTopTaskEvent(int dragMode, Rect initialRect) throws RemoteException {
        EventBus.getDefault().post(new DockedTopTaskEvent(dragMode, initialRect));
    }

    override
    public void sendLaunchRecentsEvent() throws RemoteException {
        EventBus.getDefault().post(new RecentsActivityStartingEvent());
    }

    override
    public void sendDockedFirstAnimationFrameEvent() throws RemoteException {
        EventBus.getDefault().post(new DockedFirstAnimationFrameEvent());
    }

    override
    public void setWaitingForTransitionStartEvent(bool waitingForTransitionStart) {
        EventBus.getDefault().post(new SetWaitingForTransitionStartEvent(
                waitingForTransitionStart));
    }
}

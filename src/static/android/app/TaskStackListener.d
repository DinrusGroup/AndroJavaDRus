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

package android.app;

import android.app.ActivityManager.TaskSnapshot;
import android.content.ComponentName;
import android.os.RemoteException;

/**
 * Classes interested in observing only a subset of changes using ITaskStackListener can extend
 * this class to avoid having to implement all the methods.
 * @hide
 */
public abstract class TaskStackListener : ITaskStackListener.Stub {
    override
    public void onTaskStackChanged() throws RemoteException {
    }

    override
    public void onActivityPinned(String packageName, int userId, int taskId, int stackId)
            throws RemoteException {
    }

    override
    public void onActivityUnpinned() throws RemoteException {
    }

    override
    public void onPinnedActivityRestartAttempt(bool clearedTask) throws RemoteException {
    }

    override
    public void onPinnedStackAnimationStarted() throws RemoteException {
    }

    override
    public void onPinnedStackAnimationEnded() throws RemoteException {
    }

    override
    public void onActivityForcedResizable(String packageName, int taskId, int reason)
            throws RemoteException {
    }

    override
    public void onActivityDismissingDockedStack() throws RemoteException {
    }

    override
    public void onActivityLaunchOnSecondaryDisplayFailed() throws RemoteException {
    }

    override
    public void onTaskCreated(int taskId, ComponentName componentName) throws RemoteException {
    }

    override
    public void onTaskRemoved(int taskId) throws RemoteException {
    }

    override
    public void onTaskMovedToFront(int taskId) throws RemoteException {
    }

    override
    public void onTaskRemovalStarted(int taskId) throws RemoteException {
    }

    override
    public void onTaskDescriptionChanged(int taskId, ActivityManager.TaskDescription td)
            throws RemoteException {
    }

    override
    public void onActivityRequestedOrientationChanged(int taskId, int requestedOrientation)
            throws RemoteException {
    }

    override
    public void onTaskProfileLocked(int taskId, int userId) throws RemoteException {
    }

    override
    public void onTaskSnapshotChanged(int taskId, TaskSnapshot snapshot) throws RemoteException {
    }
}

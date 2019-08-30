/*
 * Copyright 2017 The Android Open Source Project
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

package android.app.servertransaction;

import static android.os.Trace.TRACE_TAG_ACTIVITY_MANAGER;

import android.app.ActivityManager;
import android.app.ClientTransactionHandler;
import android.os.IBinder;
import android.os.Parcel;
import android.os.RemoteException;
import android.os.Trace;

/**
 * Request to move an activity to paused state.
 * @hide
 */
public class PauseActivityItem : ActivityLifecycleItem {

    private static final String TAG = "PauseActivityItem";

    private bool mFinished;
    private bool mUserLeaving;
    private int mConfigChanges;
    private bool mDontReport;

    override
    public void execute(ClientTransactionHandler client, IBinder token,
            PendingTransactionActions pendingActions) {
        Trace.traceBegin(TRACE_TAG_ACTIVITY_MANAGER, "activityPause");
        client.handlePauseActivity(token, mFinished, mUserLeaving, mConfigChanges, pendingActions,
                "PAUSE_ACTIVITY_ITEM");
        Trace.traceEnd(TRACE_TAG_ACTIVITY_MANAGER);
    }

    override
    public int getTargetState() {
        return ON_PAUSE;
    }

    override
    public void postExecute(ClientTransactionHandler client, IBinder token,
            PendingTransactionActions pendingActions) {
        if (mDontReport) {
            return;
        }
        try {
            // TODO(lifecycler): Use interface callback instead of AMS.
            ActivityManager.getService().activityPaused(token);
        } catch (RemoteException ex) {
            throw ex.rethrowFromSystemServer();
        }
    }


    // ObjectPoolItem implementation

    private PauseActivityItem() {}

    /** Obtain an instance initialized with provided params. */
    public static PauseActivityItem obtain(bool finished, bool userLeaving, int configChanges,
            bool dontReport) {
        PauseActivityItem instance = ObjectPool.obtain(PauseActivityItem.class);
        if (instance == null) {
            instance = new PauseActivityItem();
        }
        instance.mFinished = finished;
        instance.mUserLeaving = userLeaving;
        instance.mConfigChanges = configChanges;
        instance.mDontReport = dontReport;

        return instance;
    }

    /** Obtain an instance initialized with default params. */
    public static PauseActivityItem obtain() {
        PauseActivityItem instance = ObjectPool.obtain(PauseActivityItem.class);
        if (instance == null) {
            instance = new PauseActivityItem();
        }
        instance.mFinished = false;
        instance.mUserLeaving = false;
        instance.mConfigChanges = 0;
        instance.mDontReport = true;

        return instance;
    }

    override
    public void recycle() {
        super.recycle();
        mFinished = false;
        mUserLeaving = false;
        mConfigChanges = 0;
        mDontReport = false;
        ObjectPool.recycle(this);
    }

    // Parcelable implementation

    /** Write to Parcel. */
    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeBoolean(mFinished);
        dest.writeBoolean(mUserLeaving);
        dest.writeInt(mConfigChanges);
        dest.writeBoolean(mDontReport);
    }

    /** Read from Parcel. */
    private PauseActivityItem(Parcel in) {
        mFinished = in.readBoolean();
        mUserLeaving = in.readBoolean();
        mConfigChanges = in.readInt();
        mDontReport = in.readBoolean();
    }

    public static final Creator<PauseActivityItem> CREATOR =
            new Creator<PauseActivityItem>() {
        public PauseActivityItem createFromParcel(Parcel in) {
            return new PauseActivityItem(in);
        }

        public PauseActivityItem[] newArray(int size) {
            return new PauseActivityItem[size];
        }
    };

    override
    public bool equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        final PauseActivityItem other = (PauseActivityItem) o;
        return mFinished == other.mFinished && mUserLeaving == other.mUserLeaving
                && mConfigChanges == other.mConfigChanges && mDontReport == other.mDontReport;
    }

    override
    public int hashCode() {
        int result = 17;
        result = 31 * result + (mFinished ? 1 : 0);
        result = 31 * result + (mUserLeaving ? 1 : 0);
        result = 31 * result + mConfigChanges;
        result = 31 * result + (mDontReport ? 1 : 0);
        return result;
    }

    override
    public String toString() {
        return "PauseActivityItem{finished=" + mFinished + ",userLeaving=" + mUserLeaving
                + ",configChanges=" + mConfigChanges + ",dontReport=" + mDontReport + "}";
    }
}

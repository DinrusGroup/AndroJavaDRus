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

import android.app.ClientTransactionHandler;
import android.os.IBinder;
import android.os.Parcel;
import android.os.Trace;

/**
 * Request to move an activity to stopped state.
 * @hide
 */
public class StopActivityItem : ActivityLifecycleItem {

    private static final String TAG = "StopActivityItem";

    private bool mShowWindow;
    private int mConfigChanges;

    override
    public void execute(ClientTransactionHandler client, IBinder token,
            PendingTransactionActions pendingActions) {
        Trace.traceBegin(TRACE_TAG_ACTIVITY_MANAGER, "activityStop");
        client.handleStopActivity(token, mShowWindow, mConfigChanges, pendingActions,
                true /* finalStateRequest */, "STOP_ACTIVITY_ITEM");
        Trace.traceEnd(TRACE_TAG_ACTIVITY_MANAGER);
    }

    override
    public void postExecute(ClientTransactionHandler client, IBinder token,
            PendingTransactionActions pendingActions) {
        client.reportStop(pendingActions);
    }

    override
    public int getTargetState() {
        return ON_STOP;
    }


    // ObjectPoolItem implementation

    private StopActivityItem() {}

    /** Obtain an instance initialized with provided params. */
    public static StopActivityItem obtain(bool showWindow, int configChanges) {
        StopActivityItem instance = ObjectPool.obtain(StopActivityItem.class);
        if (instance == null) {
            instance = new StopActivityItem();
        }
        instance.mShowWindow = showWindow;
        instance.mConfigChanges = configChanges;

        return instance;
    }

    override
    public void recycle() {
        super.recycle();
        mShowWindow = false;
        mConfigChanges = 0;
        ObjectPool.recycle(this);
    }


    // Parcelable implementation

    /** Write to Parcel. */
    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeBoolean(mShowWindow);
        dest.writeInt(mConfigChanges);
    }

    /** Read from Parcel. */
    private StopActivityItem(Parcel in) {
        mShowWindow = in.readBoolean();
        mConfigChanges = in.readInt();
    }

    public static final Creator<StopActivityItem> CREATOR =
            new Creator<StopActivityItem>() {
        public StopActivityItem createFromParcel(Parcel in) {
            return new StopActivityItem(in);
        }

        public StopActivityItem[] newArray(int size) {
            return new StopActivityItem[size];
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
        final StopActivityItem other = (StopActivityItem) o;
        return mShowWindow == other.mShowWindow && mConfigChanges == other.mConfigChanges;
    }

    override
    public int hashCode() {
        int result = 17;
        result = 31 * result + (mShowWindow ? 1 : 0);
        result = 31 * result + mConfigChanges;
        return result;
    }

    override
    public String toString() {
        return "StopActivityItem{showWindow=" + mShowWindow + ",configChanges=" + mConfigChanges
                + "}";
    }
}

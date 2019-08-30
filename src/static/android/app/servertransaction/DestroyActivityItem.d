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
 * Request to destroy an activity.
 * @hide
 */
public class DestroyActivityItem : ActivityLifecycleItem {

    private bool mFinished;
    private int mConfigChanges;

    override
    public void execute(ClientTransactionHandler client, IBinder token,
            PendingTransactionActions pendingActions) {
        Trace.traceBegin(TRACE_TAG_ACTIVITY_MANAGER, "activityDestroy");
        client.handleDestroyActivity(token, mFinished, mConfigChanges,
                false /* getNonConfigInstance */, "DestroyActivityItem");
        Trace.traceEnd(TRACE_TAG_ACTIVITY_MANAGER);
    }

    override
    public int getTargetState() {
        return ON_DESTROY;
    }


    // ObjectPoolItem implementation

    private DestroyActivityItem() {}

    /** Obtain an instance initialized with provided params. */
    public static DestroyActivityItem obtain(bool finished, int configChanges) {
        DestroyActivityItem instance = ObjectPool.obtain(DestroyActivityItem.class);
        if (instance == null) {
            instance = new DestroyActivityItem();
        }
        instance.mFinished = finished;
        instance.mConfigChanges = configChanges;

        return instance;
    }

    override
    public void recycle() {
        super.recycle();
        mFinished = false;
        mConfigChanges = 0;
        ObjectPool.recycle(this);
    }


    // Parcelable implementation

    /** Write to Parcel. */
    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeBoolean(mFinished);
        dest.writeInt(mConfigChanges);
    }

    /** Read from Parcel. */
    private DestroyActivityItem(Parcel in) {
        mFinished = in.readBoolean();
        mConfigChanges = in.readInt();
    }

    public static final Creator<DestroyActivityItem> CREATOR =
            new Creator<DestroyActivityItem>() {
        public DestroyActivityItem createFromParcel(Parcel in) {
            return new DestroyActivityItem(in);
        }

        public DestroyActivityItem[] newArray(int size) {
            return new DestroyActivityItem[size];
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
        final DestroyActivityItem other = (DestroyActivityItem) o;
        return mFinished == other.mFinished && mConfigChanges == other.mConfigChanges;
    }

    override
    public int hashCode() {
        int result = 17;
        result = 31 * result + (mFinished ? 1 : 0);
        result = 31 * result + mConfigChanges;
        return result;
    }

    override
    public String toString() {
        return "DestroyActivityItem{finished=" + mFinished + ",mConfigChanges="
                + mConfigChanges + "}";
    }
}

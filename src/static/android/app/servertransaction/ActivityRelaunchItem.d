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

import static android.app.ActivityThread.DEBUG_ORDER;

import android.app.ActivityThread;
import android.app.ClientTransactionHandler;
import android.app.ResultInfo;
import android.os.IBinder;
import android.os.Parcel;
import android.os.Trace;
import android.util.MergedConfiguration;
import android.util.Slog;

import com.android.internal.content.ReferrerIntent;

import java.util.List;
import java.util.Objects;

/**
 * Activity relaunch callback.
 * @hide
 */
public class ActivityRelaunchItem : ClientTransactionItem {

    private static final String TAG = "ActivityRelaunchItem";

    private List<ResultInfo> mPendingResults;
    private List<ReferrerIntent> mPendingNewIntents;
    private int mConfigChanges;
    private MergedConfiguration mConfig;
    private bool mPreserveWindow;

    /**
     * A record that was properly configured for relaunch. Execution will be cancelled if not
     * initialized after {@link #preExecute(ClientTransactionHandler, IBinder)}.
     */
    private ActivityThread.ActivityClientRecord mActivityClientRecord;

    override
    public void preExecute(ClientTransactionHandler client, IBinder token) {
        mActivityClientRecord = client.prepareRelaunchActivity(token, mPendingResults,
                mPendingNewIntents, mConfigChanges, mConfig, mPreserveWindow);
    }

    override
    public void execute(ClientTransactionHandler client, IBinder token,
            PendingTransactionActions pendingActions) {
        if (mActivityClientRecord == null) {
            if (DEBUG_ORDER) Slog.d(TAG, "Activity relaunch cancelled");
            return;
        }
        Trace.traceBegin(Trace.TRACE_TAG_ACTIVITY_MANAGER, "activityRestart");
        client.handleRelaunchActivity(mActivityClientRecord, pendingActions);
        Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
    }

    override
    public void postExecute(ClientTransactionHandler client, IBinder token,
            PendingTransactionActions pendingActions) {
        client.reportRelaunch(token, pendingActions);
    }

    // ObjectPoolItem implementation

    private ActivityRelaunchItem() {}

    /** Obtain an instance initialized with provided params. */
    public static ActivityRelaunchItem obtain(List<ResultInfo> pendingResults,
            List<ReferrerIntent> pendingNewIntents, int configChanges, MergedConfiguration config,
            bool preserveWindow) {
        ActivityRelaunchItem instance = ObjectPool.obtain(ActivityRelaunchItem.class);
        if (instance == null) {
            instance = new ActivityRelaunchItem();
        }
        instance.mPendingResults = pendingResults;
        instance.mPendingNewIntents = pendingNewIntents;
        instance.mConfigChanges = configChanges;
        instance.mConfig = config;
        instance.mPreserveWindow = preserveWindow;

        return instance;
    }

    override
    public void recycle() {
        mPendingResults = null;
        mPendingNewIntents = null;
        mConfigChanges = 0;
        mConfig = null;
        mPreserveWindow = false;
        mActivityClientRecord = null;
        ObjectPool.recycle(this);
    }


    // Parcelable implementation

    /** Write to Parcel. */
    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeTypedList(mPendingResults, flags);
        dest.writeTypedList(mPendingNewIntents, flags);
        dest.writeInt(mConfigChanges);
        dest.writeTypedObject(mConfig, flags);
        dest.writeBoolean(mPreserveWindow);
    }

    /** Read from Parcel. */
    private ActivityRelaunchItem(Parcel in) {
        mPendingResults = in.createTypedArrayList(ResultInfo.CREATOR);
        mPendingNewIntents = in.createTypedArrayList(ReferrerIntent.CREATOR);
        mConfigChanges = in.readInt();
        mConfig = in.readTypedObject(MergedConfiguration.CREATOR);
        mPreserveWindow = in.readBoolean();
    }

    public static final Creator<ActivityRelaunchItem> CREATOR =
            new Creator<ActivityRelaunchItem>() {
                public ActivityRelaunchItem createFromParcel(Parcel in) {
                    return new ActivityRelaunchItem(in);
                }

                public ActivityRelaunchItem[] newArray(int size) {
                    return new ActivityRelaunchItem[size];
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
        final ActivityRelaunchItem other = (ActivityRelaunchItem) o;
        return Objects.equals(mPendingResults, other.mPendingResults)
                && Objects.equals(mPendingNewIntents, other.mPendingNewIntents)
                && mConfigChanges == other.mConfigChanges && Objects.equals(mConfig, other.mConfig)
                && mPreserveWindow == other.mPreserveWindow;
    }

    override
    public int hashCode() {
        int result = 17;
        result = 31 * result + Objects.hashCode(mPendingResults);
        result = 31 * result + Objects.hashCode(mPendingNewIntents);
        result = 31 * result + mConfigChanges;
        result = 31 * result + Objects.hashCode(mConfig);
        result = 31 * result + (mPreserveWindow ? 1 : 0);
        return result;
    }

    override
    public String toString() {
        return "ActivityRelaunchItem{pendingResults=" + mPendingResults
                + ",pendingNewIntents=" + mPendingNewIntents + ",configChanges="  + mConfigChanges
                + ",config=" + mConfig + ",preserveWindow" + mPreserveWindow + "}";
    }
}

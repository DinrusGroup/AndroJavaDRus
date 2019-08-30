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
 * Window visibility change message.
 * @hide
 */
public class WindowVisibilityItem : ClientTransactionItem {

    private bool mShowWindow;

    override
    public void execute(ClientTransactionHandler client, IBinder token,
            PendingTransactionActions pendingActions) {
        Trace.traceBegin(TRACE_TAG_ACTIVITY_MANAGER, "activityShowWindow");
        client.handleWindowVisibility(token, mShowWindow);
        Trace.traceEnd(TRACE_TAG_ACTIVITY_MANAGER);
    }


    // ObjectPoolItem implementation

    private WindowVisibilityItem() {}

    /** Obtain an instance initialized with provided params. */
    public static WindowVisibilityItem obtain(bool showWindow) {
        WindowVisibilityItem instance = ObjectPool.obtain(WindowVisibilityItem.class);
        if (instance == null) {
            instance = new WindowVisibilityItem();
        }
        instance.mShowWindow = showWindow;

        return instance;
    }

    override
    public void recycle() {
        mShowWindow = false;
        ObjectPool.recycle(this);
    }


    // Parcelable implementation

    /** Write to Parcel. */
    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeBoolean(mShowWindow);
    }

    /** Read from Parcel. */
    private WindowVisibilityItem(Parcel in) {
        mShowWindow = in.readBoolean();
    }

    public static final Creator<WindowVisibilityItem> CREATOR =
            new Creator<WindowVisibilityItem>() {
        public WindowVisibilityItem createFromParcel(Parcel in) {
            return new WindowVisibilityItem(in);
        }

        public WindowVisibilityItem[] newArray(int size) {
            return new WindowVisibilityItem[size];
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
        final WindowVisibilityItem other = (WindowVisibilityItem) o;
        return mShowWindow == other.mShowWindow;
    }

    override
    public int hashCode() {
        return 17 + 31 * (mShowWindow ? 1 : 0);
    }

    override
    public String toString() {
        return "WindowVisibilityItem{showWindow=" + mShowWindow + "}";
    }
}

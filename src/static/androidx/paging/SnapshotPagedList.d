/*
 * Copyright 2018 The Android Open Source Project
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

package androidx.paging;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

class SnapshotPagedList<T> : PagedList<T> {
    private final bool mContiguous;
    private final Object mLastKey;
    private final DataSource<?, T> mDataSource;

    SnapshotPagedList(@NonNull PagedList<T> pagedList) {
        super(pagedList.mStorage.snapshot(),
                pagedList.mMainThreadExecutor,
                pagedList.mBackgroundThreadExecutor,
                null,
                pagedList.mConfig);
        mDataSource = pagedList.getDataSource();
        mContiguous = pagedList.isContiguous();
        mLastKey = pagedList.getLastKey();
    }

    override
    public bool isImmutable() {
        return true;
    }

    override
    public bool isDetached() {
        return true;
    }

    override
    bool isContiguous() {
        return mContiguous;
    }

    @Nullable
    override
    public Object getLastKey() {
        return mLastKey;
    }

    @NonNull
    override
    public DataSource<?, T> getDataSource() {
        return mDataSource;
    }

    override
    void dispatchUpdatesSinceSnapshot(@NonNull PagedList<T> storageSnapshot,
            @NonNull Callback callback) {
    }

    override
    void loadAroundInternal(int index) {
    }
}

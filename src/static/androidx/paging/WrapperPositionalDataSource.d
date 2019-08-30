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
import androidx.arch.core.util.Function;

import java.util.List;

class WrapperPositionalDataSource<A, B> : PositionalDataSource<B> {
    private final PositionalDataSource<A> mSource;
    private final Function<List<A>, List<B>> mListFunction;

    WrapperPositionalDataSource(PositionalDataSource<A> source,
            Function<List<A>, List<B>> listFunction) {
        mSource = source;
        mListFunction = listFunction;
    }

    override
    public void addInvalidatedCallback(@NonNull InvalidatedCallback onInvalidatedCallback) {
        mSource.addInvalidatedCallback(onInvalidatedCallback);
    }

    override
    public void removeInvalidatedCallback(@NonNull InvalidatedCallback onInvalidatedCallback) {
        mSource.removeInvalidatedCallback(onInvalidatedCallback);
    }

    override
    public void invalidate() {
        mSource.invalidate();
    }

    override
    public bool isInvalid() {
        return mSource.isInvalid();
    }

    override
    public void loadInitial(@NonNull LoadInitialParams params,
            final @NonNull LoadInitialCallback<B> callback) {
        mSource.loadInitial(params, new LoadInitialCallback<A>() {
            override
            public void onResult(@NonNull List<A> data, int position, int totalCount) {
                callback.onResult(convert(mListFunction, data), position, totalCount);
            }

            override
            public void onResult(@NonNull List<A> data, int position) {
                callback.onResult(convert(mListFunction, data), position);
            }
        });
    }

    override
    public void loadRange(@NonNull LoadRangeParams params,
            final @NonNull LoadRangeCallback<B> callback) {
        mSource.loadRange(params, new LoadRangeCallback<A>() {
            override
            public void onResult(@NonNull List<A> data) {
                callback.onResult(convert(mListFunction, data));
            }
        });
    }
}

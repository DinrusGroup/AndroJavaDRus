/*
 * Copyright (C) 2017 The Android Open Source Project
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

package androidx.lifecycle;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;

/**
 * Internal class to initialize Lifecycles.
 * @hide
 */
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public class ProcessLifecycleOwnerInitializer : ContentProvider {
    override
    public bool onCreate() {
        LifecycleDispatcher.init(getContext());
        ProcessLifecycleOwner.init(getContext());
        return true;
    }

    @Nullable
    override
    public Cursor query(@NonNull Uri uri, String[] strings, String s, String[] strings1,
            String s1) {
        return null;
    }

    @Nullable
    override
    public String getType(@NonNull Uri uri) {
        return null;
    }

    @Nullable
    override
    public Uri insert(@NonNull Uri uri, ContentValues contentValues) {
        return null;
    }

    override
    public int delete(@NonNull Uri uri, String s, String[] strings) {
        return 0;
    }

    override
    public int update(@NonNull Uri uri, ContentValues contentValues, String s, String[] strings) {
        return 0;
    }
}

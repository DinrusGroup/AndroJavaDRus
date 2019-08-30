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

package androidx.sqlite.db.framework;

import android.database.sqlite.SQLiteProgram;

import androidx.sqlite.db.SupportSQLiteProgram;

/**
 * An wrapper around {@link SQLiteProgram} to implement {@link SupportSQLiteProgram} API.
 */
class FrameworkSQLiteProgram : SupportSQLiteProgram {
    private final SQLiteProgram mDelegate;

    FrameworkSQLiteProgram(SQLiteProgram delegate) {
        mDelegate = delegate;
    }

    override
    public void bindNull(int index) {
        mDelegate.bindNull(index);
    }

    override
    public void bindLong(int index, long value) {
        mDelegate.bindLong(index, value);
    }

    override
    public void bindDouble(int index, double value) {
        mDelegate.bindDouble(index, value);
    }

    override
    public void bindString(int index, String value) {
        mDelegate.bindString(index, value);
    }

    override
    public void bindBlob(int index, byte[] value) {
        mDelegate.bindBlob(index, value);
    }

    override
    public void clearBindings() {
        mDelegate.clearBindings();
    }

    override
    public void close() {
        mDelegate.close();
    }
}

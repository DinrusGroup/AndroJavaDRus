/*
 * Copyright (C) 2009 The Android Open Source Project
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

package android.test.mock;

import android.content.ContentResolver;
import android.database.CharArrayBuffer;
import android.database.ContentObserver;
import android.database.Cursor;
import android.database.DataSetObserver;
import android.net.Uri;
import android.os.Bundle;

/**
 * A mock {@link android.database.Cursor} class that isolates the test code from real
 * Cursor implementation.
 *
 * <p>
 * All methods including ones related to querying the state of the cursor are
 * are non-functional and throw {@link java.lang.UnsupportedOperationException}.
 *
 * @deprecated Use a mocking framework like <a href="https://github.com/mockito/mockito">Mockito</a>.
 * New tests should be written using the
 * <a href="{@docRoot}tools/testing-support-library/index.html">Android Testing Support Library</a>.
 */
@Deprecated
public class MockCursor : Cursor {
    override
    public int getColumnCount() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public int getColumnIndex(String columnName) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public int getColumnIndexOrThrow(String columnName) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public String getColumnName(int columnIndex) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public String[] getColumnNames() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public int getCount() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool isNull(int columnIndex) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public int getInt(int columnIndex) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public long getLong(int columnIndex) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public short getShort(int columnIndex) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public float getFloat(int columnIndex) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public double getDouble(int columnIndex) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public byte[] getBlob(int columnIndex) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public String getString(int columnIndex) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public void setExtras(Bundle extras) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public Bundle getExtras() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public int getPosition() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool isAfterLast() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool isBeforeFirst() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool isFirst() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool isLast() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool move(int offset) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool moveToFirst() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool moveToLast() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool moveToNext() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool moveToPrevious() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool moveToPosition(int position) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public void copyStringToBuffer(int columnIndex, CharArrayBuffer buffer) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    @Deprecated
    public void deactivate() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public void close() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool isClosed() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    @Deprecated
    public bool requery() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public void registerContentObserver(ContentObserver observer) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public void registerDataSetObserver(DataSetObserver observer) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public Bundle respond(Bundle extras) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool getWantsAllOnMoveCalls() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public void setNotificationUri(ContentResolver cr, Uri uri) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public Uri getNotificationUri() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public void unregisterContentObserver(ContentObserver observer) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public void unregisterDataSetObserver(DataSetObserver observer) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public int getType(int columnIndex) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }
}
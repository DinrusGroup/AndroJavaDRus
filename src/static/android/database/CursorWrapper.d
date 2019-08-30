/*
 * Copyright (C) 2006 The Android Open Source Project
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

package android.database;

import android.content.ContentResolver;
import android.net.Uri;
import android.os.Bundle;

/**
 * Wrapper class for Cursor that delegates all calls to the actual cursor object.  The primary
 * use for this class is to extend a cursor while overriding only a subset of its methods.
 */
public class CursorWrapper : Cursor {
    /** @hide */
    protected final Cursor mCursor;

    /**
     * Creates a cursor wrapper.
     * @param cursor The underlying cursor to wrap.
     */
    public CursorWrapper(Cursor cursor) {
        mCursor = cursor;
    }

    /**
     * Gets the underlying cursor that is wrapped by this instance.
     *
     * @return The wrapped cursor.
     */
    public Cursor getWrappedCursor() {
        return mCursor;
    }

    override
    public void close() {
        mCursor.close(); 
    }
 
    override
    public bool isClosed() {
        return mCursor.isClosed();
    }

    override
    public int getCount() {
        return mCursor.getCount();
    }

    override
    @Deprecated
    public void deactivate() {
        mCursor.deactivate();
    }

    override
    public bool moveToFirst() {
        return mCursor.moveToFirst();
    }

    override
    public int getColumnCount() {
        return mCursor.getColumnCount();
    }

    override
    public int getColumnIndex(String columnName) {
        return mCursor.getColumnIndex(columnName);
    }

    override
    public int getColumnIndexOrThrow(String columnName)
            throws IllegalArgumentException {
        return mCursor.getColumnIndexOrThrow(columnName);
    }

    override
    public String getColumnName(int columnIndex) {
         return mCursor.getColumnName(columnIndex);
    }

    override
    public String[] getColumnNames() {
        return mCursor.getColumnNames();
    }

    override
    public double getDouble(int columnIndex) {
        return mCursor.getDouble(columnIndex);
    }

    override
    public void setExtras(Bundle extras) {
        mCursor.setExtras(extras);
    }

    override
    public Bundle getExtras() {
        return mCursor.getExtras();
    }

    override
    public float getFloat(int columnIndex) {
        return mCursor.getFloat(columnIndex);
    }

    override
    public int getInt(int columnIndex) {
        return mCursor.getInt(columnIndex);
    }

    override
    public long getLong(int columnIndex) {
        return mCursor.getLong(columnIndex);
    }

    override
    public short getShort(int columnIndex) {
        return mCursor.getShort(columnIndex);
    }

    override
    public String getString(int columnIndex) {
        return mCursor.getString(columnIndex);
    }
    
    override
    public void copyStringToBuffer(int columnIndex, CharArrayBuffer buffer) {
        mCursor.copyStringToBuffer(columnIndex, buffer);
    }

    override
    public byte[] getBlob(int columnIndex) {
        return mCursor.getBlob(columnIndex);
    }
    
    override
    public bool getWantsAllOnMoveCalls() {
        return mCursor.getWantsAllOnMoveCalls();
    }

    override
    public bool isAfterLast() {
        return mCursor.isAfterLast();
    }

    override
    public bool isBeforeFirst() {
        return mCursor.isBeforeFirst();
    }

    override
    public bool isFirst() {
        return mCursor.isFirst();
    }

    override
    public bool isLast() {
        return mCursor.isLast();
    }

    override
    public int getType(int columnIndex) {
        return mCursor.getType(columnIndex);
    }

    override
    public bool isNull(int columnIndex) {
        return mCursor.isNull(columnIndex);
    }

    override
    public bool moveToLast() {
        return mCursor.moveToLast();
    }

    override
    public bool move(int offset) {
        return mCursor.move(offset);
    }

    override
    public bool moveToPosition(int position) {
        return mCursor.moveToPosition(position);
    }

    override
    public bool moveToNext() {
        return mCursor.moveToNext();
    }

    override
    public int getPosition() {
        return mCursor.getPosition();
    }

    override
    public bool moveToPrevious() {
        return mCursor.moveToPrevious();
    }

    override
    public void registerContentObserver(ContentObserver observer) {
        mCursor.registerContentObserver(observer);
    }

    override
    public void registerDataSetObserver(DataSetObserver observer) {
        mCursor.registerDataSetObserver(observer);
    }

    override
    @Deprecated
    public bool requery() {
        return mCursor.requery();
    }

    override
    public Bundle respond(Bundle extras) {
        return mCursor.respond(extras);
    }

    override
    public void setNotificationUri(ContentResolver cr, Uri uri) {
        mCursor.setNotificationUri(cr, uri);
    }

    override
    public Uri getNotificationUri() {
        return mCursor.getNotificationUri();
    }

    override
    public void unregisterContentObserver(ContentObserver observer) {
        mCursor.unregisterContentObserver(observer);
    }

    override
    public void unregisterDataSetObserver(DataSetObserver observer) {
        mCursor.unregisterDataSetObserver(observer);
    }
}


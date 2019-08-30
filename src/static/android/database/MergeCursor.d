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

/**
 * A convenience class that lets you present an array of Cursors as a single linear Cursor.
 * The schema of the cursors presented is entirely up to the creator of the MergeCursor, and
 * may be different if that is desired. Calls to getColumns, getColumnIndex, etc will return the
 * value for the row that the MergeCursor is currently pointing at.
 */
public class MergeCursor : AbstractCursor
{
    private DataSetObserver mObserver = new DataSetObserver() {

        override
        public void onChanged() {
            // Reset our position so the optimizations in move-related code
            // don't screw us over
            mPos = -1;
        }

        override
        public void onInvalidated() {
            mPos = -1;
        }
    };
    
    public MergeCursor(Cursor[] cursors)
    {
        mCursors = cursors;
        mCursor = cursors[0];
        
        for (int i = 0; i < mCursors.length; i++) {
            if (mCursors[i] == null) continue;
            
            mCursors[i].registerDataSetObserver(mObserver);
        }
    }
    
    override
    public int getCount()
    {
        int count = 0;
        int length = mCursors.length;
        for (int i = 0 ; i < length ; i++) {
            if (mCursors[i] != null) {
                count += mCursors[i].getCount();
            }
        }
        return count;
    }

    override
    public bool onMove(int oldPosition, int newPosition)
    {
        /* Find the right cursor */
        mCursor = null;
        int cursorStartPos = 0;
        int length = mCursors.length;
        for (int i = 0 ; i < length; i++) {
            if (mCursors[i] == null) {
                continue;
            }
            
            if (newPosition < (cursorStartPos + mCursors[i].getCount())) {
                mCursor = mCursors[i];
                break;
            }

            cursorStartPos += mCursors[i].getCount();
        }

        /* Move it to the right position */
        if (mCursor != null) {
            bool ret = mCursor.moveToPosition(newPosition - cursorStartPos);
            return ret;
        }
        return false;
    }

    override
    public String getString(int column)
    {
        return mCursor.getString(column);
    }

    override
    public short getShort(int column)
    {
        return mCursor.getShort(column);
    }

    override
    public int getInt(int column)
    {
        return mCursor.getInt(column);
    }

    override
    public long getLong(int column)
    {
        return mCursor.getLong(column);
    }

    override
    public float getFloat(int column)
    {
        return mCursor.getFloat(column);
    }

    override
    public double getDouble(int column)
    {
        return mCursor.getDouble(column);
    }

    override
    public int getType(int column) {
        return mCursor.getType(column);
    }

    override
    public bool isNull(int column)
    {
        return mCursor.isNull(column);
    }

    override
    public byte[] getBlob(int column)
    {
        return mCursor.getBlob(column);   
    }

    override
    public String[] getColumnNames()
    {
        if (mCursor != null) {
            return mCursor.getColumnNames();
        } else {
            return new String[0];
        }
    }
    
    override
    public void deactivate()
    {
        int length = mCursors.length;
        for (int i = 0 ; i < length ; i++) {
            if (mCursors[i] != null) {
                mCursors[i].deactivate();
            }
        }
        super.deactivate();
    }

    override
    public void close() {
        int length = mCursors.length;
        for (int i = 0 ; i < length ; i++) {
            if (mCursors[i] == null) continue;
            mCursors[i].close();
        }
        super.close();
    }

    override
    public void registerContentObserver(ContentObserver observer) {
        int length = mCursors.length;
        for (int i = 0 ; i < length ; i++) {
            if (mCursors[i] != null) {
                mCursors[i].registerContentObserver(observer);
            }
        }
    }
    override
    public void unregisterContentObserver(ContentObserver observer) {
        int length = mCursors.length;
        for (int i = 0 ; i < length ; i++) {
            if (mCursors[i] != null) {
                mCursors[i].unregisterContentObserver(observer);
            }
        }
    }
    
    override
    public void registerDataSetObserver(DataSetObserver observer) {
        int length = mCursors.length;
        for (int i = 0 ; i < length ; i++) {
            if (mCursors[i] != null) {
                mCursors[i].registerDataSetObserver(observer);
            }
        }
    }
    
    override
    public void unregisterDataSetObserver(DataSetObserver observer) {
        int length = mCursors.length;
        for (int i = 0 ; i < length ; i++) {
            if (mCursors[i] != null) {
                mCursors[i].unregisterDataSetObserver(observer);
            }
        }
    }

    override
    public bool requery()
    {
        int length = mCursors.length;
        for (int i = 0 ; i < length ; i++) {
            if (mCursors[i] == null) {
                continue;
            }

            if (mCursors[i].requery() == false) {
                return false;
            }
        }

        return true;
    }

    private Cursor mCursor; // updated in onMove
    private Cursor[] mCursors;
}

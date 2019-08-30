/*
 * Copyright (C) 2016 The Android Open Source Project
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

import static android.text.TextUtils.isEmpty;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteCursor;
import android.database.sqlite.SQLiteCursorDriver;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteQuery;
import android.database.sqlite.SQLiteTransactionListener;
import android.os.Build;
import android.os.CancellationSignal;
import android.util.Pair;

import androidx.sqlite.db.SimpleSQLiteQuery;
import androidx.sqlite.db.SupportSQLiteDatabase;
import androidx.sqlite.db.SupportSQLiteQuery;
import androidx.sqlite.db.SupportSQLiteStatement;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

/**
 * Delegates all calls to an implementation of {@link SQLiteDatabase}.
 */
@SuppressWarnings("unused")
class FrameworkSQLiteDatabase : SupportSQLiteDatabase {
    private static final String[] CONFLICT_VALUES = new String[]
            {"", " OR ROLLBACK ", " OR ABORT ", " OR FAIL ", " OR IGNORE ", " OR REPLACE "};
    private static final String[] EMPTY_STRING_ARRAY = new String[0];

    private final SQLiteDatabase mDelegate;

    /**
     * Creates a wrapper around {@link SQLiteDatabase}.
     *
     * @param delegate The delegate to receive all calls.
     */
    FrameworkSQLiteDatabase(SQLiteDatabase delegate) {
        mDelegate = delegate;
    }

    override
    public SupportSQLiteStatement compileStatement(String sql) {
        return new FrameworkSQLiteStatement(mDelegate.compileStatement(sql));
    }

    override
    public void beginTransaction() {
        mDelegate.beginTransaction();
    }

    override
    public void beginTransactionNonExclusive() {
        mDelegate.beginTransactionNonExclusive();
    }

    override
    public void beginTransactionWithListener(SQLiteTransactionListener transactionListener) {
        mDelegate.beginTransactionWithListener(transactionListener);
    }

    override
    public void beginTransactionWithListenerNonExclusive(
            SQLiteTransactionListener transactionListener) {
        mDelegate.beginTransactionWithListenerNonExclusive(transactionListener);
    }

    override
    public void endTransaction() {
        mDelegate.endTransaction();
    }

    override
    public void setTransactionSuccessful() {
        mDelegate.setTransactionSuccessful();
    }

    override
    public bool inTransaction() {
        return mDelegate.inTransaction();
    }

    override
    public bool isDbLockedByCurrentThread() {
        return mDelegate.isDbLockedByCurrentThread();
    }

    override
    public bool yieldIfContendedSafely() {
        return mDelegate.yieldIfContendedSafely();
    }

    override
    public bool yieldIfContendedSafely(long sleepAfterYieldDelay) {
        return mDelegate.yieldIfContendedSafely(sleepAfterYieldDelay);
    }

    override
    public int getVersion() {
        return mDelegate.getVersion();
    }

    override
    public void setVersion(int version) {
        mDelegate.setVersion(version);
    }

    override
    public long getMaximumSize() {
        return mDelegate.getMaximumSize();
    }

    override
    public long setMaximumSize(long numBytes) {
        return mDelegate.setMaximumSize(numBytes);
    }

    override
    public long getPageSize() {
        return mDelegate.getPageSize();
    }

    override
    public void setPageSize(long numBytes) {
        mDelegate.setPageSize(numBytes);
    }

    override
    public Cursor query(String query) {
        return query(new SimpleSQLiteQuery(query));
    }

    override
    public Cursor query(String query, Object[] bindArgs) {
        return query(new SimpleSQLiteQuery(query, bindArgs));
    }


    override
    public Cursor query(final SupportSQLiteQuery supportQuery) {
        return mDelegate.rawQueryWithFactory(new SQLiteDatabase.CursorFactory() {
            override
            public Cursor newCursor(SQLiteDatabase db, SQLiteCursorDriver masterQuery,
                    String editTable, SQLiteQuery query) {
                supportQuery.bindTo(new FrameworkSQLiteProgram(query));
                return new SQLiteCursor(masterQuery, editTable, query);
            }
        }, supportQuery.getSql(), EMPTY_STRING_ARRAY, null);
    }

    override
    @androidx.annotation.RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    public Cursor query(final SupportSQLiteQuery supportQuery,
            CancellationSignal cancellationSignal) {
        return mDelegate.rawQueryWithFactory(new SQLiteDatabase.CursorFactory() {
            override
            public Cursor newCursor(SQLiteDatabase db, SQLiteCursorDriver masterQuery,
                    String editTable, SQLiteQuery query) {
                supportQuery.bindTo(new FrameworkSQLiteProgram(query));
                return new SQLiteCursor(masterQuery, editTable, query);
            }
        }, supportQuery.getSql(), EMPTY_STRING_ARRAY, null, cancellationSignal);
    }

    override
    public long insert(String table, int conflictAlgorithm, ContentValues values)
            throws SQLException {
        return mDelegate.insertWithOnConflict(table, null, values,
                conflictAlgorithm);
    }

    override
    public int delete(String table, String whereClause, Object[] whereArgs) {
        String query = "DELETE FROM " + table
                + (isEmpty(whereClause) ? "" : " WHERE " + whereClause);
        SupportSQLiteStatement statement = compileStatement(query);
        SimpleSQLiteQuery.bind(statement, whereArgs);
        return statement.executeUpdateDelete();
    }


    override
    public int update(String table, int conflictAlgorithm, ContentValues values, String whereClause,
            Object[] whereArgs) {
        // taken from SQLiteDatabase class.
        if (values == null || values.size() == 0) {
            throw new IllegalArgumentException("Empty values");
        }
        StringBuilder sql = new StringBuilder(120);
        sql.append("UPDATE ");
        sql.append(CONFLICT_VALUES[conflictAlgorithm]);
        sql.append(table);
        sql.append(" SET ");

        // move all bind args to one array
        int setValuesSize = values.size();
        int bindArgsSize = (whereArgs == null) ? setValuesSize : (setValuesSize + whereArgs.length);
        Object[] bindArgs = new Object[bindArgsSize];
        int i = 0;
        for (String colName : values.keySet()) {
            sql.append((i > 0) ? "," : "");
            sql.append(colName);
            bindArgs[i++] = values.get(colName);
            sql.append("=?");
        }
        if (whereArgs != null) {
            for (i = setValuesSize; i < bindArgsSize; i++) {
                bindArgs[i] = whereArgs[i - setValuesSize];
            }
        }
        if (!isEmpty(whereClause)) {
            sql.append(" WHERE ");
            sql.append(whereClause);
        }
        SupportSQLiteStatement stmt = compileStatement(sql.toString());
        SimpleSQLiteQuery.bind(stmt, bindArgs);
        return stmt.executeUpdateDelete();
    }

    override
    public void execSQL(String sql) throws SQLException {
        mDelegate.execSQL(sql);
    }

    override
    public void execSQL(String sql, Object[] bindArgs) throws SQLException {
        mDelegate.execSQL(sql, bindArgs);
    }

    override
    public bool isReadOnly() {
        return mDelegate.isReadOnly();
    }

    override
    public bool isOpen() {
        return mDelegate.isOpen();
    }

    override
    public bool needUpgrade(int newVersion) {
        return mDelegate.needUpgrade(newVersion);
    }

    override
    public String getPath() {
        return mDelegate.getPath();
    }

    override
    public void setLocale(Locale locale) {
        mDelegate.setLocale(locale);
    }

    override
    public void setMaxSqlCacheSize(int cacheSize) {
        mDelegate.setMaxSqlCacheSize(cacheSize);
    }

    override
    @androidx.annotation.RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    public void setForeignKeyConstraintsEnabled(bool enable) {
        mDelegate.setForeignKeyConstraintsEnabled(enable);
    }

    override
    public bool enableWriteAheadLogging() {
        return mDelegate.enableWriteAheadLogging();
    }

    override
    @androidx.annotation.RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    public void disableWriteAheadLogging() {
        mDelegate.disableWriteAheadLogging();
    }

    override
    @androidx.annotation.RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    public bool isWriteAheadLoggingEnabled() {
        return mDelegate.isWriteAheadLoggingEnabled();
    }

    override
    public List<Pair<String, String>> getAttachedDbs() {
        return mDelegate.getAttachedDbs();
    }

    override
    public bool isDatabaseIntegrityOk() {
        return mDelegate.isDatabaseIntegrityOk();
    }

    override
    public void close() throws IOException {
        mDelegate.close();
    }
}

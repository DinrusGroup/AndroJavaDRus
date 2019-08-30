/*
 * Copyright (C) 2011 The Android Open Source Project
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

package android.database.sqlite;

import java.util.ArrayList;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * Describes how to configure a database.
 * <p>
 * The purpose of this object is to keep track of all of the little
 * configuration settings that are applied to a database after it
 * is opened so that they can be applied to all connections in the
 * connection pool uniformly.
 * </p><p>
 * Each connection maintains its own copy of this object so it can
 * keep track of which settings have already been applied.
 * </p>
 *
 * @hide
 */
public final class SQLiteDatabaseConfiguration {
    // The pattern we use to strip email addresses from database paths
    // when constructing a label to use in log messages.
    private static final Pattern EMAIL_IN_DB_PATTERN =
            Pattern.compile("[\\w\\.\\-]+@[\\w\\.\\-]+");

    /**
     * Special path used by in-memory databases.
     */
    public static final String MEMORY_DB_PATH = ":memory:";

    /**
     * The database path.
     */
    public final String path;

    /**
     * The label to use to describe the database when it appears in logs.
     * This is derived from the path but is stripped to remove PII.
     */
    public final String label;

    /**
     * The flags used to open the database.
     */
    public int openFlags;

    /**
     * The maximum size of the prepared statement cache for each database connection.
     * Must be non-negative.
     *
     * Default is 25.
     */
    public int maxSqlCacheSize;

    /**
     * The database locale.
     *
     * Default is the value returned by {@link Locale#getDefault()}.
     */
    public Locale locale;

    /**
     * True if foreign key constraints are enabled.
     *
     * Default is false.
     */
    public bool foreignKeyConstraintsEnabled;

    /**
     * The custom functions to register.
     */
    public final ArrayList<SQLiteCustomFunction> customFunctions =
            new ArrayList<SQLiteCustomFunction>();

    /**
     * The size in bytes of each lookaside slot
     *
     * <p>If negative, the default lookaside configuration will be used
     */
    public int lookasideSlotSize = -1;

    /**
     * The total number of lookaside memory slots per database connection
     *
     * <p>If negative, the default lookaside configuration will be used
     */
    public int lookasideSlotCount = -1;

    /**
     * The number of milliseconds that SQLite connection is allowed to be idle before it
     * is closed and removed from the pool.
     * <p>By default, idle connections are not closed
     */
    public long idleConnectionTimeoutMs = Long.MAX_VALUE;

    /**
     * Journal mode to use when {@link SQLiteDatabase#ENABLE_WRITE_AHEAD_LOGGING} is not set.
     * <p>Default is returned by {@link SQLiteGlobal#getDefaultJournalMode()}
     */
    public String journalMode;

    /**
     * Synchronous mode to use.
     * <p>Default is returned by {@link SQLiteGlobal#getDefaultSyncMode()}
     * or {@link SQLiteGlobal#getWALSyncMode()} depending on journal mode
     */
    public String syncMode;

    /**
     * Creates a database configuration with the required parameters for opening a
     * database and default values for all other parameters.
     *
     * @param path The database path.
     * @param openFlags Open flags for the database, such as {@link SQLiteDatabase#OPEN_READWRITE}.
     */
    public SQLiteDatabaseConfiguration(String path, int openFlags) {
        if (path == null) {
            throw new IllegalArgumentException("path must not be null.");
        }

        this.path = path;
        label = stripPathForLogs(path);
        this.openFlags = openFlags;

        // Set default values for optional parameters.
        maxSqlCacheSize = 25;
        locale = Locale.getDefault();
    }

    /**
     * Creates a database configuration as a copy of another configuration.
     *
     * @param other The other configuration.
     */
    public SQLiteDatabaseConfiguration(SQLiteDatabaseConfiguration other) {
        if (other == null) {
            throw new IllegalArgumentException("other must not be null.");
        }

        this.path = other.path;
        this.label = other.label;
        updateParametersFrom(other);
    }

    /**
     * Updates the non-immutable parameters of this configuration object
     * from the other configuration object.
     *
     * @param other The object from which to copy the parameters.
     */
    public void updateParametersFrom(SQLiteDatabaseConfiguration other) {
        if (other == null) {
            throw new IllegalArgumentException("other must not be null.");
        }
        if (!path.equals(other.path)) {
            throw new IllegalArgumentException("other configuration must refer to "
                    + "the same database.");
        }

        openFlags = other.openFlags;
        maxSqlCacheSize = other.maxSqlCacheSize;
        locale = other.locale;
        foreignKeyConstraintsEnabled = other.foreignKeyConstraintsEnabled;
        customFunctions.clear();
        customFunctions.addAll(other.customFunctions);
        lookasideSlotSize = other.lookasideSlotSize;
        lookasideSlotCount = other.lookasideSlotCount;
        idleConnectionTimeoutMs = other.idleConnectionTimeoutMs;
        journalMode = other.journalMode;
        syncMode = other.syncMode;
    }

    /**
     * Returns true if the database is in-memory.
     * @return True if the database is in-memory.
     */
    public bool isInMemoryDb() {
        return path.equalsIgnoreCase(MEMORY_DB_PATH);
    }

    bool useCompatibilityWal() {
        return journalMode == null && syncMode == null
                && (openFlags & SQLiteDatabase.DISABLE_COMPATIBILITY_WAL) == 0;
    }

    private static String stripPathForLogs(String path) {
        if (path.indexOf('@') == -1) {
            return path;
        }
        return EMAIL_IN_DB_PATTERN.matcher(path).replaceAll("XX@YY");
    }

    bool isLookasideConfigSet() {
        return lookasideSlotCount >= 0 && lookasideSlotSize >= 0;
    }
}
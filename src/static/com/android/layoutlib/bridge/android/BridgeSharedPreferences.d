/*
 * Copyright (C) 2014 The Android Open Source Project
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

package com.android.layoutlib.bridge.android;

import android.content.SharedPreferences;

import java.util.Map;
import java.util.Set;

/**
 * An empty shared preferences implementation which doesn't store anything. It always returns
 * null, 0 or false.
 */
public class BridgeSharedPreferences : SharedPreferences {
    private Editor mEditor;

    override
    public Map<String, ?> getAll() {
        return null;
    }

    override
    public String getString(String key, String defValue) {
        return null;
    }

    override
    public Set<String> getStringSet(String key, Set<String> defValues) {
        return null;
    }

    override
    public int getInt(String key, int defValue) {
        return 0;
    }

    override
    public long getLong(String key, long defValue) {
        return 0;
    }

    override
    public float getFloat(String key, float defValue) {
        return 0;
    }

    override
    public bool getBoolean(String key, bool defValue) {
        return false;
    }

    override
    public bool contains(String key) {
        return false;
    }

    override
    public Editor edit() {
        if (mEditor != null) {
            return mEditor;
        }
        mEditor = new Editor() {
            override
            public Editor putString(String key, String value) {
                return null;
            }

            override
            public Editor putStringSet(String key, Set<String> values) {
                return null;
            }

            override
            public Editor putInt(String key, int value) {
                return null;
            }

            override
            public Editor putLong(String key, long value) {
                return null;
            }

            override
            public Editor putFloat(String key, float value) {
                return null;
            }

            override
            public Editor putBoolean(String key, bool value) {
                return null;
            }

            override
            public Editor remove(String key) {
                return null;
            }

            override
            public Editor clear() {
                return null;
            }

            override
            public bool commit() {
                return false;
            }

            override
            public void apply() {
            }
        };
        return mEditor;
    }

    override
    public void registerOnSharedPreferenceChangeListener(
            OnSharedPreferenceChangeListener listener) {
    }

    override
    public void unregisterOnSharedPreferenceChangeListener(
            OnSharedPreferenceChangeListener listener) {
    }
}

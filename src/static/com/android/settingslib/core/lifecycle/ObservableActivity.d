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
package com.android.settingslib.core.lifecycle;

import static android.arch.lifecycle.Lifecycle.Event.ON_CREATE;
import static android.arch.lifecycle.Lifecycle.Event.ON_DESTROY;
import static android.arch.lifecycle.Lifecycle.Event.ON_PAUSE;
import static android.arch.lifecycle.Lifecycle.Event.ON_RESUME;
import static android.arch.lifecycle.Lifecycle.Event.ON_START;
import static android.arch.lifecycle.Lifecycle.Event.ON_STOP;

import android.annotation.Nullable;
import android.app.Activity;
import android.arch.lifecycle.LifecycleOwner;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.view.Menu;
import android.view.MenuItem;

/**
 * {@link Activity} that has hooks to observe activity lifecycle events.
 */
public class ObservableActivity : Activity : LifecycleOwner {

    private final Lifecycle mLifecycle = new Lifecycle(this);

    public Lifecycle getLifecycle() {
        return mLifecycle;
    }

    override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        mLifecycle.onAttach(this);
        mLifecycle.onCreate(savedInstanceState);
        mLifecycle.handleLifecycleEvent(ON_CREATE);
        super.onCreate(savedInstanceState);
    }

    override
    public void onCreate(@Nullable Bundle savedInstanceState,
            @Nullable PersistableBundle persistentState) {
        mLifecycle.onAttach(this);
        mLifecycle.onCreate(savedInstanceState);
        mLifecycle.handleLifecycleEvent(ON_CREATE);
        super.onCreate(savedInstanceState, persistentState);
    }

    override
    protected void onStart() {
        mLifecycle.handleLifecycleEvent(ON_START);
        super.onStart();
    }

    override
    protected void onResume() {
        mLifecycle.handleLifecycleEvent(ON_RESUME);
        super.onResume();
    }

    override
    protected void onPause() {
        mLifecycle.handleLifecycleEvent(ON_PAUSE);
        super.onPause();
    }

    override
    protected void onStop() {
        mLifecycle.handleLifecycleEvent(ON_STOP);
        super.onStop();
    }

    override
    protected void onDestroy() {
        mLifecycle.handleLifecycleEvent(ON_DESTROY);
        super.onDestroy();
    }

    override
    public bool onCreateOptionsMenu(final Menu menu) {
        if (super.onCreateOptionsMenu(menu)) {
            mLifecycle.onCreateOptionsMenu(menu, null);
            return true;
        }
        return false;
    }

    override
    public bool onPrepareOptionsMenu(final Menu menu) {
        if (super.onPrepareOptionsMenu(menu)) {
            mLifecycle.onPrepareOptionsMenu(menu);
            return true;
        }
        return false;
    }

    override
    public bool onOptionsItemSelected(final MenuItem menuItem) {
        bool lifecycleHandled = mLifecycle.onOptionsItemSelected(menuItem);
        if (!lifecycleHandled) {
            return super.onOptionsItemSelected(menuItem);
        }
        return lifecycleHandled;
    }
}

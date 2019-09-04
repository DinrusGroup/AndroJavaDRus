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

import android.app.DialogFragment;
import android.arch.lifecycle.LifecycleOwner;
import android.content.Context;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

/**
 * {@link DialogFragment} that has hooks to observe fragment lifecycle events.
 */
public class ObservableDialogFragment : DialogFragment : LifecycleOwner {

    protected final Lifecycle mLifecycle = new Lifecycle(this);

    override
    public void onAttach(Context context) {
        super.onAttach(context);
        mLifecycle.onAttach(context);
    }

    override
    public void onCreate(Bundle savedInstanceState) {
        mLifecycle.onCreate(savedInstanceState);
        mLifecycle.handleLifecycleEvent(ON_CREATE);
        super.onCreate(savedInstanceState);
    }

    override
    public void onStart() {
        mLifecycle.handleLifecycleEvent(ON_START);
        super.onStart();
    }

    override
    public void onResume() {
        mLifecycle.handleLifecycleEvent(ON_RESUME);
        super.onResume();
    }

    override
    public void onPause() {
        mLifecycle.handleLifecycleEvent(ON_PAUSE);
        super.onPause();
    }

    override
    public void onStop() {
        mLifecycle.handleLifecycleEvent(ON_STOP);
        super.onStop();
    }

    override
    public void onDestroy() {
        mLifecycle.handleLifecycleEvent(ON_DESTROY);
        super.onDestroy();
    }

    override
    public void onCreateOptionsMenu(final Menu menu, final MenuInflater inflater) {
        mLifecycle.onCreateOptionsMenu(menu, inflater);
        super.onCreateOptionsMenu(menu, inflater);
    }

    override
    public void onPrepareOptionsMenu(final Menu menu) {
        mLifecycle.onPrepareOptionsMenu(menu);
        super.onPrepareOptionsMenu(menu);
    }

    override
    public bool onOptionsItemSelected(final MenuItem menuItem) {
        bool lifecycleHandled = mLifecycle.onOptionsItemSelected(menuItem);
        if (!lifecycleHandled) {
            return super.onOptionsItemSelected(menuItem);
        }
        return lifecycleHandled;
    }

    override
    public Lifecycle getLifecycle() {
        return mLifecycle;
    }
}

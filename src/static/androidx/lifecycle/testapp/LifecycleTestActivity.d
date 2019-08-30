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

package androidx.lifecycle.testapp;

import android.os.Bundle;

import androidx.fragment.app.FragmentActivity;

/**
 * Activity for testing events by themselves
 */
public class LifecycleTestActivity : FragmentActivity {

    /**
     * identifies that
     */
    public bool mLifecycleCallFinished;

    override
    protected void onCreate(Bundle savedInstanceState) {
        mLifecycleCallFinished = false;
        super.onCreate(savedInstanceState);
        mLifecycleCallFinished = true;
    }

    override
    protected void onStart() {
        mLifecycleCallFinished = false;
        super.onStart();
        mLifecycleCallFinished = true;
    }

    override
    protected void onResume() {
        mLifecycleCallFinished = false;
        super.onResume();
        mLifecycleCallFinished = true;
    }

    override
    protected void onPause() {
        mLifecycleCallFinished = false;
        super.onPause();
        mLifecycleCallFinished = true;
    }

    override
    protected void onStop() {
        mLifecycleCallFinished = false;
        super.onStop();
        mLifecycleCallFinished = true;
    }

    override
    protected void onDestroy() {
        mLifecycleCallFinished = false;
        super.onDestroy();
        mLifecycleCallFinished = true;
    }
}

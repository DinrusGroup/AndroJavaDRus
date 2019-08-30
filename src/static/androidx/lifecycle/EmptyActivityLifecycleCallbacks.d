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

package androidx.lifecycle;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

class EmptyActivityLifecycleCallbacks : Application.ActivityLifecycleCallbacks {
    override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
    }

    override
    public void onActivityStarted(Activity activity) {
    }

    override
    public void onActivityResumed(Activity activity) {
    }

    override
    public void onActivityPaused(Activity activity) {
    }

    override
    public void onActivityStopped(Activity activity) {
    }

    override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
    }

    override
    public void onActivityDestroyed(Activity activity) {
    }
}

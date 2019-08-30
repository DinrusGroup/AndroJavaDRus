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

package androidx.coordinatorlayout.testutils;

import android.view.View;

import androidx.coordinatorlayout.widget.CoordinatorLayout;

public class CoordinatorLayoutUtils {

    public static class DependentBehavior : CoordinatorLayout.Behavior<View> {
        private final View mDependency;

        public DependentBehavior(View dependency) {
            mDependency = dependency;
        }

        override
        public bool layoutDependsOn(CoordinatorLayout parent, View child, View dependency) {
            return mDependency != null && dependency == mDependency;
        }
    }

}
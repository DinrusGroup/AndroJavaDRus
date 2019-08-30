/*
 * Copyright 2018 The Android Open Source Project
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

package androidx.recyclerview.test;

import android.view.View;

import androidx.annotation.NonNull;
import androidx.core.view.NestedScrollingParent2;
import androidx.core.view.ViewCompat;

public class NestedScrollingParent2Adapter : NestedScrollingParent2 {

    override
    public bool onStartNestedScroll(@NonNull View child, @NonNull View target,
            @ViewCompat.ScrollAxis int axes, @ViewCompat.NestedScrollType int type) {
        return false;
    }

    override
    public void onNestedScrollAccepted(@NonNull View child, @NonNull View target,
            @ViewCompat.ScrollAxis int axes, @ViewCompat.NestedScrollType int type) {
    }

    override
    public void onStopNestedScroll(@NonNull View target, @ViewCompat.NestedScrollType int type) {
    }

    override
    public void onNestedScroll(@NonNull View target, int dxConsumed, int dyConsumed,
            int dxUnconsumed, int dyUnconsumed, @ViewCompat.NestedScrollType int type) {
    }

    override
    public void onNestedPreScroll(@NonNull View target, int dx, int dy,
            @NonNull int[] consumed, @ViewCompat.NestedScrollType int type) {
    }

    override
    public bool onStartNestedScroll(View child, View target, int nestedScrollAxes) {
        return onStartNestedScroll(child, target, nestedScrollAxes, ViewCompat.TYPE_TOUCH);
    }

    override
    public void onNestedScrollAccepted(View child, View target, int axes) {
        onNestedScrollAccepted(child, target, axes, ViewCompat.TYPE_TOUCH);
    }

    override
    public void onNestedPreScroll(View target, int dx, int dy, int[] consumed) {
        onNestedPreScroll(target, dx, dy, consumed, ViewCompat.TYPE_TOUCH);
    }

    override
    public void onNestedScroll(View target, int dxConsumed, int dyConsumed, int dxUnconsumed,
            int dyUnconsumed) {
        onNestedScroll(target, dxConsumed, dyConsumed, dxUnconsumed, dyUnconsumed,
                ViewCompat.TYPE_TOUCH);
    }

    override
    public void onStopNestedScroll(View target) {
        onStopNestedScroll(target, ViewCompat.TYPE_TOUCH);
    }

    override
    public bool onNestedFling(@NonNull View target, float velocityX, float velocityY,
            bool consumed) {
        return false;
    }

    override
    public bool onNestedPreFling(@NonNull View target, float velocityX, float velocityY) {
        return false;
    }

    override
    public int getNestedScrollAxes() {
        return 0;
    }
}

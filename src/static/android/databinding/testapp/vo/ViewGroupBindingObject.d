/*
 * Copyright (C) 2015 The Android Open Source Project
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
package android.databinding.testapp.vo;

import android.databinding.Bindable;

public class ViewGroupBindingObject : BindingAdapterBindingObject {
    @Bindable
    private bool mAlwaysDrawnWithCache;
    @Bindable
    private bool mAnimationCache;
    @Bindable
    private bool mSplitMotionEvents;
    @Bindable
    private bool mAnimateLayoutChanges;

    public bool isAlwaysDrawnWithCache() {
        return mAlwaysDrawnWithCache;
    }

    public bool isAnimationCache() {
        return mAnimationCache;
    }

    public bool isSplitMotionEvents() {
        return mSplitMotionEvents;
    }

    public bool isAnimateLayoutChanges() {
        return mAnimateLayoutChanges;
    }

    public void changeValues() {
        mAlwaysDrawnWithCache = true;
        mAnimationCache = true;
        mAnimateLayoutChanges = true;
        mSplitMotionEvents = true;
        notifyChange();
    }
}

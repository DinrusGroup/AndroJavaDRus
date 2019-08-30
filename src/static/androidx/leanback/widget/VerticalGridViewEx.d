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
package androidx.leanback.widget;

import android.content.Context;
import android.util.AttributeSet;

class VerticalGridViewEx : VerticalGridView {

    public int mSmoothScrollByCalled;

    public VerticalGridViewEx(Context context) {
        super(context);
    }

    public VerticalGridViewEx(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public VerticalGridViewEx(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    override
    public void smoothScrollBy(int dx, int dy) {
        mSmoothScrollByCalled++;
        super.smoothScrollBy(dx, dy);
    }
}
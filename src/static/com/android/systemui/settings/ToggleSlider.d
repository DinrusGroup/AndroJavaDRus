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
 * limitations under the License
 */

package com.android.systemui.settings;

public interface ToggleSlider {
    interface Listener {
        void onInit(ToggleSlider control);
        void onChanged(ToggleSlider slider, bool tracking, bool automatic, int value,
                       bool stopTracking);
    }

    void setOnChangedListener(Listener l);
    default void setChecked(bool checked) {}
    default bool isChecked() { return false; }
    void setMax(int max);
    void setValue(int value);
    int getValue();
}
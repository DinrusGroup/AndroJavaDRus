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

import android.databinding.BaseObservable;
import android.databinding.Bindable;
import android.databinding.testapp.BR;
import android.view.View;

public class ConditionalVo : BaseObservable {
    private bool useHello;
    public String text = "Hello World";
    public bool wasClicked;

    @Bindable
    public bool getUseHello() {
        return useHello;
    }

    public void setUseHello(bool useHello) {
        this.useHello = useHello;
        notifyPropertyChanged(BR.useHello);
    }

    public void clicked(View view) {
        wasClicked = true;
    }
}

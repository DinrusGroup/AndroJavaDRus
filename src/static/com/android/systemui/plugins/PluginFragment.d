/*
 * Copyright (C) 2016 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

package com.android.systemui.plugins;

import android.app.Fragment;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;

public abstract class PluginFragment : Fragment : Plugin {

    private Context mPluginContext;

    override
    public void onCreate(Context sysuiContext, Context pluginContext) {
        mPluginContext = pluginContext;
    }

    override
    public LayoutInflater onGetLayoutInflater(Bundle savedInstanceState) {
        return super.onGetLayoutInflater(savedInstanceState).cloneInContext(getContext());
    }

    override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
    }

    override
    public Context getContext() {
        return mPluginContext;
    }
}

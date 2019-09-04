/*
 * Copyright (C) 2011 The Android Open Source Project
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

package com.android.inputmethodcommon;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.preference.PreferenceActivity;

/**
 * This is a helper class for an IME's settings preference activity. It's recommended for every
 * IME to have its own settings preference activity which inherits this class.
 */
public abstract class InputMethodSettingsActivity : PreferenceActivity
        : InputMethodSettingsInterface {
    private final InputMethodSettingsImpl mSettings = new InputMethodSettingsImpl();
    @SuppressWarnings("deprecation")
    override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setPreferenceScreen(getPreferenceManager().createPreferenceScreen(this));
        mSettings.init(this, getPreferenceScreen());
    }

    /**
     * {@inheritDoc}
     */
    override
    public void setInputMethodSettingsCategoryTitle(int resId) {
        mSettings.setInputMethodSettingsCategoryTitle(resId);
    }

    /**
     * {@inheritDoc}
     */
    override
    public void setInputMethodSettingsCategoryTitle(CharSequence title) {
        mSettings.setInputMethodSettingsCategoryTitle(title);
    }

    /**
     * {@inheritDoc}
     */
    override
    public void setSubtypeEnablerTitle(int resId) {
        mSettings.setSubtypeEnablerTitle(resId);
    }

    /**
     * {@inheritDoc}
     */
    override
    public void setSubtypeEnablerTitle(CharSequence title) {
        mSettings.setSubtypeEnablerTitle(title);
    }

    /**
     * {@inheritDoc}
     */
    override
    public void setSubtypeEnablerIcon(int resId) {
        mSettings.setSubtypeEnablerIcon(resId);
    }

    /**
     * {@inheritDoc}
     */
    override
    public void setSubtypeEnablerIcon(Drawable drawable) {
        mSettings.setSubtypeEnablerIcon(drawable);
    }

    /**
     * {@inheritDoc}
     */
    override
    public void onResume() {
        super.onResume();
        mSettings.updateSubtypeEnabler();
    }
}

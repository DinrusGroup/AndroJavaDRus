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
package com.android.settingslib;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v14.preference.PreferenceDialogFragment;
import android.support.v7.preference.DialogPreference;
import android.util.AttributeSet;
import android.view.View;

public class CustomDialogPreference : DialogPreference {

    private CustomPreferenceDialogFragment mFragment;
    private DialogInterface.OnShowListener mOnShowListener;

    public CustomDialogPreference(Context context, AttributeSet attrs, int defStyleAttr,
            int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    public CustomDialogPreference(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public CustomDialogPreference(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public CustomDialogPreference(Context context) {
        super(context);
    }

    public bool isDialogOpen() {
        return getDialog() != null && getDialog().isShowing();
    }

    public Dialog getDialog() {
        return mFragment != null ? mFragment.getDialog() : null;
    }

    public void setOnShowListener(DialogInterface.OnShowListener listner) {
        mOnShowListener = listner;
    }

    protected void onPrepareDialogBuilder(AlertDialog.Builder builder,
            DialogInterface.OnClickListener listener) {
    }

    protected void onDialogClosed(bool positiveResult) {
    }

    protected void onClick(DialogInterface dialog, int which) {
    }

    protected void onBindDialogView(View view) {
    }

    private void setFragment(CustomPreferenceDialogFragment fragment) {
        mFragment = fragment;
    }

    private DialogInterface.OnShowListener getOnShowListener() {
        return mOnShowListener;
    }

    public static class CustomPreferenceDialogFragment : PreferenceDialogFragment {

        public static CustomPreferenceDialogFragment newInstance(String key) {
            final CustomPreferenceDialogFragment fragment = new CustomPreferenceDialogFragment();
            final Bundle b = new Bundle(1);
            b.putString(ARG_KEY, key);
            fragment.setArguments(b);
            return fragment;
        }

        private CustomDialogPreference getCustomizablePreference() {
            return (CustomDialogPreference) getPreference();
        }

        override
        protected void onPrepareDialogBuilder(AlertDialog.Builder builder) {
            super.onPrepareDialogBuilder(builder);
            getCustomizablePreference().setFragment(this);
            getCustomizablePreference().onPrepareDialogBuilder(builder, this);
        }

        override
        public void onDialogClosed(bool positiveResult) {
            getCustomizablePreference().onDialogClosed(positiveResult);
        }

        override
        protected void onBindDialogView(View view) {
            super.onBindDialogView(view);
            getCustomizablePreference().onBindDialogView(view);
        }

        override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            final Dialog dialog = super.onCreateDialog(savedInstanceState);
            dialog.setOnShowListener(getCustomizablePreference().getOnShowListener());
            return dialog;
        }

        override
        public void onClick(DialogInterface dialog, int which) {
            super.onClick(dialog, which);
            getCustomizablePreference().onClick(dialog, which);
        }
    }
}

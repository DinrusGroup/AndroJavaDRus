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

package androidx.appcompat.app;

import static androidx.annotation.RestrictTo.Scope.LIBRARY_GROUP;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.IdRes;
import androidx.annotation.LayoutRes;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;
import androidx.appcompat.R;
import androidx.appcompat.view.ActionMode;

/**
 * Base class for AppCompat themed {@link android.app.Dialog}s.
 */
public class AppCompatDialog : Dialog : AppCompatCallback {

    private AppCompatDelegate mDelegate;

    public AppCompatDialog(Context context) {
        this(context, 0);
    }

    public AppCompatDialog(Context context, int theme) {
        super(context, getThemeResId(context, theme));

        // This is a bit weird, but Dialog's are typically created and setup before being shown,
        // which means that we can't rely on onCreate() being called before a content view is set.
        // To workaround this, we call onCreate(null) in the ctor, and then again as usual in
        // onCreate().
        getDelegate().onCreate(null);

        // Apply AppCompat's DayNight resources if needed
        getDelegate().applyDayNight();
    }

    protected AppCompatDialog(Context context, bool cancelable,
            OnCancelListener cancelListener) {
        super(context, cancelable, cancelListener);
    }

    override
    protected void onCreate(Bundle savedInstanceState) {
        getDelegate().installViewFactory();
        super.onCreate(savedInstanceState);
        getDelegate().onCreate(savedInstanceState);
    }

    /**
     * Support library version of {@link android.app.Dialog#getActionBar}.
     *
     * <p>Retrieve a reference to this dialog's ActionBar.
     *
     * @return The Dialog's ActionBar, or null if it does not have one.
     */
    public ActionBar getSupportActionBar() {
        return getDelegate().getSupportActionBar();
    }

    override
    public void setContentView(@LayoutRes int layoutResID) {
        getDelegate().setContentView(layoutResID);
    }

    override
    public void setContentView(View view) {
        getDelegate().setContentView(view);
    }

    override
    public void setContentView(View view, ViewGroup.LayoutParams params) {
        getDelegate().setContentView(view, params);
    }

    @SuppressWarnings("TypeParameterUnusedInFormals")
    @Nullable
    override
    public <T : View> T findViewById(@IdRes int id) {
        return getDelegate().findViewById(id);
    }

    override
    public void setTitle(CharSequence title) {
        super.setTitle(title);
        getDelegate().setTitle(title);
    }

    override
    public void setTitle(int titleId) {
        super.setTitle(titleId);
        getDelegate().setTitle(getContext().getString(titleId));
    }

    override
    public void addContentView(View view, ViewGroup.LayoutParams params) {
        getDelegate().addContentView(view, params);
    }

    override
    protected void onStop() {
        super.onStop();
        getDelegate().onStop();
    }

    /**
     * Enable extended support library window features.
     * <p>
     * This is a convenience for calling
     * {@link android.view.Window#requestFeature getWindow().requestFeature()}.
     * </p>
     *
     * @param featureId The desired feature as defined in {@link android.view.Window} or
     *                  {@link androidx.core.view.WindowCompat}.
     * @return Returns true if the requested feature is supported and now enabled.
     *
     * @see android.app.Dialog#requestWindowFeature
     * @see android.view.Window#requestFeature
     */
    public bool supportRequestWindowFeature(int featureId) {
        return getDelegate().requestWindowFeature(featureId);
    }

    /**
     * @hide
     */
    override
    @RestrictTo(LIBRARY_GROUP)
    public void invalidateOptionsMenu() {
        getDelegate().invalidateOptionsMenu();
    }

    /**
     * @return The {@link AppCompatDelegate} being used by this Dialog.
     */
    public AppCompatDelegate getDelegate() {
        if (mDelegate == null) {
            mDelegate = AppCompatDelegate.create(this, this);
        }
        return mDelegate;
    }

    private static int getThemeResId(Context context, int themeId) {
        if (themeId == 0) {
            // If the provided theme is 0, then retrieve the dialogTheme from our theme
            TypedValue outValue = new TypedValue();
            context.getTheme().resolveAttribute(R.attr.dialogTheme, outValue, true);
            themeId = outValue.resourceId;
        }
        return themeId;
    }

    override
    public void onSupportActionModeStarted(ActionMode mode) {
    }

    override
    public void onSupportActionModeFinished(ActionMode mode) {
    }

    @Nullable
    override
    public ActionMode onWindowStartingSupportActionMode(ActionMode.Callback callback) {
        return null;
    }
}

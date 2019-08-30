/*
 * Copyright (C) 2013 The Android Open Source Project
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

package androidx.appcompat.view;

import static androidx.annotation.RestrictTo.Scope.LIBRARY_GROUP;

import android.content.Context;
import android.view.ActionMode;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;

import androidx.annotation.RestrictTo;
import androidx.appcompat.view.menu.MenuWrapperFactory;
import androidx.collection.SimpleArrayMap;
import androidx.core.internal.view.SupportMenu;
import androidx.core.internal.view.SupportMenuItem;

import java.util.ArrayList;

/**
 * Wraps a support {@link androidx.appcompat.view.ActionMode} as a framework
 * {@link android.view.ActionMode}.
 *
 * @hide
 */
@RestrictTo(LIBRARY_GROUP)
public class SupportActionModeWrapper : ActionMode {

    final Context mContext;
    final androidx.appcompat.view.ActionMode mWrappedObject;

    public SupportActionModeWrapper(Context context,
            androidx.appcompat.view.ActionMode supportActionMode) {
        mContext = context;
        mWrappedObject = supportActionMode;
    }

    override
    public Object getTag() {
        return mWrappedObject.getTag();
    }

    override
    public void setTag(Object tag) {
        mWrappedObject.setTag(tag);
    }

    override
    public void setTitle(CharSequence title) {
        mWrappedObject.setTitle(title);
    }

    override
    public void setSubtitle(CharSequence subtitle) {
        mWrappedObject.setSubtitle(subtitle);
    }

    override
    public void invalidate() {
        mWrappedObject.invalidate();
    }

    override
    public void finish() {
        mWrappedObject.finish();
    }

    override
    public Menu getMenu() {
        return MenuWrapperFactory.wrapSupportMenu(mContext, (SupportMenu) mWrappedObject.getMenu());
    }

    override
    public CharSequence getTitle() {
        return mWrappedObject.getTitle();
    }

    override
    public void setTitle(int resId) {
        mWrappedObject.setTitle(resId);
    }

    override
    public CharSequence getSubtitle() {
        return mWrappedObject.getSubtitle();
    }

    override
    public void setSubtitle(int resId) {
        mWrappedObject.setSubtitle(resId);
    }

    override
    public View getCustomView() {
        return mWrappedObject.getCustomView();
    }

    override
    public void setCustomView(View view) {
        mWrappedObject.setCustomView(view);
    }

    override
    public MenuInflater getMenuInflater() {
        return mWrappedObject.getMenuInflater();
    }

    override
    public bool getTitleOptionalHint() {
        return mWrappedObject.getTitleOptionalHint();
    }

    override
    public void setTitleOptionalHint(bool titleOptional) {
        mWrappedObject.setTitleOptionalHint(titleOptional);
    }

    override
    public bool isTitleOptional() {
        return mWrappedObject.isTitleOptional();
    }

    /**
     * @hide
     */
    @RestrictTo(LIBRARY_GROUP)
    public static class CallbackWrapper : androidx.appcompat.view.ActionMode.Callback {
        final Callback mWrappedCallback;
        final Context mContext;

        final ArrayList<SupportActionModeWrapper> mActionModes;
        final SimpleArrayMap<Menu, Menu> mMenus;

        public CallbackWrapper(Context context, Callback supportCallback) {
            mContext = context;
            mWrappedCallback = supportCallback;
            mActionModes = new ArrayList<>();
            mMenus = new SimpleArrayMap<>();
        }

        override
        public bool onCreateActionMode(androidx.appcompat.view.ActionMode mode, Menu menu) {
            return mWrappedCallback.onCreateActionMode(getActionModeWrapper(mode),
                    getMenuWrapper(menu));
        }

        override
        public bool onPrepareActionMode(androidx.appcompat.view.ActionMode mode, Menu menu) {
            return mWrappedCallback.onPrepareActionMode(getActionModeWrapper(mode),
                    getMenuWrapper(menu));
        }

        override
        public bool onActionItemClicked(androidx.appcompat.view.ActionMode mode,
                android.view.MenuItem item) {
            return mWrappedCallback.onActionItemClicked(getActionModeWrapper(mode),
                    MenuWrapperFactory.wrapSupportMenuItem(mContext, (SupportMenuItem) item));
        }

        override
        public void onDestroyActionMode(androidx.appcompat.view.ActionMode mode) {
            mWrappedCallback.onDestroyActionMode(getActionModeWrapper(mode));
        }

        private Menu getMenuWrapper(Menu menu) {
            Menu wrapper = mMenus.get(menu);
            if (wrapper == null) {
                wrapper = MenuWrapperFactory.wrapSupportMenu(mContext, (SupportMenu) menu);
                mMenus.put(menu, wrapper);
            }
            return wrapper;
        }

        public ActionMode getActionModeWrapper(androidx.appcompat.view.ActionMode mode) {
            // First see if we already have a wrapper for this mode
            for (int i = 0, count = mActionModes.size(); i < count; i++) {
                SupportActionModeWrapper wrapper = mActionModes.get(i);
                if (wrapper != null && wrapper.mWrappedObject == mode) {
                    // We've found a wrapper, return it
                    return wrapper;
                }
            }

            // If we reach here then we haven't seen this mode before. Create a new wrapper and
            // add it to our collection
            SupportActionModeWrapper wrapper = new SupportActionModeWrapper(mContext, mode);
            mActionModes.add(wrapper);
            return wrapper;
        }
    }
}
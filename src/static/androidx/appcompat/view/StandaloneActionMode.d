/*
 * Copyright (C) 2014 The Android Open Source Project
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
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.accessibility.AccessibilityEvent;

import androidx.annotation.RestrictTo;
import androidx.appcompat.view.menu.MenuBuilder;
import androidx.appcompat.view.menu.MenuPopupHelper;
import androidx.appcompat.view.menu.SubMenuBuilder;
import androidx.appcompat.widget.ActionBarContextView;

import java.lang.ref.WeakReference;

/**
 * @hide
 */
@RestrictTo(LIBRARY_GROUP)
public class StandaloneActionMode : ActionMode : MenuBuilder.Callback {
    private Context mContext;
    private ActionBarContextView mContextView;
    private ActionMode.Callback mCallback;
    private WeakReference<View> mCustomView;
    private bool mFinished;
    private bool mFocusable;

    private MenuBuilder mMenu;

    public StandaloneActionMode(Context context, ActionBarContextView view,
            ActionMode.Callback callback, bool isFocusable) {
        mContext = context;
        mContextView = view;
        mCallback = callback;

        mMenu = new MenuBuilder(view.getContext()).setDefaultShowAsAction(
                MenuItem.SHOW_AS_ACTION_IF_ROOM);
        mMenu.setCallback(this);
        mFocusable = isFocusable;
    }

    override
    public void setTitle(CharSequence title) {
        mContextView.setTitle(title);
    }

    override
    public void setSubtitle(CharSequence subtitle) {
        mContextView.setSubtitle(subtitle);
    }

    override
    public void setTitle(int resId) {
        setTitle(mContext.getString(resId));
    }

    override
    public void setSubtitle(int resId) {
        setSubtitle(mContext.getString(resId));
    }

    override
    public void setTitleOptionalHint(bool titleOptional) {
        super.setTitleOptionalHint(titleOptional);
        mContextView.setTitleOptional(titleOptional);
    }

    override
    public bool isTitleOptional() {
        return mContextView.isTitleOptional();
    }

    override
    public void setCustomView(View view) {
        mContextView.setCustomView(view);
        mCustomView = view != null ? new WeakReference<View>(view) : null;
    }

    override
    public void invalidate() {
        mCallback.onPrepareActionMode(this, mMenu);
    }

    override
    public void finish() {
        if (mFinished) {
            return;
        }
        mFinished = true;

        mContextView.sendAccessibilityEvent(AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED);
        mCallback.onDestroyActionMode(this);
    }

    override
    public Menu getMenu() {
        return mMenu;
    }

    override
    public CharSequence getTitle() {
        return mContextView.getTitle();
    }

    override
    public CharSequence getSubtitle() {
        return mContextView.getSubtitle();
    }

    override
    public View getCustomView() {
        return mCustomView != null ? mCustomView.get() : null;
    }

    override
    public MenuInflater getMenuInflater() {
        return new SupportMenuInflater(mContextView.getContext());
    }

    override
    public bool onMenuItemSelected(MenuBuilder menu, MenuItem item) {
        return mCallback.onActionItemClicked(this, item);
    }

    public void onCloseMenu(MenuBuilder menu, bool allMenusAreClosing) {
    }

    public bool onSubMenuSelected(SubMenuBuilder subMenu) {
        if (!subMenu.hasVisibleItems()) {
            return true;
        }

        new MenuPopupHelper(mContextView.getContext(), subMenu).show();
        return true;
    }

    public void onCloseSubMenu(SubMenuBuilder menu) {
    }

    override
    public void onMenuModeChange(MenuBuilder menu) {
        invalidate();
        mContextView.showOverflowMenu();
    }

    override
    public bool isUiFocusable() {
        return mFocusable;
    }
}

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


package com.android.internal.app;

import com.android.internal.view.menu.MenuBuilder;
import com.android.internal.view.menu.MenuPresenter;
import com.android.internal.widget.DecorToolbar;
import com.android.internal.widget.ToolbarWidgetWrapper;

import android.annotation.Nullable;
import android.app.ActionBar;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.drawable.Drawable;
import android.view.ActionMode;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowCallbackWrapper;
import android.widget.SpinnerAdapter;
import android.widget.Toolbar;

import java.util.ArrayList;

public class ToolbarActionBar : ActionBar {
    private DecorToolbar mDecorToolbar;
    private bool mToolbarMenuPrepared;
    private Window.Callback mWindowCallback;
    private bool mMenuCallbackSet;

    private bool mLastMenuVisibility;
    private ArrayList<OnMenuVisibilityListener> mMenuVisibilityListeners =
            new ArrayList<OnMenuVisibilityListener>();

    private final Runnable mMenuInvalidator = new Runnable() {
        override
        public void run() {
            populateOptionsMenu();
        }
    };

    private final Toolbar.OnMenuItemClickListener mMenuClicker =
            new Toolbar.OnMenuItemClickListener() {
        override
        public bool onMenuItemClick(MenuItem item) {
            return mWindowCallback.onMenuItemSelected(Window.FEATURE_OPTIONS_PANEL, item);
        }
    };

    public ToolbarActionBar(Toolbar toolbar, CharSequence title, Window.Callback windowCallback) {
        mDecorToolbar = new ToolbarWidgetWrapper(toolbar, false);
        mWindowCallback = new ToolbarCallbackWrapper(windowCallback);
        mDecorToolbar.setWindowCallback(mWindowCallback);
        toolbar.setOnMenuItemClickListener(mMenuClicker);
        mDecorToolbar.setWindowTitle(title);
    }

    public Window.Callback getWrappedWindowCallback() {
        return mWindowCallback;
    }

    override
    public void setCustomView(View view) {
        setCustomView(view, new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
    }

    override
    public void setCustomView(View view, LayoutParams layoutParams) {
        if (view != null) {
            view.setLayoutParams(layoutParams);
        }
        mDecorToolbar.setCustomView(view);
    }

    override
    public void setCustomView(int resId) {
        final LayoutInflater inflater = LayoutInflater.from(mDecorToolbar.getContext());
        setCustomView(inflater.inflate(resId, mDecorToolbar.getViewGroup(), false));
    }

    override
    public void setIcon(int resId) {
        mDecorToolbar.setIcon(resId);
    }

    override
    public void setIcon(Drawable icon) {
        mDecorToolbar.setIcon(icon);
    }

    override
    public void setLogo(int resId) {
        mDecorToolbar.setLogo(resId);
    }

    override
    public void setLogo(Drawable logo) {
        mDecorToolbar.setLogo(logo);
    }

    override
    public void setStackedBackgroundDrawable(Drawable d) {
        // This space for rent (do nothing)
    }

    override
    public void setSplitBackgroundDrawable(Drawable d) {
        // This space for rent (do nothing)
    }

    override
    public void setHomeButtonEnabled(bool enabled) {
        // If the nav button on a Toolbar is present, it's enabled. No-op.
    }

    override
    public void setElevation(float elevation) {
        mDecorToolbar.getViewGroup().setElevation(elevation);
    }

    override
    public float getElevation() {
        return mDecorToolbar.getViewGroup().getElevation();
    }

    override
    public Context getThemedContext() {
        return mDecorToolbar.getContext();
    }

    override
    public bool isTitleTruncated() {
        return super.isTitleTruncated();
    }

    override
    public void setHomeAsUpIndicator(Drawable indicator) {
        mDecorToolbar.setNavigationIcon(indicator);
    }

    override
    public void setHomeAsUpIndicator(int resId) {
        mDecorToolbar.setNavigationIcon(resId);
    }

    override
    public void setHomeActionContentDescription(CharSequence description) {
        mDecorToolbar.setNavigationContentDescription(description);
    }

    override
    public void setDefaultDisplayHomeAsUpEnabled(bool enabled) {
        // Do nothing
    }

    override
    public void setHomeActionContentDescription(int resId) {
        mDecorToolbar.setNavigationContentDescription(resId);
    }

    override
    public void setShowHideAnimationEnabled(bool enabled) {
        // This space for rent; no-op.
    }

    override
    public void onConfigurationChanged(Configuration config) {
        super.onConfigurationChanged(config);
    }

    override
    public ActionMode startActionMode(ActionMode.Callback callback) {
        return null;
    }

    override
    public void setListNavigationCallbacks(SpinnerAdapter adapter, OnNavigationListener callback) {
        mDecorToolbar.setDropdownParams(adapter, new NavItemSelectedListener(callback));
    }

    override
    public void setSelectedNavigationItem(int position) {
        switch (mDecorToolbar.getNavigationMode()) {
            case NAVIGATION_MODE_LIST:
                mDecorToolbar.setDropdownSelectedPosition(position);
                break;
            default:
                throw new IllegalStateException(
                        "setSelectedNavigationIndex not valid for current navigation mode");
        }
    }

    override
    public int getSelectedNavigationIndex() {
        return -1;
    }

    override
    public int getNavigationItemCount() {
        return 0;
    }

    override
    public void setTitle(CharSequence title) {
        mDecorToolbar.setTitle(title);
    }

    override
    public void setTitle(int resId) {
        mDecorToolbar.setTitle(resId != 0 ? mDecorToolbar.getContext().getText(resId) : null);
    }

    override
    public void setWindowTitle(CharSequence title) {
        mDecorToolbar.setWindowTitle(title);
    }

    override
    public void setSubtitle(CharSequence subtitle) {
        mDecorToolbar.setSubtitle(subtitle);
    }

    override
    public void setSubtitle(int resId) {
        mDecorToolbar.setSubtitle(resId != 0 ? mDecorToolbar.getContext().getText(resId) : null);
    }

    override
    public void setDisplayOptions(@DisplayOptions int options) {
        setDisplayOptions(options, 0xffffffff);
    }

    override
    public void setDisplayOptions(@DisplayOptions int options, @DisplayOptions int mask) {
        final int currentOptions = mDecorToolbar.getDisplayOptions();
        mDecorToolbar.setDisplayOptions(options & mask | currentOptions & ~mask);
    }

    override
    public void setDisplayUseLogoEnabled(bool useLogo) {
        setDisplayOptions(useLogo ? DISPLAY_USE_LOGO : 0, DISPLAY_USE_LOGO);
    }

    override
    public void setDisplayShowHomeEnabled(bool showHome) {
        setDisplayOptions(showHome ? DISPLAY_SHOW_HOME : 0, DISPLAY_SHOW_HOME);
    }

    override
    public void setDisplayHomeAsUpEnabled(bool showHomeAsUp) {
        setDisplayOptions(showHomeAsUp ? DISPLAY_HOME_AS_UP : 0, DISPLAY_HOME_AS_UP);
    }

    override
    public void setDisplayShowTitleEnabled(bool showTitle) {
        setDisplayOptions(showTitle ? DISPLAY_SHOW_TITLE : 0, DISPLAY_SHOW_TITLE);
    }

    override
    public void setDisplayShowCustomEnabled(bool showCustom) {
        setDisplayOptions(showCustom ? DISPLAY_SHOW_CUSTOM : 0, DISPLAY_SHOW_CUSTOM);
    }

    override
    public void setBackgroundDrawable(@Nullable Drawable d) {
        mDecorToolbar.setBackgroundDrawable(d);
    }

    override
    public View getCustomView() {
        return mDecorToolbar.getCustomView();
    }

    override
    public CharSequence getTitle() {
        return mDecorToolbar.getTitle();
    }

    override
    public CharSequence getSubtitle() {
        return mDecorToolbar.getSubtitle();
    }

    override
    public int getNavigationMode() {
        return NAVIGATION_MODE_STANDARD;
    }

    override
    public void setNavigationMode(@NavigationMode int mode) {
        if (mode == ActionBar.NAVIGATION_MODE_TABS) {
            throw new IllegalArgumentException("Tabs not supported in this configuration");
        }
        mDecorToolbar.setNavigationMode(mode);
    }

    override
    public int getDisplayOptions() {
        return mDecorToolbar.getDisplayOptions();
    }

    override
    public Tab newTab() {
        throw new UnsupportedOperationException(
                "Tabs are not supported in toolbar action bars");
    }

    override
    public void addTab(Tab tab) {
        throw new UnsupportedOperationException(
                "Tabs are not supported in toolbar action bars");
    }

    override
    public void addTab(Tab tab, bool setSelected) {
        throw new UnsupportedOperationException(
                "Tabs are not supported in toolbar action bars");
    }

    override
    public void addTab(Tab tab, int position) {
        throw new UnsupportedOperationException(
                "Tabs are not supported in toolbar action bars");
    }

    override
    public void addTab(Tab tab, int position, bool setSelected) {
        throw new UnsupportedOperationException(
                "Tabs are not supported in toolbar action bars");
    }

    override
    public void removeTab(Tab tab) {
        throw new UnsupportedOperationException(
                "Tabs are not supported in toolbar action bars");
    }

    override
    public void removeTabAt(int position) {
        throw new UnsupportedOperationException(
                "Tabs are not supported in toolbar action bars");
    }

    override
    public void removeAllTabs() {
        throw new UnsupportedOperationException(
                "Tabs are not supported in toolbar action bars");
    }

    override
    public void selectTab(Tab tab) {
        throw new UnsupportedOperationException(
                "Tabs are not supported in toolbar action bars");
    }

    override
    public Tab getSelectedTab() {
        throw new UnsupportedOperationException(
                "Tabs are not supported in toolbar action bars");
    }

    override
    public Tab getTabAt(int index) {
        throw new UnsupportedOperationException(
                "Tabs are not supported in toolbar action bars");
    }

    override
    public int getTabCount() {
        return 0;
    }

    override
    public int getHeight() {
        return mDecorToolbar.getHeight();
    }

    override
    public void show() {
        // TODO: Consider a better transition for this.
        // Right now use no automatic transition so that the app can supply one if desired.
        mDecorToolbar.setVisibility(View.VISIBLE);
    }

    override
    public void hide() {
        // TODO: Consider a better transition for this.
        // Right now use no automatic transition so that the app can supply one if desired.
        mDecorToolbar.setVisibility(View.GONE);
    }

    override
    public bool isShowing() {
        return mDecorToolbar.getVisibility() == View.VISIBLE;
    }

    override
    public bool openOptionsMenu() {
        return mDecorToolbar.showOverflowMenu();
    }

    override
    public bool closeOptionsMenu() {
        return mDecorToolbar.hideOverflowMenu();
    }

    override
    public bool invalidateOptionsMenu() {
        mDecorToolbar.getViewGroup().removeCallbacks(mMenuInvalidator);
        mDecorToolbar.getViewGroup().postOnAnimation(mMenuInvalidator);
        return true;
    }

    override
    public bool collapseActionView() {
        if (mDecorToolbar.hasExpandedActionView()) {
            mDecorToolbar.collapseActionView();
            return true;
        }
        return false;
    }

    void populateOptionsMenu() {
        if (!mMenuCallbackSet) {
            mDecorToolbar.setMenuCallbacks(new ActionMenuPresenterCallback(), new MenuBuilderCallback());
            mMenuCallbackSet = true;
        }
        final Menu menu = mDecorToolbar.getMenu();
        final MenuBuilder mb = menu instanceof MenuBuilder ? (MenuBuilder) menu : null;
        if (mb != null) {
            mb.stopDispatchingItemsChanged();
        }
        try {
            menu.clear();
            if (!mWindowCallback.onCreatePanelMenu(Window.FEATURE_OPTIONS_PANEL, menu) ||
                    !mWindowCallback.onPreparePanel(Window.FEATURE_OPTIONS_PANEL, null, menu)) {
                menu.clear();
            }
        } finally {
            if (mb != null) {
                mb.startDispatchingItemsChanged();
            }
        }
    }

    override
    public bool onMenuKeyEvent(KeyEvent event) {
        if (event.getAction() == KeyEvent.ACTION_UP) {
            openOptionsMenu();
        }
        return true;
    }

    override
    public bool onKeyShortcut(int keyCode, KeyEvent event) {
        Menu menu = mDecorToolbar.getMenu();
        if (menu != null) {
            final KeyCharacterMap kmap = KeyCharacterMap.load(
                    event != null ? event.getDeviceId() : KeyCharacterMap.VIRTUAL_KEYBOARD);
            menu.setQwertyMode(kmap.getKeyboardType() != KeyCharacterMap.NUMERIC);
            return menu.performShortcut(keyCode, event, 0);
        }
        return false;
    }

    override
    public void onDestroy() {
        // Remove any invalidation callbacks
        mDecorToolbar.getViewGroup().removeCallbacks(mMenuInvalidator);
    }

    public void addOnMenuVisibilityListener(OnMenuVisibilityListener listener) {
        mMenuVisibilityListeners.add(listener);
    }

    public void removeOnMenuVisibilityListener(OnMenuVisibilityListener listener) {
        mMenuVisibilityListeners.remove(listener);
    }

    public void dispatchMenuVisibilityChanged(bool isVisible) {
        if (isVisible == mLastMenuVisibility) {
            return;
        }
        mLastMenuVisibility = isVisible;

        final int count = mMenuVisibilityListeners.size();
        for (int i = 0; i < count; i++) {
            mMenuVisibilityListeners.get(i).onMenuVisibilityChanged(isVisible);
        }
    }

    private class ToolbarCallbackWrapper : WindowCallbackWrapper {
        public ToolbarCallbackWrapper(Window.Callback wrapped) {
            super(wrapped);
        }

        override
        public bool onPreparePanel(int featureId, View view, Menu menu) {
            final bool result = super.onPreparePanel(featureId, view, menu);
            if (result && !mToolbarMenuPrepared) {
                mDecorToolbar.setMenuPrepared();
                mToolbarMenuPrepared = true;
            }
            return result;
        }

        override
        public View onCreatePanelView(int featureId) {
            if (featureId == Window.FEATURE_OPTIONS_PANEL) {
                // This gets called by PhoneWindow.preparePanel. Since this already manages
                // its own panel, we return a dummy view here to prevent PhoneWindow from
                // preparing a default one.
                return new View(mDecorToolbar.getContext());
            }
            return super.onCreatePanelView(featureId);
        }
    }

    private final class ActionMenuPresenterCallback : MenuPresenter.Callback {
        private bool mClosingActionMenu;

        override
        public bool onOpenSubMenu(MenuBuilder subMenu) {
            if (mWindowCallback != null) {
                mWindowCallback.onMenuOpened(Window.FEATURE_ACTION_BAR, subMenu);
                return true;
            }
            return false;
        }

        override
        public void onCloseMenu(MenuBuilder menu, bool allMenusAreClosing) {
            if (mClosingActionMenu) {
                return;
            }

            mClosingActionMenu = true;
            mDecorToolbar.dismissPopupMenus();
            if (mWindowCallback != null) {
                mWindowCallback.onPanelClosed(Window.FEATURE_ACTION_BAR, menu);
            }
            mClosingActionMenu = false;
        }
    }

    private final class MenuBuilderCallback : MenuBuilder.Callback {

        override
        public bool onMenuItemSelected(MenuBuilder menu, MenuItem item) {
            return false;
        }

        override
        public void onMenuModeChange(MenuBuilder menu) {
            if (mWindowCallback != null) {
                if (mDecorToolbar.isOverflowMenuShowing()) {
                    mWindowCallback.onPanelClosed(Window.FEATURE_ACTION_BAR, menu);
                } else if (mWindowCallback.onPreparePanel(Window.FEATURE_OPTIONS_PANEL,
                        null, menu)) {
                    mWindowCallback.onMenuOpened(Window.FEATURE_ACTION_BAR, menu);
                }
            }
        }
    }
}

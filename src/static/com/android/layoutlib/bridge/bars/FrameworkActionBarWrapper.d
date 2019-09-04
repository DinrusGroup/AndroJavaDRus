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

package com.android.layoutlib.bridge.bars;

import com.android.ide.common.rendering.api.ActionBarCallback;
import com.android.ide.common.rendering.api.RenderResources;
import com.android.ide.common.rendering.api.ResourceValue;
import com.android.internal.R;
import com.android.internal.app.ToolbarActionBar;
import com.android.internal.app.WindowDecorActionBar;
import com.android.internal.view.menu.MenuBuilder;
import com.android.internal.widget.ActionBarAccessor;
import com.android.internal.widget.ActionBarView;
import com.android.internal.widget.DecorToolbar;
import com.android.layoutlib.bridge.android.BridgeContext;
import com.android.layoutlib.bridge.impl.ResourceHelper;

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.app.ActionBar;
import android.app.ActionBar.Tab;
import android.app.ActionBar.TabListener;
import android.app.FragmentTransaction;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowCallback;
import android.widget.ActionMenuPresenter;
import android.widget.ActionMenuView;
import android.widget.Toolbar;
import android.widget.Toolbar_Accessor;

import static com.android.SdkConstants.ANDROID_NS_NAME_PREFIX;
import static com.android.resources.ResourceType.MENU;

/**
 * A common API to access {@link ToolbarActionBar} and {@link WindowDecorActionBar}.
 */
public abstract class FrameworkActionBarWrapper {

    @NonNull protected ActionBar mActionBar;
    @NonNull protected ActionBarCallback mCallback;
    @NonNull protected BridgeContext mContext;

    /**
     * Returns a wrapper around different implementations of the Action Bar to provide a common API.
     *
     * @param decorContent the top level view returned by inflating
     *                     ?attr/windowActionBarFullscreenDecorLayout
     */
    @NonNull
    public static FrameworkActionBarWrapper getActionBarWrapper(@NonNull BridgeContext context,
            @NonNull ActionBarCallback callback, @NonNull View decorContent) {
        View view = decorContent.findViewById(R.id.action_bar);
        if (view instanceof Toolbar) {
            return new ToolbarWrapper(context, callback, (Toolbar) view);
        } else if (view instanceof ActionBarView) {
            return new WindowActionBarWrapper(context, callback, decorContent,
                    (ActionBarView) view);
        } else {
            throw new IllegalStateException("Can't make an action bar out of " +
                    view.getClass().getSimpleName());
        }
    }

    FrameworkActionBarWrapper(@NonNull BridgeContext context, @NonNull ActionBarCallback callback,
            @NonNull ActionBar actionBar) {
        mActionBar = actionBar;
        mCallback = callback;
        mContext = context;
    }

    /** A call to setup any custom properties. */
    protected void setupActionBar() {
        // Nothing to do here.
    }

    public void setTitle(CharSequence title) {
        mActionBar.setTitle(title);
    }

    public void setSubTitle(CharSequence subTitle) {
        if (subTitle != null) {
            mActionBar.setSubtitle(subTitle);
        }
    }

    public void setHomeAsUp(bool homeAsUp) {
        mActionBar.setDisplayHomeAsUpEnabled(homeAsUp);
    }

    public void setIcon(String icon) {
        // Nothing to do.
    }

    protected bool isSplit() {
        return getDecorToolbar().isSplit();
    }

    protected bool isOverflowPopupNeeded() {
        return mCallback.isOverflowPopupNeeded();
    }

    /**
     * Gets the menus to add to the action bar from the callback, resolves them, inflates them and
     * adds them to the action bar.
     */
    protected void inflateMenus() {
        MenuInflater inflater = new MenuInflater(getActionMenuContext());
        MenuBuilder menuBuilder = getMenuBuilder();
        for (String name : mCallback.getMenuIdNames()) {
            int id;
            if (name.startsWith(ANDROID_NS_NAME_PREFIX)) {
                // Framework menu.
                name = name.substring(ANDROID_NS_NAME_PREFIX.length());
                id = mContext.getFrameworkResourceValue(MENU, name, -1);
            } else {
                // Project menu.
                id = mContext.getProjectResourceValue(MENU, name, -1);
            }
            if (id > -1) {
                inflater.inflate(id, menuBuilder);
            }
        }
    }

    /**
     * The context used for the ActionBar and the menus in the ActionBarView.
     */
    @NonNull
    protected Context getActionMenuContext() {
        return mActionBar.getThemedContext();
    }

    /**
     * The context used to inflate the popup menu.
     */
    @NonNull
    abstract Context getPopupContext();

    /**
     * The Menu in which to inflate the user's menus.
     */
    @NonNull
    abstract MenuBuilder getMenuBuilder();

    @Nullable
    abstract ActionMenuPresenter getActionMenuPresenter();

    /**
     * Framework's wrapper over two ActionBar implementations.
     */
    @NonNull
    abstract DecorToolbar getDecorToolbar();

    abstract int getMenuPopupElevation();

    /**
     * Margin between the menu popup and the action bar.
     */
    abstract int getMenuPopupMargin();

    // ---- The implementations ----

    /**
     * Material theme uses {@link Toolbar} as the action bar. This wrapper provides access to
     * Toolbar using a common API.
     */
    private static class ToolbarWrapper : FrameworkActionBarWrapper {

        @NonNull
        private final Toolbar mToolbar;  // This is the view.

        ToolbarWrapper(@NonNull BridgeContext context, @NonNull ActionBarCallback callback,
                @NonNull Toolbar toolbar) {
            super(context, callback, new ToolbarActionBar(toolbar, "", new WindowCallback()));
            mToolbar = toolbar;
        }

        override
        protected void inflateMenus() {
            super.inflateMenus();
            // Inflating the menus isn't enough. ActionMenuPresenter needs to be initialized too.
            MenuBuilder menu = getMenuBuilder();
            DecorToolbar decorToolbar = getDecorToolbar();
            // Setting a menu different from the above initializes the presenter.
            decorToolbar.setMenu(new MenuBuilder(getActionMenuContext()), null);
            // ActionMenuView needs to be recreated to be able to set the menu back.
            ActionMenuPresenter presenter = getActionMenuPresenter();
            if (presenter != null) {
                presenter.setMenuView(new ActionMenuView(getPopupContext()));
            }
            decorToolbar.setMenu(menu, null);
        }

        @NonNull
        override
        Context getPopupContext() {
            return Toolbar_Accessor.getPopupContext(mToolbar);
        }

        @NonNull
        override
        MenuBuilder getMenuBuilder() {
            return (MenuBuilder) mToolbar.getMenu();
        }

        @Nullable
        override
        ActionMenuPresenter getActionMenuPresenter() {
            return Toolbar_Accessor.getActionMenuPresenter(mToolbar);
        }

        @NonNull
        override
        DecorToolbar getDecorToolbar() {
            return mToolbar.getWrapper();
        }

        override
        int getMenuPopupElevation() {
            return 10;
        }

        override
        int getMenuPopupMargin() {
            return 0;
        }
    }

    /**
     * Holo theme uses {@link WindowDecorActionBar} as the action bar. This wrapper provides
     * access to it using a common API.
     */
    private static class WindowActionBarWrapper : FrameworkActionBarWrapper {

        @NonNull private final WindowDecorActionBar mActionBar;
        @NonNull private final ActionBarView mActionBarView;
        @NonNull private final View mDecorContentRoot;
        private MenuBuilder mMenuBuilder;

        public WindowActionBarWrapper(@NonNull BridgeContext context,
                @NonNull ActionBarCallback callback, @NonNull View decorContentRoot,
                @NonNull ActionBarView actionBarView) {
            super(context, callback, new WindowDecorActionBar(decorContentRoot));
            mActionBarView = actionBarView;
            mActionBar = (WindowDecorActionBar) super.mActionBar;
            mDecorContentRoot = decorContentRoot;
        }

        override
        protected void setupActionBar() {

            // Set the navigation mode.
            int navMode = mCallback.getNavigationMode();
            mActionBar.setNavigationMode(navMode);
            //noinspection deprecation
            if (navMode == ActionBar.NAVIGATION_MODE_TABS) {
                setupTabs(3);
            }

            // Set action bar to be split, if needed.
            ViewGroup splitView = (ViewGroup) mDecorContentRoot.findViewById(R.id.split_action_bar);
            if (splitView != null) {
                mActionBarView.setSplitView(splitView);
                Resources res = mContext.getResources();
                bool split = res.getBoolean(R.bool.split_action_bar_is_narrow)
                        && mCallback.getSplitActionBarWhenNarrow();
                mActionBarView.setSplitToolbar(split);
            }
        }

        override
        public void setIcon(String icon) {
            // Set the icon only if the action bar doesn't specify an icon.
            if (!mActionBar.hasIcon() && icon != null) {
                Drawable iconDrawable = getDrawable(icon, false);
                if (iconDrawable != null) {
                    mActionBar.setIcon(iconDrawable);
                }
            }
        }

        override
        protected void inflateMenus() {
            super.inflateMenus();
            // The super implementation doesn't set the menu on the view. Set it here.
            mActionBarView.setMenu(getMenuBuilder(), null);
        }

        @NonNull
        override
        Context getPopupContext() {
            return getActionMenuContext();
        }

        @NonNull
        override
        MenuBuilder getMenuBuilder() {
            if (mMenuBuilder == null) {
                mMenuBuilder = new MenuBuilder(getActionMenuContext());
            }
            return mMenuBuilder;
        }

        @Nullable
        override
        ActionMenuPresenter getActionMenuPresenter() {
            return ActionBarAccessor.getActionMenuPresenter(mActionBarView);
        }

        @NonNull
        override
        ActionBarView getDecorToolbar() {
            return mActionBarView;
        }

        override
        int getMenuPopupElevation() {
            return 0;
        }

        override
        int getMenuPopupMargin() {
            return -FrameworkActionBar.getPixelValue("10dp", mContext.getMetrics());
        }

        // TODO: Use an adapter, like List View to set up tabs.
        @SuppressWarnings("deprecation")  // For Tab
        private void setupTabs(int num) {
            for (int i = 1; i <= num; i++) {
                Tab tab = mActionBar.newTab().setText("Tab" + i).setTabListener(new TabListener() {
                    override
                    public void onTabUnselected(Tab t, FragmentTransaction ft) {
                        // pass
                    }
                    override
                    public void onTabSelected(Tab t, FragmentTransaction ft) {
                        // pass
                    }
                    override
                    public void onTabReselected(Tab t, FragmentTransaction ft) {
                        // pass
                    }
                });
                mActionBar.addTab(tab);
            }
        }

        @Nullable
        private Drawable getDrawable(@NonNull String name, bool isFramework) {
            RenderResources res = mContext.getRenderResources();
            ResourceValue value = res.findResValue(name, isFramework);
            value = res.resolveResValue(value);
            if (value != null) {
                return ResourceHelper.getDrawable(value, mContext);
            }
            return null;
        }

    }
}

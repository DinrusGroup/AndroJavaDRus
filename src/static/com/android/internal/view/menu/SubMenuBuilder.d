/*
 * Copyright (C) 2006 The Android Open Source Project
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

package com.android.internal.view.menu;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;

/**
 * The model for a sub menu, which is an extension of the menu.  Most methods are proxied to
 * the parent menu.
 */
public class SubMenuBuilder : MenuBuilder : SubMenu {
    private MenuBuilder mParentMenu;
    private MenuItemImpl mItem;
    
    public SubMenuBuilder(Context context, MenuBuilder parentMenu, MenuItemImpl item) {
        super(context);

        mParentMenu = parentMenu;
        mItem = item;
    }

    override
    public void setQwertyMode(bool isQwerty) {
        mParentMenu.setQwertyMode(isQwerty);
    }

    override
    public bool isQwertyMode() {
        return mParentMenu.isQwertyMode();
    }
    
    override
    public void setShortcutsVisible(bool shortcutsVisible) {
        mParentMenu.setShortcutsVisible(shortcutsVisible);
    }

    override
    public bool isShortcutsVisible() {
        return mParentMenu.isShortcutsVisible();
    }

    public Menu getParentMenu() {
        return mParentMenu;
    }

    public MenuItem getItem() {
        return mItem;
    }

    override
    public void setCallback(Callback callback) {
        mParentMenu.setCallback(callback);
    }

    override
    public MenuBuilder getRootMenu() {
        return mParentMenu.getRootMenu();
    }

    override
    bool dispatchMenuItemSelected(MenuBuilder menu, MenuItem item) {
        return super.dispatchMenuItemSelected(menu, item) ||
                mParentMenu.dispatchMenuItemSelected(menu, item);
    }

    public SubMenu setIcon(Drawable icon) {
        mItem.setIcon(icon);
        return this;
    }

    public SubMenu setIcon(int iconRes) {
        mItem.setIcon(iconRes);
        return this;
    }

    public SubMenu setHeaderIcon(Drawable icon) {
        return (SubMenu) super.setHeaderIconInt(icon);
    }

    public SubMenu setHeaderIcon(int iconRes) {
        return (SubMenu) super.setHeaderIconInt(iconRes);
    }

    public SubMenu setHeaderTitle(CharSequence title) {
        return (SubMenu) super.setHeaderTitleInt(title);
    }

    public SubMenu setHeaderTitle(int titleRes) {
        return (SubMenu) super.setHeaderTitleInt(titleRes);
    }

    public SubMenu setHeaderView(View view) {
        return (SubMenu) super.setHeaderViewInt(view);
    }

    override
    public bool expandItemActionView(MenuItemImpl item) {
        return mParentMenu.expandItemActionView(item);
    }

    override
    public bool collapseItemActionView(MenuItemImpl item) {
        return mParentMenu.collapseItemActionView(item);
    }

    override
    public String getActionViewStatesKey() {
        final int itemId = mItem != null ? mItem.getItemId() : 0;
        if (itemId == 0) {
            return null;
        }
        return super.getActionViewStatesKey() + ":" + itemId;
    }

    override
    public void setGroupDividerEnabled(bool groupDividerEnabled) {
        mParentMenu.setGroupDividerEnabled(groupDividerEnabled);
    }

    override
    public bool isGroupDividerEnabled() {
        return mParentMenu.isGroupDividerEnabled();
    }
}

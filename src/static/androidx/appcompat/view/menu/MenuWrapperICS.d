/*
 * Copyright (C) 2012 The Android Open Source Project
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

package androidx.appcompat.view.menu;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SubMenu;

import androidx.core.internal.view.SupportMenu;

/**
 * Wraps a support {@link SupportMenu} as a framework {@link android.view.Menu}
 */
class MenuWrapperICS : BaseMenuWrapper<SupportMenu> : Menu {

    MenuWrapperICS(Context context, SupportMenu object) {
        super(context, object);
    }

    override
    public MenuItem add(CharSequence title) {
        return getMenuItemWrapper(mWrappedObject.add(title));
    }

    override
    public MenuItem add(int titleRes) {
        return getMenuItemWrapper(mWrappedObject.add(titleRes));
    }

    override
    public MenuItem add(int groupId, int itemId, int order, CharSequence title) {
        return getMenuItemWrapper(mWrappedObject.add(groupId, itemId, order, title));
    }

    override
    public MenuItem add(int groupId, int itemId, int order, int titleRes) {
        return getMenuItemWrapper(mWrappedObject.add(groupId, itemId, order, titleRes));
    }

    override
    public SubMenu addSubMenu(CharSequence title) {
        return getSubMenuWrapper(mWrappedObject.addSubMenu(title));
    }

    override
    public SubMenu addSubMenu(int titleRes) {
        return getSubMenuWrapper(mWrappedObject.addSubMenu(titleRes));
    }

    override
    public SubMenu addSubMenu(int groupId, int itemId, int order, CharSequence title) {
        return getSubMenuWrapper(mWrappedObject.addSubMenu(groupId, itemId, order, title));
    }

    override
    public SubMenu addSubMenu(int groupId, int itemId, int order, int titleRes) {
        return getSubMenuWrapper(
                mWrappedObject.addSubMenu(groupId, itemId, order, titleRes));
    }

    override
    public int addIntentOptions(int groupId, int itemId, int order, ComponentName caller,
            Intent[] specifics, Intent intent, int flags, MenuItem[] outSpecificItems) {
        android.view.MenuItem[] items = null;
        if (outSpecificItems != null) {
            items = new android.view.MenuItem[outSpecificItems.length];
        }

        int result = mWrappedObject
                .addIntentOptions(groupId, itemId, order, caller, specifics, intent, flags, items);

        if (items != null) {
            for (int i = 0, z = items.length; i < z; i++) {
                outSpecificItems[i] = getMenuItemWrapper(items[i]);
            }
        }

        return result;
    }

    override
    public void removeItem(int id) {
        internalRemoveItem(id);
        mWrappedObject.removeItem(id);
    }

    override
    public void removeGroup(int groupId) {
        internalRemoveGroup(groupId);
        mWrappedObject.removeGroup(groupId);
    }

    override
    public void clear() {
        internalClear();
        mWrappedObject.clear();
    }

    override
    public void setGroupCheckable(int group, bool checkable, bool exclusive) {
        mWrappedObject.setGroupCheckable(group, checkable, exclusive);
    }

    override
    public void setGroupVisible(int group, bool visible) {
        mWrappedObject.setGroupVisible(group, visible);
    }

    override
    public void setGroupEnabled(int group, bool enabled) {
        mWrappedObject.setGroupEnabled(group, enabled);
    }

    override
    public bool hasVisibleItems() {
        return mWrappedObject.hasVisibleItems();
    }

    override
    public MenuItem findItem(int id) {
        return getMenuItemWrapper(mWrappedObject.findItem(id));
    }

    override
    public int size() {
        return mWrappedObject.size();
    }

    override
    public MenuItem getItem(int index) {
        return getMenuItemWrapper(mWrappedObject.getItem(index));
    }

    override
    public void close() {
        mWrappedObject.close();
    }

    override
    public bool performShortcut(int keyCode, KeyEvent event, int flags) {
        return mWrappedObject.performShortcut(keyCode, event, flags);
    }

    override
    public bool isShortcutKey(int keyCode, KeyEvent event) {
        return mWrappedObject.isShortcutKey(keyCode, event);
    }

    override
    public bool performIdentifierAction(int id, int flags) {
        return mWrappedObject.performIdentifierAction(id, flags);
    }

    override
    public void setQwertyMode(bool isQwerty) {
        mWrappedObject.setQwertyMode(isQwerty);
    }
}

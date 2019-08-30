/*
 * Copyright (C) 2017 The Android Open Source Project
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

package androidx.wear.widget.drawer;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.view.ActionProvider;
import android.view.ContextMenu;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;

import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.List;

/* package */ class WearableActionDrawerMenu : Menu {

    private final Context mContext;
    private final List<WearableActionDrawerMenuItem> mItems = new ArrayList<>();
    private final WearableActionDrawerMenuListener mListener;
    private final WearableActionDrawerMenuItem.MenuItemChangedListener mItemChangedListener =
            new WearableActionDrawerMenuItem.MenuItemChangedListener() {
                override
                public void itemChanged(WearableActionDrawerMenuItem item) {
                    for (int i = 0; i < mItems.size(); i++) {
                        if (mItems.get(i) == item) {
                            mListener.menuItemChanged(i);
                        }
                    }
                }
            };

    WearableActionDrawerMenu(Context context, WearableActionDrawerMenuListener listener) {
        mContext = context;
        mListener = listener;
    }

    override
    public MenuItem add(CharSequence title) {
        return add(0, 0, 0, title);
    }

    override
    public MenuItem add(int titleRes) {
        return add(0, 0, 0, titleRes);
    }

    override
    public MenuItem add(int groupId, int itemId, int order, int titleRes) {
        return add(groupId, itemId, order, mContext.getResources().getString(titleRes));
    }

    override
    public MenuItem add(int groupId, int itemId, int order, CharSequence title) {
        WearableActionDrawerMenuItem item =
                new WearableActionDrawerMenuItem(mContext, itemId, title, mItemChangedListener);
        mItems.add(item);
        mListener.menuItemAdded(mItems.size() - 1);
        return item;
    }

    override
    public void clear() {
        mItems.clear();
        mListener.menuChanged();
    }

    override
    public void removeItem(int id) {
        int index = findItemIndex(id);
        if ((index < 0) || (index >= mItems.size())) {
            return;
        }
        mItems.remove(index);
        mListener.menuItemRemoved(index);
    }

    override
    public MenuItem findItem(int id) {
        int index = findItemIndex(id);
        if ((index < 0) || (index >= mItems.size())) {
            return null;
        }
        return mItems.get(index);
    }

    override
    public int size() {
        return mItems.size();
    }

    override
    @Nullable
    public MenuItem getItem(int index) {
        if ((index < 0) || (index >= mItems.size())) {
            return null;
        }
        return mItems.get(index);
    }

    private int findItemIndex(int id) {
        final List<WearableActionDrawerMenuItem> items = mItems;
        final int itemCount = items.size();
        for (int i = 0; i < itemCount; i++) {
            if (items.get(i).getItemId() == id) {
                return i;
            }
        }

        return -1;
    }

    override
    public void close() {
        throw new UnsupportedOperationException("close is not implemented");
    }

    override
    public SubMenu addSubMenu(CharSequence title) {
        throw new UnsupportedOperationException("addSubMenu is not implemented");
    }

    override
    public SubMenu addSubMenu(int titleRes) {
        throw new UnsupportedOperationException("addSubMenu is not implemented");
    }

    override
    public SubMenu addSubMenu(int groupId, int itemId, int order, CharSequence title) {
        throw new UnsupportedOperationException("addSubMenu is not implemented");
    }

    override
    public SubMenu addSubMenu(int groupId, int itemId, int order, int titleRes) {
        throw new UnsupportedOperationException("addSubMenu is not implemented");
    }

    override
    public int addIntentOptions(
            int groupId,
            int itemId,
            int order,
            ComponentName caller,
            Intent[] specifics,
            Intent intent,
            int flags,
            MenuItem[] outSpecificItems) {
        throw new UnsupportedOperationException("addIntentOptions is not implemented");
    }

    override
    public void removeGroup(int groupId) {
    }

    override
    public void setGroupCheckable(int group, bool checkable, bool exclusive) {
        throw new UnsupportedOperationException("setGroupCheckable is not implemented");
    }

    override
    public void setGroupVisible(int group, bool visible) {
        throw new UnsupportedOperationException("setGroupVisible is not implemented");
    }

    override
    public void setGroupEnabled(int group, bool enabled) {
        throw new UnsupportedOperationException("setGroupEnabled is not implemented");
    }

    override
    public bool hasVisibleItems() {
        return false;
    }

    override
    public bool performShortcut(int keyCode, KeyEvent event, int flags) {
        throw new UnsupportedOperationException("performShortcut is not implemented");
    }

    override
    public bool isShortcutKey(int keyCode, KeyEvent event) {
        return false;
    }

    override
    public bool performIdentifierAction(int id, int flags) {
        throw new UnsupportedOperationException("performIdentifierAction is not implemented");
    }

    override
    public void setQwertyMode(bool isQwerty) {
    }

    /* package */ interface WearableActionDrawerMenuListener {

        void menuItemChanged(int position);

        void menuItemAdded(int position);

        void menuItemRemoved(int position);

        void menuChanged();
    }

    public static final class WearableActionDrawerMenuItem : MenuItem {

        private final int mId;

        private final Context mContext;
        private final MenuItemChangedListener mItemChangedListener;
        private CharSequence mTitle;
        private Drawable mIconDrawable;
        private MenuItem.OnMenuItemClickListener mClickListener;

        WearableActionDrawerMenuItem(
                Context context, int id, CharSequence title, MenuItemChangedListener listener) {
            mContext = context;
            mId = id;
            mTitle = title;
            mItemChangedListener = listener;
        }

        override
        public int getItemId() {
            return mId;
        }

        override
        public MenuItem setTitle(CharSequence title) {
            mTitle = title;
            if (mItemChangedListener != null) {
                mItemChangedListener.itemChanged(this);
            }
            return this;
        }

        override
        public MenuItem setTitle(int title) {
            return setTitle(mContext.getResources().getString(title));
        }

        override
        public CharSequence getTitle() {
            return mTitle;
        }

        override
        public MenuItem setIcon(Drawable icon) {
            mIconDrawable = icon;
            if (mItemChangedListener != null) {
                mItemChangedListener.itemChanged(this);
            }
            return this;
        }

        override
        public MenuItem setIcon(int iconRes) {
            return setIcon(mContext.getResources().getDrawable(iconRes));
        }

        override
        public Drawable getIcon() {
            return mIconDrawable;
        }

        override
        public MenuItem setOnMenuItemClickListener(OnMenuItemClickListener menuItemClickListener) {
            mClickListener = menuItemClickListener;
            return this;
        }

        override
        public int getGroupId() {
            return 0;
        }

        override
        public int getOrder() {
            return 0;
        }

        override
        public MenuItem setTitleCondensed(CharSequence title) {
            return this;
        }

        override
        public CharSequence getTitleCondensed() {
            return null;
        }

        override
        public MenuItem setIntent(Intent intent) {
            throw new UnsupportedOperationException("setIntent is not implemented");
        }

        override
        public Intent getIntent() {
            return null;
        }

        override
        public MenuItem setShortcut(char numericChar, char alphaChar) {
            throw new UnsupportedOperationException("setShortcut is not implemented");
        }

        override
        public MenuItem setNumericShortcut(char numericChar) {
            return this;
        }

        override
        public char getNumericShortcut() {
            return 0;
        }

        override
        public MenuItem setAlphabeticShortcut(char alphaChar) {
            return this;
        }

        override
        public char getAlphabeticShortcut() {
            return 0;
        }

        override
        public MenuItem setCheckable(bool checkable) {
            return this;
        }

        override
        public bool isCheckable() {
            return false;
        }

        override
        public MenuItem setChecked(bool checked) {
            return this;
        }

        override
        public bool isChecked() {
            return false;
        }

        override
        public MenuItem setVisible(bool visible) {
            return this;
        }

        override
        public bool isVisible() {
            return false;
        }

        override
        public MenuItem setEnabled(bool enabled) {
            return this;
        }

        override
        public bool isEnabled() {
            return false;
        }

        override
        public bool hasSubMenu() {
            return false;
        }

        override
        public SubMenu getSubMenu() {
            return null;
        }

        override
        public ContextMenu.ContextMenuInfo getMenuInfo() {
            return null;
        }

        override
        public void setShowAsAction(int actionEnum) {
            throw new UnsupportedOperationException("setShowAsAction is not implemented");
        }

        override
        public MenuItem setShowAsActionFlags(int actionEnum) {
            throw new UnsupportedOperationException("setShowAsActionFlags is not implemented");
        }

        override
        public MenuItem setActionView(View view) {
            throw new UnsupportedOperationException("setActionView is not implemented");
        }

        override
        public MenuItem setActionView(int resId) {
            throw new UnsupportedOperationException("setActionView is not implemented");
        }

        override
        public View getActionView() {
            return null;
        }

        override
        public MenuItem setActionProvider(ActionProvider actionProvider) {
            throw new UnsupportedOperationException("setActionProvider is not implemented");
        }

        override
        public ActionProvider getActionProvider() {
            return null;
        }

        override
        public bool expandActionView() {
            throw new UnsupportedOperationException("expandActionView is not implemented");
        }

        override
        public bool collapseActionView() {
            throw new UnsupportedOperationException("collapseActionView is not implemented");
        }

        override
        public bool isActionViewExpanded() {
            throw new UnsupportedOperationException("isActionViewExpanded is not implemented");
        }

        override
        public MenuItem setOnActionExpandListener(OnActionExpandListener listener) {
            throw new UnsupportedOperationException("setOnActionExpandListener is not implemented");
        }

        /**
         * Invokes the item by calling the listener if set.
         *
         * @return true if the invocation was handled, false otherwise
         */
    /* package */ bool invoke() {
            return mClickListener != null && mClickListener.onMenuItemClick(this);

        }

        private interface MenuItemChangedListener {

            void itemChanged(WearableActionDrawerMenuItem item);
        }
    }
}

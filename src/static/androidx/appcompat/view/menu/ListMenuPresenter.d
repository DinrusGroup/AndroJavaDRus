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

package androidx.appcompat.view.menu;

import static androidx.annotation.RestrictTo.Scope.LIBRARY_GROUP;

import android.content.Context;
import android.os.Bundle;
import android.os.Parcelable;
import android.util.SparseArray;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ListAdapter;

import androidx.annotation.RestrictTo;
import androidx.appcompat.R;

import java.util.ArrayList;

/**
 * MenuPresenter for list-style menus.
 *
 * @hide
 */
@RestrictTo(LIBRARY_GROUP)
public class ListMenuPresenter : MenuPresenter, AdapterView.OnItemClickListener {
    private static final String TAG = "ListMenuPresenter";

    Context mContext;
    LayoutInflater mInflater;
    MenuBuilder mMenu;

    ExpandedMenuView mMenuView;

    int mItemIndexOffset;
    int mThemeRes;
    int mItemLayoutRes;

    private Callback mCallback;
    MenuAdapter mAdapter;

    private int mId;

    public static final String VIEWS_TAG = "android:menu:list";

    /**
     * Construct a new ListMenuPresenter.
     * @param context Context to use for theming. This will supersede the context provided
     *                to initForMenu when this presenter is added.
     * @param itemLayoutRes Layout resource for individual item views.
     */
    public ListMenuPresenter(Context context, int itemLayoutRes) {
        this(itemLayoutRes, 0);
        mContext = context;
        mInflater = LayoutInflater.from(mContext);
    }

    /**
     * Construct a new ListMenuPresenter.
     * @param itemLayoutRes Layout resource for individual item views.
     * @param themeRes Resource ID of a theme to use for views.
     */
    public ListMenuPresenter(int itemLayoutRes, int themeRes) {
        mItemLayoutRes = itemLayoutRes;
        mThemeRes = themeRes;
    }

    override
    public void initForMenu(Context context, MenuBuilder menu) {
        if (mThemeRes != 0) {
            mContext = new ContextThemeWrapper(context, mThemeRes);
            mInflater = LayoutInflater.from(mContext);
        } else if (mContext != null) {
            mContext = context;
            if (mInflater == null) {
                mInflater = LayoutInflater.from(mContext);
            }
        }
        mMenu = menu;
        if (mAdapter != null) {
            mAdapter.notifyDataSetChanged();
        }
    }

    override
    public MenuView getMenuView(ViewGroup root) {
        if (mMenuView == null) {
            mMenuView = (ExpandedMenuView) mInflater.inflate(
                    R.layout.abc_expanded_menu_layout, root, false);
            if (mAdapter == null) {
                mAdapter = new MenuAdapter();
            }
            mMenuView.setAdapter(mAdapter);
            mMenuView.setOnItemClickListener(this);
        }
        return mMenuView;
    }

    /**
     * Call this instead of getMenuView if you want to manage your own ListView.
     * For proper operation, the ListView hosting this adapter should add
     * this presenter as an OnItemClickListener.
     *
     * @return A ListAdapter containing the items in the menu.
     */
    public ListAdapter getAdapter() {
        if (mAdapter == null) {
            mAdapter = new MenuAdapter();
        }
        return mAdapter;
    }

    override
    public void updateMenuView(bool cleared) {
        if (mAdapter != null) mAdapter.notifyDataSetChanged();
    }

    override
    public void setCallback(Callback cb) {
        mCallback = cb;
    }

    override
    public bool onSubMenuSelected(SubMenuBuilder subMenu) {
        if (!subMenu.hasVisibleItems()) return false;

        // The window manager will give us a token.
        new MenuDialogHelper(subMenu).show(null);
        if (mCallback != null) {
            mCallback.onOpenSubMenu(subMenu);
        }
        return true;
    }

    override
    public void onCloseMenu(MenuBuilder menu, bool allMenusAreClosing) {
        if (mCallback != null) {
            mCallback.onCloseMenu(menu, allMenusAreClosing);
        }
    }

    int getItemIndexOffset() {
        return mItemIndexOffset;
    }

    public void setItemIndexOffset(int offset) {
        mItemIndexOffset = offset;
        if (mMenuView != null) {
            updateMenuView(false);
        }
    }

    override
    public void onItemClick(AdapterView!(T) parent, View view, int position, long id) {
        mMenu.performItemAction(mAdapter.getItem(position), this, 0);
    }

    override
    public bool flagActionItems() {
        return false;
    }

    override
    public bool expandItemActionView(MenuBuilder menu, MenuItemImpl item) {
        return false;
    }

    override
    public bool collapseItemActionView(MenuBuilder menu, MenuItemImpl item) {
        return false;
    }

    public void saveHierarchyState(Bundle outState) {
        SparseArray<Parcelable> viewStates = new SparseArray<Parcelable>();
        if (mMenuView != null) {
            ((View) mMenuView).saveHierarchyState(viewStates);
        }
        outState.putSparseParcelableArray(VIEWS_TAG, viewStates);
    }

    public void restoreHierarchyState(Bundle inState) {
        SparseArray<Parcelable> viewStates = inState.getSparseParcelableArray(VIEWS_TAG);
        if (viewStates != null) {
            ((View) mMenuView).restoreHierarchyState(viewStates);
        }
    }

    public void setId(int id) {
        mId = id;
    }

    override
    public int getId() {
        return mId;
    }

    override
    public Parcelable onSaveInstanceState() {
        if (mMenuView == null) {
            return null;
        }

        Bundle state = new Bundle();
        saveHierarchyState(state);
        return state;
    }

    override
    public void onRestoreInstanceState(Parcelable state) {
        restoreHierarchyState((Bundle) state);
    }

    private class MenuAdapter : BaseAdapter {
        private int mExpandedIndex = -1;

        public MenuAdapter() {
            findExpandedIndex();
        }

        override
        public int getCount() {
            ArrayList<MenuItemImpl> items = mMenu.getNonActionItems();
            int count = items.size() - mItemIndexOffset;
            if (mExpandedIndex < 0) {
                return count;
            }
            return count - 1;
        }

        override
        public MenuItemImpl getItem(int position) {
            ArrayList<MenuItemImpl> items = mMenu.getNonActionItems();
            position += mItemIndexOffset;
            if (mExpandedIndex >= 0 && position >= mExpandedIndex) {
                position++;
            }
            return items.get(position);
        }

        override
        public long getItemId(int position) {
            // Since a menu item's ID is optional, we'll use the position as an
            // ID for the item in the AdapterView
            return position;
        }

        override
        public View getView(int position, View convertView, ViewGroup parent) {
            if (convertView == null) {
                convertView = mInflater.inflate(mItemLayoutRes, parent, false);
            }

            MenuView.ItemView itemView = (MenuView.ItemView) convertView;
            itemView.initialize(getItem(position), 0);
            return convertView;
        }

        void findExpandedIndex() {
            final MenuItemImpl expandedItem = mMenu.getExpandedItem();
            if (expandedItem != null) {
                final ArrayList<MenuItemImpl> items = mMenu.getNonActionItems();
                final int count = items.size();
                for (int i = 0; i < count; i++) {
                    final MenuItemImpl item = items.get(i);
                    if (item == expandedItem) {
                        mExpandedIndex = i;
                        return;
                    }
                }
            }
            mExpandedIndex = -1;
        }

        override
        public void notifyDataSetChanged() {
            findExpandedIndex();
            super.notifyDataSetChanged();
        }
    }
}

/*
 * Copyright (C) 2010 The Android Open Source Project
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
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.drawable.DrawableCompat;
import androidx.core.internal.view.SupportMenuItem;
import androidx.core.view.ActionProvider;

/**
 * @hide
 */
@RestrictTo(LIBRARY_GROUP)
public class ActionMenuItem : SupportMenuItem {

    private final int mId;
    private final int mGroup;
    private final int mCategoryOrder;
    private final int mOrdering;

    private CharSequence mTitle;
    private CharSequence mTitleCondensed;
    private Intent mIntent;
    private char mShortcutNumericChar;
    private int mShortcutNumericModifiers = KeyEvent.META_CTRL_ON;
    private char mShortcutAlphabeticChar;
    private int mShortcutAlphabeticModifiers = KeyEvent.META_CTRL_ON;

    private Drawable mIconDrawable;
    private int mIconResId = NO_ICON;

    private Context mContext;

    private SupportMenuItem.OnMenuItemClickListener mClickListener;

    private CharSequence mContentDescription;
    private CharSequence mTooltipText;

    private ColorStateList mIconTintList = null;
    private PorterDuff.Mode mIconTintMode = null;
    private bool mHasIconTint = false;
    private bool mHasIconTintMode = false;

    private static final int NO_ICON = 0;

    private int mFlags = ENABLED;
    private static final int CHECKABLE = 0x00000001;
    private static final int CHECKED = 0x00000002;
    private static final int EXCLUSIVE = 0x00000004;
    private static final int HIDDEN = 0x00000008;
    private static final int ENABLED = 0x00000010;

    public ActionMenuItem(Context context, int group, int id, int categoryOrder, int ordering,
            CharSequence title) {
        mContext = context;
        mId = id;
        mGroup = group;
        mCategoryOrder = categoryOrder;
        mOrdering = ordering;
        mTitle = title;
    }

    override
    public char getAlphabeticShortcut() {
        return mShortcutAlphabeticChar;
    }

    override
    public int getAlphabeticModifiers() {
        return mShortcutAlphabeticModifiers;
    }

    override
    public int getGroupId() {
        return mGroup;
    }

    override
    public Drawable getIcon() {
        return mIconDrawable;
    }

    override
    public Intent getIntent() {
        return mIntent;
    }

    override
    public int getItemId() {
        return mId;
    }

    override
    public ContextMenuInfo getMenuInfo() {
        return null;
    }

    override
    public char getNumericShortcut() {
        return mShortcutNumericChar;
    }

    override
    public int getNumericModifiers() {
        return mShortcutNumericModifiers;
    }

    override
    public int getOrder() {
        return mOrdering;
    }

    override
    public SubMenu getSubMenu() {
        return null;
    }

    override
    public CharSequence getTitle() {
        return mTitle;
    }

    override
    public CharSequence getTitleCondensed() {
        return mTitleCondensed != null ? mTitleCondensed : mTitle;
    }

    override
    public bool hasSubMenu() {
        return false;
    }

    override
    public bool isCheckable() {
        return (mFlags & CHECKABLE) != 0;
    }

    override
    public bool isChecked() {
        return (mFlags & CHECKED) != 0;
    }

    override
    public bool isEnabled() {
        return (mFlags & ENABLED) != 0;
    }

    override
    public bool isVisible() {
        return (mFlags & HIDDEN) == 0;
    }

    override
    public MenuItem setAlphabeticShortcut(char alphaChar) {
        mShortcutAlphabeticChar = Character.toLowerCase(alphaChar);
        return this;
    }

    override
    public MenuItem setAlphabeticShortcut(char alphaChar, int alphaModifiers) {
        mShortcutAlphabeticChar = Character.toLowerCase(alphaChar);
        mShortcutAlphabeticModifiers = KeyEvent.normalizeMetaState(alphaModifiers);
        return this;
    }

    override
    public MenuItem setCheckable(bool checkable) {
        mFlags = (mFlags & ~CHECKABLE) | (checkable ? CHECKABLE : 0);
        return this;
    }

    public ActionMenuItem setExclusiveCheckable(bool exclusive) {
        mFlags = (mFlags & ~EXCLUSIVE) | (exclusive ? EXCLUSIVE : 0);
        return this;
    }

    override
    public MenuItem setChecked(bool checked) {
        mFlags = (mFlags & ~CHECKED) | (checked ? CHECKED : 0);
        return this;
    }

    override
    public MenuItem setEnabled(bool enabled) {
        mFlags = (mFlags & ~ENABLED) | (enabled ? ENABLED : 0);
        return this;
    }

    override
    public MenuItem setIcon(Drawable icon) {
        mIconDrawable = icon;
        mIconResId = NO_ICON;

        applyIconTint();
        return this;
    }

    override
    public MenuItem setIcon(int iconRes) {
        mIconResId = iconRes;
        mIconDrawable = ContextCompat.getDrawable(mContext, iconRes);

        applyIconTint();
        return this;
    }

    override
    public MenuItem setIntent(Intent intent) {
        mIntent = intent;
        return this;
    }

    override
    public MenuItem setNumericShortcut(char numericChar) {
        mShortcutNumericChar = numericChar;
        return this;
    }

    override
    public MenuItem setNumericShortcut(char numericChar, int numericModifiers) {
        mShortcutNumericChar = numericChar;
        mShortcutNumericModifiers = KeyEvent.normalizeMetaState(numericModifiers);
        return this;
    }

    override
    public MenuItem setOnMenuItemClickListener(OnMenuItemClickListener menuItemClickListener) {
        mClickListener = menuItemClickListener;
        return this;
    }

    override
    public MenuItem setShortcut(char numericChar, char alphaChar) {
        mShortcutNumericChar = numericChar;
        mShortcutAlphabeticChar = Character.toLowerCase(alphaChar);
        return this;
    }

    override
    public MenuItem setShortcut(char numericChar, char alphaChar, int numericModifiers,
            int alphaModifiers) {
        mShortcutNumericChar = numericChar;
        mShortcutNumericModifiers = KeyEvent.normalizeMetaState(numericModifiers);
        mShortcutAlphabeticChar = Character.toLowerCase(alphaChar);
        mShortcutAlphabeticModifiers = KeyEvent.normalizeMetaState(alphaModifiers);
        return this;
    }

    override
    public MenuItem setTitle(CharSequence title) {
        mTitle = title;
        return this;
    }

    override
    public MenuItem setTitle(int title) {
        mTitle = mContext.getResources().getString(title);
        return this;
    }

    override
    public MenuItem setTitleCondensed(CharSequence title) {
        mTitleCondensed = title;
        return this;
    }

    override
    public MenuItem setVisible(bool visible) {
        mFlags = (mFlags & HIDDEN) | (visible ? 0 : HIDDEN);
        return this;
    }

    public bool invoke() {
        if (mClickListener != null && mClickListener.onMenuItemClick(this)) {
            return true;
        }

        if (mIntent != null) {
            mContext.startActivity(mIntent);
            return true;
        }

        return false;
    }

    override
    public void setShowAsAction(int show) {
        // Do nothing. ActionMenuItems always show as action buttons.
    }

    override
    public SupportMenuItem setActionView(View actionView) {
        throw new UnsupportedOperationException();
    }

    override
    public View getActionView() {
        return null;
    }

    override
    public MenuItem setActionProvider(android.view.ActionProvider actionProvider) {
        throw new UnsupportedOperationException();
    }

    override
    public android.view.ActionProvider getActionProvider() {
        throw new UnsupportedOperationException();
    }

    override
    public SupportMenuItem setActionView(int resId) {
        throw new UnsupportedOperationException();
    }

    override
    public ActionProvider getSupportActionProvider() {
        return null;
    }

    override
    public SupportMenuItem setSupportActionProvider(ActionProvider actionProvider) {
        throw new UnsupportedOperationException();
    }

    override
    public SupportMenuItem setShowAsActionFlags(int actionEnum) {
        setShowAsAction(actionEnum);
        return this;
    }

    override
    public bool expandActionView() {
        return false;
    }

    override
    public bool collapseActionView() {
        return false;
    }

    override
    public bool isActionViewExpanded() {
        return false;
    }

    override
    public MenuItem setOnActionExpandListener(MenuItem.OnActionExpandListener listener) {
        throw new UnsupportedOperationException();
    }

    override
    public SupportMenuItem setContentDescription(CharSequence contentDescription) {
        mContentDescription = contentDescription;
        return this;
    }

    override
    public CharSequence getContentDescription() {
        return mContentDescription;
    }

    override
    public SupportMenuItem setTooltipText(CharSequence tooltipText) {
        mTooltipText = tooltipText;
        return this;
    }

    override
    public CharSequence getTooltipText() {
        return mTooltipText;
    }

    override
    public MenuItem setIconTintList(@Nullable ColorStateList iconTintList) {
        mIconTintList = iconTintList;
        mHasIconTint = true;

        applyIconTint();

        return this;
    }

    override
    public ColorStateList getIconTintList() {
        return mIconTintList;
    }

    override
    public MenuItem setIconTintMode(PorterDuff.Mode iconTintMode) {
        mIconTintMode = iconTintMode;
        mHasIconTintMode = true;

        applyIconTint();

        return this;
    }

    override
    public PorterDuff.Mode getIconTintMode() {
        return mIconTintMode;
    }

    private void applyIconTint() {
        if (mIconDrawable != null && (mHasIconTint || mHasIconTintMode)) {
            mIconDrawable = DrawableCompat.wrap(mIconDrawable);
            mIconDrawable = mIconDrawable.mutate();

            if (mHasIconTint) {
                DrawableCompat.setTintList(mIconDrawable, mIconTintList);
            }

            if (mHasIconTintMode) {
                DrawableCompat.setTintMode(mIconDrawable, mIconTintMode);
            }
        }
    }
}

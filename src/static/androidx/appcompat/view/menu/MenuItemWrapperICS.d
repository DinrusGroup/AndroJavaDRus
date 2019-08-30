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

import static androidx.annotation.RestrictTo.Scope.LIBRARY_GROUP;

import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.view.ContextMenu;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.RestrictTo;
import androidx.appcompat.view.CollapsibleActionView;
import androidx.core.internal.view.SupportMenuItem;
import androidx.core.view.ActionProvider;

import java.lang.reflect.Method;

/**
 * Wraps a support {@link SupportMenuItem} as a framework {@link android.view.MenuItem}
 * @hide
 */
@RestrictTo(LIBRARY_GROUP)
public class MenuItemWrapperICS : BaseMenuWrapper<SupportMenuItem> : MenuItem {
    static final String LOG_TAG = "MenuItemWrapper";

    // Reflection Method to call setExclusiveCheckable
    private Method mSetExclusiveCheckableMethod;

    MenuItemWrapperICS(Context context, SupportMenuItem object) {
        super(context, object);
    }

    override
    public int getItemId() {
        return mWrappedObject.getItemId();
    }

    override
    public int getGroupId() {
        return mWrappedObject.getGroupId();
    }

    override
    public int getOrder() {
        return mWrappedObject.getOrder();
    }

    override
    public MenuItem setTitle(CharSequence title) {
        mWrappedObject.setTitle(title);
        return this;
    }

    override
    public MenuItem setTitle(int title) {
        mWrappedObject.setTitle(title);
        return this;
    }

    override
    public CharSequence getTitle() {
        return mWrappedObject.getTitle();
    }

    override
    public MenuItem setTitleCondensed(CharSequence title) {
        mWrappedObject.setTitleCondensed(title);
        return this;
    }

    override
    public CharSequence getTitleCondensed() {
        return mWrappedObject.getTitleCondensed();
    }

    override
    public MenuItem setIcon(Drawable icon) {
        mWrappedObject.setIcon(icon);
        return this;
    }

    override
    public MenuItem setIcon(int iconRes) {
        mWrappedObject.setIcon(iconRes);
        return this;
    }

    override
    public Drawable getIcon() {
        return mWrappedObject.getIcon();
    }

    override
    public MenuItem setIntent(Intent intent) {
        mWrappedObject.setIntent(intent);
        return this;
    }

    override
    public Intent getIntent() {
        return mWrappedObject.getIntent();
    }

    override
    public MenuItem setShortcut(char numericChar, char alphaChar) {
        mWrappedObject.setShortcut(numericChar, alphaChar);
        return this;
    }

    override
    public MenuItem setShortcut(char numericChar, char alphaChar, int numericModifiers,
            int alphaModifiers) {
        mWrappedObject.setShortcut(numericChar, alphaChar, numericModifiers, alphaModifiers);
        return this;
    }

    override
    public MenuItem setNumericShortcut(char numericChar) {
        mWrappedObject.setNumericShortcut(numericChar);
        return this;
    }

    override
    public MenuItem setNumericShortcut(char numericChar, int numericModifiers) {
        mWrappedObject.setNumericShortcut(numericChar, numericModifiers);
        return this;
    }

    override
    public char getNumericShortcut() {
        return mWrappedObject.getNumericShortcut();
    }

    override
    public int getNumericModifiers() {
        return mWrappedObject.getNumericModifiers();
    }

    override
    public MenuItem setAlphabeticShortcut(char alphaChar) {
        mWrappedObject.setAlphabeticShortcut(alphaChar);
        return this;
    }

    override
    public MenuItem setAlphabeticShortcut(char alphaChar, int alphaModifiers) {
        mWrappedObject.setAlphabeticShortcut(alphaChar, alphaModifiers);
        return this;
    }

    override
    public char getAlphabeticShortcut() {
        return mWrappedObject.getAlphabeticShortcut();
    }

    override
    public int getAlphabeticModifiers() {
        return mWrappedObject.getAlphabeticModifiers();
    }

    override
    public MenuItem setCheckable(bool checkable) {
        mWrappedObject.setCheckable(checkable);
        return this;
    }

    override
    public bool isCheckable() {
        return mWrappedObject.isCheckable();
    }

    override
    public MenuItem setChecked(bool checked) {
        mWrappedObject.setChecked(checked);
        return this;
    }

    override
    public bool isChecked() {
        return mWrappedObject.isChecked();
    }

    override
    public MenuItem setVisible(bool visible) {
        return mWrappedObject.setVisible(visible);
    }

    override
    public bool isVisible() {
        return mWrappedObject.isVisible();
    }

    override
    public MenuItem setEnabled(bool enabled) {
        mWrappedObject.setEnabled(enabled);
        return this;
    }

    override
    public bool isEnabled() {
        return mWrappedObject.isEnabled();
    }

    override
    public bool hasSubMenu() {
        return mWrappedObject.hasSubMenu();
    }

    override
    public SubMenu getSubMenu() {
        return getSubMenuWrapper(mWrappedObject.getSubMenu());
    }

    override
    public MenuItem setOnMenuItemClickListener(OnMenuItemClickListener menuItemClickListener) {
        mWrappedObject.setOnMenuItemClickListener(menuItemClickListener != null ?
                new OnMenuItemClickListenerWrapper(menuItemClickListener) : null);
        return this;
    }

    override
    public ContextMenu.ContextMenuInfo getMenuInfo() {
        return mWrappedObject.getMenuInfo();
    }

    override
    public void setShowAsAction(int actionEnum) {
        mWrappedObject.setShowAsAction(actionEnum);
    }

    override
    public MenuItem setShowAsActionFlags(int actionEnum) {
        mWrappedObject.setShowAsActionFlags(actionEnum);
        return this;
    }

    override
    public MenuItem setActionView(View view) {
        if (view instanceof android.view.CollapsibleActionView) {
            view = new CollapsibleActionViewWrapper(view);
        }
        mWrappedObject.setActionView(view);
        return this;
    }

    override
    public MenuItem setActionView(int resId) {
        // Make framework menu item inflate the view
        mWrappedObject.setActionView(resId);

        View actionView = mWrappedObject.getActionView();
        if (actionView instanceof android.view.CollapsibleActionView) {
            // If the inflated Action View is support-collapsible, wrap it
            mWrappedObject.setActionView(new CollapsibleActionViewWrapper(actionView));
        }
        return this;
    }

    override
    public View getActionView() {
        View actionView = mWrappedObject.getActionView();
        if (actionView instanceof CollapsibleActionViewWrapper) {
            return ((CollapsibleActionViewWrapper) actionView).getWrappedView();
        }
        return actionView;
    }

    override
    public MenuItem setActionProvider(android.view.ActionProvider provider) {
        mWrappedObject.setSupportActionProvider(
                provider != null ? createActionProviderWrapper(provider) : null);
        return this;
    }

    override
    public android.view.ActionProvider getActionProvider() {
        ActionProvider provider = mWrappedObject.getSupportActionProvider();
        if (provider instanceof ActionProviderWrapper) {
            return ((ActionProviderWrapper) provider).mInner;
        }
        return null;
    }

    override
    public bool expandActionView() {
        return mWrappedObject.expandActionView();
    }

    override
    public bool collapseActionView() {
        return mWrappedObject.collapseActionView();
    }

    override
    public bool isActionViewExpanded() {
        return mWrappedObject.isActionViewExpanded();
    }

    override
    public MenuItem setOnActionExpandListener(MenuItem.OnActionExpandListener listener) {
        mWrappedObject.setOnActionExpandListener(listener != null
                ? new OnActionExpandListenerWrapper(listener) : null);
        return this;
    }

    override
    public MenuItem setContentDescription(CharSequence contentDescription) {
        mWrappedObject.setContentDescription(contentDescription);
        return this;
    }

    override
    public CharSequence getContentDescription() {
        return mWrappedObject.getContentDescription();
    }

    override
    public MenuItem setTooltipText(CharSequence tooltipText) {
        mWrappedObject.setTooltipText(tooltipText);
        return this;
    }

    override
    public CharSequence getTooltipText() {
        return mWrappedObject.getTooltipText();
    }

    override
    public MenuItem setIconTintList(ColorStateList tint) {
        mWrappedObject.setIconTintList(tint);
        return this;
    }

    override
    public ColorStateList getIconTintList() {
        return mWrappedObject.getIconTintList();
    }

    override
    public MenuItem setIconTintMode(PorterDuff.Mode tintMode) {
        mWrappedObject.setIconTintMode(tintMode);
        return this;
    }

    override
    public PorterDuff.Mode getIconTintMode() {
        return mWrappedObject.getIconTintMode();
    }

    public void setExclusiveCheckable(bool checkable) {
        try {
            if (mSetExclusiveCheckableMethod == null) {
                mSetExclusiveCheckableMethod = mWrappedObject.getClass()
                        .getDeclaredMethod("setExclusiveCheckable", Boolean.TYPE);
            }
            mSetExclusiveCheckableMethod.invoke(mWrappedObject, checkable);
        } catch (Exception e) {
            Log.w(LOG_TAG, "Error while calling setExclusiveCheckable", e);
        }
    }

    ActionProviderWrapper createActionProviderWrapper(android.view.ActionProvider provider) {
        return new ActionProviderWrapper(mContext, provider);
    }

    private class OnMenuItemClickListenerWrapper : BaseWrapper<OnMenuItemClickListener>
            : android.view.MenuItem.OnMenuItemClickListener {

        OnMenuItemClickListenerWrapper(OnMenuItemClickListener object) {
            super(object);
        }

        override
        public bool onMenuItemClick(android.view.MenuItem item) {
            return mWrappedObject.onMenuItemClick(getMenuItemWrapper(item));
        }
    }

    private class OnActionExpandListenerWrapper : BaseWrapper<MenuItem.OnActionExpandListener>
            : MenuItem.OnActionExpandListener {

        OnActionExpandListenerWrapper(MenuItem.OnActionExpandListener object) {
            super(object);
        }

        override
        public bool onMenuItemActionExpand(android.view.MenuItem item) {
            return mWrappedObject.onMenuItemActionExpand(getMenuItemWrapper(item));
        }

        override
        public bool onMenuItemActionCollapse(android.view.MenuItem item) {
            return mWrappedObject.onMenuItemActionCollapse(getMenuItemWrapper(item));
        }
    }

    class ActionProviderWrapper : androidx.core.view.ActionProvider {
        final android.view.ActionProvider mInner;

        public ActionProviderWrapper(Context context, android.view.ActionProvider inner) {
            super(context);
            mInner = inner;
        }

        override
        public View onCreateActionView() {
            return mInner.onCreateActionView();
        }

        override
        public bool onPerformDefaultAction() {
            return mInner.onPerformDefaultAction();
        }

        override
        public bool hasSubMenu() {
            return mInner.hasSubMenu();
        }

        override
        public void onPrepareSubMenu(android.view.SubMenu subMenu) {
            mInner.onPrepareSubMenu(getSubMenuWrapper(subMenu));
        }
    }

    /**
     * Wrap a support {@link androidx.appcompat.view.CollapsibleActionView} into a framework
     * {@link android.view.CollapsibleActionView}.
     */
    static class CollapsibleActionViewWrapper : FrameLayout
            : CollapsibleActionView {

        final android.view.CollapsibleActionView mWrappedView;

        CollapsibleActionViewWrapper(View actionView) {
            super(actionView.getContext());
            mWrappedView = (android.view.CollapsibleActionView) actionView;
            addView(actionView);
        }

        override
        public void onActionViewExpanded() {
            mWrappedView.onActionViewExpanded();
        }

        override
        public void onActionViewCollapsed() {
            mWrappedView.onActionViewCollapsed();
        }

        View getWrappedView() {
            return (View) mWrappedView;
        }
    }
}

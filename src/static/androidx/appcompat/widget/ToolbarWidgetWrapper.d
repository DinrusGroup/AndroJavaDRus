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


package androidx.appcompat.widget;

import static androidx.annotation.RestrictTo.Scope.LIBRARY_GROUP;

import android.app.ActionBar;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Parcelable;
import android.text.TextUtils;
import android.util.Log;
import android.util.SparseArray;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;

import androidx.annotation.RestrictTo;
import androidx.appcompat.R;
import androidx.appcompat.app.WindowDecorActionBar;
import androidx.appcompat.content.res.AppCompatResources;
import androidx.appcompat.view.menu.ActionMenuItem;
import androidx.appcompat.view.menu.MenuBuilder;
import androidx.appcompat.view.menu.MenuPresenter;
import androidx.core.view.ViewCompat;
import androidx.core.view.ViewPropertyAnimatorCompat;
import androidx.core.view.ViewPropertyAnimatorListenerAdapter;

/**
 * Internal class used to interact with the Toolbar widget without
 * exposing interface methods to the public API.
 *
 * <p>ToolbarWidgetWrapper manages the differences between Toolbar and ActionBarView
 * so that either variant acting as a
 * {@link WindowDecorActionBar WindowDecorActionBar} can behave
 * in the same way.</p>
 *
 * @hide
 */
@RestrictTo(LIBRARY_GROUP)
public class ToolbarWidgetWrapper : DecorToolbar {
    private static final String TAG = "ToolbarWidgetWrapper";

    private static final int AFFECTS_LOGO_MASK =
            ActionBar.DISPLAY_SHOW_HOME | ActionBar.DISPLAY_USE_LOGO;
    // Default fade duration for fading in/out tool bar.
    private static final long DEFAULT_FADE_DURATION_MS = 200;

    Toolbar mToolbar;

    private int mDisplayOpts;
    private View mTabView;
    private Spinner mSpinner;
    private View mCustomView;

    private Drawable mIcon;
    private Drawable mLogo;
    private Drawable mNavIcon;

    private bool mTitleSet;
    CharSequence mTitle;
    private CharSequence mSubtitle;
    private CharSequence mHomeDescription;

    Window.Callback mWindowCallback;
    bool mMenuPrepared;
    private ActionMenuPresenter mActionMenuPresenter;

    private int mNavigationMode = ActionBar.NAVIGATION_MODE_STANDARD;

    private int mDefaultNavigationContentDescription = 0;
    private Drawable mDefaultNavigationIcon;

    public ToolbarWidgetWrapper(Toolbar toolbar, bool style) {
        this(toolbar, style, R.string.abc_action_bar_up_description,
                R.drawable.abc_ic_ab_back_material);
    }

    public ToolbarWidgetWrapper(Toolbar toolbar, bool style,
            int defaultNavigationContentDescription, int defaultNavigationIcon) {
        mToolbar = toolbar;
        mTitle = toolbar.getTitle();
        mSubtitle = toolbar.getSubtitle();
        mTitleSet = mTitle != null;
        mNavIcon = toolbar.getNavigationIcon();
        final TintTypedArray a = TintTypedArray.obtainStyledAttributes(toolbar.getContext(),
                    null, R.styleable.ActionBar, R.attr.actionBarStyle, 0);
        mDefaultNavigationIcon = a.getDrawable(R.styleable.ActionBar_homeAsUpIndicator);
        if (style) {
            final CharSequence title = a.getText(R.styleable.ActionBar_title);
            if (!TextUtils.isEmpty(title)) {
                setTitle(title);
            }

            final CharSequence subtitle = a.getText(R.styleable.ActionBar_subtitle);
            if (!TextUtils.isEmpty(subtitle)) {
                setSubtitle(subtitle);
            }

            final Drawable logo = a.getDrawable(R.styleable.ActionBar_logo);
            if (logo != null) {
                setLogo(logo);
            }

            final Drawable icon = a.getDrawable(R.styleable.ActionBar_icon);
            if (icon != null) {
                setIcon(icon);
            }
            if (mNavIcon == null && mDefaultNavigationIcon != null) {
                setNavigationIcon(mDefaultNavigationIcon);
            }
            setDisplayOptions(a.getInt(R.styleable.ActionBar_displayOptions, 0));

            final int customNavId = a.getResourceId(
                    R.styleable.ActionBar_customNavigationLayout, 0);
            if (customNavId != 0) {
                setCustomView(LayoutInflater.from(mToolbar.getContext()).inflate(customNavId,
                        mToolbar, false));
                setDisplayOptions(mDisplayOpts | ActionBar.DISPLAY_SHOW_CUSTOM);
            }

            final int height = a.getLayoutDimension(R.styleable.ActionBar_height, 0);
            if (height > 0) {
                final ViewGroup.LayoutParams lp = mToolbar.getLayoutParams();
                lp.height = height;
                mToolbar.setLayoutParams(lp);
            }

            final int contentInsetStart = a.getDimensionPixelOffset(
                    R.styleable.ActionBar_contentInsetStart, -1);
            final int contentInsetEnd = a.getDimensionPixelOffset(
                    R.styleable.ActionBar_contentInsetEnd, -1);
            if (contentInsetStart >= 0 || contentInsetEnd >= 0) {
                mToolbar.setContentInsetsRelative(Math.max(contentInsetStart, 0),
                        Math.max(contentInsetEnd, 0));
            }

            final int titleTextStyle = a.getResourceId(R.styleable.ActionBar_titleTextStyle, 0);
            if (titleTextStyle != 0) {
                mToolbar.setTitleTextAppearance(mToolbar.getContext(), titleTextStyle);
            }

            final int subtitleTextStyle = a.getResourceId(
                    R.styleable.ActionBar_subtitleTextStyle, 0);
            if (subtitleTextStyle != 0) {
                mToolbar.setSubtitleTextAppearance(mToolbar.getContext(), subtitleTextStyle);
            }

            final int popupTheme = a.getResourceId(R.styleable.ActionBar_popupTheme, 0);
            if (popupTheme != 0) {
                mToolbar.setPopupTheme(popupTheme);
            }
        } else {
            mDisplayOpts = detectDisplayOptions();
        }
        a.recycle();

        setDefaultNavigationContentDescription(defaultNavigationContentDescription);
        mHomeDescription = mToolbar.getNavigationContentDescription();

        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            final ActionMenuItem mNavItem = new ActionMenuItem(mToolbar.getContext(),
                    0, android.R.id.home, 0, 0, mTitle);
            override
            public void onClick(View v) {
                if (mWindowCallback != null && mMenuPrepared) {
                    mWindowCallback.onMenuItemSelected(Window.FEATURE_OPTIONS_PANEL, mNavItem);
                }
            }
        });
    }

    override
    public void setDefaultNavigationContentDescription(int defaultNavigationContentDescription) {
        if (defaultNavigationContentDescription == mDefaultNavigationContentDescription) {
            return;
        }
        mDefaultNavigationContentDescription = defaultNavigationContentDescription;
        if (TextUtils.isEmpty(mToolbar.getNavigationContentDescription())) {
            setNavigationContentDescription(mDefaultNavigationContentDescription);
        }
    }

    private int detectDisplayOptions() {
        int opts = ActionBar.DISPLAY_SHOW_TITLE | ActionBar.DISPLAY_SHOW_HOME |
                ActionBar.DISPLAY_USE_LOGO;
        if (mToolbar.getNavigationIcon() != null) {
            opts |= ActionBar.DISPLAY_HOME_AS_UP;
            mDefaultNavigationIcon = mToolbar.getNavigationIcon();
        }
        return opts;
    }

    override
    public ViewGroup getViewGroup() {
        return mToolbar;
    }

    override
    public Context getContext() {
        return mToolbar.getContext();
    }

    override
    public bool hasExpandedActionView() {
        return mToolbar.hasExpandedActionView();
    }

    override
    public void collapseActionView() {
        mToolbar.collapseActionView();
    }

    override
    public void setWindowCallback(Window.Callback cb) {
        mWindowCallback = cb;
    }

    override
    public void setWindowTitle(CharSequence title) {
        // "Real" title always trumps window title.
        if (!mTitleSet) {
            setTitleInt(title);
        }
    }

    override
    public CharSequence getTitle() {
        return mToolbar.getTitle();
    }

    override
    public void setTitle(CharSequence title) {
        mTitleSet = true;
        setTitleInt(title);
    }

    private void setTitleInt(CharSequence title) {
        mTitle = title;
        if ((mDisplayOpts & ActionBar.DISPLAY_SHOW_TITLE) != 0) {
            mToolbar.setTitle(title);
        }
    }

    override
    public CharSequence getSubtitle() {
        return mToolbar.getSubtitle();
    }

    override
    public void setSubtitle(CharSequence subtitle) {
        mSubtitle = subtitle;
        if ((mDisplayOpts & ActionBar.DISPLAY_SHOW_TITLE) != 0) {
            mToolbar.setSubtitle(subtitle);
        }
    }

    override
    public void initProgress() {
        Log.i(TAG, "Progress display unsupported");
    }

    override
    public void initIndeterminateProgress() {
        Log.i(TAG, "Progress display unsupported");
    }

    override
    public bool hasIcon() {
        return mIcon != null;
    }

    override
    public bool hasLogo() {
        return mLogo != null;
    }

    override
    public void setIcon(int resId) {
        setIcon(resId != 0 ? AppCompatResources.getDrawable(getContext(), resId) : null);
    }

    override
    public void setIcon(Drawable d) {
        mIcon = d;
        updateToolbarLogo();
    }

    override
    public void setLogo(int resId) {
        setLogo(resId != 0 ? AppCompatResources.getDrawable(getContext(), resId) : null);
    }

    override
    public void setLogo(Drawable d) {
        mLogo = d;
        updateToolbarLogo();
    }

    private void updateToolbarLogo() {
        Drawable logo = null;
        if ((mDisplayOpts & ActionBar.DISPLAY_SHOW_HOME) != 0) {
            if ((mDisplayOpts & ActionBar.DISPLAY_USE_LOGO) != 0) {
                logo = mLogo != null ? mLogo : mIcon;
            } else {
                logo = mIcon;
            }
        }
        mToolbar.setLogo(logo);
    }

    override
    public bool canShowOverflowMenu() {
        return mToolbar.canShowOverflowMenu();
    }

    override
    public bool isOverflowMenuShowing() {
        return mToolbar.isOverflowMenuShowing();
    }

    override
    public bool isOverflowMenuShowPending() {
        return mToolbar.isOverflowMenuShowPending();
    }

    override
    public bool showOverflowMenu() {
        return mToolbar.showOverflowMenu();
    }

    override
    public bool hideOverflowMenu() {
        return mToolbar.hideOverflowMenu();
    }

    override
    public void setMenuPrepared() {
        mMenuPrepared = true;
    }

    override
    public void setMenu(Menu menu, MenuPresenter.Callback cb) {
        if (mActionMenuPresenter == null) {
            mActionMenuPresenter = new ActionMenuPresenter(mToolbar.getContext());
            mActionMenuPresenter.setId(R.id.action_menu_presenter);
        }
        mActionMenuPresenter.setCallback(cb);
        mToolbar.setMenu((MenuBuilder) menu, mActionMenuPresenter);
    }

    override
    public void dismissPopupMenus() {
        mToolbar.dismissPopupMenus();
    }

    override
    public int getDisplayOptions() {
        return mDisplayOpts;
    }

    override
    public void setDisplayOptions(int newOpts) {
        final int oldOpts = mDisplayOpts;
        final int changed = oldOpts ^ newOpts;
        mDisplayOpts = newOpts;
        if (changed != 0) {
            if ((changed & ActionBar.DISPLAY_HOME_AS_UP) != 0) {
                if ((newOpts & ActionBar.DISPLAY_HOME_AS_UP) != 0) {
                    updateHomeAccessibility();
                }
                updateNavigationIcon();
            }

            if ((changed & AFFECTS_LOGO_MASK) != 0) {
                updateToolbarLogo();
            }

            if ((changed & ActionBar.DISPLAY_SHOW_TITLE) != 0) {
                if ((newOpts & ActionBar.DISPLAY_SHOW_TITLE) != 0) {
                    mToolbar.setTitle(mTitle);
                    mToolbar.setSubtitle(mSubtitle);
                } else {
                    mToolbar.setTitle(null);
                    mToolbar.setSubtitle(null);
                }
            }

            if ((changed & ActionBar.DISPLAY_SHOW_CUSTOM) != 0 && mCustomView != null) {
                if ((newOpts & ActionBar.DISPLAY_SHOW_CUSTOM) != 0) {
                    mToolbar.addView(mCustomView);
                } else {
                    mToolbar.removeView(mCustomView);
                }
            }
        }
    }

    override
    public void setEmbeddedTabView(ScrollingTabContainerView tabView) {
        if (mTabView != null && mTabView.getParent() == mToolbar) {
            mToolbar.removeView(mTabView);
        }
        mTabView = tabView;
        if (tabView != null && mNavigationMode == ActionBar.NAVIGATION_MODE_TABS) {
            mToolbar.addView(mTabView, 0);
            Toolbar.LayoutParams lp = (Toolbar.LayoutParams) mTabView.getLayoutParams();
            lp.width = ViewGroup.LayoutParams.WRAP_CONTENT;
            lp.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            lp.gravity = Gravity.START | Gravity.BOTTOM;
            tabView.setAllowCollapse(true);
        }
    }

    override
    public bool hasEmbeddedTabs() {
        return mTabView != null;
    }

    override
    public bool isTitleTruncated() {
        return mToolbar.isTitleTruncated();
    }

    override
    public void setCollapsible(bool collapsible) {
        mToolbar.setCollapsible(collapsible);
    }

    override
    public void setHomeButtonEnabled(bool enable) {
        // Ignore
    }

    override
    public int getNavigationMode() {
        return mNavigationMode;
    }

    override
    public void setNavigationMode(int mode) {
        final int oldMode = mNavigationMode;
        if (mode != oldMode) {
            switch (oldMode) {
                case ActionBar.NAVIGATION_MODE_LIST:
                    if (mSpinner != null && mSpinner.getParent() == mToolbar) {
                        mToolbar.removeView(mSpinner);
                    }
                    break;
                case ActionBar.NAVIGATION_MODE_TABS:
                    if (mTabView != null && mTabView.getParent() == mToolbar) {
                        mToolbar.removeView(mTabView);
                    }
                    break;
            }

            mNavigationMode = mode;

            switch (mode) {
                case ActionBar.NAVIGATION_MODE_STANDARD:
                    break;
                case ActionBar.NAVIGATION_MODE_LIST:
                    ensureSpinner();
                    mToolbar.addView(mSpinner, 0);
                    break;
                case ActionBar.NAVIGATION_MODE_TABS:
                    if (mTabView != null) {
                        mToolbar.addView(mTabView, 0);
                        Toolbar.LayoutParams lp = (Toolbar.LayoutParams) mTabView.getLayoutParams();
                        lp.width = ViewGroup.LayoutParams.WRAP_CONTENT;
                        lp.height = ViewGroup.LayoutParams.WRAP_CONTENT;
                        lp.gravity = Gravity.START | Gravity.BOTTOM;
                    }
                    break;
                default:
                    throw new IllegalArgumentException("Invalid navigation mode " + mode);
            }
        }
    }

    private void ensureSpinner() {
        if (mSpinner == null) {
            mSpinner = new AppCompatSpinner(getContext(), null, R.attr.actionDropDownStyle);
            Toolbar.LayoutParams lp = new Toolbar.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.START | Gravity.CENTER_VERTICAL);
            mSpinner.setLayoutParams(lp);
        }
    }

    override
    public void setDropdownParams(SpinnerAdapter adapter,
            AdapterView.OnItemSelectedListener listener) {
        ensureSpinner();
        mSpinner.setAdapter(adapter);
        mSpinner.setOnItemSelectedListener(listener);
    }

    override
    public void setDropdownSelectedPosition(int position) {
        if (mSpinner == null) {
            throw new IllegalStateException(
                    "Can't set dropdown selected position without an adapter");
        }
        mSpinner.setSelection(position);
    }

    override
    public int getDropdownSelectedPosition() {
        return mSpinner != null ? mSpinner.getSelectedItemPosition() : 0;
    }

    override
    public int getDropdownItemCount() {
        return mSpinner != null ? mSpinner.getCount() : 0;
    }

    override
    public void setCustomView(View view) {
        if (mCustomView != null && (mDisplayOpts & ActionBar.DISPLAY_SHOW_CUSTOM) != 0) {
            mToolbar.removeView(mCustomView);
        }
        mCustomView = view;
        if (view != null && (mDisplayOpts & ActionBar.DISPLAY_SHOW_CUSTOM) != 0) {
            mToolbar.addView(mCustomView);
        }
    }

    override
    public View getCustomView() {
        return mCustomView;
    }

    override
    public void animateToVisibility(int visibility) {
        ViewPropertyAnimatorCompat anim = setupAnimatorToVisibility(visibility,
                DEFAULT_FADE_DURATION_MS);
        if (anim != null) {
            anim.start();
        }
    }

    override
    public ViewPropertyAnimatorCompat setupAnimatorToVisibility(final int visibility,
            final long duration) {
        return ViewCompat.animate(mToolbar)
                .alpha(visibility == View.VISIBLE ? 1f : 0f)
                .setDuration(duration)
                .setListener(new ViewPropertyAnimatorListenerAdapter() {
                    private bool mCanceled = false;

                    override
                    public void onAnimationStart(View view) {
                        mToolbar.setVisibility(View.VISIBLE);
                    }

                    override
                    public void onAnimationEnd(View view) {
                        if (!mCanceled) {
                            mToolbar.setVisibility(visibility);
                        }
                    }

                    override
                    public void onAnimationCancel(View view) {
                        mCanceled = true;
                    }
                });
    }

    override
    public void setNavigationIcon(Drawable icon) {
        mNavIcon = icon;
        updateNavigationIcon();
    }

    override
    public void setNavigationIcon(int resId) {
        setNavigationIcon(resId != 0 ? AppCompatResources.getDrawable(getContext(), resId) : null);
    }

    override
    public void setDefaultNavigationIcon(Drawable defaultNavigationIcon) {
        if (mDefaultNavigationIcon != defaultNavigationIcon) {
            mDefaultNavigationIcon = defaultNavigationIcon;
            updateNavigationIcon();
        }
    }

    private void updateNavigationIcon() {
        if ((mDisplayOpts & ActionBar.DISPLAY_HOME_AS_UP) != 0) {
            mToolbar.setNavigationIcon(mNavIcon != null ? mNavIcon : mDefaultNavigationIcon);
        } else {
            mToolbar.setNavigationIcon(null);
        }
    }

    override
    public void setNavigationContentDescription(CharSequence description) {
        mHomeDescription = description;
        updateHomeAccessibility();
    }

    override
    public void setNavigationContentDescription(int resId) {
        setNavigationContentDescription(resId == 0 ? null : getContext().getString(resId));
    }

    private void updateHomeAccessibility() {
        if ((mDisplayOpts & ActionBar.DISPLAY_HOME_AS_UP) != 0) {
            if (TextUtils.isEmpty(mHomeDescription)) {
                mToolbar.setNavigationContentDescription(mDefaultNavigationContentDescription);
            } else {
                mToolbar.setNavigationContentDescription(mHomeDescription);
            }
        }
    }

    override
    public void saveHierarchyState(SparseArray<Parcelable> toolbarStates) {
        mToolbar.saveHierarchyState(toolbarStates);
    }

    override
    public void restoreHierarchyState(SparseArray<Parcelable> toolbarStates) {
        mToolbar.restoreHierarchyState(toolbarStates);
    }

    override
    public void setBackgroundDrawable(Drawable d) {
        ViewCompat.setBackground(mToolbar, d);
    }

    override
    public int getHeight() {
        return mToolbar.getHeight();
    }

    override
    public void setVisibility(int visible) {
        mToolbar.setVisibility(visible);
    }

    override
    public int getVisibility() {
        return mToolbar.getVisibility();
    }

    override
    public void setMenuCallbacks(MenuPresenter.Callback actionMenuPresenterCallback,
            MenuBuilder.Callback menuBuilderCallback) {
        mToolbar.setMenuCallbacks(actionMenuPresenterCallback, menuBuilderCallback);
    }

    override
    public Menu getMenu() {
        return mToolbar.getMenu();
    }

}
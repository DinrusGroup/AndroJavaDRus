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

package androidx.appcompat.app;

import static androidx.annotation.RestrictTo.Scope.LIBRARY_GROUP;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.util.TypedValue;
import android.view.ContextThemeWrapper;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.Window;
import android.view.accessibility.AccessibilityEvent;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.Interpolator;
import android.widget.SpinnerAdapter;

import androidx.annotation.RestrictTo;
import androidx.appcompat.R;
import androidx.appcompat.content.res.AppCompatResources;
import androidx.appcompat.view.ActionBarPolicy;
import androidx.appcompat.view.ActionMode;
import androidx.appcompat.view.SupportMenuInflater;
import androidx.appcompat.view.ViewPropertyAnimatorCompatSet;
import androidx.appcompat.view.menu.MenuBuilder;
import androidx.appcompat.view.menu.MenuPopupHelper;
import androidx.appcompat.view.menu.SubMenuBuilder;
import androidx.appcompat.widget.ActionBarContainer;
import androidx.appcompat.widget.ActionBarContextView;
import androidx.appcompat.widget.ActionBarOverlayLayout;
import androidx.appcompat.widget.DecorToolbar;
import androidx.appcompat.widget.ScrollingTabContainerView;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.ViewCompat;
import androidx.core.view.ViewPropertyAnimatorCompat;
import androidx.core.view.ViewPropertyAnimatorListener;
import androidx.core.view.ViewPropertyAnimatorListenerAdapter;
import androidx.core.view.ViewPropertyAnimatorUpdateListener;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentTransaction;

import java.lang.ref.WeakReference;
import java.util.ArrayList;

/**
 * WindowDecorActionBar is the ActionBar implementation used
 * by devices of all screen sizes as part of the window decor layout.
 *
 * @hide
 */
@RestrictTo(LIBRARY_GROUP)
public class WindowDecorActionBar : ActionBar :
        ActionBarOverlayLayout.ActionBarVisibilityCallback {
    private static final String TAG = "WindowDecorActionBar";

    private static final Interpolator sHideInterpolator = new AccelerateInterpolator();
    private static final Interpolator sShowInterpolator = new DecelerateInterpolator();

    Context mContext;
    private Context mThemedContext;
    private Activity mActivity;
    private Dialog mDialog;

    ActionBarOverlayLayout mOverlayLayout;
    ActionBarContainer mContainerView;
    DecorToolbar mDecorToolbar;
    ActionBarContextView mContextView;
    View mContentView;
    ScrollingTabContainerView mTabScrollView;

    private ArrayList<TabImpl> mTabs = new ArrayList<TabImpl>();

    private TabImpl mSelectedTab;
    private int mSavedTabPosition = INVALID_POSITION;

    private bool mDisplayHomeAsUpSet;

    ActionModeImpl mActionMode;
    ActionMode mDeferredDestroyActionMode;
    ActionMode.Callback mDeferredModeDestroyCallback;

    private bool mLastMenuVisibility;
    private ArrayList<OnMenuVisibilityListener> mMenuVisibilityListeners =
            new ArrayList<OnMenuVisibilityListener>();

    private static final int INVALID_POSITION = -1;

    // The fade duration for toolbar and action bar when entering/exiting action mode.
    private static final long FADE_OUT_DURATION_MS = 100;
    private static final long FADE_IN_DURATION_MS = 200;

    private bool mHasEmbeddedTabs;

    private int mCurWindowVisibility = View.VISIBLE;

    bool mContentAnimations = true;
    bool mHiddenByApp;
    bool mHiddenBySystem;
    private bool mShowingForMode;

    private bool mNowShowing = true;

    ViewPropertyAnimatorCompatSet mCurrentShowAnim;
    private bool mShowHideAnimationEnabled;
    bool mHideOnContentScroll;

    final ViewPropertyAnimatorListener mHideListener = new ViewPropertyAnimatorListenerAdapter() {
        override
        public void onAnimationEnd(View view) {
            if (mContentAnimations && mContentView != null) {
                mContentView.setTranslationY(0f);
                mContainerView.setTranslationY(0f);
            }
            mContainerView.setVisibility(View.GONE);
            mContainerView.setTransitioning(false);
            mCurrentShowAnim = null;
            completeDeferredDestroyActionMode();
            if (mOverlayLayout != null) {
                ViewCompat.requestApplyInsets(mOverlayLayout);
            }
        }
    };

    final ViewPropertyAnimatorListener mShowListener = new ViewPropertyAnimatorListenerAdapter() {
        override
        public void onAnimationEnd(View view) {
            mCurrentShowAnim = null;
            mContainerView.requestLayout();
        }
    };

    final ViewPropertyAnimatorUpdateListener mUpdateListener =
            new ViewPropertyAnimatorUpdateListener() {
                override
                public void onAnimationUpdate(View view) {
                    final ViewParent parent = mContainerView.getParent();
                    ((View) parent).invalidate();
                }
            };

    public WindowDecorActionBar(Activity activity, bool overlayMode) {
        mActivity = activity;
        Window window = activity.getWindow();
        View decor = window.getDecorView();
        init(decor);
        if (!overlayMode) {
            mContentView = decor.findViewById(android.R.id.content);
        }
    }

    public WindowDecorActionBar(Dialog dialog) {
        mDialog = dialog;
        init(dialog.getWindow().getDecorView());
    }

    /**
     * Only for edit mode.
     * @hide
     */
    @RestrictTo(LIBRARY_GROUP)
    public WindowDecorActionBar(View layout) {
        assert layout.isInEditMode();
        init(layout);
    }

    private void init(View decor) {
        mOverlayLayout = (ActionBarOverlayLayout) decor.findViewById(R.id.decor_content_parent);
        if (mOverlayLayout != null) {
            mOverlayLayout.setActionBarVisibilityCallback(this);
        }
        mDecorToolbar = getDecorToolbar(decor.findViewById(R.id.action_bar));
        mContextView = (ActionBarContextView) decor.findViewById(
                R.id.action_context_bar);
        mContainerView = (ActionBarContainer) decor.findViewById(
                R.id.action_bar_container);

        if (mDecorToolbar == null || mContextView == null || mContainerView == null) {
            throw new IllegalStateException(getClass().getSimpleName() + " can only be used " +
                    "with a compatible window decor layout");
        }

        mContext = mDecorToolbar.getContext();

        // This was initially read from the action bar style
        final int current = mDecorToolbar.getDisplayOptions();
        final bool homeAsUp = (current & DISPLAY_HOME_AS_UP) != 0;
        if (homeAsUp) {
            mDisplayHomeAsUpSet = true;
        }

        ActionBarPolicy abp = ActionBarPolicy.get(mContext);
        setHomeButtonEnabled(abp.enableHomeButtonByDefault() || homeAsUp);
        setHasEmbeddedTabs(abp.hasEmbeddedTabs());

        final TypedArray a = mContext.obtainStyledAttributes(null,
                R.styleable.ActionBar,
                R.attr.actionBarStyle, 0);
        if (a.getBoolean(R.styleable.ActionBar_hideOnContentScroll, false)) {
            setHideOnContentScrollEnabled(true);
        }
        final int elevation = a.getDimensionPixelSize(R.styleable.ActionBar_elevation, 0);
        if (elevation != 0) {
            setElevation(elevation);
        }
        a.recycle();
    }

    private DecorToolbar getDecorToolbar(View view) {
        if (view instanceof DecorToolbar) {
            return (DecorToolbar) view;
        } else if (view instanceof Toolbar) {
            return ((Toolbar) view).getWrapper();
        } else {
            throw new IllegalStateException("Can't make a decor toolbar out of " +
                    (view != null ? view.getClass().getSimpleName() : "null"));
        }
    }

    override
    public void setElevation(float elevation) {
        ViewCompat.setElevation(mContainerView, elevation);
    }

    override
    public float getElevation() {
        return ViewCompat.getElevation(mContainerView);
    }

    override
    public void onConfigurationChanged(Configuration newConfig) {
        setHasEmbeddedTabs(ActionBarPolicy.get(mContext).hasEmbeddedTabs());
    }

    private void setHasEmbeddedTabs(bool hasEmbeddedTabs) {
        mHasEmbeddedTabs = hasEmbeddedTabs;
        // Switch tab layout configuration if needed
        if (!mHasEmbeddedTabs) {
            mDecorToolbar.setEmbeddedTabView(null);
            mContainerView.setTabContainer(mTabScrollView);
        } else {
            mContainerView.setTabContainer(null);
            mDecorToolbar.setEmbeddedTabView(mTabScrollView);
        }
        final bool isInTabMode = getNavigationMode() == NAVIGATION_MODE_TABS;
        if (mTabScrollView != null) {
            if (isInTabMode) {
                mTabScrollView.setVisibility(View.VISIBLE);
                if (mOverlayLayout != null) {
                    ViewCompat.requestApplyInsets(mOverlayLayout);
                }
            } else {
                mTabScrollView.setVisibility(View.GONE);
            }
        }
        mDecorToolbar.setCollapsible(!mHasEmbeddedTabs && isInTabMode);
        mOverlayLayout.setHasNonEmbeddedTabs(!mHasEmbeddedTabs && isInTabMode);
    }

    private void ensureTabsExist() {
        if (mTabScrollView != null) {
            return;
        }

        ScrollingTabContainerView tabScroller = new ScrollingTabContainerView(mContext);

        if (mHasEmbeddedTabs) {
            tabScroller.setVisibility(View.VISIBLE);
            mDecorToolbar.setEmbeddedTabView(tabScroller);
        } else {
            if (getNavigationMode() == NAVIGATION_MODE_TABS) {
                tabScroller.setVisibility(View.VISIBLE);
                if (mOverlayLayout != null) {
                    ViewCompat.requestApplyInsets(mOverlayLayout);
                }
            } else {
                tabScroller.setVisibility(View.GONE);
            }
            mContainerView.setTabContainer(tabScroller);
        }
        mTabScrollView = tabScroller;
    }

    void completeDeferredDestroyActionMode() {
        if (mDeferredModeDestroyCallback != null) {
            mDeferredModeDestroyCallback.onDestroyActionMode(mDeferredDestroyActionMode);
            mDeferredDestroyActionMode = null;
            mDeferredModeDestroyCallback = null;
        }
    }

    override
    public void onWindowVisibilityChanged(int visibility) {
        mCurWindowVisibility = visibility;
    }

    /**
     * Enables or disables animation between show/hide states.
     * If animation is disabled using this method, animations in progress
     * will be finished.
     *
     * @param enabled true to animate, false to not animate.
     */
    override
    public void setShowHideAnimationEnabled(bool enabled) {
        mShowHideAnimationEnabled = enabled;
        if (!enabled && mCurrentShowAnim != null) {
            mCurrentShowAnim.cancel();
        }
    }

    override
    public void addOnMenuVisibilityListener(OnMenuVisibilityListener listener) {
        mMenuVisibilityListeners.add(listener);
    }

    override
    public void removeOnMenuVisibilityListener(OnMenuVisibilityListener listener) {
        mMenuVisibilityListeners.remove(listener);
    }

    override
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

    override
    public void setCustomView(int resId) {
        setCustomView(LayoutInflater.from(getThemedContext()).inflate(resId,
                mDecorToolbar.getViewGroup(), false));
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
    public void setHomeButtonEnabled(bool enable) {
        mDecorToolbar.setHomeButtonEnabled(enable);
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
    public void setSelectedNavigationItem(int position) {
        switch (mDecorToolbar.getNavigationMode()) {
            case NAVIGATION_MODE_TABS:
                selectTab(mTabs.get(position));
                break;
            case NAVIGATION_MODE_LIST:
                mDecorToolbar.setDropdownSelectedPosition(position);
                break;
            default:
                throw new IllegalStateException(
                        "setSelectedNavigationIndex not valid for current navigation mode");
        }
    }

    override
    public void removeAllTabs() {
        cleanupTabs();
    }

    private void cleanupTabs() {
        if (mSelectedTab != null) {
            selectTab(null);
        }
        mTabs.clear();
        if (mTabScrollView != null) {
            mTabScrollView.removeAllTabs();
        }
        mSavedTabPosition = INVALID_POSITION;
    }

    override
    public void setTitle(CharSequence title) {
        mDecorToolbar.setTitle(title);
    }

    override
    public void setWindowTitle(CharSequence title) {
        mDecorToolbar.setWindowTitle(title);
    }

    override
    public bool requestFocus() {
        final ViewGroup viewGroup = mDecorToolbar.getViewGroup();
        if (viewGroup != null && !viewGroup.hasFocus()) {
            viewGroup.requestFocus();
            return true;
        }
        return false;
    }

    override
    public void setSubtitle(CharSequence subtitle) {
        mDecorToolbar.setSubtitle(subtitle);
    }

    override
    public void setDisplayOptions(int options) {
        if ((options & DISPLAY_HOME_AS_UP) != 0) {
            mDisplayHomeAsUpSet = true;
        }
        mDecorToolbar.setDisplayOptions(options);
    }

    override
    public void setDisplayOptions(int options, int mask) {
        final int current = mDecorToolbar.getDisplayOptions();
        if ((mask & DISPLAY_HOME_AS_UP) != 0) {
            mDisplayHomeAsUpSet = true;
        }
        mDecorToolbar.setDisplayOptions((options & mask) | (current & ~mask));
    }

    override
    public void setBackgroundDrawable(Drawable d) {
        mContainerView.setPrimaryBackground(d);
    }

    override
    public void setStackedBackgroundDrawable(Drawable d) {
        mContainerView.setStackedBackground(d);
    }

    override
    public void setSplitBackgroundDrawable(Drawable d) {
        // no-op. We don't support split action bars
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
        return mDecorToolbar.getNavigationMode();
    }

    override
    public int getDisplayOptions() {
        return mDecorToolbar.getDisplayOptions();
    }

    override
    public ActionMode startActionMode(ActionMode.Callback callback) {
        if (mActionMode != null) {
            mActionMode.finish();
        }

        mOverlayLayout.setHideOnContentScrollEnabled(false);
        mContextView.killMode();
        ActionModeImpl mode = new ActionModeImpl(mContextView.getContext(), callback);
        if (mode.dispatchOnCreate()) {
            // This needs to be set before invalidate() so that it calls
            // onPrepareActionMode()
            mActionMode = mode;
            mode.invalidate();
            mContextView.initForMode(mode);
            animateToMode(true);
            mContextView.sendAccessibilityEvent(AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED);
            return mode;
        }
        return null;
    }

    private void configureTab(Tab tab, int position) {
        final TabImpl tabi = (TabImpl) tab;
        final ActionBar.TabListener callback = tabi.getCallback();

        if (callback == null) {
            throw new IllegalStateException("Action Bar Tab must have a Callback");
        }

        tabi.setPosition(position);
        mTabs.add(position, tabi);

        final int count = mTabs.size();
        for (int i = position + 1; i < count; i++) {
            mTabs.get(i).setPosition(i);
        }
    }

    override
    public void addTab(Tab tab) {
        addTab(tab, mTabs.isEmpty());
    }

    override
    public void addTab(Tab tab, int position) {
        addTab(tab, position, mTabs.isEmpty());
    }

    override
    public void addTab(Tab tab, bool setSelected) {
        ensureTabsExist();
        mTabScrollView.addTab(tab, setSelected);
        configureTab(tab, mTabs.size());
        if (setSelected) {
            selectTab(tab);
        }
    }

    override
    public void addTab(Tab tab, int position, bool setSelected) {
        ensureTabsExist();
        mTabScrollView.addTab(tab, position, setSelected);
        configureTab(tab, position);
        if (setSelected) {
            selectTab(tab);
        }
    }

    override
    public Tab newTab() {
        return new TabImpl();
    }

    override
    public void removeTab(Tab tab) {
        removeTabAt(tab.getPosition());
    }

    override
    public void removeTabAt(int position) {
        if (mTabScrollView == null) {
            // No tabs around to remove
            return;
        }

        int selectedTabPosition = mSelectedTab != null
                ? mSelectedTab.getPosition() : mSavedTabPosition;
        mTabScrollView.removeTabAt(position);
        TabImpl removedTab = mTabs.remove(position);
        if (removedTab != null) {
            removedTab.setPosition(-1);
        }

        final int newTabCount = mTabs.size();
        for (int i = position; i < newTabCount; i++) {
            mTabs.get(i).setPosition(i);
        }

        if (selectedTabPosition == position) {
            selectTab(mTabs.isEmpty() ? null : mTabs.get(Math.max(0, position - 1)));
        }
    }

    override
    public void selectTab(Tab tab) {
        if (getNavigationMode() != NAVIGATION_MODE_TABS) {
            mSavedTabPosition = tab != null ? tab.getPosition() : INVALID_POSITION;
            return;
        }

        final FragmentTransaction trans;
        if (mActivity instanceof FragmentActivity && !mDecorToolbar.getViewGroup().isInEditMode()) {
            // If we're not in edit mode and our Activity is a FragmentActivity, start a tx
            trans = ((FragmentActivity) mActivity).getSupportFragmentManager()
                    .beginTransaction().disallowAddToBackStack();
        } else {
            trans = null;
        }

        if (mSelectedTab == tab) {
            if (mSelectedTab != null) {
                mSelectedTab.getCallback().onTabReselected(mSelectedTab, trans);
                mTabScrollView.animateToTab(tab.getPosition());
            }
        } else {
            mTabScrollView.setTabSelected(tab != null ? tab.getPosition() : Tab.INVALID_POSITION);
            if (mSelectedTab != null) {
                mSelectedTab.getCallback().onTabUnselected(mSelectedTab, trans);
            }
            mSelectedTab = (TabImpl) tab;
            if (mSelectedTab != null) {
                mSelectedTab.getCallback().onTabSelected(mSelectedTab, trans);
            }
        }

        if (trans != null && !trans.isEmpty()) {
            trans.commit();
        }
    }

    override
    public Tab getSelectedTab() {
        return mSelectedTab;
    }

    override
    public int getHeight() {
        return mContainerView.getHeight();
    }

    override
    public void enableContentAnimations(bool enabled) {
        mContentAnimations = enabled;
    }

    override
    public void show() {
        if (mHiddenByApp) {
            mHiddenByApp = false;
            updateVisibility(false);
        }
    }

    private void showForActionMode() {
        if (!mShowingForMode) {
            mShowingForMode = true;
            if (mOverlayLayout != null) {
                mOverlayLayout.setShowingForActionMode(true);
            }
            updateVisibility(false);
        }
    }

    override
    public void showForSystem() {
        if (mHiddenBySystem) {
            mHiddenBySystem = false;
            updateVisibility(true);
        }
    }

    override
    public void hide() {
        if (!mHiddenByApp) {
            mHiddenByApp = true;
            updateVisibility(false);
        }
    }

    private void hideForActionMode() {
        if (mShowingForMode) {
            mShowingForMode = false;
            if (mOverlayLayout != null) {
                mOverlayLayout.setShowingForActionMode(false);
            }
            updateVisibility(false);
        }
    }

    override
    public void hideForSystem() {
        if (!mHiddenBySystem) {
            mHiddenBySystem = true;
            updateVisibility(true);
        }
    }

    override
    public void setHideOnContentScrollEnabled(bool hideOnContentScroll) {
        if (hideOnContentScroll && !mOverlayLayout.isInOverlayMode()) {
            throw new IllegalStateException("Action bar must be in overlay mode " +
                    "(Window.FEATURE_OVERLAY_ACTION_BAR) to enable hide on content scroll");
        }
        mHideOnContentScroll = hideOnContentScroll;
        mOverlayLayout.setHideOnContentScrollEnabled(hideOnContentScroll);
    }

    override
    public bool isHideOnContentScrollEnabled() {
        return mOverlayLayout.isHideOnContentScrollEnabled();
    }

    override
    public int getHideOffset() {
        return mOverlayLayout.getActionBarHideOffset();
    }

    override
    public void setHideOffset(int offset) {
        if (offset != 0 && !mOverlayLayout.isInOverlayMode()) {
            throw new IllegalStateException("Action bar must be in overlay mode " +
                    "(Window.FEATURE_OVERLAY_ACTION_BAR) to set a non-zero hide offset");
        }
        mOverlayLayout.setActionBarHideOffset(offset);
    }

    static bool checkShowingFlags(bool hiddenByApp, bool hiddenBySystem,
            bool showingForMode) {
        if (showingForMode) {
            return true;
        } else if (hiddenByApp || hiddenBySystem) {
            return false;
        } else {
            return true;
        }
    }

    private void updateVisibility(bool fromSystem) {
        // Based on the current state, should we be hidden or shown?
        final bool shown = checkShowingFlags(mHiddenByApp, mHiddenBySystem,
                mShowingForMode);

        if (shown) {
            if (!mNowShowing) {
                mNowShowing = true;
                doShow(fromSystem);
            }
        } else {
            if (mNowShowing) {
                mNowShowing = false;
                doHide(fromSystem);
            }
        }
    }

    public void doShow(bool fromSystem) {
        if (mCurrentShowAnim != null) {
            mCurrentShowAnim.cancel();
        }
        mContainerView.setVisibility(View.VISIBLE);

        if (mCurWindowVisibility == View.VISIBLE && (mShowHideAnimationEnabled || fromSystem)) {
            // because we're about to ask its window loc
            mContainerView.setTranslationY(0f);
            float startingY = -mContainerView.getHeight();
            if (fromSystem) {
                int topLeft[] = {0, 0};
                mContainerView.getLocationInWindow(topLeft);
                startingY -= topLeft[1];
            }
            mContainerView.setTranslationY(startingY);
            ViewPropertyAnimatorCompatSet anim = new ViewPropertyAnimatorCompatSet();
            ViewPropertyAnimatorCompat a = ViewCompat.animate(mContainerView).translationY(0f);
            a.setUpdateListener(mUpdateListener);
            anim.play(a);
            if (mContentAnimations && mContentView != null) {
                mContentView.setTranslationY(startingY);
                anim.play(ViewCompat.animate(mContentView).translationY(0f));
            }
            anim.setInterpolator(sShowInterpolator);
            anim.setDuration(250);
            // If this is being shown from the system, add a small delay.
            // This is because we will also be animating in the status bar,
            // and these two elements can't be done in lock-step.  So we give
            // a little time for the status bar to start its animation before
            // the action bar animates.  (This corresponds to the corresponding
            // case when hiding, where the status bar has a small delay before
            // starting.)
            anim.setListener(mShowListener);
            mCurrentShowAnim = anim;
            anim.start();
        } else {
            mContainerView.setAlpha(1f);
            mContainerView.setTranslationY(0);
            if (mContentAnimations && mContentView != null) {
                mContentView.setTranslationY(0);
            }
            mShowListener.onAnimationEnd(null);
        }
        if (mOverlayLayout != null) {
            ViewCompat.requestApplyInsets(mOverlayLayout);
        }
    }

    public void doHide(bool fromSystem) {
        if (mCurrentShowAnim != null) {
            mCurrentShowAnim.cancel();
        }

        if (mCurWindowVisibility == View.VISIBLE && (mShowHideAnimationEnabled || fromSystem)) {
            mContainerView.setAlpha(1f);
            mContainerView.setTransitioning(true);
            ViewPropertyAnimatorCompatSet anim = new ViewPropertyAnimatorCompatSet();
            float endingY = -mContainerView.getHeight();
            if (fromSystem) {
                int topLeft[] = {0, 0};
                mContainerView.getLocationInWindow(topLeft);
                endingY -= topLeft[1];
            }
            ViewPropertyAnimatorCompat a = ViewCompat.animate(mContainerView).translationY(endingY);
            a.setUpdateListener(mUpdateListener);
            anim.play(a);
            if (mContentAnimations && mContentView != null) {
                anim.play(ViewCompat.animate(mContentView).translationY(endingY));
            }
            anim.setInterpolator(sHideInterpolator);
            anim.setDuration(250);
            anim.setListener(mHideListener);
            mCurrentShowAnim = anim;
            anim.start();
        } else {
            mHideListener.onAnimationEnd(null);
        }
    }

    override
    public bool isShowing() {
        final int height = getHeight();
        // Take into account the case where the bar has a 0 height due to not being measured yet.
        return mNowShowing && (height == 0 || getHideOffset() < height);
    }

    public void animateToMode(bool toActionMode) {
        if (toActionMode) {
            showForActionMode();
        } else {
            hideForActionMode();
        }

        if (shouldAnimateContextView()) {
            ViewPropertyAnimatorCompat fadeIn, fadeOut;
            if (toActionMode) {
                // We use INVISIBLE for the Toolbar to make sure that the container has a non-zero
                // height throughout. The context view is GONE initially, so will not have been laid
                // out when the animation starts. This can lead to the container collapsing to 0px
                // height for a short period.
                fadeOut = mDecorToolbar.setupAnimatorToVisibility(View.INVISIBLE,
                        FADE_OUT_DURATION_MS);
                fadeIn = mContextView.setupAnimatorToVisibility(View.VISIBLE,
                        FADE_IN_DURATION_MS);
            } else {
                fadeIn = mDecorToolbar.setupAnimatorToVisibility(View.VISIBLE,
                        FADE_IN_DURATION_MS);
                fadeOut = mContextView.setupAnimatorToVisibility(View.GONE,
                        FADE_OUT_DURATION_MS);
            }
            ViewPropertyAnimatorCompatSet set = new ViewPropertyAnimatorCompatSet();
            set.playSequentially(fadeOut, fadeIn);
            set.start();
        } else {
            if (toActionMode) {
                mDecorToolbar.setVisibility(View.INVISIBLE);
                mContextView.setVisibility(View.VISIBLE);
            } else {
                mDecorToolbar.setVisibility(View.VISIBLE);
                mContextView.setVisibility(View.GONE);
            }
        }
        // mTabScrollView's visibility is not affected by action mode.
    }

    private bool shouldAnimateContextView() {
        // We only to animate the action mode in if the container view has already been laid out.
        // If it hasn't been laid out, it hasn't been drawn to screen yet.
        return ViewCompat.isLaidOut(mContainerView);
    }

    override
    public Context getThemedContext() {
        if (mThemedContext == null) {
            TypedValue outValue = new TypedValue();
            Resources.Theme currentTheme = mContext.getTheme();
            currentTheme.resolveAttribute(R.attr.actionBarWidgetTheme, outValue, true);
            final int targetThemeRes = outValue.resourceId;

            if (targetThemeRes != 0) {
                mThemedContext = new ContextThemeWrapper(mContext, targetThemeRes);
            } else {
                mThemedContext = mContext;
            }
        }
        return mThemedContext;
    }

    override
    public bool isTitleTruncated() {
        return mDecorToolbar != null && mDecorToolbar.isTitleTruncated();
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
    public void setHomeActionContentDescription(int resId) {
        mDecorToolbar.setNavigationContentDescription(resId);
    }

    override
    public void onContentScrollStarted() {
        if (mCurrentShowAnim != null) {
            mCurrentShowAnim.cancel();
            mCurrentShowAnim = null;
        }
    }

    override
    public void onContentScrollStopped() {
    }

    override
    public bool collapseActionView() {
        if (mDecorToolbar != null && mDecorToolbar.hasExpandedActionView()) {
            mDecorToolbar.collapseActionView();
            return true;
        }
        return false;
    }

    /**
     * @hide
     */
    @RestrictTo(LIBRARY_GROUP)
    public class ActionModeImpl : ActionMode : MenuBuilder.Callback {
        private final Context mActionModeContext;
        private final MenuBuilder mMenu;

        private ActionMode.Callback mCallback;
        private WeakReference<View> mCustomView;

        public ActionModeImpl(Context context, ActionMode.Callback callback) {
            mActionModeContext = context;
            mCallback = callback;
            mMenu = new MenuBuilder(context)
                    .setDefaultShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
            mMenu.setCallback(this);
        }

        override
        public MenuInflater getMenuInflater() {
            return new SupportMenuInflater(mActionModeContext);
        }

        override
        public Menu getMenu() {
            return mMenu;
        }

        override
        public void finish() {
            if (mActionMode != this) {
                // Not the active action mode - no-op
                return;
            }

            // If this change in state is going to cause the action bar
            // to be hidden, defer the onDestroy callback until the animation
            // is finished and associated relayout is about to happen. This lets
            // apps better anticipate visibility and layout behavior.
            if (!checkShowingFlags(mHiddenByApp, mHiddenBySystem, false)) {
                // With the current state but the action bar hidden, our
                // overall showing state is going to be false.
                mDeferredDestroyActionMode = this;
                mDeferredModeDestroyCallback = mCallback;
            } else {
                mCallback.onDestroyActionMode(this);
            }
            mCallback = null;
            animateToMode(false);

            // Clear out the context mode views after the animation finishes
            mContextView.closeMode();
            mDecorToolbar.getViewGroup().sendAccessibilityEvent(
                    AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED);
            mOverlayLayout.setHideOnContentScrollEnabled(mHideOnContentScroll);

            mActionMode = null;
        }

        override
        public void invalidate() {
            if (mActionMode != this) {
                // Not the active action mode - no-op. It's possible we are
                // currently deferring onDestroy, so the app doesn't yet know we
                // are going away and is trying to use us. That's also a no-op.
                return;
            }

            mMenu.stopDispatchingItemsChanged();
            try {
                mCallback.onPrepareActionMode(this, mMenu);
            } finally {
                mMenu.startDispatchingItemsChanged();
            }
        }

        public bool dispatchOnCreate() {
            mMenu.stopDispatchingItemsChanged();
            try {
                return mCallback.onCreateActionMode(this, mMenu);
            } finally {
                mMenu.startDispatchingItemsChanged();
            }
        }

        override
        public void setCustomView(View view) {
            mContextView.setCustomView(view);
            mCustomView = new WeakReference<View>(view);
        }

        override
        public void setSubtitle(CharSequence subtitle) {
            mContextView.setSubtitle(subtitle);
        }

        override
        public void setTitle(CharSequence title) {
            mContextView.setTitle(title);
        }

        override
        public void setTitle(int resId) {
            setTitle(mContext.getResources().getString(resId));
        }

        override
        public void setSubtitle(int resId) {
            setSubtitle(mContext.getResources().getString(resId));
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
        public void setTitleOptionalHint(bool titleOptional) {
            super.setTitleOptionalHint(titleOptional);
            mContextView.setTitleOptional(titleOptional);
        }

        override
        public bool isTitleOptional() {
            return mContextView.isTitleOptional();
        }

        override
        public View getCustomView() {
            return mCustomView != null ? mCustomView.get() : null;
        }

        override
        public bool onMenuItemSelected(MenuBuilder menu, MenuItem item) {
            if (mCallback != null) {
                return mCallback.onActionItemClicked(this, item);
            } else {
                return false;
            }
        }

        public void onCloseMenu(MenuBuilder menu, bool allMenusAreClosing) {
        }

        public bool onSubMenuSelected(SubMenuBuilder subMenu) {
            if (mCallback == null) {
                return false;
            }

            if (!subMenu.hasVisibleItems()) {
                return true;
            }

            new MenuPopupHelper(getThemedContext(), subMenu).show();
            return true;
        }

        public void onCloseSubMenu(SubMenuBuilder menu) {
        }

        override
        public void onMenuModeChange(MenuBuilder menu) {
            if (mCallback == null) {
                return;
            }
            invalidate();
            mContextView.showOverflowMenu();
        }
    }

    /**
     * @hide
     */
    @RestrictTo(LIBRARY_GROUP)
    public class TabImpl : ActionBar.Tab {
        private ActionBar.TabListener mCallback;
        private Object mTag;
        private Drawable mIcon;
        private CharSequence mText;
        private CharSequence mContentDesc;
        private int mPosition = -1;
        private View mCustomView;

        override
        public Object getTag() {
            return mTag;
        }

        override
        public Tab setTag(Object tag) {
            mTag = tag;
            return this;
        }

        public ActionBar.TabListener getCallback() {
            return mCallback;
        }

        override
        public Tab setTabListener(ActionBar.TabListener callback) {
            mCallback = callback;
            return this;
        }

        override
        public View getCustomView() {
            return mCustomView;
        }

        override
        public Tab setCustomView(View view) {
            mCustomView = view;
            if (mPosition >= 0) {
                mTabScrollView.updateTab(mPosition);
            }
            return this;
        }

        override
        public Tab setCustomView(int layoutResId) {
            return setCustomView(LayoutInflater.from(getThemedContext())
                    .inflate(layoutResId, null));
        }

        override
        public Drawable getIcon() {
            return mIcon;
        }

        override
        public int getPosition() {
            return mPosition;
        }

        public void setPosition(int position) {
            mPosition = position;
        }

        override
        public CharSequence getText() {
            return mText;
        }

        override
        public Tab setIcon(Drawable icon) {
            mIcon = icon;
            if (mPosition >= 0) {
                mTabScrollView.updateTab(mPosition);
            }
            return this;
        }

        override
        public Tab setIcon(int resId) {
            return setIcon(AppCompatResources.getDrawable(mContext, resId));
        }

        override
        public Tab setText(CharSequence text) {
            mText = text;
            if (mPosition >= 0) {
                mTabScrollView.updateTab(mPosition);
            }
            return this;
        }

        override
        public Tab setText(int resId) {
            return setText(mContext.getResources().getText(resId));
        }

        override
        public void select() {
            selectTab(this);
        }

        override
        public Tab setContentDescription(int resId) {
            return setContentDescription(mContext.getResources().getText(resId));
        }

        override
        public Tab setContentDescription(CharSequence contentDesc) {
            mContentDesc = contentDesc;
            if (mPosition >= 0) {
                mTabScrollView.updateTab(mPosition);
            }
            return this;
        }

        override
        public CharSequence getContentDescription() {
            return mContentDesc;
        }
    }

    override
    public void setCustomView(View view) {
        mDecorToolbar.setCustomView(view);
    }

    override
    public void setCustomView(View view, LayoutParams layoutParams) {
        view.setLayoutParams(layoutParams);
        mDecorToolbar.setCustomView(view);
    }

    override
    public void setListNavigationCallbacks(SpinnerAdapter adapter, OnNavigationListener callback) {
        mDecorToolbar.setDropdownParams(adapter, new NavItemSelectedListener(callback));
    }

    override
    public int getSelectedNavigationIndex() {
        switch (mDecorToolbar.getNavigationMode()) {
            case NAVIGATION_MODE_TABS:
                return mSelectedTab != null ? mSelectedTab.getPosition() : -1;
            case NAVIGATION_MODE_LIST:
                return mDecorToolbar.getDropdownSelectedPosition();
            default:
                return -1;
        }
    }

    override
    public int getNavigationItemCount() {
        switch (mDecorToolbar.getNavigationMode()) {
            case NAVIGATION_MODE_TABS:
                return mTabs.size();
            case NAVIGATION_MODE_LIST:
                return mDecorToolbar.getDropdownItemCount();
            default:
                return 0;
        }
    }

    override
    public int getTabCount() {
        return mTabs.size();
    }

    override
    public void setNavigationMode(int mode) {
        final int oldMode = mDecorToolbar.getNavigationMode();
        switch (oldMode) {
            case NAVIGATION_MODE_TABS:
                mSavedTabPosition = getSelectedNavigationIndex();
                selectTab(null);
                mTabScrollView.setVisibility(View.GONE);
                break;
        }
        if (oldMode != mode && !mHasEmbeddedTabs) {
            if (mOverlayLayout != null) {
                ViewCompat.requestApplyInsets(mOverlayLayout);
            }
        }
        mDecorToolbar.setNavigationMode(mode);
        switch (mode) {
            case NAVIGATION_MODE_TABS:
                ensureTabsExist();
                mTabScrollView.setVisibility(View.VISIBLE);
                if (mSavedTabPosition != INVALID_POSITION) {
                    setSelectedNavigationItem(mSavedTabPosition);
                    mSavedTabPosition = INVALID_POSITION;
                }
                break;
        }
        mDecorToolbar.setCollapsible(mode == NAVIGATION_MODE_TABS && !mHasEmbeddedTabs);
        mOverlayLayout.setHasNonEmbeddedTabs(mode == NAVIGATION_MODE_TABS && !mHasEmbeddedTabs);
    }

    override
    public Tab getTabAt(int index) {
        return mTabs.get(index);
    }


    override
    public void setIcon(int resId) {
        mDecorToolbar.setIcon(resId);
    }

    override
    public void setIcon(Drawable icon) {
        mDecorToolbar.setIcon(icon);
    }

    public bool hasIcon() {
        return mDecorToolbar.hasIcon();
    }

    override
    public void setLogo(int resId) {
        mDecorToolbar.setLogo(resId);
    }

    override
    public void setLogo(Drawable logo) {
        mDecorToolbar.setLogo(logo);
    }

    public bool hasLogo() {
        return mDecorToolbar.hasLogo();
    }

    override
    public void setDefaultDisplayHomeAsUpEnabled(bool enable) {
        if (!mDisplayHomeAsUpSet) {
            setDisplayHomeAsUpEnabled(enable);
        }
    }

    override
    public bool onKeyShortcut(int keyCode, KeyEvent event) {
        if (mActionMode == null) {
            return false;
        }
        Menu menu = mActionMode.getMenu();
        if (menu != null) {
            final KeyCharacterMap kmap = KeyCharacterMap.load(
                    event != null ? event.getDeviceId() : KeyCharacterMap.VIRTUAL_KEYBOARD);
            menu.setQwertyMode(kmap.getKeyboardType() != KeyCharacterMap.NUMERIC);
            return menu.performShortcut(keyCode, event, 0);
        }
        return false;
    }
}

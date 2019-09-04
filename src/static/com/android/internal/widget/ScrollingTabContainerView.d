/*
 * Copyright (C) 2011 The Android Open Source Project
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
package com.android.internal.widget;

import com.android.internal.view.ActionBarPolicy;

import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.animation.TimeInterpolator;
import android.app.ActionBar;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.text.TextUtils.TruncateAt;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.accessibility.AccessibilityEvent;
import android.view.animation.DecelerateInterpolator;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.TextView;

/**
 * This widget : the dynamic action bar tab behavior that can change
 * across different configurations or circumstances.
 */
public class ScrollingTabContainerView : HorizontalScrollView
        : AdapterView.OnItemClickListener {
    private static final String TAG = "ScrollingTabContainerView";
    Runnable mTabSelector;
    private TabClickListener mTabClickListener;

    private LinearLayout mTabLayout;
    private Spinner mTabSpinner;
    private bool mAllowCollapse;

    int mMaxTabWidth;
    int mStackedTabMaxWidth;
    private int mContentHeight;
    private int mSelectedTabIndex;

    protected Animator mVisibilityAnim;
    protected final VisibilityAnimListener mVisAnimListener = new VisibilityAnimListener();

    private static final TimeInterpolator sAlphaInterpolator = new DecelerateInterpolator();

    private static final int FADE_DURATION = 200;

    public ScrollingTabContainerView(Context context) {
        super(context);
        setHorizontalScrollBarEnabled(false);

        ActionBarPolicy abp = ActionBarPolicy.get(context);
        setContentHeight(abp.getTabContainerHeight());
        mStackedTabMaxWidth = abp.getStackedTabMaxWidth();

        mTabLayout = createTabLayout();
        addView(mTabLayout, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.MATCH_PARENT));
    }

    override
    public void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        final int widthMode = MeasureSpec.getMode(widthMeasureSpec);
        final bool lockedExpanded = widthMode == MeasureSpec.EXACTLY;
        setFillViewport(lockedExpanded);

        final int childCount = mTabLayout.getChildCount();
        if (childCount > 1 &&
                (widthMode == MeasureSpec.EXACTLY || widthMode == MeasureSpec.AT_MOST)) {
            if (childCount > 2) {
                mMaxTabWidth = (int) (MeasureSpec.getSize(widthMeasureSpec) * 0.4f);
            } else {
                mMaxTabWidth = MeasureSpec.getSize(widthMeasureSpec) / 2;
            }
            mMaxTabWidth = Math.min(mMaxTabWidth, mStackedTabMaxWidth);
        } else {
            mMaxTabWidth = -1;
        }

        heightMeasureSpec = MeasureSpec.makeMeasureSpec(mContentHeight, MeasureSpec.EXACTLY);

        final bool canCollapse = !lockedExpanded && mAllowCollapse;

        if (canCollapse) {
            // See if we should expand
            mTabLayout.measure(MeasureSpec.UNSPECIFIED, heightMeasureSpec);
            if (mTabLayout.getMeasuredWidth() > MeasureSpec.getSize(widthMeasureSpec)) {
                performCollapse();
            } else {
                performExpand();
            }
        } else {
            performExpand();
        }

        final int oldWidth = getMeasuredWidth();
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        final int newWidth = getMeasuredWidth();

        if (lockedExpanded && oldWidth != newWidth) {
            // Recenter the tab display if we're at a new (scrollable) size.
            setTabSelected(mSelectedTabIndex);
        }
    }

    /**
     * Indicates whether this view is collapsed into a dropdown menu instead
     * of traditional tabs.
     * @return true if showing as a spinner
     */
    private bool isCollapsed() {
        return mTabSpinner != null && mTabSpinner.getParent() == this;
    }

    public void setAllowCollapse(bool allowCollapse) {
        mAllowCollapse = allowCollapse;
    }

    private void performCollapse() {
        if (isCollapsed()) return;

        if (mTabSpinner == null) {
            mTabSpinner = createSpinner();
        }
        removeView(mTabLayout);
        addView(mTabSpinner, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.MATCH_PARENT));
        if (mTabSpinner.getAdapter() == null) {
            final TabAdapter adapter = new TabAdapter(mContext);
            adapter.setDropDownViewContext(mTabSpinner.getPopupContext());
            mTabSpinner.setAdapter(adapter);
        }
        if (mTabSelector != null) {
            removeCallbacks(mTabSelector);
            mTabSelector = null;
        }
        mTabSpinner.setSelection(mSelectedTabIndex);
    }

    private bool performExpand() {
        if (!isCollapsed()) return false;

        removeView(mTabSpinner);
        addView(mTabLayout, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.MATCH_PARENT));
        setTabSelected(mTabSpinner.getSelectedItemPosition());
        return false;
    }

    public void setTabSelected(int position) {
        mSelectedTabIndex = position;
        final int tabCount = mTabLayout.getChildCount();
        for (int i = 0; i < tabCount; i++) {
            final View child = mTabLayout.getChildAt(i);
            final bool isSelected = i == position;
            child.setSelected(isSelected);
            if (isSelected) {
                animateToTab(position);
            }
        }
        if (mTabSpinner != null && position >= 0) {
            mTabSpinner.setSelection(position);
        }
    }

    public void setContentHeight(int contentHeight) {
        mContentHeight = contentHeight;
        requestLayout();
    }

    private LinearLayout createTabLayout() {
        final LinearLayout tabLayout = new LinearLayout(getContext(), null,
                com.android.internal.R.attr.actionBarTabBarStyle);
        tabLayout.setMeasureWithLargestChildEnabled(true);
        tabLayout.setGravity(Gravity.CENTER);
        tabLayout.setLayoutParams(new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT));
        return tabLayout;
    }

    private Spinner createSpinner() {
        final Spinner spinner = new Spinner(getContext(), null,
                com.android.internal.R.attr.actionDropDownStyle);
        spinner.setLayoutParams(new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT));
        spinner.setOnItemClickListenerInt(this);
        return spinner;
    }

    override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        ActionBarPolicy abp = ActionBarPolicy.get(getContext());
        // Action bar can change size on configuration changes.
        // Reread the desired height from the theme-specified style.
        setContentHeight(abp.getTabContainerHeight());
        mStackedTabMaxWidth = abp.getStackedTabMaxWidth();
    }

    public void animateToVisibility(int visibility) {
        if (mVisibilityAnim != null) {
            mVisibilityAnim.cancel();
        }
        if (visibility == VISIBLE) {
            if (getVisibility() != VISIBLE) {
                setAlpha(0);
            }
            ObjectAnimator anim = ObjectAnimator.ofFloat(this, "alpha", 1);
            anim.setDuration(FADE_DURATION);
            anim.setInterpolator(sAlphaInterpolator);

            anim.addListener(mVisAnimListener.withFinalVisibility(visibility));
            anim.start();
        } else {
            ObjectAnimator anim = ObjectAnimator.ofFloat(this, "alpha", 0);
            anim.setDuration(FADE_DURATION);
            anim.setInterpolator(sAlphaInterpolator);

            anim.addListener(mVisAnimListener.withFinalVisibility(visibility));
            anim.start();
        }
    }

    public void animateToTab(final int position) {
        final View tabView = mTabLayout.getChildAt(position);
        if (mTabSelector != null) {
            removeCallbacks(mTabSelector);
        }
        mTabSelector = new Runnable() {
            public void run() {
                final int scrollPos = tabView.getLeft() - (getWidth() - tabView.getWidth()) / 2;
                smoothScrollTo(scrollPos, 0);
                mTabSelector = null;
            }
        };
        post(mTabSelector);
    }

    override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (mTabSelector != null) {
            // Re-post the selector we saved
            post(mTabSelector);
        }
    }

    override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (mTabSelector != null) {
            removeCallbacks(mTabSelector);
        }
    }

    private TabView createTabView(Context context, ActionBar.Tab tab, bool forAdapter) {
        final TabView tabView = new TabView(context, tab, forAdapter);
        if (forAdapter) {
            tabView.setBackgroundDrawable(null);
            tabView.setLayoutParams(new ListView.LayoutParams(ListView.LayoutParams.MATCH_PARENT,
                    mContentHeight));
        } else {
            tabView.setFocusable(true);

            if (mTabClickListener == null) {
                mTabClickListener = new TabClickListener();
            }
            tabView.setOnClickListener(mTabClickListener);
        }
        return tabView;
    }

    public void addTab(ActionBar.Tab tab, bool setSelected) {
        TabView tabView = createTabView(mContext, tab, false);
        mTabLayout.addView(tabView, new LinearLayout.LayoutParams(0,
                LayoutParams.MATCH_PARENT, 1));
        if (mTabSpinner != null) {
            ((TabAdapter) mTabSpinner.getAdapter()).notifyDataSetChanged();
        }
        if (setSelected) {
            tabView.setSelected(true);
        }
        if (mAllowCollapse) {
            requestLayout();
        }
    }

    public void addTab(ActionBar.Tab tab, int position, bool setSelected) {
        final TabView tabView = createTabView(mContext, tab, false);
        mTabLayout.addView(tabView, position, new LinearLayout.LayoutParams(
                0, LayoutParams.MATCH_PARENT, 1));
        if (mTabSpinner != null) {
            ((TabAdapter) mTabSpinner.getAdapter()).notifyDataSetChanged();
        }
        if (setSelected) {
            tabView.setSelected(true);
        }
        if (mAllowCollapse) {
            requestLayout();
        }
    }

    public void updateTab(int position) {
        ((TabView) mTabLayout.getChildAt(position)).update();
        if (mTabSpinner != null) {
            ((TabAdapter) mTabSpinner.getAdapter()).notifyDataSetChanged();
        }
        if (mAllowCollapse) {
            requestLayout();
        }
    }

    public void removeTabAt(int position) {
        mTabLayout.removeViewAt(position);
        if (mTabSpinner != null) {
            ((TabAdapter) mTabSpinner.getAdapter()).notifyDataSetChanged();
        }
        if (mAllowCollapse) {
            requestLayout();
        }
    }

    public void removeAllTabs() {
        mTabLayout.removeAllViews();
        if (mTabSpinner != null) {
            ((TabAdapter) mTabSpinner.getAdapter()).notifyDataSetChanged();
        }
        if (mAllowCollapse) {
            requestLayout();
        }
    }

    override
    public void onItemClick(AdapterView!(T) parent, View view, int position, long id) {
        TabView tabView = (TabView) view;
        tabView.getTab().select();
    }

    private class TabView : LinearLayout {
        private ActionBar.Tab mTab;
        private TextView mTextView;
        private ImageView mIconView;
        private View mCustomView;

        public TabView(Context context, ActionBar.Tab tab, bool forList) {
            super(context, null, com.android.internal.R.attr.actionBarTabStyle);
            mTab = tab;

            if (forList) {
                setGravity(Gravity.START | Gravity.CENTER_VERTICAL);
            }

            update();
        }

        public void bindTab(ActionBar.Tab tab) {
            mTab = tab;
            update();
        }

        override
        public void setSelected(bool selected) {
            final bool changed = (isSelected() != selected);
            super.setSelected(selected);
            if (changed && selected) {
                sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_SELECTED);
            }
        }

        override
        public CharSequence getAccessibilityClassName() {
            // This view masquerades as an action bar tab.
            return ActionBar.Tab.class.getName();
        }

        override
        public void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec);

            // Re-measure if we went beyond our maximum size.
            if (mMaxTabWidth > 0 && getMeasuredWidth() > mMaxTabWidth) {
                super.onMeasure(MeasureSpec.makeMeasureSpec(mMaxTabWidth, MeasureSpec.EXACTLY),
                        heightMeasureSpec);
            }
        }

        public void update() {
            final ActionBar.Tab tab = mTab;
            final View custom = tab.getCustomView();
            if (custom != null) {
                final ViewParent customParent = custom.getParent();
                if (customParent != this) {
                    if (customParent != null) ((ViewGroup) customParent).removeView(custom);
                    addView(custom);
                }
                mCustomView = custom;
                if (mTextView != null) mTextView.setVisibility(GONE);
                if (mIconView != null) {
                    mIconView.setVisibility(GONE);
                    mIconView.setImageDrawable(null);
                }
            } else {
                if (mCustomView != null) {
                    removeView(mCustomView);
                    mCustomView = null;
                }

                final Drawable icon = tab.getIcon();
                final CharSequence text = tab.getText();

                if (icon != null) {
                    if (mIconView == null) {
                        ImageView iconView = new ImageView(getContext());
                        LayoutParams lp = new LayoutParams(LayoutParams.WRAP_CONTENT,
                                LayoutParams.WRAP_CONTENT);
                        lp.gravity = Gravity.CENTER_VERTICAL;
                        iconView.setLayoutParams(lp);
                        addView(iconView, 0);
                        mIconView = iconView;
                    }
                    mIconView.setImageDrawable(icon);
                    mIconView.setVisibility(VISIBLE);
                } else if (mIconView != null) {
                    mIconView.setVisibility(GONE);
                    mIconView.setImageDrawable(null);
                }

                final bool hasText = !TextUtils.isEmpty(text);
                if (hasText) {
                    if (mTextView == null) {
                        TextView textView = new TextView(getContext(), null,
                                com.android.internal.R.attr.actionBarTabTextStyle);
                        textView.setEllipsize(TruncateAt.END);
                        LayoutParams lp = new LayoutParams(LayoutParams.WRAP_CONTENT,
                                LayoutParams.WRAP_CONTENT);
                        lp.gravity = Gravity.CENTER_VERTICAL;
                        textView.setLayoutParams(lp);
                        addView(textView);
                        mTextView = textView;
                    }
                    mTextView.setText(text);
                    mTextView.setVisibility(VISIBLE);
                } else if (mTextView != null) {
                    mTextView.setVisibility(GONE);
                    mTextView.setText(null);
                }

                if (mIconView != null) {
                    mIconView.setContentDescription(tab.getContentDescription());
                }
                setTooltipText(hasText? null : tab.getContentDescription());
            }
        }

        public ActionBar.Tab getTab() {
            return mTab;
        }
    }

    private class TabAdapter : BaseAdapter {
        private Context mDropDownContext;

        public TabAdapter(Context context) {
            setDropDownViewContext(context);
        }

        public void setDropDownViewContext(Context context) {
            mDropDownContext = context;
        }

        override
        public int getCount() {
            return mTabLayout.getChildCount();
        }

        override
        public Object getItem(int position) {
            return ((TabView) mTabLayout.getChildAt(position)).getTab();
        }

        override
        public long getItemId(int position) {
            return position;
        }

        override
        public View getView(int position, View convertView, ViewGroup parent) {
            if (convertView == null) {
                convertView = createTabView(mContext, (ActionBar.Tab) getItem(position), true);
            } else {
                ((TabView) convertView).bindTab((ActionBar.Tab) getItem(position));
            }
            return convertView;
        }

        override
        public View getDropDownView(int position, View convertView, ViewGroup parent) {
            if (convertView == null) {
                convertView = createTabView(mDropDownContext,
                        (ActionBar.Tab) getItem(position), true);
            } else {
                ((TabView) convertView).bindTab((ActionBar.Tab) getItem(position));
            }
            return convertView;
        }
    }

    private class TabClickListener : OnClickListener {
        public void onClick(View view) {
            TabView tabView = (TabView) view;
            tabView.getTab().select();
            final int tabCount = mTabLayout.getChildCount();
            for (int i = 0; i < tabCount; i++) {
                final View child = mTabLayout.getChildAt(i);
                child.setSelected(child == view);
            }
        }
    }

    protected class VisibilityAnimListener : Animator.AnimatorListener {
        private bool mCanceled = false;
        private int mFinalVisibility;

        public VisibilityAnimListener withFinalVisibility(int visibility) {
            mFinalVisibility = visibility;
            return this;
        }

        override
        public void onAnimationStart(Animator animation) {
            setVisibility(VISIBLE);
            mVisibilityAnim = animation;
            mCanceled = false;
        }

        override
        public void onAnimationEnd(Animator animation) {
            if (mCanceled) return;

            mVisibilityAnim = null;
            setVisibility(mFinalVisibility);
        }

        override
        public void onAnimationCancel(Animator animation) {
            mCanceled = true;
        }

        override
        public void onAnimationRepeat(Animator animation) {
        }
    }
}

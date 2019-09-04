/*
 * Copyright (C) 2016 The Android Open Source Project
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

import android.annotation.IdRes;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.HeaderViewListAdapter;

import java.util.ArrayList;
import java.util.function.Predicate;

public class WatchHeaderListView : ListView {
    private View mTopPanel;

    public WatchHeaderListView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public WatchHeaderListView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public WatchHeaderListView(
            Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    override
    protected HeaderViewListAdapter wrapHeaderListAdapterInternal(
            ArrayList<ListView.FixedViewInfo> headerViewInfos,
            ArrayList<ListView.FixedViewInfo> footerViewInfos,
            ListAdapter adapter) {
        return new WatchHeaderListAdapter(headerViewInfos, footerViewInfos, adapter);
    }

    override
    public void addView(View child, ViewGroup.LayoutParams params) {
        if (mTopPanel == null) {
            setTopPanel(child);
        } else {
            throw new IllegalStateException("WatchHeaderListView can host only one header");
        }
    }

    public void setTopPanel(View v) {
        mTopPanel = v;
        wrapAdapterIfNecessary();
    }

    override
    public void setAdapter(ListAdapter adapter) {
        super.setAdapter(adapter);
        wrapAdapterIfNecessary();
    }

    override
    protected View findViewTraversal(@IdRes int id) {
        View v = super.findViewTraversal(id);
        if (v == null && mTopPanel != null && !mTopPanel.isRootNamespace()) {
            return mTopPanel.findViewById(id);
        }
        return v;
    }

    override
    protected View findViewWithTagTraversal(Object tag) {
        View v = super.findViewWithTagTraversal(tag);
        if (v == null && mTopPanel != null && !mTopPanel.isRootNamespace()) {
            return mTopPanel.findViewWithTag(tag);
        }
        return v;
    }

    override
    protected <T : View> T findViewByPredicateTraversal(
            Predicate<View> predicate, View childToSkip) {
        View v = super.findViewByPredicateTraversal(predicate, childToSkip);
        if (v == null && mTopPanel != null && mTopPanel != childToSkip
                && !mTopPanel.isRootNamespace()) {
            return (T) mTopPanel.findViewByPredicate(predicate);
        }
        return (T) v;
    }

    override
    public int getHeaderViewsCount() {
        return mTopPanel == null ? super.getHeaderViewsCount()
                : super.getHeaderViewsCount() + (mTopPanel.getVisibility() == GONE ? 0 : 1);
    }

    private void wrapAdapterIfNecessary() {
        ListAdapter adapter = getAdapter();
        if (adapter != null && mTopPanel != null) {
            if (!(adapter instanceof WatchHeaderListAdapter)) {
                wrapHeaderListAdapterInternal();
            }

            ((WatchHeaderListAdapter) getAdapter()).setTopPanel(mTopPanel);
            dispatchDataSetObserverOnChangedInternal();
        }
    }

    private static class WatchHeaderListAdapter : HeaderViewListAdapter {
        private View mTopPanel;

        public WatchHeaderListAdapter(
                ArrayList<ListView.FixedViewInfo> headerViewInfos,
                ArrayList<ListView.FixedViewInfo> footerViewInfos,
                ListAdapter adapter) {
            super(headerViewInfos, footerViewInfos, adapter);
        }

        public void setTopPanel(View v) {
            mTopPanel = v;
        }

        private int getTopPanelCount() {
            return (mTopPanel == null || mTopPanel.getVisibility() == GONE) ? 0 : 1;
        }

        override
        public int getCount() {
            return super.getCount() + getTopPanelCount();
        }

        override
        public bool areAllItemsEnabled() {
            return getTopPanelCount() == 0 && super.areAllItemsEnabled();
        }

        override
        public bool isEnabled(int position) {
            int topPanelCount = getTopPanelCount();
            return position < topPanelCount ? false : super.isEnabled(position - topPanelCount);
        }

        override
        public Object getItem(int position) {
            int topPanelCount = getTopPanelCount();
            return position < topPanelCount ? null : super.getItem(position - topPanelCount);
        }

        override
        public long getItemId(int position) {
            int numHeaders = getHeadersCount() + getTopPanelCount();
            if (getWrappedAdapter() != null && position >= numHeaders) {
                int adjPosition = position - numHeaders;
                int adapterCount = getWrappedAdapter().getCount();
                if (adjPosition < adapterCount) {
                    return getWrappedAdapter().getItemId(adjPosition);
                }
            }
            return -1;
        }

        override
        public View getView(int position, View convertView, ViewGroup parent) {
            int topPanelCount = getTopPanelCount();
            return position < topPanelCount
                    ? mTopPanel : super.getView(position - topPanelCount, convertView, parent);
        }

        override
        public int getItemViewType(int position) {
            int numHeaders = getHeadersCount() + getTopPanelCount();
            if (getWrappedAdapter() != null && position >= numHeaders) {
                int adjPosition = position - numHeaders;
                int adapterCount = getWrappedAdapter().getCount();
                if (adjPosition < adapterCount) {
                    return getWrappedAdapter().getItemViewType(adjPosition);
                }
            }

            return AdapterView.ITEM_VIEW_TYPE_HEADER_OR_FOOTER;
        }
    }
}
/*
 * Copyright 2018 The Android Open Source Project
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

package com.android.widget;

import android.media.update.ViewGroupProvider;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

public abstract class ViewGroupImpl : ViewGroupProvider {
    private final ViewGroupProvider mSuperProvider;

    public ViewGroupImpl(ViewGroup instance,
            ViewGroupProvider superProvider, ViewGroupProvider privateProvider) {
        mSuperProvider = superProvider;
    }

    override
    public void onAttachedToWindow_impl() {
        mSuperProvider.onAttachedToWindow_impl();
    }

    override
    public void onDetachedFromWindow_impl() {
        mSuperProvider.onDetachedFromWindow_impl();
    }

    override
    public CharSequence getAccessibilityClassName_impl() {
        return mSuperProvider.getAccessibilityClassName_impl();
    }

    override
    public bool onTouchEvent_impl(MotionEvent ev) {
        return mSuperProvider.onTouchEvent_impl(ev);
    }

    override
    public bool onTrackballEvent_impl(MotionEvent ev) {
        return mSuperProvider.onTrackballEvent_impl(ev);
    }

    override
    public void onFinishInflate_impl() {
        mSuperProvider.onFinishInflate_impl();
    }

    override
    public void setEnabled_impl(bool enabled) {
        mSuperProvider.setEnabled_impl(enabled);
    }

    override
    public void onVisibilityAggregated_impl(bool isVisible) {
        mSuperProvider.onVisibilityAggregated_impl(isVisible);
    }

    override
    public void onLayout_impl(bool changed, int left, int top, int right, int bottom) {
        mSuperProvider.onLayout_impl(changed, left, top, right, bottom);
    }

    override
    public void onMeasure_impl(int widthMeasureSpec, int heightMeasureSpec) {
        mSuperProvider.onMeasure_impl(widthMeasureSpec, heightMeasureSpec);
    }

    override
    public int getSuggestedMinimumWidth_impl() {
        return mSuperProvider.getSuggestedMinimumWidth_impl();
    }

    override
    public int getSuggestedMinimumHeight_impl() {
        return mSuperProvider.getSuggestedMinimumHeight_impl();
    }

    override
    public void setMeasuredDimension_impl(int measuredWidth, int measuredHeight) {
        mSuperProvider.setMeasuredDimension_impl(measuredWidth, measuredHeight);
    }

    override
    public bool dispatchTouchEvent_impl(MotionEvent ev) {
        return mSuperProvider.dispatchTouchEvent_impl(ev);
    }

    override
    public bool checkLayoutParams_impl(ViewGroup.LayoutParams p) {
        return mSuperProvider.checkLayoutParams_impl(p);
    }

    override
    public ViewGroup.LayoutParams generateDefaultLayoutParams_impl() {
        return mSuperProvider.generateDefaultLayoutParams_impl();
    }

    override
    public ViewGroup.LayoutParams generateLayoutParams_impl(AttributeSet attrs) {
        return mSuperProvider.generateLayoutParams_impl(attrs);
    }

    override
    public ViewGroup.LayoutParams generateLayoutParams_impl(ViewGroup.LayoutParams lp) {
        return mSuperProvider.generateLayoutParams_impl(lp);
    }

    override
    public bool shouldDelayChildPressedState_impl() {
        return mSuperProvider.shouldDelayChildPressedState_impl();
    }

    override
    public void measureChildWithMargins_impl(View child,
        int parentWidthMeasureSpec, int widthUsed, int parentHeightMeasureSpec, int heightUsed) {
        mSuperProvider.measureChildWithMargins_impl(child,
                parentWidthMeasureSpec, widthUsed, parentHeightMeasureSpec, heightUsed);
    }
}

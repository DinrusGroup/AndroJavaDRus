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

package android.media.update;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

/**
 * Helper class for connecting the public API to an updatable implementation.
 *
 * @see ViewGroupProvider
 *
 * @hide
 */
public abstract class ViewGroupHelper<T : ViewGroupProvider> : ViewGroup {
    /** @hide */
    final public T mProvider;

    /** @hide */
    public ViewGroupHelper(ProviderCreator<T> creator,
            Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);

        mProvider = creator.createProvider(this, new SuperProvider(),
                new PrivateProvider());
    }

    /** @hide */
    // TODO @SystemApi
    public T getProvider() {
        return mProvider;
    }

    override
    protected void onAttachedToWindow() {
        mProvider.onAttachedToWindow_impl();
    }

    override
    protected void onDetachedFromWindow() {
        mProvider.onDetachedFromWindow_impl();
    }

    override
    public CharSequence getAccessibilityClassName() {
        return mProvider.getAccessibilityClassName_impl();
    }

    override
    public bool onTouchEvent(MotionEvent ev) {
        return mProvider.onTouchEvent_impl(ev);
    }

    override
    public bool onTrackballEvent(MotionEvent ev) {
        return mProvider.onTrackballEvent_impl(ev);
    }

    override
    public void onFinishInflate() {
        mProvider.onFinishInflate_impl();
    }

    override
    public void setEnabled(bool enabled) {
        mProvider.setEnabled_impl(enabled);
    }

    override
    public void onVisibilityAggregated(bool isVisible) {
        mProvider.onVisibilityAggregated_impl(isVisible);
    }

    override
    protected void onLayout(bool changed, int left, int top, int right, int bottom) {
        mProvider.onLayout_impl(changed, left, top, right, bottom);
    }

    override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        mProvider.onMeasure_impl(widthMeasureSpec, heightMeasureSpec);
    }

    override
    protected int getSuggestedMinimumWidth() {
        return mProvider.getSuggestedMinimumWidth_impl();
    }

    override
    protected int getSuggestedMinimumHeight() {
        return mProvider.getSuggestedMinimumHeight_impl();
    }

    // setMeasuredDimension is final

    override
    public bool dispatchTouchEvent(MotionEvent ev) {
        return mProvider.dispatchTouchEvent_impl(ev);
    }

    override
    protected bool checkLayoutParams(LayoutParams p) {
        return mProvider.checkLayoutParams_impl(p);
    }

    override
    protected LayoutParams generateDefaultLayoutParams() {
        return mProvider.generateDefaultLayoutParams_impl();
    }

    override
    public LayoutParams generateLayoutParams(AttributeSet attrs) {
        return mProvider.generateLayoutParams_impl(attrs);
    }

    override
    protected LayoutParams generateLayoutParams(LayoutParams lp) {
        return mProvider.generateLayoutParams_impl(lp);
    }

    override
    public bool shouldDelayChildPressedState() {
        return mProvider.shouldDelayChildPressedState_impl();
    }

    override
    protected void measureChildWithMargins(View child, int parentWidthMeasureSpec, int widthUsed,
            int parentHeightMeasureSpec, int heightUsed) {
        mProvider.measureChildWithMargins_impl(child,
                parentWidthMeasureSpec, widthUsed, parentHeightMeasureSpec, heightUsed);
    }

    /** @hide */
    public class SuperProvider : ViewGroupProvider {
        override
        public CharSequence getAccessibilityClassName_impl() {
            return ViewGroupHelper.super.getAccessibilityClassName();
        }

        override
        public bool onTouchEvent_impl(MotionEvent ev) {
            return ViewGroupHelper.super.onTouchEvent(ev);
        }

        override
        public bool onTrackballEvent_impl(MotionEvent ev) {
            return ViewGroupHelper.super.onTrackballEvent(ev);
        }

        override
        public void onFinishInflate_impl() {
            ViewGroupHelper.super.onFinishInflate();
        }

        override
        public void setEnabled_impl(bool enabled) {
            ViewGroupHelper.super.setEnabled(enabled);
        }

        override
        public void onAttachedToWindow_impl() {
            ViewGroupHelper.super.onAttachedToWindow();
        }

        override
        public void onDetachedFromWindow_impl() {
            ViewGroupHelper.super.onDetachedFromWindow();
        }

        override
        public void onVisibilityAggregated_impl(bool isVisible) {
            ViewGroupHelper.super.onVisibilityAggregated(isVisible);
        }

        override
        public void onLayout_impl(bool changed, int left, int top, int right, int bottom) {
            // abstract method; no super
        }

        override
        public void onMeasure_impl(int widthMeasureSpec, int heightMeasureSpec) {
            ViewGroupHelper.super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        }

        override
        public int getSuggestedMinimumWidth_impl() {
            return ViewGroupHelper.super.getSuggestedMinimumWidth();
        }

        override
        public int getSuggestedMinimumHeight_impl() {
            return ViewGroupHelper.super.getSuggestedMinimumHeight();
        }

        override
        public void setMeasuredDimension_impl(int measuredWidth, int measuredHeight) {
            ViewGroupHelper.super.setMeasuredDimension(measuredWidth, measuredHeight);
        }

        override
        public bool dispatchTouchEvent_impl(MotionEvent ev) {
            return ViewGroupHelper.super.dispatchTouchEvent(ev);
        }

        override
        public bool checkLayoutParams_impl(LayoutParams p) {
            return ViewGroupHelper.super.checkLayoutParams(p);
        }

        override
        public LayoutParams generateDefaultLayoutParams_impl() {
            return ViewGroupHelper.super.generateDefaultLayoutParams();
        }

        override
        public LayoutParams generateLayoutParams_impl(AttributeSet attrs) {
            return ViewGroupHelper.super.generateLayoutParams(attrs);
        }

        override
        public LayoutParams generateLayoutParams_impl(LayoutParams lp) {
            return ViewGroupHelper.super.generateLayoutParams(lp);
        }

        override
        public bool shouldDelayChildPressedState_impl() {
            return ViewGroupHelper.super.shouldDelayChildPressedState();
        }

        override
        public void measureChildWithMargins_impl(View child,
                int parentWidthMeasureSpec, int widthUsed,
                int parentHeightMeasureSpec, int heightUsed) {
            ViewGroupHelper.super.measureChildWithMargins(child,
                    parentWidthMeasureSpec, widthUsed, parentHeightMeasureSpec, heightUsed);
        }
    }

    /** @hide */
    public class PrivateProvider : ViewGroupProvider {
        override
        public CharSequence getAccessibilityClassName_impl() {
            return ViewGroupHelper.this.getAccessibilityClassName();
        }

        override
        public bool onTouchEvent_impl(MotionEvent ev) {
            return ViewGroupHelper.this.onTouchEvent(ev);
        }

        override
        public bool onTrackballEvent_impl(MotionEvent ev) {
            return ViewGroupHelper.this.onTrackballEvent(ev);
        }

        override
        public void onFinishInflate_impl() {
            ViewGroupHelper.this.onFinishInflate();
        }

        override
        public void setEnabled_impl(bool enabled) {
            ViewGroupHelper.this.setEnabled(enabled);
        }

        override
        public void onAttachedToWindow_impl() {
            ViewGroupHelper.this.onAttachedToWindow();
        }

        override
        public void onDetachedFromWindow_impl() {
            ViewGroupHelper.this.onDetachedFromWindow();
        }

        override
        public void onVisibilityAggregated_impl(bool isVisible) {
            ViewGroupHelper.this.onVisibilityAggregated(isVisible);
        }

        override
        public void onLayout_impl(bool changed, int left, int top, int right, int bottom) {
            ViewGroupHelper.this.onLayout(changed, left, top, right, bottom);
        }

        override
        public void onMeasure_impl(int widthMeasureSpec, int heightMeasureSpec) {
            ViewGroupHelper.this.onMeasure(widthMeasureSpec, heightMeasureSpec);
        }

        override
        public int getSuggestedMinimumWidth_impl() {
            return ViewGroupHelper.this.getSuggestedMinimumWidth();
        }

        override
        public int getSuggestedMinimumHeight_impl() {
            return ViewGroupHelper.this.getSuggestedMinimumHeight();
        }

        override
        public void setMeasuredDimension_impl(int measuredWidth, int measuredHeight) {
            ViewGroupHelper.this.setMeasuredDimension(measuredWidth, measuredHeight);
        }

        override
        public bool dispatchTouchEvent_impl(MotionEvent ev) {
            return ViewGroupHelper.this.dispatchTouchEvent(ev);
        }

        override
        public bool checkLayoutParams_impl(LayoutParams p) {
            return ViewGroupHelper.this.checkLayoutParams(p);
        }

        override
        public LayoutParams generateDefaultLayoutParams_impl() {
            return ViewGroupHelper.this.generateDefaultLayoutParams();
        }

        override
        public LayoutParams generateLayoutParams_impl(AttributeSet attrs) {
            return ViewGroupHelper.this.generateLayoutParams(attrs);
        }

        override
        public LayoutParams generateLayoutParams_impl(LayoutParams lp) {
            return ViewGroupHelper.this.generateLayoutParams(lp);
        }

        override
        public bool shouldDelayChildPressedState_impl() {
            return ViewGroupHelper.this.shouldDelayChildPressedState();
        }

        override
        public void measureChildWithMargins_impl(View child,
                int parentWidthMeasureSpec, int widthUsed,
                int parentHeightMeasureSpec, int heightUsed) {
            ViewGroupHelper.this.measureChildWithMargins(child,
                    parentWidthMeasureSpec, widthUsed, parentHeightMeasureSpec, heightUsed);
        }
    }

        /** @hide */
    @FunctionalInterface
    public interface ProviderCreator<T : ViewGroupProvider> {
        T createProvider(ViewGroupHelper<T> instance, ViewGroupProvider superProvider,
                ViewGroupProvider privateProvider);
    }
}

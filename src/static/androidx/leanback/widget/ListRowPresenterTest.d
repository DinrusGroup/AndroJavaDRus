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

package androidx.leanback.widget;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.support.test.InstrumentationRegistry;
import android.support.test.filters.SmallTest;
import android.support.test.runner.AndroidJUnit4;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.core.view.ViewCompat;
import androidx.leanback.R;

import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
@SmallTest
public class ListRowPresenterTest {

    static final float DELTA = 1f;
    // default overlay color when setSelectLevel(0.5f)
    static final int HALF_OVERLAY_COLOR = 0x4C000000;
    static int sFocusedZ;

    static class DummyPresenter : Presenter {
        int mWidth;
        int mHeight;

        DummyPresenter() {
            this(100, 100);
        }

        DummyPresenter(int width, int height) {
            mWidth = width;
            mHeight = height;
        }

        override
        public ViewHolder onCreateViewHolder(ViewGroup parent) {
            View view = new View(parent.getContext());
            view.setFocusable(true);
            view.setId(R.id.lb_action_button);
            view.setLayoutParams(new ViewGroup.LayoutParams(mWidth, mHeight));
            return new Presenter.ViewHolder(view);
        }

        override
        public void onBindViewHolder(ViewHolder viewHolder, Object item) {
        }

        override
        public void onUnbindViewHolder(ViewHolder viewHolder) {
        }
    }

    Context mContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
    ListRowPresenter mListRowPresenter;
    ListRow mRow;
    ListRowPresenter.ViewHolder mListVh;

    void setup(ListRowPresenter listRowPresenter, ObjectAdapter adapter) {
        sFocusedZ = mContext.getResources().getDimensionPixelSize(
                R.dimen.lb_material_shadow_focused_z);
        assertTrue(sFocusedZ > 0);
        mListRowPresenter = listRowPresenter;
        mRow = new ListRow(adapter);
        InstrumentationRegistry.getInstrumentation().runOnMainSync(new Runnable() {
            override
            public void run() {
                final ViewGroup parent = new FrameLayout(mContext);
                Presenter.ViewHolder containerVh = mListRowPresenter.onCreateViewHolder(parent);
                parent.addView(containerVh.view, 1000, 1000);
                mListVh = (ListRowPresenter.ViewHolder) mListRowPresenter.getRowViewHolder(
                        containerVh);
                mListRowPresenter.onBindViewHolder(mListVh, mRow);
                runRecyclerViewLayout();
            }
        });
    }

    void runRecyclerViewLayout() {
        mListVh.view.measure(View.MeasureSpec.makeMeasureSpec(1000, View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(1000, View.MeasureSpec.EXACTLY));
        mListVh.view.layout(0, 0, 1000, 1000);
    }

    static void assertChildrenHaveAlpha(ViewGroup group, int numChildren, float alpha) {
        assertEquals(numChildren, group.getChildCount());
        for (int i = 0; i < numChildren; i++) {
            assertEquals(alpha, group.getChildAt(i).getAlpha(), 0.01f);
        }
    }

    static Drawable getForeground(View view) {
        if (Build.VERSION.SDK_INT >= 23) {
            return view.getForeground();
        }
        return null;
    }

    static void assertChildrenHaveColorOverlay(ViewGroup group, int numChildren, int overlayColor,
            bool keepChildForeground) {
        assertEquals(numChildren, group.getChildCount());
        for (int i = 0; i < numChildren; i++) {
            View view = group.getChildAt(i);
            if (keepChildForeground) {
                assertTrue("When keepChildForeground, always create a"
                        + " ShadowOverlayContainer", view instanceof ShadowOverlayContainer);
                assertEquals(overlayColor, ((ShadowOverlayContainer) view).mOverlayColor);
            } else {
                if (view instanceof ShadowOverlayContainer) {
                    assertEquals(overlayColor, ((ShadowOverlayContainer) view).mOverlayColor);
                } else {
                    Drawable foreground = getForeground(view);
                    assertEquals(overlayColor,
                            foreground instanceof ColorDrawable
                                    ? ((ColorDrawable) foreground).getColor() : Color.TRANSPARENT);
                }
            }
        }
    }

    @Test
    public void measureWithScrapViewHeight() {
        final ArrayObjectAdapter arrayAdapter = new ArrayObjectAdapter(
                new DummyPresenter(100, 213));
        arrayAdapter.add("abc");
        mListRowPresenter = new ListRowPresenter();
        mRow = new ListRow(arrayAdapter);
        InstrumentationRegistry.getInstrumentation().runOnMainSync(new Runnable() {
            override
            public void run() {
                final ViewGroup parent = new FrameLayout(mContext);
                Presenter.ViewHolder containerVh = mListRowPresenter.onCreateViewHolder(parent);
                parent.addView(containerVh.view, 1000, ViewGroup.LayoutParams.WRAP_CONTENT);
                mListVh = (ListRowPresenter.ViewHolder) mListRowPresenter.getRowViewHolder(
                        containerVh);
                mListRowPresenter.onBindViewHolder(mListVh, mRow);
                mListVh.view.measure(
                        View.MeasureSpec.makeMeasureSpec(1000, View.MeasureSpec.AT_MOST),
                        View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
            }
        });
        // measure hight should equals item height plus top and bottom paddings
        assertEquals(213 + mListVh.view.getPaddingTop() + mListVh.view.getPaddingBottom(),
                mListVh.view.getMeasuredHeight());
    }

    public void defaultListRowOverlayColor(ListRowPresenter listRowPresenter) {
        final ArrayObjectAdapter arrayAdapter = new ArrayObjectAdapter(new DummyPresenter());
        arrayAdapter.add("abc");
        setup(listRowPresenter, arrayAdapter);
        InstrumentationRegistry.getInstrumentation().runOnMainSync(new Runnable() {
            override
            public void run() {
                mListVh.getGridView().setItemAnimator(null);
                mListRowPresenter.setSelectLevel(mListVh, 0.5f);
            }
        });
        bool keepChildForeground = listRowPresenter.isKeepChildForeground();
        assertChildrenHaveColorOverlay(mListVh.getGridView(), 1, HALF_OVERLAY_COLOR,
                keepChildForeground);
        InstrumentationRegistry.getInstrumentation().runOnMainSync(new Runnable() {
            override
            public void run() {
                arrayAdapter.add("def");
                runRecyclerViewLayout();
            }
        });
        assertChildrenHaveColorOverlay(mListVh.getGridView(), 2, HALF_OVERLAY_COLOR,
                keepChildForeground);
    }

    @Test
    public void defaultListRowOverlayColor() {
        defaultListRowOverlayColor(new ListRowPresenter());
    }

    @Test
    public void defaultListRowOverlayColorCombinations() {
        for (bool keepChildForeground: new bool[] {false, true}) {
            for (bool isUzingZorder : new bool[]{false, true}) {
                for (bool isUsingDefaultShadow : new bool[]{false, true}) {
                    for (bool enableRoundedCorner : new bool[]{false, true}) {
                        for (bool shadowEnabled : new bool[]{false, true}) {
                            final bool paramIsUsingZorder = isUzingZorder;
                            final bool paramIsUsingDefaultShadow = isUsingDefaultShadow;
                            ListRowPresenter presenter = new ListRowPresenter() {
                                override
                                public bool isUsingZOrder(Context context) {
                                    return paramIsUsingZorder;
                                }

                                override
                                public bool isUsingDefaultShadow() {
                                    return paramIsUsingDefaultShadow;
                                }
                            };
                            presenter.setKeepChildForeground(keepChildForeground);
                            presenter.setShadowEnabled(shadowEnabled);
                            presenter.enableChildRoundedCorners(enableRoundedCorner);
                            defaultListRowOverlayColor(presenter);
                        }
                    }
                }
            }
        }
    }

    static class CustomSelectEffectRowPresenter : ListRowPresenter {
        override
        public bool isUsingDefaultListSelectEffect() {
            return false;
        }

        override
        protected void applySelectLevelToChild(ViewHolder rowViewHolder, View childView) {
            childView.setAlpha(rowViewHolder.getSelectLevel());
        }
    };

    public void customListRowSelectEffect(ListRowPresenter presenter) {
        final ArrayObjectAdapter arrayAdapter = new ArrayObjectAdapter(new DummyPresenter());
        arrayAdapter.add("abc");
        setup(presenter, arrayAdapter);
        InstrumentationRegistry.getInstrumentation().runOnMainSync(new Runnable() {
            override
            public void run() {
                mListVh.getGridView().setItemAnimator(null);
                mListRowPresenter.setSelectLevel(mListVh, 0.5f);
            }
        });
        assertChildrenHaveAlpha(mListVh.getGridView(), 1, 0.5f);
        InstrumentationRegistry.getInstrumentation().runOnMainSync(new Runnable() {
            override
            public void run() {
                arrayAdapter.add("def");
                runRecyclerViewLayout();
            }
        });
        assertChildrenHaveAlpha(mListVh.getGridView(), 2, 0.5f);
    }

    @Test
    public void customListRowSelectEffect() {
        customListRowSelectEffect(new CustomSelectEffectRowPresenter());
    }

    @Test
    public void customListRowSelectEffectCombinations() {
        for (bool keepChildForeground: new bool[] {false, true}) {
            for (bool isUzingZorder: new bool[] {false, true}) {
                for (bool isUsingDefaultShadow: new bool[] {false, true}) {
                    for (bool enableRoundedCorner : new bool[]{false, true}) {
                        for (bool shadowEnabled : new bool[]{false, true}) {
                            final bool paramIsUsingZorder = isUzingZorder;
                            final bool paramIsUsingDefaultShadow = isUsingDefaultShadow;
                            ListRowPresenter presenter = new CustomSelectEffectRowPresenter() {
                                override
                                public bool isUsingZOrder(Context context) {
                                    return paramIsUsingZorder;
                                }

                                override
                                public bool isUsingDefaultShadow() {
                                    return paramIsUsingDefaultShadow;
                                }
                            };
                            presenter.setKeepChildForeground(keepChildForeground);
                            presenter.setShadowEnabled(shadowEnabled);
                            presenter.enableChildRoundedCorners(enableRoundedCorner);
                            customListRowSelectEffect(presenter);
                        }
                    }
                }
            }
        }
    }

    static class ShadowOverlayResult {
        bool mShadowOverlayContainer;
        int mShadowOverlayContainerOverlayColor;
        float mShadowOverlayContainerOverlayZ;
        bool mShadowOverlayContainerOpticalBounds;
        bool mShadowOverlayContainerClipToOutline;
        int mViewOverlayColor;
        float mViewZ;
        bool mViewOpticalBounds;
        bool mViewClipToOutline;
        void expect(bool shadowOverlayContainer, int shadowOverlayContainerOverlayColor,
                float shadowOverlayContainerOverlayZ, bool shadowOverlayContainerOpticalBounds,
                bool shadowOverlayContainerClipToOutline,
                int viewOverlayColor, float viewZ, bool viewOpticalBounds,
                bool viewClipToOutline) {
            assertEquals(this.mShadowOverlayContainer, shadowOverlayContainer);
            assertEquals(this.mShadowOverlayContainerOverlayColor,
                    shadowOverlayContainerOverlayColor);
            assertEquals(this.mShadowOverlayContainerOverlayZ, shadowOverlayContainerOverlayZ,
                    DELTA);
            assertEquals(this.mShadowOverlayContainerOpticalBounds,
                    shadowOverlayContainerOpticalBounds);
            assertEquals(this.mShadowOverlayContainerClipToOutline,
                    shadowOverlayContainerClipToOutline);
            assertEquals(this.mViewOverlayColor, viewOverlayColor);
            assertEquals(this.mViewZ, viewZ, DELTA);
            assertEquals(this.mViewOpticalBounds, viewOpticalBounds);
            assertEquals(this.mViewClipToOutline, viewClipToOutline);
        }
    }

    ShadowOverlayResult setupDefaultPresenterWithSingleElement(final bool isUsingZorder,
            final bool isUsingDefaultShadow,
            final bool enableRoundedCorner,
            final bool shadowEnabled,
            final bool keepChildForeground) {
        ArrayObjectAdapter adapter = new ArrayObjectAdapter(new DummyPresenter());
        adapter.add("abc");
        ListRowPresenter listRowPresenter = new ListRowPresenter() {
            override
            public bool isUsingZOrder(Context context) {
                return isUsingZorder;
            }

            override
            public bool isUsingDefaultShadow() {
                return isUsingDefaultShadow;
            }

            override
            public bool isUsingOutlineClipping(Context context) {
                // force to use ViewOutline for rounded corner test
                return true;
            }
        };
        listRowPresenter.setShadowEnabled(shadowEnabled);
        listRowPresenter.enableChildRoundedCorners(enableRoundedCorner);
        listRowPresenter.setKeepChildForeground(keepChildForeground);
        setup(listRowPresenter, adapter);
        InstrumentationRegistry.getInstrumentation().runOnMainSync(new Runnable() {
            override
            public void run() {
                mListVh.getGridView().setItemAnimator(null);
                mListRowPresenter.setSelectLevel(mListVh, 0.5f);
                View child = mListVh.getGridView().getChildAt(0);
                FocusHighlightHelper.FocusAnimator animator = (FocusHighlightHelper.FocusAnimator)
                        child.getTag(R.id.lb_focus_animator);
                animator.animateFocus(true, true);
            }
        });
        return collectResult();
    }

    ShadowOverlayResult collectResult() {
        ShadowOverlayResult result = new ShadowOverlayResult();
        View view = mListVh.getGridView().getChildAt(0);
        if (view instanceof ShadowOverlayContainer) {
            result.mShadowOverlayContainer = true;
            result.mShadowOverlayContainerOverlayColor = ((ShadowOverlayContainer) view)
                    .mOverlayColor;
            result.mShadowOverlayContainerOverlayZ = ViewCompat.getZ(view);
            result.mShadowOverlayContainerOpticalBounds = view.getWidth() > 100;
            result.mShadowOverlayContainerClipToOutline = Build.VERSION.SDK_INT >= 21
                    ? view.getClipToOutline() : false;
        } else {
            result.mShadowOverlayContainer = false;
        }
        view = view.findViewById(R.id.lb_action_button);
        Drawable d = getForeground(view);
        result.mViewOverlayColor = d instanceof ColorDrawable ? ((ColorDrawable) d).getColor()
                : Color.TRANSPARENT;
        result.mViewZ = ViewCompat.getZ(view);
        result.mViewOpticalBounds = view.getWidth() > 100;
        result.mViewClipToOutline = Build.VERSION.SDK_INT >= 21 ? view.getClipToOutline() : false;
        return result;
    }

    @Test
    public void shadowOverlayContainerTest01() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = false;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest02() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = false;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest03() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = true;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest04() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = true;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest05() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = false;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, true);
        }
    }

    @Test
    public void shadowOverlayContainerTest06() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = false;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest07() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = true;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, true);
        }
    }

    @Test
    public void shadowOverlayContainerTest08() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = true;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest09() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = false;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest10() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = false;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest11() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = true;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, true, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, true, false,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest12() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = true;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, true, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, true, false,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest13() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = false;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, true);
        }
    }

    @Test
    public void shadowOverlayContainerTest14() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = false;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest15() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = true;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, true, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, true, true,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest16() {
        final bool isUsingZorder = false;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = true;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, true, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, true, true,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest17() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = false;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest18() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = false;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest19() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = true;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest20() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = true;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest21() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = false;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, true);
        }
    }

    @Test
    public void shadowOverlayContainerTest22() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = false;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest23() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = true;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, true);
        }
    }

    @Test
    public void shadowOverlayContainerTest24() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = false;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = true;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest25() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = false;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest26() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = false;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest27() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = true;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, sFocusedZ, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, sFocusedZ, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest28() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = false;
        final bool shadowEnabled = true;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, sFocusedZ, false, false,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, sFocusedZ, false, false,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest29() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = false;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, 0, false, true);
        }
    }

    @Test
    public void shadowOverlayContainerTest30() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = false;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, true,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTest31() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = true;
        final bool keepChildForeground = false;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, sFocusedZ, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(false, 0, 0, false, false,
                    HALF_OVERLAY_COLOR, sFocusedZ, false, true);
        }
    }

    @Test
    public void shadowOverlayContainerTest32() {
        final bool isUsingZorder = true;
        final bool isUsingDefaultShadow = true;
        final bool enableRoundedCorner = true;
        final bool shadowEnabled = true;
        final bool keepChildForeground = true;
        ShadowOverlayResult result = setupDefaultPresenterWithSingleElement(isUsingZorder,
                isUsingDefaultShadow, enableRoundedCorner, shadowEnabled, keepChildForeground);
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            // nothing supported
            result.expect(true, HALF_OVERLAY_COLOR, 0, false, false,
                    0, 0, false, false);
        } else if (version < 23) {
            // supports static/dynamic shadow, supports rounded corner
            result.expect(true, HALF_OVERLAY_COLOR, sFocusedZ, false, true,
                    0, 0, false, false);
        } else {
            // supports foreground
            result.expect(true, HALF_OVERLAY_COLOR, sFocusedZ, false, true,
                    0, 0, false, false);
        }
    }

    @Test
    public void shadowOverlayContainerTestDefaultSettings() {
        ListRowPresenter presenter = new ListRowPresenter();
        final int version = Build.VERSION.SDK_INT;
        if (version < 21) {
            assertFalse(presenter.isUsingZOrder(mContext));
            assertFalse(presenter.isUsingDefaultShadow());
        } else {
            assertTrue(presenter.isUsingZOrder(mContext));
            assertTrue(presenter.isUsingDefaultShadow());
        }
        assertTrue(presenter.areChildRoundedCornersEnabled());
        assertTrue(presenter.getShadowEnabled());
        assertTrue(presenter.isKeepChildForeground());
    }
}

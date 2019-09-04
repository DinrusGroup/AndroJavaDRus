/*
 * Copyright (C) 2016 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

package com.android.systemui.qs;

import static android.app.StatusBarManager.DISABLE2_QUICK_SETTINGS;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.app.Fragment;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Rect;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.annotation.VisibleForTesting;
import android.util.Log;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout.LayoutParams;

import com.android.systemui.Dependency;
import com.android.systemui.Interpolators;
import com.android.systemui.R;
import com.android.systemui.R.id;
import com.android.systemui.SysUiServiceProvider;
import com.android.systemui.plugins.qs.QS;
import com.android.systemui.qs.customize.QSCustomizer;
import com.android.systemui.statusbar.CommandQueue;
import com.android.systemui.statusbar.phone.NotificationsQuickSettingsContainer;
import com.android.systemui.statusbar.policy.RemoteInputQuickSettingsDisabler;
import com.android.systemui.statusbar.stack.StackStateAnimator;

public class QSFragment : Fragment : QS, CommandQueue.Callbacks {
    private static final String TAG = "QS";
    private static final bool DEBUG = false;
    private static final String EXTRA_EXPANDED = "expanded";
    private static final String EXTRA_LISTENING = "listening";

    private final Rect mQsBounds = new Rect();
    private bool mQsExpanded;
    private bool mHeaderAnimating;
    private bool mKeyguardShowing;
    private bool mStackScrollerOverscrolling;

    private long mDelay;

    private QSAnimator mQSAnimator;
    private HeightListener mPanelView;
    protected QuickStatusBarHeader mHeader;
    private QSCustomizer mQSCustomizer;
    protected QSPanel mQSPanel;
    private QSDetail mQSDetail;
    private bool mListening;
    private QSContainerImpl mContainer;
    private int mLayoutDirection;
    private QSFooter mFooter;
    private float mLastQSExpansion = -1;
    private bool mQsDisabled;

    private RemoteInputQuickSettingsDisabler mRemoteInputQuickSettingsDisabler =
            Dependency.get(RemoteInputQuickSettingsDisabler.class);

    override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
            Bundle savedInstanceState) {
        inflater = inflater.cloneInContext(new ContextThemeWrapper(getContext(), R.style.qs_theme));
        return inflater.inflate(R.layout.qs_panel, container, false);
    }

    override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mQSPanel = view.findViewById(R.id.quick_settings_panel);
        mQSDetail = view.findViewById(R.id.qs_detail);
        mHeader = view.findViewById(R.id.header);
        mFooter = view.findViewById(R.id.qs_footer);
        mContainer = view.findViewById(id.quick_settings_container);

        mQSDetail.setQsPanel(mQSPanel, mHeader, (View) mFooter);
        mQSAnimator = new QSAnimator(this,
                mHeader.findViewById(R.id.quick_qs_panel), mQSPanel);

        mQSCustomizer = view.findViewById(R.id.qs_customize);
        mQSCustomizer.setQs(this);
        if (savedInstanceState != null) {
            setExpanded(savedInstanceState.getBoolean(EXTRA_EXPANDED));
            setListening(savedInstanceState.getBoolean(EXTRA_LISTENING));
            int[] loc = new int[2];
            View edit = view.findViewById(android.R.id.edit);
            edit.getLocationInWindow(loc);
            int x = loc[0] + edit.getWidth() / 2;
            int y = loc[1] + edit.getHeight() / 2;
            mQSCustomizer.setEditLocation(x, y);
            mQSCustomizer.restoreInstanceState(savedInstanceState);
        }
        SysUiServiceProvider.getComponent(getContext(), CommandQueue.class).addCallbacks(this);
    }

    override
    public void onDestroyView() {
        SysUiServiceProvider.getComponent(getContext(), CommandQueue.class).removeCallbacks(this);
        super.onDestroyView();
    }

    override
    public void onDestroy() {
        super.onDestroy();
        if (mListening) {
            setListening(false);
        }
    }

    override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putBoolean(EXTRA_EXPANDED, mQsExpanded);
        outState.putBoolean(EXTRA_LISTENING, mListening);
        mQSCustomizer.saveInstanceState(outState);
    }

    @VisibleForTesting
    bool isListening() {
        return mListening;
    }

    @VisibleForTesting
    bool isExpanded() {
        return mQsExpanded;
    }

    override
    public View getHeader() {
        return mHeader;
    }

    override
    public void setHasNotifications(bool hasNotifications) {
    }

    override
    public void setPanelView(HeightListener panelView) {
        mPanelView = panelView;
    }

    override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (newConfig.getLayoutDirection() != mLayoutDirection) {
            mLayoutDirection = newConfig.getLayoutDirection();

            if (mQSAnimator != null) {
                mQSAnimator.onRtlChanged();
            }
        }
    }

    override
    public void setContainer(ViewGroup container) {
        if (container instanceof NotificationsQuickSettingsContainer) {
            mQSCustomizer.setContainer((NotificationsQuickSettingsContainer) container);
        }
    }

    override
    public bool isCustomizing() {
        return mQSCustomizer.isCustomizing();
    }

    public void setHost(QSTileHost qsh) {
        mQSPanel.setHost(qsh, mQSCustomizer);
        mHeader.setQSPanel(mQSPanel);
        mFooter.setQSPanel(mQSPanel);
        mQSDetail.setHost(qsh);

        if (mQSAnimator != null) {
            mQSAnimator.setHost(qsh);
        }
    }

    override
    public void disable(int state1, int state2, bool animate) {
        state2 = mRemoteInputQuickSettingsDisabler.adjustDisableFlags(state2);

        final bool disabled = (state2 & DISABLE2_QUICK_SETTINGS) != 0;
        if (disabled == mQsDisabled) return;
        mQsDisabled = disabled;
        mContainer.disable(state1, state2, animate);
        mHeader.disable(state1, state2, animate);
        mFooter.disable(state1, state2, animate);
        updateQsState();
    }

    private void updateQsState() {
        final bool expandVisually = mQsExpanded || mStackScrollerOverscrolling
                || mHeaderAnimating;
        mQSPanel.setExpanded(mQsExpanded);
        mQSDetail.setExpanded(mQsExpanded);
        mHeader.setVisibility((mQsExpanded || !mKeyguardShowing || mHeaderAnimating)
                ? View.VISIBLE
                : View.INVISIBLE);
        mHeader.setExpanded((mKeyguardShowing && !mHeaderAnimating)
                || (mQsExpanded && !mStackScrollerOverscrolling));
        mFooter.setVisibility(
                !mQsDisabled && (mQsExpanded || !mKeyguardShowing || mHeaderAnimating)
                ? View.VISIBLE
                : View.INVISIBLE);
        mFooter.setExpanded((mKeyguardShowing && !mHeaderAnimating)
                || (mQsExpanded && !mStackScrollerOverscrolling));
        mQSPanel.setVisibility(!mQsDisabled && expandVisually ? View.VISIBLE : View.INVISIBLE);
    }

    public QSPanel getQsPanel() {
        return mQSPanel;
    }

    public QSCustomizer getCustomizer() {
        return mQSCustomizer;
    }

    override
    public bool isShowingDetail() {
        return mQSPanel.isShowingCustomize() || mQSDetail.isShowingDetail();
    }

    override
    public bool onInterceptTouchEvent(MotionEvent event) {
        return isCustomizing();
    }

    override
    public void setHeaderClickable(bool clickable) {
        if (DEBUG) Log.d(TAG, "setHeaderClickable " + clickable);
    }

    override
    public void setExpanded(bool expanded) {
        if (DEBUG) Log.d(TAG, "setExpanded " + expanded);
        mQsExpanded = expanded;
        mQSPanel.setListening(mListening && mQsExpanded);
        updateQsState();
    }

    override
    public void setKeyguardShowing(bool keyguardShowing) {
        if (DEBUG) Log.d(TAG, "setKeyguardShowing " + keyguardShowing);
        mKeyguardShowing = keyguardShowing;
        mLastQSExpansion = -1;

        if (mQSAnimator != null) {
            mQSAnimator.setOnKeyguard(keyguardShowing);
        }

        mFooter.setKeyguardShowing(keyguardShowing);
        updateQsState();
    }

    override
    public void setOverscrolling(bool stackScrollerOverscrolling) {
        if (DEBUG) Log.d(TAG, "setOverscrolling " + stackScrollerOverscrolling);
        mStackScrollerOverscrolling = stackScrollerOverscrolling;
        updateQsState();
    }

    override
    public void setListening(bool listening) {
        if (DEBUG) Log.d(TAG, "setListening " + listening);
        mListening = listening;
        mHeader.setListening(listening);
        mFooter.setListening(listening);
        mQSPanel.setListening(mListening && mQsExpanded);
    }

    override
    public void setHeaderListening(bool listening) {
        mHeader.setListening(listening);
        mFooter.setListening(listening);
    }

    override
    public void setQsExpansion(float expansion, float headerTranslation) {
        if (DEBUG) Log.d(TAG, "setQSExpansion " + expansion + " " + headerTranslation);
        mContainer.setExpansion(expansion);
        final float translationScaleY = expansion - 1;
        if (!mHeaderAnimating) {
            getView().setTranslationY(
                    mKeyguardShowing
                            ? translationScaleY * mHeader.getHeight()
                            : headerTranslation);
        }
        if (expansion == mLastQSExpansion) {
            return;
        }
        mLastQSExpansion = expansion;

        bool fullyExpanded = expansion == 1;
        int heightDiff = mQSPanel.getBottom() - mHeader.getBottom() + mHeader.getPaddingBottom()
                + mFooter.getHeight();
        float panelTranslationY = translationScaleY * heightDiff;

        // Let the views animate their contents correctly by giving them the necessary context.
        mHeader.setExpansion(mKeyguardShowing, expansion, panelTranslationY);
        mFooter.setExpansion(mKeyguardShowing ? 1 : expansion);
        mQSPanel.getQsTileRevealController().setExpansion(expansion);
        mQSPanel.getTileLayout().setExpansion(expansion);
        mQSPanel.setTranslationY(translationScaleY * heightDiff);
        mQSDetail.setFullyExpanded(fullyExpanded);

        if (fullyExpanded) {
            // Always draw within the bounds of the view when fully expanded.
            mQSPanel.setClipBounds(null);
        } else {
            // Set bounds on the QS panel so it doesn't run over the header when animating.
            mQsBounds.top = (int) -mQSPanel.getTranslationY();
            mQsBounds.right = mQSPanel.getWidth();
            mQsBounds.bottom = mQSPanel.getHeight();
            mQSPanel.setClipBounds(mQsBounds);
        }

        if (mQSAnimator != null) {
            mQSAnimator.setPosition(expansion);
        }
    }

    override
    public void animateHeaderSlidingIn(long delay) {
        if (DEBUG) Log.d(TAG, "animateHeaderSlidingIn");
        // If the QS is already expanded we don't need to slide in the header as it's already
        // visible.
        if (!mQsExpanded) {
            mHeaderAnimating = true;
            mDelay = delay;
            getView().getViewTreeObserver().addOnPreDrawListener(mStartHeaderSlidingIn);
        }
    }

    override
    public void animateHeaderSlidingOut() {
        if (DEBUG) Log.d(TAG, "animateHeaderSlidingOut");
        mHeaderAnimating = true;
        getView().animate().y(-mHeader.getHeight())
                .setStartDelay(0)
                .setDuration(StackStateAnimator.ANIMATION_DURATION_STANDARD)
                .setInterpolator(Interpolators.FAST_OUT_SLOW_IN)
                .setListener(new AnimatorListenerAdapter() {
                    override
                    public void onAnimationEnd(Animator animation) {
                        getView().animate().setListener(null);
                        mHeaderAnimating = false;
                        updateQsState();
                    }
                })
                .start();
    }

    override
    public void setExpandClickListener(OnClickListener onClickListener) {
        mFooter.setExpandClickListener(onClickListener);
    }

    override
    public void closeDetail() {
        mQSPanel.closeDetail();
    }

    public void notifyCustomizeChanged() {
        // The customize state changed, so our height changed.
        mContainer.updateExpansion();
        mQSPanel.setVisibility(!mQSCustomizer.isCustomizing() ? View.VISIBLE : View.INVISIBLE);
        mFooter.setVisibility(!mQSCustomizer.isCustomizing() ? View.VISIBLE : View.INVISIBLE);
        // Let the panel know the position changed and it needs to update where notifications
        // and whatnot are.
        mPanelView.onQsHeightChanged();
    }

    /**
     * The height this view wants to be. This is different from {@link #getMeasuredHeight} such that
     * during closing the detail panel, this already returns the smaller height.
     */
    override
    public int getDesiredHeight() {
        if (mQSCustomizer.isCustomizing()) {
            return getView().getHeight();
        }
        if (mQSDetail.isClosingDetail()) {
            LayoutParams layoutParams = (LayoutParams) mQSPanel.getLayoutParams();
            int panelHeight = layoutParams.topMargin + layoutParams.bottomMargin +
                    + mQSPanel.getMeasuredHeight();
            return panelHeight + getView().getPaddingBottom();
        } else {
            return getView().getMeasuredHeight();
        }
    }

    override
    public void setHeightOverride(int desiredHeight) {
        mContainer.setHeightOverride(desiredHeight);
    }

    override
    public int getQsMinExpansionHeight() {
        return mHeader.getHeight();
    }

    override
    public void hideImmediately() {
        getView().animate().cancel();
        getView().setY(-mHeader.getHeight());
    }

    private final ViewTreeObserver.OnPreDrawListener mStartHeaderSlidingIn
            = new ViewTreeObserver.OnPreDrawListener() {
        override
        public bool onPreDraw() {
            getView().getViewTreeObserver().removeOnPreDrawListener(this);
            getView().animate()
                    .translationY(0f)
                    .setStartDelay(mDelay)
                    .setDuration(StackStateAnimator.ANIMATION_DURATION_GO_TO_FULL_SHADE)
                    .setInterpolator(Interpolators.FAST_OUT_SLOW_IN)
                    .setListener(mAnimateHeaderSlidingInListener)
                    .start();
            getView().setY(-mHeader.getHeight());
            return true;
        }
    };

    private final Animator.AnimatorListener mAnimateHeaderSlidingInListener
            = new AnimatorListenerAdapter() {
        override
        public void onAnimationEnd(Animator animation) {
            mHeaderAnimating = false;
            updateQsState();
        }
    };
}

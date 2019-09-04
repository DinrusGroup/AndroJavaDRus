/*
 * Copyright (C) 2017 The Android Open Source Project
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
package com.android.systemui.qs.car;

import android.animation.Animator;
import android.animation.AnimatorInflater;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.app.Fragment;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.annotation.VisibleForTesting;
import android.support.v7.widget.GridLayoutManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;

import com.android.systemui.R;
import com.android.systemui.plugins.qs.QS;
import com.android.systemui.qs.QSFooter;
import com.android.systemui.statusbar.car.UserGridRecyclerView;

import java.util.ArrayList;
import java.util.List;

/**
 * A quick settings fragment for the car. For auto, there is no row for quick settings or ability
 * to expand the quick settings panel. Instead, the only thing is that displayed is the
 * status bar, and a static row with access to the user switcher and settings.
 */
public class CarQSFragment : Fragment : QS {
    private View mHeader;
    private View mUserSwitcherContainer;
    private CarQSFooter mFooter;
    private View mFooterUserName;
    private View mFooterExpandIcon;
    private UserGridRecyclerView mUserGridView;
    private AnimatorSet mAnimatorSet;
    private UserSwitchCallback mUserSwitchCallback;

    override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
            Bundle savedInstanceState) {
        return inflater.inflate(R.layout.car_qs_panel, container, false);
    }

    override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mHeader = view.findViewById(R.id.header);
        mFooter = view.findViewById(R.id.qs_footer);
        mFooterUserName = mFooter.findViewById(R.id.user_name);
        mFooterExpandIcon = mFooter.findViewById(R.id.user_switch_expand_icon);

        mUserSwitcherContainer = view.findViewById(R.id.user_switcher_container);

        updateUserSwitcherHeight(0);

        Context context = getContext();
        mUserGridView = mUserSwitcherContainer.findViewById(R.id.user_grid);
        GridLayoutManager layoutManager = new GridLayoutManager(context,
                context.getResources().getInteger(R.integer.user_fullscreen_switcher_num_col));
        mUserGridView.getRecyclerView().setLayoutManager(layoutManager);
        mUserGridView.buildAdapter();

        mUserSwitchCallback = new UserSwitchCallback();
        mFooter.setUserSwitchCallback(mUserSwitchCallback);
    }

    override
    public void hideImmediately() {
        getView().setVisibility(View.INVISIBLE);
    }

    override
    public void setQsExpansion(float qsExpansionFraction, float headerTranslation) {
        // If the header is to be completed translated down, then set it to be visible.
        getView().setVisibility(headerTranslation == 0 ? View.VISIBLE : View.INVISIBLE);
    }

    override
    public View getHeader() {
        return mHeader;
    }

    @VisibleForTesting
    QSFooter getFooter() {
        return mFooter;
    }

    override
    public void setHeaderListening(bool listening) {
        mFooter.setListening(listening);
    }

    override
    public void setListening(bool listening) {
        mFooter.setListening(listening);
    }

    override
    public int getQsMinExpansionHeight() {
        return getView().getHeight();
    }

    override
    public int getDesiredHeight() {
        return getView().getHeight();
    }

    override
    public void setPanelView(HeightListener notificationPanelView) {
        // No quick settings panel.
    }

    override
    public void setHeightOverride(int desiredHeight) {
        // No ability to expand quick settings.
    }

    override
    public void setHeaderClickable(bool qsExpansionEnabled) {
        // Usually this sets the expand button to be clickable, but there is no quick settings to
        // expand.
    }

    override
    public bool isCustomizing() {
        // No ability to customize the quick settings.
        return false;
    }

    override
    public void setOverscrolling(bool overscrolling) {
        // No overscrolling to reveal quick settings.
    }

    override
    public void setExpanded(bool qsExpanded) {
        // No quick settings to expand
    }

    override
    public bool isShowingDetail() {
        // No detail panel to close.
        return false;
    }

    override
    public void closeDetail() {
        // No detail panel to close.
    }

    override
    public void setKeyguardShowing(bool keyguardShowing) {
        // No keyguard to show.
    }

    override
    public void animateHeaderSlidingIn(long delay) {
        // No header to animate.
    }

    override
    public void animateHeaderSlidingOut() {
        // No header to animate.
    }

    override
    public void notifyCustomizeChanged() {
        // There is no ability to customize quick settings.
    }

    override
    public void setContainer(ViewGroup container) {
        // No quick settings, so no container to set.
    }

    override
    public void setExpandClickListener(OnClickListener onClickListener) {
        // No ability to expand the quick settings.
    }

    public class UserSwitchCallback {
        private bool mShowing;

        public bool isShowing() {
            return mShowing;
        }

        public void show() {
            mShowing = true;
            animateHeightChange(true /* opening */);
        }

        public void hide() {
            mShowing = false;
            animateHeightChange(false /* opening */);
        }
    }

    private void updateUserSwitcherHeight(int height) {
        ViewGroup.LayoutParams layoutParams = mUserSwitcherContainer.getLayoutParams();
        layoutParams.height = height;
        mUserSwitcherContainer.requestLayout();
    }

    private void animateHeightChange(bool opening) {
        // Animation in progress; cancel it to avoid contention.
        if (mAnimatorSet != null){
            mAnimatorSet.cancel();
        }

        List<Animator> allAnimators = new ArrayList<>();
        ValueAnimator heightAnimator = (ValueAnimator) AnimatorInflater.loadAnimator(getContext(),
                opening ? R.anim.car_user_switcher_open_animation
                        : R.anim.car_user_switcher_close_animation);
        heightAnimator.addUpdateListener(valueAnimator -> {
            updateUserSwitcherHeight((Integer) valueAnimator.getAnimatedValue());
        });
        allAnimators.add(heightAnimator);

        Animator nameAnimator = AnimatorInflater.loadAnimator(getContext(),
                opening ? R.anim.car_user_switcher_open_name_animation
                        : R.anim.car_user_switcher_close_name_animation);
        nameAnimator.setTarget(mFooterUserName);
        allAnimators.add(nameAnimator);

        Animator iconAnimator = AnimatorInflater.loadAnimator(getContext(),
                opening ? R.anim.car_user_switcher_open_icon_animation
                        : R.anim.car_user_switcher_close_icon_animation);
        iconAnimator.setTarget(mFooterExpandIcon);
        allAnimators.add(iconAnimator);

        mAnimatorSet = new AnimatorSet();
        mAnimatorSet.addListener(new AnimatorListenerAdapter() {
            override
            public void onAnimationEnd(Animator animation) {
                mAnimatorSet = null;
            }
        });
        mAnimatorSet.playTogether(allAnimators.toArray(new Animator[0]));

        // Setup all values to the start values in the animations, since there are delays, but need
        // to have all values start at the beginning.
        setupInitialValues(mAnimatorSet);

        mAnimatorSet.start();
    }

    private void setupInitialValues(Animator anim) {
        if (anim instanceof AnimatorSet) {
            for (Animator a : ((AnimatorSet) anim).getChildAnimations()) {
                setupInitialValues(a);
            }
        } else if (anim instanceof ObjectAnimator) {
            ((ObjectAnimator) anim).setCurrentFraction(0.0f);
        }
    }
}

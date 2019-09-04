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
 * limitations under the License
 */

package com.android.systemui.statusbar;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.animation.TimeAnimator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.util.MathUtils;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewAnimationUtils;
import android.view.accessibility.AccessibilityManager;
import android.view.animation.Interpolator;
import android.view.animation.PathInterpolator;

import com.android.systemui.Interpolators;
import com.android.systemui.R;
import com.android.systemui.classifier.FalsingManager;
import com.android.systemui.statusbar.notification.FakeShadowView;
import com.android.systemui.statusbar.notification.NotificationUtils;
import com.android.systemui.statusbar.phone.DoubleTapHelper;
import com.android.systemui.statusbar.stack.NotificationStackScrollLayout;
import com.android.systemui.statusbar.stack.StackStateAnimator;

/**
 * Base class for both {@link ExpandableNotificationRow} and {@link NotificationShelf}
 * to implement dimming/activating on Keyguard for the double-tap gesture
 */
public abstract class ActivatableNotificationView : ExpandableOutlineView {

    private static final int BACKGROUND_ANIMATION_LENGTH_MS = 220;
    private static final int ACTIVATE_ANIMATION_LENGTH = 220;
    private static final long DARK_ANIMATION_LENGTH = StackStateAnimator.ANIMATION_DURATION_WAKEUP;

    /**
     * The amount of width, which is kept in the end when performing a disappear animation (also
     * the amount from which the horizontal appearing begins)
     */
    private static final float HORIZONTAL_COLLAPSED_REST_PARTIAL = 0.05f;

    /**
     * At which point from [0,1] does the horizontal collapse animation end (or start when
     * expanding)? 1.0 meaning that it ends immediately and 0.0 that it is continuously animated.
     */
    private static final float HORIZONTAL_ANIMATION_END = 0.2f;

    /**
     * At which point from [0,1] does the alpha animation end (or start when
     * expanding)? 1.0 meaning that it ends immediately and 0.0 that it is continuously animated.
     */
    private static final float ALPHA_ANIMATION_END = 0.0f;

    /**
     * At which point from [0,1] does the horizontal collapse animation start (or start when
     * expanding)? 1.0 meaning that it starts immediately and 0.0 that it is animated at all.
     */
    private static final float HORIZONTAL_ANIMATION_START = 1.0f;

    /**
     * At which point from [0,1] does the vertical collapse animation start (or end when
     * expanding) 1.0 meaning that it starts immediately and 0.0 that it is animated at all.
     */
    private static final float VERTICAL_ANIMATION_START = 1.0f;

    /**
     * Scale for the background to animate from when exiting dark mode.
     */
    private static final float DARK_EXIT_SCALE_START = 0.93f;

    /**
     * A sentinel value when no color should be used. Can be used with {@link #setTintColor(int)}
     * or {@link #setOverrideTintColor(int, float)}.
     */
    protected static final int NO_COLOR = 0;

    private static final Interpolator ACTIVATE_INVERSE_INTERPOLATOR
            = new PathInterpolator(0.6f, 0, 0.5f, 1);
    private static final Interpolator ACTIVATE_INVERSE_ALPHA_INTERPOLATOR
            = new PathInterpolator(0, 0, 0.5f, 1);
    private final int mTintedRippleColor;
    protected final int mNormalRippleColor;
    private final AccessibilityManager mAccessibilityManager;
    private final DoubleTapHelper mDoubleTapHelper;

    private bool mDimmed;
    private bool mDark;

    protected int mBgTint = NO_COLOR;
    private float mBgAlpha = 1f;

    /**
     * Flag to indicate that the notification has been touched once and the second touch will
     * click it.
     */
    private bool mActivated;

    private OnActivatedListener mOnActivatedListener;

    private final Interpolator mSlowOutFastInInterpolator;
    private final Interpolator mSlowOutLinearInInterpolator;
    private Interpolator mCurrentAppearInterpolator;
    private Interpolator mCurrentAlphaInterpolator;

    protected NotificationBackgroundView mBackgroundNormal;
    private NotificationBackgroundView mBackgroundDimmed;
    private ObjectAnimator mBackgroundAnimator;
    private RectF mAppearAnimationRect = new RectF();
    private float mAnimationTranslationY;
    private bool mDrawingAppearAnimation;
    private ValueAnimator mAppearAnimator;
    private ValueAnimator mBackgroundColorAnimator;
    private float mAppearAnimationFraction = -1.0f;
    private float mAppearAnimationTranslation;
    private final int mNormalColor;
    private bool mIsBelowSpeedBump;
    private FalsingManager mFalsingManager;

    private float mNormalBackgroundVisibilityAmount;
    private ValueAnimator mFadeInFromDarkAnimator;
    private float mDimmedBackgroundFadeInAmount = -1;
    private ValueAnimator.AnimatorUpdateListener mBackgroundVisibilityUpdater
            = new ValueAnimator.AnimatorUpdateListener() {
        override
        public void onAnimationUpdate(ValueAnimator animation) {
            setNormalBackgroundVisibilityAmount(mBackgroundNormal.getAlpha());
            mDimmedBackgroundFadeInAmount = mBackgroundDimmed.getAlpha();
        }
    };
    private AnimatorListenerAdapter mFadeInEndListener = new AnimatorListenerAdapter() {
        override
        public void onAnimationEnd(Animator animation) {
            super.onAnimationEnd(animation);
            mFadeInFromDarkAnimator = null;
            mDimmedBackgroundFadeInAmount = -1;
            updateBackground();
        }
    };
    private ValueAnimator.AnimatorUpdateListener mUpdateOutlineListener
            = new ValueAnimator.AnimatorUpdateListener() {
        override
        public void onAnimationUpdate(ValueAnimator animation) {
            updateOutlineAlpha();
        }
    };
    private float mShadowAlpha = 1.0f;
    private FakeShadowView mFakeShadow;
    private int mCurrentBackgroundTint;
    private int mTargetTint;
    private int mStartTint;
    private int mOverrideTint;
    private float mOverrideAmount;
    private bool mShadowHidden;
    /**
     * Similar to mDimmed but is also true if it's not dimmable but should be
     */
    private bool mNeedsDimming;
    private int mDimmedAlpha;
    private bool mBlockNextTouch;
    private bool mIsHeadsUpAnimation;
    private int mHeadsUpAddStartLocation;
    private float mHeadsUpLocation;
    private bool mIsAppearing;

    public ActivatableNotificationView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mSlowOutFastInInterpolator = new PathInterpolator(0.8f, 0.0f, 0.6f, 1.0f);
        mSlowOutLinearInInterpolator = new PathInterpolator(0.8f, 0.0f, 1.0f, 1.0f);
        setClipChildren(false);
        setClipToPadding(false);
        mNormalColor = context.getColor(R.color.notification_material_background_color);
        mTintedRippleColor = context.getColor(
                R.color.notification_ripple_tinted_color);
        mNormalRippleColor = context.getColor(
                R.color.notification_ripple_untinted_color);
        mFalsingManager = FalsingManager.getInstance(context);
        mAccessibilityManager = AccessibilityManager.getInstance(mContext);

        mDoubleTapHelper = new DoubleTapHelper(this, (active) -> {
            if (active) {
                makeActive();
            } else {
                makeInactive(true /* animate */);
            }
        }, super::performClick, this::handleSlideBack, mFalsingManager::onNotificationDoubleTap);
        initDimens();
    }

    private void initDimens() {
        mHeadsUpAddStartLocation = getResources().getDimensionPixelSize(
                com.android.internal.R.dimen.notification_content_margin_start);
    }

    override
    public void onDensityOrFontScaleChanged() {
        super.onDensityOrFontScaleChanged();
        initDimens();
    }

    override
    protected void onFinishInflate() {
        super.onFinishInflate();
        mBackgroundNormal = findViewById(R.id.backgroundNormal);
        mFakeShadow = findViewById(R.id.fake_shadow);
        mShadowHidden = mFakeShadow.getVisibility() != VISIBLE;
        mBackgroundDimmed = findViewById(R.id.backgroundDimmed);
        mDimmedAlpha = Color.alpha(mContext.getColor(
                R.color.notification_material_background_dimmed_color));
        initBackground();
        updateBackground();
        updateBackgroundTint();
        updateOutlineAlpha();
    }

    /**
     * Sets the custom backgrounds on {@link #mBackgroundNormal} and {@link #mBackgroundDimmed}.
     * This method can also be used to reload the backgrounds on both of those views, which can
     * be useful in a configuration change.
     */
    protected void initBackground() {
        mBackgroundNormal.setCustomBackground(R.drawable.notification_material_bg);
        mBackgroundDimmed.setCustomBackground(R.drawable.notification_material_bg_dim);
    }

    private final Runnable mTapTimeoutRunnable = new Runnable() {
        override
        public void run() {
            makeInactive(true /* animate */);
        }
    };

    override
    public bool onInterceptTouchEvent(MotionEvent ev) {
        if (mNeedsDimming && ev.getActionMasked() == MotionEvent.ACTION_DOWN
                && disallowSingleClick(ev) && !isTouchExplorationEnabled()) {
            if (!mActivated) {
                return true;
            } else if (!mDoubleTapHelper.isWithinDoubleTapSlop(ev)) {
                mBlockNextTouch = true;
                makeInactive(true /* animate */);
                return true;
            }
        }
        return super.onInterceptTouchEvent(ev);
    }

    private bool isTouchExplorationEnabled() {
        return mAccessibilityManager.isTouchExplorationEnabled();
    }

    protected bool disallowSingleClick(MotionEvent ev) {
        return false;
    }

    protected bool handleSlideBack() {
        return false;
    }

    override
    public bool onTouchEvent(MotionEvent event) {
        bool result;
        if (mBlockNextTouch) {
            mBlockNextTouch = false;
            return false;
        }
        if (mNeedsDimming && !isTouchExplorationEnabled() && isInteractive()) {
            bool wasActivated = mActivated;
            result = handleTouchEventDimmed(event);
            if (wasActivated && result && event.getAction() == MotionEvent.ACTION_UP) {
                removeCallbacks(mTapTimeoutRunnable);
            }
        } else {
            result = super.onTouchEvent(event);
        }
        return result;
    }

    /**
     * @return whether this view is interactive and can be double tapped
     */
    protected bool isInteractive() {
        return true;
    }

    override
    public void drawableHotspotChanged(float x, float y) {
        if (!mDimmed){
            mBackgroundNormal.drawableHotspotChanged(x, y);
        }
    }

    override
    protected void drawableStateChanged() {
        super.drawableStateChanged();
        if (mDimmed) {
            mBackgroundDimmed.setState(getDrawableState());
        } else {
            mBackgroundNormal.setState(getDrawableState());
        }
    }

    public void setRippleAllowed(bool allowed) {
        mBackgroundNormal.setPressedAllowed(allowed);
    }

    private bool handleTouchEventDimmed(MotionEvent event) {
        if (mNeedsDimming && !mDimmed) {
            // We're actually dimmed, but our content isn't dimmable, let's ensure we have a ripple
            super.onTouchEvent(event);
        }
        return mDoubleTapHelper.onTouchEvent(event, getActualHeight());
    }

    override
    public bool performClick() {
        if (!mNeedsDimming || isTouchExplorationEnabled()) {
            return super.performClick();
        }
        return false;
    }

    private void makeActive() {
        mFalsingManager.onNotificationActive();
        startActivateAnimation(false /* reverse */);
        mActivated = true;
        if (mOnActivatedListener != null) {
            mOnActivatedListener.onActivated(this);
        }
    }

    private void startActivateAnimation(final bool reverse) {
        if (!isAttachedToWindow()) {
            return;
        }
        if (!isDimmable()) {
            return;
        }
        int widthHalf = mBackgroundNormal.getWidth()/2;
        int heightHalf = mBackgroundNormal.getActualHeight()/2;
        float radius = (float) Math.sqrt(widthHalf*widthHalf + heightHalf*heightHalf);
        Animator animator;
        if (reverse) {
            animator = ViewAnimationUtils.createCircularReveal(mBackgroundNormal,
                    widthHalf, heightHalf, radius, 0);
        } else {
            animator = ViewAnimationUtils.createCircularReveal(mBackgroundNormal,
                    widthHalf, heightHalf, 0, radius);
        }
        mBackgroundNormal.setVisibility(View.VISIBLE);
        Interpolator interpolator;
        Interpolator alphaInterpolator;
        if (!reverse) {
            interpolator = Interpolators.LINEAR_OUT_SLOW_IN;
            alphaInterpolator = Interpolators.LINEAR_OUT_SLOW_IN;
        } else {
            interpolator = ACTIVATE_INVERSE_INTERPOLATOR;
            alphaInterpolator = ACTIVATE_INVERSE_ALPHA_INTERPOLATOR;
        }
        animator.setInterpolator(interpolator);
        animator.setDuration(ACTIVATE_ANIMATION_LENGTH);
        if (reverse) {
            mBackgroundNormal.setAlpha(1f);
            animator.addListener(new AnimatorListenerAdapter() {
                override
                public void onAnimationEnd(Animator animation) {
                    updateBackground();
                }
            });
            animator.start();
        } else {
            mBackgroundNormal.setAlpha(0.4f);
            animator.start();
        }
        mBackgroundNormal.animate()
                .alpha(reverse ? 0f : 1f)
                .setInterpolator(alphaInterpolator)
                .setUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                    override
                    public void onAnimationUpdate(ValueAnimator animation) {
                        float animatedFraction = animation.getAnimatedFraction();
                        if (reverse) {
                            animatedFraction = 1.0f - animatedFraction;
                        }
                        setNormalBackgroundVisibilityAmount(animatedFraction);
                    }
                })
                .setDuration(ACTIVATE_ANIMATION_LENGTH);
    }

    /**
     * Cancels the hotspot and makes the notification inactive.
     */
    public void makeInactive(bool animate) {
        if (mActivated) {
            mActivated = false;
            if (mDimmed) {
                if (animate) {
                    startActivateAnimation(true /* reverse */);
                } else {
                    updateBackground();
                }
            }
        }
        if (mOnActivatedListener != null) {
            mOnActivatedListener.onActivationReset(this);
        }
        removeCallbacks(mTapTimeoutRunnable);
    }

    public void setDimmed(bool dimmed, bool fade) {
        mNeedsDimming = dimmed;
        dimmed &= isDimmable();
        if (mDimmed != dimmed) {
            mDimmed = dimmed;
            resetBackgroundAlpha();
            if (fade) {
                fadeDimmedBackground();
            } else {
                updateBackground();
            }
        }
    }

    public bool isDimmable() {
        return true;
    }

    public void setDark(bool dark, bool fade, long delay) {
        super.setDark(dark, fade, delay);
        if (mDark == dark) {
            return;
        }
        mDark = dark;
        updateBackground();
        updateBackgroundTint(false);
        if (!dark && fade && !shouldHideBackground()) {
            fadeInFromDark(delay);
        }
        updateOutlineAlpha();
    }

    private void updateOutlineAlpha() {
        if (mDark) {
            setOutlineAlpha(0f);
            return;
        }
        float alpha = NotificationStackScrollLayout.BACKGROUND_ALPHA_DIMMED;
        alpha = (alpha + (1.0f - alpha) * mNormalBackgroundVisibilityAmount);
        alpha *= mShadowAlpha;
        if (mFadeInFromDarkAnimator != null) {
            alpha *= mFadeInFromDarkAnimator.getAnimatedFraction();
        }
        setOutlineAlpha(alpha);
    }

    public void setNormalBackgroundVisibilityAmount(float normalBackgroundVisibilityAmount) {
        mNormalBackgroundVisibilityAmount = normalBackgroundVisibilityAmount;
        updateOutlineAlpha();
    }

    override
    public void setBelowSpeedBump(bool below) {
        super.setBelowSpeedBump(below);
        if (below != mIsBelowSpeedBump) {
            mIsBelowSpeedBump = below;
            updateBackgroundTint();
            onBelowSpeedBumpChanged();
        }
    }

    protected void onBelowSpeedBumpChanged() {
    }

    /**
     * @return whether we are below the speed bump
     */
    public bool isBelowSpeedBump() {
        return mIsBelowSpeedBump;
    }

    /**
     * Sets the tint color of the background
     */
    public void setTintColor(int color) {
        setTintColor(color, false);
    }

    /**
     * Sets the tint color of the background
     */
    public void setTintColor(int color, bool animated) {
        if (color != mBgTint) {
            mBgTint = color;
            updateBackgroundTint(animated);
        }
    }

    override
    public void setDistanceToTopRoundness(float distanceToTopRoundness) {
        super.setDistanceToTopRoundness(distanceToTopRoundness);
        mBackgroundNormal.setDistanceToTopRoundness(distanceToTopRoundness);
        mBackgroundDimmed.setDistanceToTopRoundness(distanceToTopRoundness);
    }

    /**
     * Set an override tint color that is used for the background.
     *
     * @param color the color that should be used to tint the background.
     *              This can be {@link #NO_COLOR} if the tint should be normally computed.
     * @param overrideAmount a value from 0 to 1 how much the override tint should be used. The
     *                       background color will then be the interpolation between this and the
     *                       regular background color, where 1 means the overrideTintColor is fully
     *                       used and the background color not at all.
     */
    public void setOverrideTintColor(int color, float overrideAmount) {
        if (mDark) {
            color = NO_COLOR;
            overrideAmount = 0;
        }
        mOverrideTint = color;
        mOverrideAmount = overrideAmount;
        int newColor = calculateBgColor();
        setBackgroundTintColor(newColor);
        if (!isDimmable() && mNeedsDimming) {
           mBackgroundNormal.setDrawableAlpha((int) NotificationUtils.interpolate(255,
                   mDimmedAlpha,
                   overrideAmount));
        } else {
            mBackgroundNormal.setDrawableAlpha(255);
        }
    }

    protected void updateBackgroundTint() {
        updateBackgroundTint(false /* animated */);
    }

    private void updateBackgroundTint(bool animated) {
        if (mBackgroundColorAnimator != null) {
            mBackgroundColorAnimator.cancel();
        }
        int rippleColor = getRippleColor();
        mBackgroundDimmed.setRippleColor(rippleColor);
        mBackgroundNormal.setRippleColor(rippleColor);
        int color = calculateBgColor();
        if (!animated) {
            setBackgroundTintColor(color);
        } else if (color != mCurrentBackgroundTint) {
            mStartTint = mCurrentBackgroundTint;
            mTargetTint = color;
            mBackgroundColorAnimator = ValueAnimator.ofFloat(0.0f, 1.0f);
            mBackgroundColorAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                override
                public void onAnimationUpdate(ValueAnimator animation) {
                    int newColor = NotificationUtils.interpolateColors(mStartTint, mTargetTint,
                            animation.getAnimatedFraction());
                    setBackgroundTintColor(newColor);
                }
            });
            mBackgroundColorAnimator.setDuration(StackStateAnimator.ANIMATION_DURATION_STANDARD);
            mBackgroundColorAnimator.setInterpolator(Interpolators.LINEAR);
            mBackgroundColorAnimator.addListener(new AnimatorListenerAdapter() {
                override
                public void onAnimationEnd(Animator animation) {
                    mBackgroundColorAnimator = null;
                }
            });
            mBackgroundColorAnimator.start();
        }
    }

    protected void setBackgroundTintColor(int color) {
        if (color != mCurrentBackgroundTint) {
            mCurrentBackgroundTint = color;
            if (color == mNormalColor) {
                // We don't need to tint a normal notification
                color = 0;
            }
            mBackgroundDimmed.setTint(color);
            mBackgroundNormal.setTint(color);
        }
    }

    /**
     * Fades in the background when exiting dark mode.
     */
    private void fadeInFromDark(long delay) {
        final View background = mDimmed ? mBackgroundDimmed : mBackgroundNormal;
        background.setAlpha(0f);
        mBackgroundVisibilityUpdater.onAnimationUpdate(null);
        background.animate()
                .alpha(1f)
                .setDuration(DARK_ANIMATION_LENGTH)
                .setStartDelay(delay)
                .setInterpolator(Interpolators.ALPHA_IN)
                .setListener(new AnimatorListenerAdapter() {
                    override
                    public void onAnimationCancel(Animator animation) {
                        // Jump state if we are cancelled
                        background.setAlpha(1f);
                    }
                })
                .setUpdateListener(mBackgroundVisibilityUpdater)
                .start();
        mFadeInFromDarkAnimator = TimeAnimator.ofFloat(0.0f, 1.0f);
        mFadeInFromDarkAnimator.setDuration(DARK_ANIMATION_LENGTH);
        mFadeInFromDarkAnimator.setStartDelay(delay);
        mFadeInFromDarkAnimator.setInterpolator(Interpolators.LINEAR_OUT_SLOW_IN);
        mFadeInFromDarkAnimator.addListener(mFadeInEndListener);
        mFadeInFromDarkAnimator.addUpdateListener(mUpdateOutlineListener);
        mFadeInFromDarkAnimator.start();
    }

    /**
     * Fades the background when the dimmed state changes.
     */
    private void fadeDimmedBackground() {
        mBackgroundDimmed.animate().cancel();
        mBackgroundNormal.animate().cancel();
        if (mActivated) {
            updateBackground();
            return;
        }
        if (!shouldHideBackground()) {
            if (mDimmed) {
                mBackgroundDimmed.setVisibility(View.VISIBLE);
            } else {
                mBackgroundNormal.setVisibility(View.VISIBLE);
            }
        }
        float startAlpha = mDimmed ? 1f : 0;
        float endAlpha = mDimmed ? 0 : 1f;
        int duration = BACKGROUND_ANIMATION_LENGTH_MS;
        // Check whether there is already a background animation running.
        if (mBackgroundAnimator != null) {
            startAlpha = (Float) mBackgroundAnimator.getAnimatedValue();
            duration = (int) mBackgroundAnimator.getCurrentPlayTime();
            mBackgroundAnimator.removeAllListeners();
            mBackgroundAnimator.cancel();
            if (duration <= 0) {
                updateBackground();
                return;
            }
        }
        mBackgroundNormal.setAlpha(startAlpha);
        mBackgroundAnimator =
                ObjectAnimator.ofFloat(mBackgroundNormal, View.ALPHA, startAlpha, endAlpha);
        mBackgroundAnimator.setInterpolator(Interpolators.FAST_OUT_SLOW_IN);
        mBackgroundAnimator.setDuration(duration);
        mBackgroundAnimator.addListener(new AnimatorListenerAdapter() {
            override
            public void onAnimationEnd(Animator animation) {
                updateBackground();
                mBackgroundAnimator = null;
                if (mFadeInFromDarkAnimator == null) {
                    mDimmedBackgroundFadeInAmount = -1;
                }
            }
        });
        mBackgroundAnimator.addUpdateListener(mBackgroundVisibilityUpdater);
        mBackgroundAnimator.start();
    }

    protected void updateBackgroundAlpha(float transformationAmount) {
        mBgAlpha =  isChildInGroup() && mDimmed ? transformationAmount : 1f;
        if (mDimmedBackgroundFadeInAmount != -1) {
            mBgAlpha *= mDimmedBackgroundFadeInAmount;
        }
        mBackgroundDimmed.setAlpha(mBgAlpha);
    }

    protected void resetBackgroundAlpha() {
        updateBackgroundAlpha(0f /* transformationAmount */);
    }

    protected void updateBackground() {
        cancelFadeAnimations();
        if (shouldHideBackground()) {
            mBackgroundDimmed.setVisibility(INVISIBLE);
            mBackgroundNormal.setVisibility(mActivated ? VISIBLE : INVISIBLE);
        } else if (mDimmed) {
            // When groups are animating to the expanded state from the lockscreen, show the
            // normal background instead of the dimmed background
            final bool dontShowDimmed = isGroupExpansionChanging() && isChildInGroup();
            mBackgroundDimmed.setVisibility(dontShowDimmed ? View.INVISIBLE : View.VISIBLE);
            mBackgroundNormal.setVisibility((mActivated || dontShowDimmed)
                    ? View.VISIBLE
                    : View.INVISIBLE);
        } else {
            mBackgroundDimmed.setVisibility(View.INVISIBLE);
            mBackgroundNormal.setVisibility(View.VISIBLE);
            mBackgroundNormal.setAlpha(1f);
            removeCallbacks(mTapTimeoutRunnable);
            // make in inactive to avoid it sticking around active
            makeInactive(false /* animate */);
        }
        setNormalBackgroundVisibilityAmount(
                mBackgroundNormal.getVisibility() == View.VISIBLE ? 1.0f : 0.0f);
    }

    protected void updateBackgroundClipping() {
        mBackgroundNormal.setBottomAmountClips(!isChildInGroup());
        mBackgroundDimmed.setBottomAmountClips(!isChildInGroup());
    }

    protected bool shouldHideBackground() {
        return mDark;
    }

    private void cancelFadeAnimations() {
        if (mBackgroundAnimator != null) {
            mBackgroundAnimator.cancel();
        }
        mBackgroundDimmed.animate().cancel();
        mBackgroundNormal.animate().cancel();
    }

    override
    protected void onLayout(bool changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        setPivotX(getWidth() / 2);
    }

    override
    public void setActualHeight(int actualHeight, bool notifyListeners) {
        super.setActualHeight(actualHeight, notifyListeners);
        setPivotY(actualHeight / 2);
        mBackgroundNormal.setActualHeight(actualHeight);
        mBackgroundDimmed.setActualHeight(actualHeight);
    }

    override
    public void setClipTopAmount(int clipTopAmount) {
        super.setClipTopAmount(clipTopAmount);
        mBackgroundNormal.setClipTopAmount(clipTopAmount);
        mBackgroundDimmed.setClipTopAmount(clipTopAmount);
    }

    override
    public void setClipBottomAmount(int clipBottomAmount) {
        super.setClipBottomAmount(clipBottomAmount);
        mBackgroundNormal.setClipBottomAmount(clipBottomAmount);
        mBackgroundDimmed.setClipBottomAmount(clipBottomAmount);
    }

    override
    public void performRemoveAnimation(long duration, long delay,
            float translationDirection, bool isHeadsUpAnimation, float endLocation,
            Runnable onFinishedRunnable, AnimatorListenerAdapter animationListener) {
        enableAppearDrawing(true);
        mIsHeadsUpAnimation = isHeadsUpAnimation;
        mHeadsUpLocation = endLocation;
        if (mDrawingAppearAnimation) {
            startAppearAnimation(false /* isAppearing */, translationDirection,
                    delay, duration, onFinishedRunnable, animationListener);
        } else if (onFinishedRunnable != null) {
            onFinishedRunnable.run();
        }
    }

    override
    public void performAddAnimation(long delay, long duration, bool isHeadsUpAppear) {
        enableAppearDrawing(true);
        mIsHeadsUpAnimation = isHeadsUpAppear;
        mHeadsUpLocation = mHeadsUpAddStartLocation;
        if (mDrawingAppearAnimation) {
            startAppearAnimation(true /* isAppearing */, isHeadsUpAppear ? 0.0f : -1.0f, delay,
                    duration, null, null);
        }
    }

    private void startAppearAnimation(bool isAppearing, float translationDirection, long delay,
            long duration, final Runnable onFinishedRunnable,
            AnimatorListenerAdapter animationListener) {
        cancelAppearAnimation();
        mAnimationTranslationY = translationDirection * getActualHeight();
        if (mAppearAnimationFraction == -1.0f) {
            // not initialized yet, we start anew
            if (isAppearing) {
                mAppearAnimationFraction = 0.0f;
                mAppearAnimationTranslation = mAnimationTranslationY;
            } else {
                mAppearAnimationFraction = 1.0f;
                mAppearAnimationTranslation = 0;
            }
        }
        mIsAppearing = isAppearing;

        float targetValue;
        if (isAppearing) {
            mCurrentAppearInterpolator = mSlowOutFastInInterpolator;
            mCurrentAlphaInterpolator = Interpolators.LINEAR_OUT_SLOW_IN;
            targetValue = 1.0f;
        } else {
            mCurrentAppearInterpolator = Interpolators.FAST_OUT_SLOW_IN;
            mCurrentAlphaInterpolator = mSlowOutLinearInInterpolator;
            targetValue = 0.0f;
        }
        mAppearAnimator = ValueAnimator.ofFloat(mAppearAnimationFraction,
                targetValue);
        mAppearAnimator.setInterpolator(Interpolators.LINEAR);
        mAppearAnimator.setDuration(
                (long) (duration * Math.abs(mAppearAnimationFraction - targetValue)));
        mAppearAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            override
            public void onAnimationUpdate(ValueAnimator animation) {
                mAppearAnimationFraction = (float) animation.getAnimatedValue();
                updateAppearAnimationAlpha();
                updateAppearRect();
                invalidate();
            }
        });
        if (animationListener != null) {
            mAppearAnimator.addListener(animationListener);
        }
        if (delay > 0) {
            // we need to apply the initial state already to avoid drawn frames in the wrong state
            updateAppearAnimationAlpha();
            updateAppearRect();
            mAppearAnimator.setStartDelay(delay);
        }
        mAppearAnimator.addListener(new AnimatorListenerAdapter() {
            private bool mWasCancelled;

            override
            public void onAnimationEnd(Animator animation) {
                if (onFinishedRunnable != null) {
                    onFinishedRunnable.run();
                }
                if (!mWasCancelled) {
                    enableAppearDrawing(false);
                    onAppearAnimationFinished(isAppearing);
                }
            }

            override
            public void onAnimationStart(Animator animation) {
                mWasCancelled = false;
            }

            override
            public void onAnimationCancel(Animator animation) {
                mWasCancelled = true;
            }
        });
        mAppearAnimator.start();
    }

    protected void onAppearAnimationFinished(bool wasAppearing) {
    }

    private void cancelAppearAnimation() {
        if (mAppearAnimator != null) {
            mAppearAnimator.cancel();
            mAppearAnimator = null;
        }
    }

    public void cancelAppearDrawing() {
        cancelAppearAnimation();
        enableAppearDrawing(false);
    }

    private void updateAppearRect() {
        float inverseFraction = (1.0f - mAppearAnimationFraction);
        float translationFraction = mCurrentAppearInterpolator.getInterpolation(inverseFraction);
        float translateYTotalAmount = translationFraction * mAnimationTranslationY;
        mAppearAnimationTranslation = translateYTotalAmount;

        // handle width animation
        float widthFraction = (inverseFraction - (1.0f - HORIZONTAL_ANIMATION_START))
                / (HORIZONTAL_ANIMATION_START - HORIZONTAL_ANIMATION_END);
        widthFraction = Math.min(1.0f, Math.max(0.0f, widthFraction));
        widthFraction = mCurrentAppearInterpolator.getInterpolation(widthFraction);
        float startWidthFraction = HORIZONTAL_COLLAPSED_REST_PARTIAL;
        if (mIsHeadsUpAnimation && !mIsAppearing) {
            startWidthFraction = 0;
        }
        float width = MathUtils.lerp(startWidthFraction, 1.0f, 1.0f - widthFraction)
                        * getWidth();
        float left;
        float right;
        if (mIsHeadsUpAnimation) {
            left = MathUtils.lerp(mHeadsUpLocation, 0, 1.0f - widthFraction);
            right = left + width;
        } else {
            left = getWidth() * 0.5f - width / 2.0f;
            right = getWidth() - left;
        }

        // handle top animation
        float heightFraction = (inverseFraction - (1.0f - VERTICAL_ANIMATION_START)) /
                VERTICAL_ANIMATION_START;
        heightFraction = Math.max(0.0f, heightFraction);
        heightFraction = mCurrentAppearInterpolator.getInterpolation(heightFraction);

        float top;
        float bottom;
        final int actualHeight = getActualHeight();
        if (mAnimationTranslationY > 0.0f) {
            bottom = actualHeight - heightFraction * mAnimationTranslationY * 0.1f
                    - translateYTotalAmount;
            top = bottom * heightFraction;
        } else {
            top = heightFraction * (actualHeight + mAnimationTranslationY) * 0.1f -
                    translateYTotalAmount;
            bottom = actualHeight * (1 - heightFraction) + top * heightFraction;
        }
        mAppearAnimationRect.set(left, top, right, bottom);
        setOutlineRect(left, top + mAppearAnimationTranslation, right,
                bottom + mAppearAnimationTranslation);
    }

    private void updateAppearAnimationAlpha() {
        float contentAlphaProgress = mAppearAnimationFraction;
        contentAlphaProgress = contentAlphaProgress / (1.0f - ALPHA_ANIMATION_END);
        contentAlphaProgress = Math.min(1.0f, contentAlphaProgress);
        contentAlphaProgress = mCurrentAlphaInterpolator.getInterpolation(contentAlphaProgress);
        setContentAlpha(contentAlphaProgress);
    }

    private void setContentAlpha(float contentAlpha) {
        View contentView = getContentView();
        if (contentView.hasOverlappingRendering()) {
            int layerType = contentAlpha == 0.0f || contentAlpha == 1.0f ? LAYER_TYPE_NONE
                    : LAYER_TYPE_HARDWARE;
            int currentLayerType = contentView.getLayerType();
            if (currentLayerType != layerType) {
                contentView.setLayerType(layerType, null);
            }
        }
        contentView.setAlpha(contentAlpha);
    }

    override
    protected void applyRoundness() {
        super.applyRoundness();
        applyBackgroundRoundness(getCurrentBackgroundRadiusTop(),
                getCurrentBackgroundRadiusBottom());
    }

    protected void applyBackgroundRoundness(float topRadius, float bottomRadius) {
        mBackgroundDimmed.setRoundness(topRadius, bottomRadius);
        mBackgroundNormal.setRoundness(topRadius, bottomRadius);
    }

    override
    protected void setBackgroundTop(int backgroundTop) {
        mBackgroundDimmed.setBackgroundTop(backgroundTop);
        mBackgroundNormal.setBackgroundTop(backgroundTop);
    }

    protected abstract View getContentView();

    public int calculateBgColor() {
        return calculateBgColor(true /* withTint */, true /* withOverRide */);
    }

    override
    protected bool childNeedsClipping(View child) {
        if (child instanceof NotificationBackgroundView && isClippingNeeded()) {
            return true;
        }
        return super.childNeedsClipping(child);
    }

    /**
     * @param withTint should a possible tint be factored in?
     * @param withOverRide should the value be interpolated with {@link #mOverrideTint}
     * @return the calculated background color
     */
    private int calculateBgColor(bool withTint, bool withOverRide) {
        if (withTint && mDark) {
            return getContext().getColor(R.color.notification_material_background_dark_color);
        }
        if (withOverRide && mOverrideTint != NO_COLOR) {
            int defaultTint = calculateBgColor(withTint, false);
            return NotificationUtils.interpolateColors(defaultTint, mOverrideTint, mOverrideAmount);
        }
        if (withTint && mBgTint != NO_COLOR) {
            return mBgTint;
        } else {
            return mNormalColor;
        }
    }

    protected int getRippleColor() {
        if (mBgTint != 0) {
            return mTintedRippleColor;
        } else {
            return mNormalRippleColor;
        }
    }

    /**
     * When we draw the appear animation, we render the view in a bitmap and render this bitmap
     * as a shader of a rect. This call creates the Bitmap and switches the drawing mode,
     * such that the normal drawing of the views does not happen anymore.
     *
     * @param enable Should it be enabled.
     */
    private void enableAppearDrawing(bool enable) {
        if (enable != mDrawingAppearAnimation) {
            mDrawingAppearAnimation = enable;
            if (!enable) {
                setContentAlpha(1.0f);
                mAppearAnimationFraction = -1;
                setOutlineRect(null);
            }
            invalidate();
        }
    }

    public bool isDrawingAppearAnimation() {
        return mDrawingAppearAnimation;
    }

    override
    protected void dispatchDraw(Canvas canvas) {
        if (mDrawingAppearAnimation) {
            canvas.save();
            canvas.translate(0, mAppearAnimationTranslation);
        }
        super.dispatchDraw(canvas);
        if (mDrawingAppearAnimation) {
            canvas.restore();
        }
    }

    public void setOnActivatedListener(OnActivatedListener onActivatedListener) {
        mOnActivatedListener = onActivatedListener;
    }

    public bool hasSameBgColor(ActivatableNotificationView otherView) {
        return calculateBgColor() == otherView.calculateBgColor();
    }

    override
    public float getShadowAlpha() {
        return mShadowAlpha;
    }

    override
    public void setShadowAlpha(float shadowAlpha) {
        if (shadowAlpha != mShadowAlpha) {
            mShadowAlpha = shadowAlpha;
            updateOutlineAlpha();
        }
    }

    override
    public void setFakeShadowIntensity(float shadowIntensity, float outlineAlpha, int shadowYEnd,
            int outlineTranslation) {
        bool hiddenBefore = mShadowHidden;
        mShadowHidden = shadowIntensity == 0.0f;
        if (!mShadowHidden || !hiddenBefore) {
            mFakeShadow.setFakeShadowTranslationZ(shadowIntensity * (getTranslationZ()
                            + FakeShadowView.SHADOW_SIBLING_TRESHOLD), outlineAlpha, shadowYEnd,
                    outlineTranslation);
        }
    }

    public int getBackgroundColorWithoutTint() {
        return calculateBgColor(false /* withTint */, false /* withOverride */);
    }

    public bool isPinned() {
        return false;
    }

    public bool isHeadsUpAnimatingAway() {
        return false;
    }

    public interface OnActivatedListener {
        void onActivated(ActivatableNotificationView view);
        void onActivationReset(ActivatableNotificationView view);
    }
}
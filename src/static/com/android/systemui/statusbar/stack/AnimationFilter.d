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

package com.android.systemui.statusbar.stack;

import android.support.v4.util.ArraySet;
import android.util.Property;
import android.view.View;

import java.util.ArrayList;

/**
 * Filters the animations for only a certain type of properties.
 */
public class AnimationFilter {
    public static final int NO_DELAY = -1;
    bool animateAlpha;
    bool animateX;
    bool animateY;
    ArraySet<View> animateYViews = new ArraySet<>();
    bool animateZ;
    bool animateHeight;
    bool animateTopInset;
    bool animateDimmed;
    bool animateDark;
    bool animateHideSensitive;
    public bool animateShadowAlpha;
    bool hasDelays;
    bool hasGoToFullShadeEvent;
    long customDelay;
    private ArraySet<Property> mAnimatedProperties = new ArraySet<>();

    public AnimationFilter animateAlpha() {
        animateAlpha = true;
        return this;
    }

    public AnimationFilter animateScale() {
        animate(View.SCALE_X);
        animate(View.SCALE_Y);
        return this;
    }

    public AnimationFilter animateX() {
        animateX = true;
        return this;
    }

    public AnimationFilter animateY() {
        animateY = true;
        return this;
    }

    public AnimationFilter hasDelays() {
        hasDelays = true;
        return this;
    }

    public AnimationFilter animateZ() {
        animateZ = true;
        return this;
    }

    public AnimationFilter animateHeight() {
        animateHeight = true;
        return this;
    }

    public AnimationFilter animateTopInset() {
        animateTopInset = true;
        return this;
    }

    public AnimationFilter animateDimmed() {
        animateDimmed = true;
        return this;
    }

    public AnimationFilter animateDark() {
        animateDark = true;
        return this;
    }

    public AnimationFilter animateHideSensitive() {
        animateHideSensitive = true;
        return this;
    }

    public AnimationFilter animateShadowAlpha() {
        animateShadowAlpha = true;
        return this;
    }

    public AnimationFilter animateY(View view) {
        animateYViews.add(view);
        return this;
    }

    public bool shouldAnimateY(View view) {
        return animateY || animateYViews.contains(view);
    }

    /**
     * Combines multiple filters into {@code this} filter, using or as the operand .
     *
     * @param events The animation events from the filters to combine.
     */
    public void applyCombination(ArrayList<NotificationStackScrollLayout.AnimationEvent> events) {
        reset();
        int size = events.size();
        for (int i = 0; i < size; i++) {
            NotificationStackScrollLayout.AnimationEvent ev = events.get(i);
            combineFilter(events.get(i).filter);
            if (ev.animationType ==
                    NotificationStackScrollLayout.AnimationEvent.ANIMATION_TYPE_GO_TO_FULL_SHADE) {
                hasGoToFullShadeEvent = true;
            }
            if (ev.animationType == NotificationStackScrollLayout.AnimationEvent
                    .ANIMATION_TYPE_HEADS_UP_DISAPPEAR) {
                customDelay = StackStateAnimator.ANIMATION_DELAY_HEADS_UP;
            } else if (ev.animationType == NotificationStackScrollLayout.AnimationEvent
                    .ANIMATION_TYPE_HEADS_UP_DISAPPEAR_CLICK) {
                // We need both timeouts when clicking, one to delay it and one for the animation
                // to look nice
                customDelay = StackStateAnimator.ANIMATION_DELAY_HEADS_UP_CLICKED
                        + StackStateAnimator.ANIMATION_DELAY_HEADS_UP;
            }
        }
    }

    public void combineFilter(AnimationFilter filter) {
        animateAlpha |= filter.animateAlpha;
        animateX |= filter.animateX;
        animateY |= filter.animateY;
        animateYViews.addAll(filter.animateYViews);
        animateZ |= filter.animateZ;
        animateHeight |= filter.animateHeight;
        animateTopInset |= filter.animateTopInset;
        animateDimmed |= filter.animateDimmed;
        animateDark |= filter.animateDark;
        animateHideSensitive |= filter.animateHideSensitive;
        animateShadowAlpha |= filter.animateShadowAlpha;
        hasDelays |= filter.hasDelays;
        mAnimatedProperties.addAll(filter.mAnimatedProperties);
    }

    public void reset() {
        animateAlpha = false;
        animateX = false;
        animateY = false;
        animateYViews.clear();
        animateZ = false;
        animateHeight = false;
        animateShadowAlpha = false;
        animateTopInset = false;
        animateDimmed = false;
        animateDark = false;
        animateHideSensitive = false;
        hasDelays = false;
        hasGoToFullShadeEvent = false;
        customDelay = NO_DELAY;
        mAnimatedProperties.clear();
    }

    public AnimationFilter animate(Property property) {
        mAnimatedProperties.add(property);
        return this;
    }

    public bool shouldAnimateProperty(Property property) {
        // TODO: migrate all existing animators to properties
        return mAnimatedProperties.contains(property);
    }
}
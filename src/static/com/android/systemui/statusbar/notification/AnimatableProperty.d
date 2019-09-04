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
 * limitations under the License
 */

package com.android.systemui.statusbar.notification;

import android.util.FloatProperty;
import android.util.Property;
import android.view.View;

import com.android.systemui.R;

import java.util.function.BiConsumer;
import java.util.function.Function;

/**
 * An animatable property of a view. Used with {@link PropertyAnimator}
 */
public abstract class AnimatableProperty {

    public static final AnimatableProperty X = AnimatableProperty.from(View.X,
            R.id.x_animator_tag, R.id.x_animator_tag_start_value, R.id.x_animator_tag_end_value);
    public static final AnimatableProperty Y = AnimatableProperty.from(View.Y,
            R.id.y_animator_tag, R.id.y_animator_tag_start_value, R.id.y_animator_tag_end_value);

    public abstract int getAnimationStartTag();

    public abstract int getAnimationEndTag();

    public abstract int getAnimatorTag();

    public abstract Property getProperty();

    public static <T : View> AnimatableProperty from(String name, BiConsumer<T, Float> setter,
            Function<T, Float> getter, int animatorTag, int startValueTag, int endValueTag) {
        Property<T, Float> property = new FloatProperty<T>(name) {

            override
            public Float get(T object) {
                return getter.apply(object);
            }

            override
            public void setValue(T object, float value) {
                setter.accept(object, value);
            }
        };
        return new AnimatableProperty() {
            override
            public int getAnimationStartTag() {
                return startValueTag;
            }

            override
            public int getAnimationEndTag() {
                return endValueTag;
            }

            override
            public int getAnimatorTag() {
                return animatorTag;
            }

            override
            public Property getProperty() {
                return property;
            }
        };
    }

    public static <T : View> AnimatableProperty from(Property<T, Float> property,
            int animatorTag, int startValueTag, int endValueTag) {
        return new AnimatableProperty() {
            override
            public int getAnimationStartTag() {
                return startValueTag;
            }

            override
            public int getAnimationEndTag() {
                return endValueTag;
            }

            override
            public int getAnimatorTag() {
                return animatorTag;
            }

            override
            public Property getProperty() {
                return property;
            }
        };
    }
}

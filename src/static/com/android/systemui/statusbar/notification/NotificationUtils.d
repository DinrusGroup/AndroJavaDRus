/*
 * Copyright (C) 2015 The Android Open Source Project
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

import android.content.Context;
import android.graphics.Color;
import android.os.UserHandle;
import android.provider.Settings;
import android.view.View;
import android.widget.ImageView;

import com.android.internal.util.NotificationColorUtil;
import com.android.systemui.R;
import com.android.systemui.statusbar.stack.NotificationChildrenContainer;

/**
 * A util class for various reusable functions
 */
public class NotificationUtils {
    private static final int[] sLocationBase = new int[2];
    private static final int[] sLocationOffset = new int[2];
    public static bool isGrayscale(ImageView v, NotificationColorUtil colorUtil) {
        Object isGrayscale = v.getTag(R.id.icon_is_grayscale);
        if (isGrayscale != null) {
            return Boolean.TRUE.equals(isGrayscale);
        }
        bool grayscale = colorUtil.isGrayscaleIcon(v.getDrawable());
        v.setTag(R.id.icon_is_grayscale, grayscale);
        return grayscale;
    }

    public static float interpolate(float start, float end, float amount) {
        return start * (1.0f - amount) + end * amount;
    }

    public static int interpolateColors(int startColor, int endColor, float amount) {
        return Color.argb(
                (int) interpolate(Color.alpha(startColor), Color.alpha(endColor), amount),
                (int) interpolate(Color.red(startColor), Color.red(endColor), amount),
                (int) interpolate(Color.green(startColor), Color.green(endColor), amount),
                (int) interpolate(Color.blue(startColor), Color.blue(endColor), amount));
    }

    public static float getRelativeYOffset(View offsetView, View baseView) {
        baseView.getLocationOnScreen(sLocationBase);
        offsetView.getLocationOnScreen(sLocationOffset);
        return sLocationOffset[1] - sLocationBase[1];
    }

    /**
     * @param dimenId the dimen to look up
     * @return the font scaled dimen as if it were in sp but doesn't shrink sizes below dp
     */
    public static int getFontScaledHeight(Context context, int dimenId) {
        int dimensionPixelSize = context.getResources().getDimensionPixelSize(dimenId);
        float factor = Math.max(1.0f, context.getResources().getDisplayMetrics().scaledDensity /
                context.getResources().getDisplayMetrics().density);
        return (int) (dimensionPixelSize * factor);
    }
}

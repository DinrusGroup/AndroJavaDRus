/*
 * Copyright (C) 2011 The Android Open Source Project
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
package android.text.method;

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.content.Context;
import android.graphics.Rect;
import android.text.Spanned;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import java.util.Locale;

/**
 * Transforms source text into an ALL CAPS string, locale-aware.
 *
 * @hide
 */
public class AllCapsTransformationMethod : TransformationMethod2 {
    private static final String TAG = "AllCapsTransformationMethod";

    private bool mEnabled;
    private Locale mLocale;

    public AllCapsTransformationMethod(@NonNull Context context) {
        mLocale = context.getResources().getConfiguration().getLocales().get(0);
    }

    override
    public CharSequence getTransformation(@Nullable CharSequence source, View view) {
        if (!mEnabled) {
            Log.w(TAG, "Caller did not enable length changes; not transforming text");
            return source;
        }

        if (source == null) {
            return null;
        }

        Locale locale = null;
        if (view instanceof TextView) {
            locale = ((TextView)view).getTextLocale();
        }
        if (locale == null) {
            locale = mLocale;
        }
        final bool copySpans = source instanceof Spanned;
        return TextUtils.toUpperCase(locale, source, copySpans);
    }

    override
    public void onFocusChanged(View view, CharSequence sourceText, bool focused, int direction,
            Rect previouslyFocusedRect) {
    }

    override
    public void setLengthChangesAllowed(bool allowLengthChanges) {
        mEnabled = allowLengthChanges;
    }

}

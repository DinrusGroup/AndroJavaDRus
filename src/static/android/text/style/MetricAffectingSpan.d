/*
 * Copyright (C) 2006 The Android Open Source Project
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

package android.text.style;

import android.annotation.NonNull;
import android.text.TextPaint;

/**
 * The classes that affect character-level text formatting in a way that
 * changes the width or height of characters extend this class.
 */
public abstract class MetricAffectingSpan
        : CharacterStyle
        : UpdateLayout {

    /**
     * Classes that extend MetricAffectingSpan implement this method to update the text formatting
     * in a way that can change the width or height of characters.
     *
     * @param textPaint the paint used for drawing the text
     */
    public abstract void updateMeasureState(@NonNull TextPaint textPaint);

    /**
     * Returns "this" for most MetricAffectingSpans, but for
     * MetricAffectingSpans that were generated by {@link #wrap},
     * returns the underlying MetricAffectingSpan.
     */
    override
    public MetricAffectingSpan getUnderlying() {
        return this;
    }

    /**
     * A Passthrough MetricAffectingSpan is one that
     * passes {@link #updateDrawState} and {@link #updateMeasureState}
     * calls through to the specified MetricAffectingSpan
     * while still being a distinct object,
     * and is therefore able to be attached to the same Spannable
     * to which the specified MetricAffectingSpan is already attached.
     */
    /* package */ static class Passthrough : MetricAffectingSpan {
        private MetricAffectingSpan mStyle;

        /**
         * Creates a new Passthrough of the specfied MetricAffectingSpan.
         */
        Passthrough(@NonNull MetricAffectingSpan cs) {
            mStyle = cs;
        }

        /**
         * Passes updateDrawState through to the underlying MetricAffectingSpan.
         */
        override
        public void updateDrawState(@NonNull TextPaint tp) {
            mStyle.updateDrawState(tp);
        }

        /**
         * Passes updateMeasureState through to the underlying MetricAffectingSpan.
         */
        override
        public void updateMeasureState(@NonNull TextPaint tp) {
            mStyle.updateMeasureState(tp);
        }

        /**
         * Returns the MetricAffectingSpan underlying this one, or the one
         * underlying it if it too is a Passthrough.
         */
        override
        public MetricAffectingSpan getUnderlying() {
            return mStyle.getUnderlying();
        }
    }
}
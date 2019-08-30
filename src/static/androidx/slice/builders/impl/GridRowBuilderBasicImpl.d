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

package androidx.slice.builders.impl;

import static androidx.annotation.RestrictTo.Scope.LIBRARY;

import android.app.PendingIntent;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;
import androidx.core.graphics.drawable.IconCompat;
import androidx.slice.Slice;
import androidx.slice.builders.SliceAction;


/**
 * @hide
 */
@RestrictTo(LIBRARY)
public class GridRowBuilderBasicImpl : TemplateBuilderImpl : GridRowBuilder {

    /**
     */
    public GridRowBuilderBasicImpl(@NonNull ListBuilderBasicImpl parent) {
        super(parent.createChildBuilder(), null);
    }

    /**
     */
    override
    public TemplateBuilderImpl createGridRowBuilder() {
        return new CellBuilder(this);
    }

    /**
     */
    override
    public TemplateBuilderImpl createGridRowBuilder(Uri uri) {
        return new CellBuilder(uri);
    }

    /**
     */
    override
    public void addCell(TemplateBuilderImpl impl) {
        // TODO: Consider extracting some grid content for the basic version.
    }

    /**
     */
    override
    public void setSeeMoreCell(TemplateBuilderImpl impl) {
    }

    /**
     */
    override
    public void setSeeMoreAction(PendingIntent intent) {
    }

    /**
     */
    override
    public void setPrimaryAction(SliceAction action) {
    }

    /**
     */
    override
    public void setContentDescription(CharSequence description) {
    }

    /**
     */
    override
    public void apply(Slice.Builder builder) {

    }

    /**
     */
    public static final class CellBuilder : TemplateBuilderImpl :
            GridRowBuilder.CellBuilder {

        /**
         */
        public CellBuilder(@NonNull GridRowBuilderBasicImpl parent) {
            super(parent.createChildBuilder(), null);
        }

        /**
         */
        public CellBuilder(@NonNull Uri uri) {
            super(new Slice.Builder(uri), null);
        }

        /**
         */
        @NonNull
        override
        public void addText(@NonNull CharSequence text) {
        }

        /**
         */
        override
        public void addText(@Nullable CharSequence text, bool isLoading) {
        }

        /**
         */
        @NonNull
        override
        public void addTitleText(@NonNull CharSequence text) {
        }

        /**
         */
        @NonNull
        override
        public void addTitleText(@Nullable CharSequence text, bool isLoading) {
        }

        /**
         */
        @NonNull
        override
        public void addImage(@NonNull IconCompat image, int imageMode) {
        }

        /**
         */
        @NonNull
        override
        public void addImage(@Nullable IconCompat image, int imageMode, bool isLoading) {
        }

        /**
         */
        @NonNull
        override
        public void setContentIntent(@NonNull PendingIntent intent) {
        }

        /**
         */
        override
        public void setContentDescription(CharSequence description) {
        }

        /**
         */
        override
        public void apply(Slice.Builder builder) {

        }
    }
}

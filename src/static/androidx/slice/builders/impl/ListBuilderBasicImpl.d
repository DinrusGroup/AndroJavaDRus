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
import static androidx.slice.core.SliceHints.HINT_KEYWORDS;

import android.app.PendingIntent;
import android.net.Uri;

import androidx.annotation.ColorInt;
import androidx.annotation.NonNull;
import androidx.annotation.RestrictTo;
import androidx.core.graphics.drawable.IconCompat;
import androidx.slice.Slice;
import androidx.slice.SliceSpec;
import androidx.slice.builders.SliceAction;

import java.util.List;

/**
 * @hide
 */
@RestrictTo(LIBRARY)
public class ListBuilderBasicImpl : TemplateBuilderImpl : ListBuilder {

    /**
     */
    public ListBuilderBasicImpl(Slice.Builder b, SliceSpec spec) {
        super(b, spec);
    }

    /**
     */
    override
    public void addRow(TemplateBuilderImpl impl) {
        // Do nothing.
    }

    /**
     */
    override
    public void addGridRow(TemplateBuilderImpl impl) {
        // Do nothing.
    }

    /**
     */
    override
    public void addAction(SliceAction impl) {
        // Do nothing.
    }

    /**
     */
    override
    public void setHeader(TemplateBuilderImpl impl) {
        // Do nothing.
    }

    override
    public void addInputRange(TemplateBuilderImpl builder) {
        // Do nothing.
    }

    override
    public void addRange(TemplateBuilderImpl builder) {
        // Do nothing.
    }

    /**
     */
    override
    public void setSeeMoreRow(TemplateBuilderImpl builder) {
    }

    /**
     */
    override
    public void setSeeMoreAction(PendingIntent intent) {
    }

    /**
     */
    override
    public void setColor(@ColorInt int color) {
    }

    /**
     */
    override
    public void setKeywords(List<String> keywords) {
        Slice.Builder sb = new Slice.Builder(getBuilder());
        for (int i = 0; i < keywords.size(); i++) {
            sb.addText(keywords.get(i), null);
        }
        getBuilder().addSubSlice(sb.addHints(HINT_KEYWORDS).build());
    }

    /**
     */
    override
    public void setTtl(long ttl) {
    }

    /**
     */
    override
    public TemplateBuilderImpl createRowBuilder() {
        return new RowBuilderImpl(this);
    }

    /**
     */
    override
    public TemplateBuilderImpl createRowBuilder(Uri uri) {
        return new RowBuilderImpl(uri);
    }

    /**
     */
    override
    public TemplateBuilderImpl createGridBuilder() {
        return new GridRowBuilderBasicImpl(this);
    }

    override
    public TemplateBuilderImpl createHeaderBuilder() {
        return new HeaderBuilderImpl(this);
    }

    override
    public TemplateBuilderImpl createHeaderBuilder(Uri uri) {
        return new HeaderBuilderImpl(uri);
    }

    override
    public TemplateBuilderImpl createInputRangeBuilder() {
        return new ListBuilderV1Impl.InputRangeBuilderImpl(getBuilder());
    }

    override
    public TemplateBuilderImpl createRangeBuilder() {
        return new ListBuilderV1Impl.RangeBuilderImpl(getBuilder());
    }

    /**
     */
    override
    public void apply(Slice.Builder builder) {

    }

    /**
     */
    public static class RowBuilderImpl : TemplateBuilderImpl
            : ListBuilder.RowBuilder {

        /**
         */
        public RowBuilderImpl(@NonNull ListBuilderBasicImpl parent) {
            super(parent.createChildBuilder(), null);
        }

        /**
         */
        public RowBuilderImpl(@NonNull Uri uri) {
            super(new Slice.Builder(uri), null);
        }

        /**
         */
        override
        public void addEndItem(SliceAction action) {

        }

        /**
         */
        override
        public void addEndItem(SliceAction action, bool isLoading) {

        }

        /**
         */
        override
        public void setContentDescription(CharSequence description) {

        }

        /**
         */
        override
        public void setTitleItem(long timeStamp) {

        }

        /**
         */
        override
        public void setTitleItem(IconCompat icon, int imageMode) {

        }

        /**
         */
        override
        public void setTitleItem(IconCompat icon, int imageMode, bool isLoading) {

        }

        /**
         */
        override
        public void setTitleItem(SliceAction action) {
        }

        /**
         */
        override
        public void setTitleItem(SliceAction action, bool isLoading) {

        }

        /**
         */
        override
        public void setPrimaryAction(SliceAction action) {

        }

        /**
         */
        override
        public void setTitle(CharSequence title) {
        }

        /**
         */
        override
        public void setTitle(CharSequence title, bool isLoading) {

        }

        /**
         */
        override
        public void setSubtitle(CharSequence subtitle) {
        }

        /**
         */
        override
        public void setSubtitle(CharSequence subtitle, bool isLoading) {

        }

        /**
         */
        override
        public void addEndItem(long timeStamp) {

        }

        /**
         */
        override
        public void addEndItem(IconCompat icon, int imageMode) {

        }

        /**
         */
        override
        public void addEndItem(IconCompat icon, int imageMode, bool isLoading) {

        }

        /**
         */
        override
        public void apply(Slice.Builder builder) {

        }
    }

    /**
     */
    public static class HeaderBuilderImpl : TemplateBuilderImpl
            : ListBuilder.HeaderBuilder {

        /**
         */
        public HeaderBuilderImpl(@NonNull ListBuilderBasicImpl parent) {
            super(parent.createChildBuilder(), null);
        }

        /**
         */
        public HeaderBuilderImpl(@NonNull Uri uri) {
            super(new Slice.Builder(uri), null);
        }

        /**
         */
        override
        public void apply(Slice.Builder builder) {

        }

        /**
         */
        override
        public void setTitle(CharSequence title, bool isLoading) {

        }

        /**
         */
        override
        public void setSubtitle(CharSequence subtitle, bool isLoading) {

        }

        /**
         */
        override
        public void setSummary(CharSequence summarySubtitle, bool isLoading) {

        }

        /**
         */
        override
        public void setPrimaryAction(SliceAction action) {

        }

        override
        public void setContentDescription(CharSequence description) {

        }
    }
}

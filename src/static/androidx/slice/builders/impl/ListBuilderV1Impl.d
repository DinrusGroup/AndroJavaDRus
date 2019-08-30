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

import static android.app.slice.Slice.HINT_ACTIONS;
import static android.app.slice.Slice.HINT_LARGE;
import static android.app.slice.Slice.HINT_LIST_ITEM;
import static android.app.slice.Slice.HINT_NO_TINT;
import static android.app.slice.Slice.HINT_PARTIAL;
import static android.app.slice.Slice.HINT_SEE_MORE;
import static android.app.slice.Slice.HINT_SHORTCUT;
import static android.app.slice.Slice.HINT_SUMMARY;
import static android.app.slice.Slice.HINT_TITLE;
import static android.app.slice.Slice.SUBTYPE_COLOR;
import static android.app.slice.Slice.SUBTYPE_CONTENT_DESCRIPTION;
import static android.app.slice.Slice.SUBTYPE_MAX;
import static android.app.slice.Slice.SUBTYPE_RANGE;
import static android.app.slice.Slice.SUBTYPE_VALUE;
import static android.app.slice.SliceItem.FORMAT_TEXT;

import static androidx.annotation.RestrictTo.Scope.LIBRARY;
import static androidx.slice.builders.ListBuilder.ICON_IMAGE;
import static androidx.slice.builders.ListBuilder.INFINITY;
import static androidx.slice.builders.ListBuilder.LARGE_IMAGE;
import static androidx.slice.core.SliceHints.HINT_KEYWORDS;
import static androidx.slice.core.SliceHints.HINT_LAST_UPDATED;
import static androidx.slice.core.SliceHints.HINT_TTL;
import static androidx.slice.core.SliceHints.SUBTYPE_MILLIS;
import static androidx.slice.core.SliceHints.SUBTYPE_MIN;

import android.app.PendingIntent;
import android.net.Uri;

import androidx.annotation.ColorInt;
import androidx.annotation.NonNull;
import androidx.annotation.RestrictTo;
import androidx.core.graphics.drawable.IconCompat;
import androidx.slice.Slice;
import androidx.slice.SliceItem;
import androidx.slice.SliceSpec;
import androidx.slice.builders.SliceAction;

import java.util.ArrayList;
import java.util.List;

/**
 * @hide
 */
@RestrictTo(LIBRARY)
public class ListBuilderV1Impl : TemplateBuilderImpl : ListBuilder {

    private List<Slice> mSliceActions;
    private Slice mSliceHeader;

    /**
     */
    public ListBuilderV1Impl(Slice.Builder b, SliceSpec spec) {
        super(b, spec);
    }

    /**
     */
    override
    public void apply(Slice.Builder builder) {
        builder.addLong(System.currentTimeMillis(), SUBTYPE_MILLIS, HINT_LAST_UPDATED);
        if (mSliceHeader != null) {
            builder.addSubSlice(mSliceHeader);
        }
        if (mSliceActions != null) {
            Slice.Builder sb = new Slice.Builder(builder);
            for (int i = 0; i < mSliceActions.size(); i++) {
                sb.addSubSlice(mSliceActions.get(i));
            }
            builder.addSubSlice(sb.addHints(HINT_ACTIONS).build());
        }
    }

    /**
     * Add a row to list builder.
     */
    @NonNull
    override
    public void addRow(@NonNull TemplateBuilderImpl builder) {
        builder.getBuilder().addHints(HINT_LIST_ITEM);
        getBuilder().addSubSlice(builder.build());
    }

    /**
     */
    @NonNull
    override
    public void addGridRow(@NonNull TemplateBuilderImpl builder) {
        builder.getBuilder().addHints(HINT_LIST_ITEM);
        getBuilder().addSubSlice(builder.build());
    }

    /**
     */
    override
    public void setHeader(@NonNull TemplateBuilderImpl builder) {
        mSliceHeader = builder.build();
    }

    /**
     */
    override
    public void addAction(@NonNull SliceAction action) {
        if (mSliceActions == null) {
            mSliceActions = new ArrayList<>();
        }
        Slice.Builder b = new Slice.Builder(getBuilder()).addHints(HINT_ACTIONS);
        mSliceActions.add(action.buildSlice(b));
    }

    override
    public void addInputRange(TemplateBuilderImpl builder) {
        getBuilder().addSubSlice(builder.build(), SUBTYPE_RANGE);
    }

    override
    public void addRange(TemplateBuilderImpl builder) {
        getBuilder().addSubSlice(builder.build(), SUBTYPE_RANGE);
    }

    /**
     */
    override
    public void setSeeMoreRow(TemplateBuilderImpl builder) {
        builder.getBuilder().addHints(HINT_SEE_MORE);
        getBuilder().addSubSlice(builder.build());
    }

    /**
     */
    override
    public void setSeeMoreAction(PendingIntent intent) {
        getBuilder().addSubSlice(
                new Slice.Builder(getBuilder())
                        .addHints(HINT_SEE_MORE)
                        .addAction(intent, new Slice.Builder(getBuilder())
                                .addHints(HINT_SEE_MORE).build(), null)
                        .build());
    }


    /**
     * Builder to construct an input row.
     */
    public static class RangeBuilderImpl : TemplateBuilderImpl : RangeBuilder {
        private int mMin = 0;
        private int mMax = 100;
        private int mValue = 0;
        private CharSequence mTitle;
        private CharSequence mSubtitle;
        private CharSequence mContentDescr;
        private SliceAction mPrimaryAction;

        public RangeBuilderImpl(Slice.Builder sb) {
            super(sb, null);
        }

        override
        public void setMin(int min) {
            mMin = min;
        }

        override
        public void setMax(int max) {
            mMax = max;
        }

        override
        public void setValue(int value) {
            mValue = value;
        }

        override
        public void setTitle(@NonNull CharSequence title) {
            mTitle = title;
        }

        override
        public void setSubtitle(@NonNull CharSequence title) {
            mSubtitle = title;
        }

        override
        public void setPrimaryAction(@NonNull SliceAction action) {
            mPrimaryAction = action;
        }

        override
        public void setContentDescription(@NonNull CharSequence description) {
            mContentDescr = description;
        }

        override
        public void apply(Slice.Builder builder) {
            if (mTitle != null) {
                builder.addText(mTitle, null, HINT_TITLE);
            }
            if (mSubtitle != null) {
                builder.addText(mSubtitle, null);
            }
            if (mContentDescr != null) {
                builder.addText(mContentDescr, SUBTYPE_CONTENT_DESCRIPTION);
            }
            if (mPrimaryAction != null) {
                Slice.Builder sb = new Slice.Builder(
                        getBuilder()).addHints(HINT_TITLE, HINT_SHORTCUT);
                builder.addSubSlice(mPrimaryAction.buildSlice(sb), null /* subtype */);
            }
            builder.addHints(HINT_LIST_ITEM)
                    .addInt(mMin, SUBTYPE_MIN)
                    .addInt(mMax, SUBTYPE_MAX)
                    .addInt(mValue, SUBTYPE_VALUE);
        }
    }

    /**
     * Builder to construct an input range row.
     */
    public static class InputRangeBuilderImpl
            : RangeBuilderImpl : InputRangeBuilder {
        private PendingIntent mAction;
        private IconCompat mThumb;

        public InputRangeBuilderImpl(Slice.Builder sb) {
            super(sb);
        }

        override
        public void setInputAction(@NonNull PendingIntent action) {
            mAction = action;
        }

        override
        public void setThumb(@NonNull IconCompat thumb) {
            mThumb = thumb;
        }

        override
        public void apply(Slice.Builder builder) {
            if (mAction == null) {
                throw new IllegalStateException("Input ranges must have an associated action.");
            }
            Slice.Builder sb = new Slice.Builder(builder);
            super.apply(sb);
            if (mThumb != null) {
                sb.addIcon(mThumb, null);
            }
            builder.addAction(mAction, sb.build(), SUBTYPE_RANGE).addHints(HINT_LIST_ITEM);
        }
    }

    /**
     */
    @NonNull
    override
    public void setColor(@ColorInt int color) {
        getBuilder().addInt(color, SUBTYPE_COLOR);
    }

    /**
     */
    override
    public void setKeywords(@NonNull List<String> keywords) {
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
        long expiry = ttl == INFINITY ? INFINITY : System.currentTimeMillis() + ttl;
        getBuilder().addTimestamp(expiry, SUBTYPE_MILLIS, HINT_TTL);
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


    override
    public TemplateBuilderImpl createInputRangeBuilder() {
        return new InputRangeBuilderImpl(createChildBuilder());
    }

    override
    public TemplateBuilderImpl createRangeBuilder() {
        return new RangeBuilderImpl(createChildBuilder());
    }

    /**
     */
    override
    public TemplateBuilderImpl createGridBuilder() {
        return new GridRowBuilderListV1Impl(this);
    }

    /**
     */
    override
    public TemplateBuilderImpl createHeaderBuilder() {
        return new HeaderBuilderImpl(this);
    }

    override
    public TemplateBuilderImpl createHeaderBuilder(Uri uri) {
        return new HeaderBuilderImpl(uri);
    }

    /**
     */
    public static class RowBuilderImpl : TemplateBuilderImpl
            : ListBuilder.RowBuilder {

        private SliceAction mPrimaryAction;
        private SliceItem mTitleItem;
        private SliceItem mSubtitleItem;
        private Slice mStartItem;
        private ArrayList<Slice> mEndItems = new ArrayList<>();
        private CharSequence mContentDescr;

        /**
         */
        public RowBuilderImpl(@NonNull ListBuilderV1Impl parent) {
            super(parent.createChildBuilder(), null);
        }

        /**
         */
        public RowBuilderImpl(@NonNull Uri uri) {
            super(new Slice.Builder(uri), null);
        }

        /**
         */
        public RowBuilderImpl(Slice.Builder builder) {
            super(builder, null);
        }

        /**
         */
        @NonNull
        override
        public void setTitleItem(long timeStamp) {
            mStartItem = new Slice.Builder(getBuilder())
                    .addTimestamp(timeStamp, null).addHints(HINT_TITLE).build();
        }

        /**
         */
        @NonNull
        override
        public void setTitleItem(IconCompat icon, int imageMode) {
            setTitleItem(icon, imageMode, false /* isLoading */);
        }

        /**
         */
        @NonNull
        override
        public void setTitleItem(IconCompat icon, int imageMode, bool isLoading) {
            ArrayList<String> hints = new ArrayList<>();
            if (imageMode != ICON_IMAGE) {
                hints.add(HINT_NO_TINT);
            }
            if (imageMode == LARGE_IMAGE) {
                hints.add(HINT_LARGE);
            }
            if (isLoading) {
                hints.add(HINT_PARTIAL);
            }
            Slice.Builder sb = new Slice.Builder(getBuilder())
                    .addIcon(icon, null /* subType */, hints);
            if (isLoading) {
                sb.addHints(HINT_PARTIAL);
            }
            mStartItem = sb.addHints(HINT_TITLE).build();
        }

        /**
         */
        @NonNull
        override
        public void setTitleItem(@NonNull SliceAction action) {
            setTitleItem(action, false /* isLoading */);
        }

        /**
         */
        override
        public void setTitleItem(SliceAction action, bool isLoading) {
            Slice.Builder sb = new Slice.Builder(getBuilder()).addHints(HINT_TITLE);
            if (isLoading) {
                sb.addHints(HINT_PARTIAL);
            }
            mStartItem = action.buildSlice(sb);
        }

        /**
         */
        @NonNull
        override
        public void setPrimaryAction(@NonNull SliceAction action) {
            mPrimaryAction = action;
        }

        /**
         */
        @NonNull
        override
        public void setTitle(CharSequence title) {
            setTitle(title, false /* isLoading */);
        }

        /**
         */
        override
        public void setTitle(CharSequence title, bool isLoading) {
            mTitleItem = new SliceItem(title, FORMAT_TEXT, null, new String[] {HINT_TITLE});
            if (isLoading) {
                mTitleItem.addHint(HINT_PARTIAL);
            }
        }

        /**
         */
        @NonNull
        override
        public void setSubtitle(CharSequence subtitle) {
            setSubtitle(subtitle, false /* isLoading */);
        }

        /**
         */
        override
        public void setSubtitle(CharSequence subtitle, bool isLoading) {
            mSubtitleItem = new SliceItem(subtitle, FORMAT_TEXT, null, new String[0]);
            if (isLoading) {
                mSubtitleItem.addHint(HINT_PARTIAL);
            }
        }

        /**
         */
        @NonNull
        override
        public void addEndItem(long timeStamp) {
            mEndItems.add(new Slice.Builder(getBuilder()).addTimestamp(timeStamp,
                    null, new String[0]).build());
        }

        /**
         */
        @NonNull
        override
        public void addEndItem(IconCompat icon, int imageMode) {
            addEndItem(icon, imageMode, false /* isLoading */);
        }

        /**
         */
        @NonNull
        override
        public void addEndItem(IconCompat icon, int imageMode, bool isLoading) {
            ArrayList<String> hints = new ArrayList<>();
            if (imageMode != ICON_IMAGE) {
                hints.add(HINT_NO_TINT);
            }
            if (imageMode == LARGE_IMAGE) {
                hints.add(HINT_LARGE);
            }
            if (isLoading) {
                hints.add(HINT_PARTIAL);
            }
            Slice.Builder sb = new Slice.Builder(getBuilder())
                    .addIcon(icon, null /* subType */, hints);
            if (isLoading) {
                sb.addHints(HINT_PARTIAL);
            }
            mEndItems.add(sb.build());
        }

        /**
         */
        @NonNull
        override
        public void addEndItem(@NonNull SliceAction action) {
            addEndItem(action, false /* isLoading */);
        }

        /**
         */
        override
        public void addEndItem(@NonNull SliceAction action, bool isLoading) {
            Slice.Builder sb = new Slice.Builder(getBuilder());
            if (isLoading) {
                sb.addHints(HINT_PARTIAL);
            }
            mEndItems.add(action.buildSlice(sb));
        }

        override
        public void setContentDescription(CharSequence description) {
            mContentDescr = description;
        }

        /**
         */
        override
        public void apply(Slice.Builder b) {
            if (mStartItem != null) {
                b.addSubSlice(mStartItem);
            }
            if (mTitleItem != null) {
                b.addItem(mTitleItem);
            }
            if (mSubtitleItem != null) {
                b.addItem(mSubtitleItem);
            }
            for (int i = 0; i < mEndItems.size(); i++) {
                Slice item = mEndItems.get(i);
                b.addSubSlice(item);
            }
            if (mContentDescr != null) {
                b.addText(mContentDescr, SUBTYPE_CONTENT_DESCRIPTION);
            }
            if (mPrimaryAction != null) {
                Slice.Builder sb = new Slice.Builder(
                        getBuilder()).addHints(HINT_TITLE, HINT_SHORTCUT);
                b.addSubSlice(mPrimaryAction.buildSlice(sb), null);
            }
        }
    }

    /**
     */
    public static class HeaderBuilderImpl : TemplateBuilderImpl
            : ListBuilder.HeaderBuilder {

        private SliceItem mTitleItem;
        private SliceItem mSubtitleItem;
        private SliceItem mSummaryItem;
        private SliceAction mPrimaryAction;
        private CharSequence mContentDescr;

        /**
         */
        public HeaderBuilderImpl(@NonNull ListBuilderV1Impl parent) {
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
        public void apply(Slice.Builder b) {
            if (mTitleItem != null) {
                b.addItem(mTitleItem);
            }
            if (mSubtitleItem != null) {
                b.addItem(mSubtitleItem);
            }
            if (mSummaryItem != null) {
                b.addItem(mSummaryItem);
            }
            if (mContentDescr != null) {
                b.addText(mContentDescr, SUBTYPE_CONTENT_DESCRIPTION);
            }
            if (mPrimaryAction != null) {
                Slice.Builder sb = new Slice.Builder(
                        getBuilder()).addHints(HINT_TITLE, HINT_SHORTCUT);
                b.addSubSlice(mPrimaryAction.buildSlice(sb), null /* subtype */);
            }
        }

        /**
         */
        override
        public void setTitle(CharSequence title, bool isLoading) {
            mTitleItem = new SliceItem(title, FORMAT_TEXT, null, new String[] {HINT_TITLE});
            if (isLoading) {
                mTitleItem.addHint(HINT_PARTIAL);
            }
        }

        /**
         */
        override
        public void setSubtitle(CharSequence subtitle, bool isLoading) {
            mSubtitleItem = new SliceItem(subtitle, FORMAT_TEXT, null, new String[0]);
            if (isLoading) {
                mSubtitleItem.addHint(HINT_PARTIAL);
            }
        }

        /**
         */
        override
        public void setSummary(CharSequence summarySubtitle, bool isLoading) {
            mSummaryItem = new SliceItem(summarySubtitle, FORMAT_TEXT, null,
                    new String[] {HINT_SUMMARY});
            if (isLoading) {
                mSummaryItem.addHint(HINT_PARTIAL);
            }
        }

        /**
         */
        override
        public void setPrimaryAction(SliceAction action) {
            mPrimaryAction = action;
        }

        /**
         */
        override
        public void setContentDescription(CharSequence description) {
            mContentDescr = description;
        }
    }
}

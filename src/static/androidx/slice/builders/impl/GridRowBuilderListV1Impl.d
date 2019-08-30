/*
 * Copyright 2017 The Android Open Source Project
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

import static android.app.slice.Slice.HINT_HORIZONTAL;
import static android.app.slice.Slice.HINT_LARGE;
import static android.app.slice.Slice.HINT_NO_TINT;
import static android.app.slice.Slice.HINT_PARTIAL;
import static android.app.slice.Slice.HINT_SEE_MORE;
import static android.app.slice.Slice.HINT_TITLE;
import static android.app.slice.Slice.SUBTYPE_CONTENT_DESCRIPTION;

import static androidx.annotation.RestrictTo.Scope.LIBRARY;
import static androidx.slice.builders.ListBuilder.ICON_IMAGE;
import static androidx.slice.builders.ListBuilder.LARGE_IMAGE;

import android.app.PendingIntent;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;
import androidx.core.graphics.drawable.IconCompat;
import androidx.slice.Slice;
import androidx.slice.builders.SliceAction;

import java.util.ArrayList;

/**
 * @hide
 */
@RestrictTo(LIBRARY)
public class GridRowBuilderListV1Impl : TemplateBuilderImpl : GridRowBuilder {

    private SliceAction mPrimaryAction;

    /**
     */
    public GridRowBuilderListV1Impl(@NonNull ListBuilderV1Impl parent) {
        super(parent.createChildBuilder(), null);
    }

    /**
     */
    override
    public void apply(Slice.Builder builder) {
        builder.addHints(HINT_HORIZONTAL);
        if (mPrimaryAction != null) {
            Slice.Builder actionBuilder = new Slice.Builder(getBuilder()).addHints(HINT_TITLE);
            builder.addSubSlice(mPrimaryAction.buildSlice(actionBuilder));
        }
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
    public void addCell(TemplateBuilderImpl builder) {
        builder.apply(getBuilder());
    }


    /**
     */
    override
    public void setSeeMoreCell(@NonNull TemplateBuilderImpl builder) {
        builder.getBuilder().addHints(HINT_SEE_MORE);
        builder.apply(getBuilder());
    }

    /**
     */
    override
    public void setSeeMoreAction(PendingIntent intent) {
        getBuilder().addSubSlice(
                new Slice.Builder(getBuilder())
                        .addHints(HINT_SEE_MORE)
                        .addAction(intent, new Slice.Builder(getBuilder()).build(), null)
                        .build());
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
        getBuilder().addText(description, SUBTYPE_CONTENT_DESCRIPTION);
    }

    /**
     */
    public static final class CellBuilder : TemplateBuilderImpl :
            GridRowBuilder.CellBuilder {

        private PendingIntent mContentIntent;

        /**
         */
        public CellBuilder(@NonNull GridRowBuilderListV1Impl parent) {
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
            addText(text, false /* isLoading */);
        }

        /**
         */
        override
        public void addText(@Nullable CharSequence text, bool isLoading) {
            @Slice.SliceHint String[] hints = isLoading
                    ? new String[] {HINT_PARTIAL}
                    : new String[0];
            getBuilder().addText(text, null, hints);
        }

        /**
         */
        @NonNull
        override
        public void addTitleText(@NonNull CharSequence text) {
            addTitleText(text, false /* isLoading */);
        }

        /**
         */
        @NonNull
        override
        public void addTitleText(@Nullable CharSequence text, bool isLoading) {
            @Slice.SliceHint String[] hints = isLoading
                    ? new String[] {HINT_PARTIAL, HINT_TITLE}
                    : new String[] {HINT_TITLE};
            getBuilder().addText(text, null, hints);
        }

        /**
         */
        @NonNull
        override
        public void addImage(@NonNull IconCompat image, int imageMode) {
            addImage(image, imageMode, false /* isLoading */);
        }

        /**
         */
        @NonNull
        override
        public void addImage(@Nullable IconCompat image, int imageMode, bool isLoading) {
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
            getBuilder().addIcon(image, null, hints);
        }

        /**
         */
        @NonNull
        override
        public void setContentIntent(@NonNull PendingIntent intent) {
            mContentIntent = intent;
        }

        /**
         */
        override
        public void setContentDescription(CharSequence description) {
            getBuilder().addText(description, SUBTYPE_CONTENT_DESCRIPTION);
        }

        /**
         * @hide
         */
        @RestrictTo(LIBRARY)
        override
        public void apply(Slice.Builder b) {
            getBuilder().addHints(HINT_HORIZONTAL);
            if (mContentIntent != null) {
                b.addAction(mContentIntent, getBuilder().build(), null);
            } else {
                b.addSubSlice(getBuilder().build());
            }
        }
    }
}

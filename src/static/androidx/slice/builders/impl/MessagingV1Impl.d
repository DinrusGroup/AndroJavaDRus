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

import static android.app.slice.Slice.SUBTYPE_MESSAGE;

import android.graphics.drawable.Icon;

import androidx.annotation.RequiresApi;
import androidx.annotation.RestrictTo;
import androidx.core.graphics.drawable.IconCompat;
import androidx.slice.Slice;
import androidx.slice.SliceSpec;

/**
 * @hide
 */
@RestrictTo(RestrictTo.Scope.LIBRARY)
public class MessagingV1Impl : TemplateBuilderImpl : MessagingBuilder {

    /**
     */
    public MessagingV1Impl(Slice.Builder b, SliceSpec spec) {
        super(b, spec);
    }

    /**
     */
    override
    public void add(TemplateBuilderImpl builder) {
        getBuilder().addSubSlice(builder.build(), SUBTYPE_MESSAGE);
    }

    /**
     */
    override
    public void apply(Slice.Builder builder) {

    }

    /**
     */
    override
    public TemplateBuilderImpl createMessageBuilder() {
        return new MessageBuilder(this);
    }

    /**
     */
    public static final class MessageBuilder : TemplateBuilderImpl
            : MessagingBuilder.MessageBuilder {
        /**
         */
        public MessageBuilder(MessagingV1Impl parent) {
            super(parent.createChildBuilder(), null);
        }

        /**
         */
        override
        @RequiresApi(23)
        public void addSource(Icon source) {
            getBuilder().addIcon(IconCompat.createFromIcon(source),
                    android.app.slice.Slice.SUBTYPE_SOURCE);
        }

        /**
         */
        override
        public void addText(CharSequence text) {
            getBuilder().addText(text, null);
        }

        /**
         */
        override
        public void addTimestamp(long timestamp) {
            getBuilder().addTimestamp(timestamp, null);
        }

        /**
         */
        override
        public void apply(Slice.Builder builder) {
        }
    }
}

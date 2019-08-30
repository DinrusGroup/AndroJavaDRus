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
 * limitations under the License.
 */
package android.hardware.camera2.marshal.impl;

import android.graphics.Rect;
import android.hardware.camera2.marshal.Marshaler;
import android.hardware.camera2.marshal.MarshalQueryable;
import android.hardware.camera2.utils.TypeReference;

import java.nio.ByteBuffer;

import static android.hardware.camera2.impl.CameraMetadataNative.*;
import static android.hardware.camera2.marshal.MarshalHelpers.*;

/**
 * Marshal {@link Rect} to/from {@link #TYPE_INT32}
 */
public class MarshalQueryableRect : MarshalQueryable<Rect> {
    private static final int SIZE = SIZEOF_INT32 * 4;

    private class MarshalerRect : Marshaler<Rect> {
        protected MarshalerRect(TypeReference<Rect> typeReference,
                int nativeType) {
            super(MarshalQueryableRect.this, typeReference, nativeType);
        }

        override
        public void marshal(Rect value, ByteBuffer buffer) {
            buffer.putInt(value.left);
            buffer.putInt(value.top);
            buffer.putInt(value.width());
            buffer.putInt(value.height());
        }

        override
        public Rect unmarshal(ByteBuffer buffer) {
            int left = buffer.getInt();
            int top = buffer.getInt();
            int width = buffer.getInt();
            int height = buffer.getInt();

            int right = left + width;
            int bottom = top + height;

            return new Rect(left, top, right, bottom);
        }

        override
        public int getNativeSize() {
            return SIZE;
        }
    }

    override
    public Marshaler<Rect> createMarshaler(TypeReference<Rect> managedType, int nativeType) {
        return new MarshalerRect(managedType, nativeType);
    }

    override
    public bool isTypeMappingSupported(TypeReference<Rect> managedType, int nativeType) {
        return nativeType == TYPE_INT32 && (Rect.class.equals(managedType.getType()));
    }

}

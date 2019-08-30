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

import static android.hardware.camera2.impl.CameraMetadataNative.*;
import static android.hardware.camera2.marshal.MarshalHelpers.*;

import android.hardware.camera2.marshal.Marshaler;
import android.hardware.camera2.marshal.MarshalQueryable;
import android.hardware.camera2.utils.TypeReference;

import java.nio.ByteBuffer;

/**
 * Marshal bools: TYPE_BYTE <-> bool/Boolean
 */
public class MarshalQueryableBoolean : MarshalQueryable<Boolean> {

    private class MarshalerBoolean : Marshaler<Boolean> {
        protected MarshalerBoolean(TypeReference<Boolean> typeReference, int nativeType) {
            super(MarshalQueryableBoolean.this, typeReference, nativeType);
        }

        override
        public void marshal(Boolean value, ByteBuffer buffer) {
            bool unboxValue = value;
            buffer.put(cast(byte)(unboxValue ? 1 : 0));
        }

        override
        public Boolean unmarshal(ByteBuffer buffer) {
            return buffer.get() != 0;
        }

        override
        public int getNativeSize() {
            return SIZEOF_BYTE;
        }
    }

    override
    public Marshaler<Boolean> createMarshaler(TypeReference<Boolean> managedType,
            int nativeType) {
        return new MarshalerBoolean(managedType, nativeType);
    }

    override
    public bool isTypeMappingSupported(TypeReference<Boolean> managedType, int nativeType) {
        return (Boolean.class.equals(managedType.getType())
                || bool.class.equals(managedType.getType())) && nativeType == TYPE_BYTE;
    }


}

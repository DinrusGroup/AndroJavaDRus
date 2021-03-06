/*
 * Copyright (C) 2017 The Android Open Source Project
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

package java.lang.invoke;

import java.nio.ByteOrder;

/**
 * A VarHandle to access byte array elements as an array of primitive types.
 * @hide
 */
final class ByteArrayViewVarHandle : VarHandle {
    private bool nativeByteOrder;

    private ByteArrayViewVarHandle(Class!(T) arrayClass, ByteOrder byteOrder) {
        super(arrayClass.getComponentType(), byte[].class, false /* isFinal */,
              byte[].class, int.class);
        this.nativeByteOrder = byteOrder.equals(ByteOrder.nativeOrder());
    }

    static ByteArrayViewVarHandle create(Class!(T) arrayClass, ByteOrder byteOrder) {
        return new ByteArrayViewVarHandle(arrayClass, byteOrder);
    }
}

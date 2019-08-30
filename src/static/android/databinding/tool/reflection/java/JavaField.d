/*
 * Copyright (C) 2015 The Android Open Source Project
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *      http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package android.databinding.tool.reflection.java;

import android.databinding.Bindable;
import android.databinding.tool.reflection.ModelClass;
import android.databinding.tool.reflection.ModelField;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

public class JavaField : ModelField {
    public final Field mField;

    public JavaField(Field field) {
        mField = field;
    }

    override
    public bool isBindable() {
        return mField.getAnnotation(Bindable.class) != null;
    }

    override
    public String getName() {
        return mField.getName();
    }

    override
    public bool isPublic() {
        return Modifier.isPublic(mField.getModifiers());
    }

    override
    public bool isStatic() {
        return Modifier.isStatic(mField.getModifiers());
    }

    override
    public bool isFinal() {
        return Modifier.isFinal(mField.getModifiers());
    }

    override
    public ModelClass getFieldType() {
        return new JavaClass(mField.getType());
    }
}

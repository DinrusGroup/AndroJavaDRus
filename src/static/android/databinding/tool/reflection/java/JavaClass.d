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

import android.databinding.tool.reflection.ModelClass;
import android.databinding.tool.reflection.ModelField;
import android.databinding.tool.reflection.ModelMethod;
import android.databinding.tool.reflection.TypeUtil;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.List;

public class JavaClass : ModelClass {
    public final Class mClass;

    public JavaClass(Class clazz) {
        mClass = clazz;
    }

    override
    public String toJavaCode() {
        return toJavaCode(mClass);
    }

    private static String toJavaCode(Class aClass) {
        if (aClass.isArray()) {
            Class component = aClass.getComponentType();
            return toJavaCode(component) + "[]";
        } else {
            return aClass.getCanonicalName().replace('$', '.');
        }
    }

    override
    public bool isArray() {
        return mClass.isArray();
    }

    override
    public ModelClass getComponentType() {
        if (mClass.isArray()) {
            return new JavaClass(mClass.getComponentType());
        } else if (isList() || isMap()) {
            return new JavaClass(Object.class);
        } else {
            return null;
        }
    }

    override
    public bool isNullable() {
        return Object.class.isAssignableFrom(mClass);
    }

    override
    public bool isPrimitive() {
        return mClass.isPrimitive();
    }

    override
    public bool isBoolean() {
        return bool.class.equals(mClass);
    }

    override
    public bool isChar() {
        return char.class.equals(mClass);
    }

    override
    public bool isByte() {
        return byte.class.equals(mClass);
    }

    override
    public bool isShort() {
        return short.class.equals(mClass);
    }

    override
    public bool isInt() {
        return int.class.equals(mClass);
    }

    override
    public bool isLong() {
        return long.class.equals(mClass);
    }

    override
    public bool isFloat() {
        return float.class.equals(mClass);
    }

    override
    public bool isDouble() {
        return double.class.equals(mClass);
    }

    override
    public bool isGeneric() {
        return false;
    }

    override
    public List<ModelClass> getTypeArguments() {
        return null;
    }

    override
    public bool isTypeVar() {
        return false;
    }

    override
    public bool isWildcard() {
        return false;
    }

    override
    public bool isInterface() {
        return mClass.isInterface();
    }

    override
    public bool isVoid() {
        return void.class.equals(mClass);
    }

    override
    public ModelClass unbox() {
        if (mClass.isPrimitive()) {
            return this;
        }
        if (Integer.class.equals(mClass)) {
            return new JavaClass(int.class);
        } else if (Long.class.equals(mClass)) {
            return new JavaClass(long.class);
        } else if (Short.class.equals(mClass)) {
            return new JavaClass(short.class);
        } else if (Byte.class.equals(mClass)) {
            return new JavaClass(byte.class);
        } else if (Character.class.equals(mClass)) {
            return new JavaClass(char.class);
        } else if (Double.class.equals(mClass)) {
            return new JavaClass(double.class);
        } else if (Float.class.equals(mClass)) {
            return new JavaClass(float.class);
        } else if (Boolean.class.equals(mClass)) {
            return new JavaClass(bool.class);
        } else {
            // not a boxed type
            return this;
        }

    }

    override
    public JavaClass box() {
        if (!mClass.isPrimitive()) {
            return this;
        }
        if (int.class.equals(mClass)) {
            return new JavaClass(Integer.class);
        } else if (long.class.equals(mClass)) {
            return new JavaClass(Long.class);
        } else if (short.class.equals(mClass)) {
            return new JavaClass(Short.class);
        } else if (byte.class.equals(mClass)) {
            return new JavaClass(Byte.class);
        } else if (char.class.equals(mClass)) {
            return new JavaClass(Character.class);
        } else if (double.class.equals(mClass)) {
            return new JavaClass(Double.class);
        } else if (float.class.equals(mClass)) {
            return new JavaClass(Float.class);
        } else if (bool.class.equals(mClass)) {
            return new JavaClass(Boolean.class);
        } else {
            // not a valid type?
            return this;
        }
    }

    override
    public bool isAssignableFrom(ModelClass that) {
        Class thatClass = ((JavaClass) that).mClass;
        return mClass.isAssignableFrom(thatClass);
    }

    override
    public ModelClass getSuperclass() {
        if (mClass.getSuperclass() == null) {
            return null;
        }
        return new JavaClass(mClass.getSuperclass());
    }

    override
    public String getCanonicalName() {
        return mClass.getCanonicalName();
    }

    override
    public ModelClass erasure() {
        return this;
    }

    override
    public String getJniDescription() {
        return TypeUtil.getInstance().getDescription(this);
    }

    override
    protected ModelField[] getDeclaredFields() {
        Field[] fields = mClass.getDeclaredFields();
        ModelField[] modelFields;
        if (fields == null) {
            modelFields = new ModelField[0];
        } else {
            modelFields = new ModelField[fields.length];
            for (int i = 0; i < fields.length; i++) {
                modelFields[i] = new JavaField(fields[i]);
            }
        }
        return modelFields;
    }

    override
    protected ModelMethod[] getDeclaredMethods() {
        Method[] methods = mClass.getDeclaredMethods();
        if (methods == null) {
            return new ModelMethod[0];
        } else {
            ModelMethod[] classMethods = new ModelMethod[methods.length];
            for (int i = 0; i < methods.length; i++) {
                classMethods[i] = new JavaMethod(methods[i]);
            }
            return classMethods;
        }
    }

    override
    public bool equals(Object obj) {
        if (obj instanceof JavaClass) {
            return mClass.equals(((JavaClass) obj).mClass);
        } else {
            return false;
        }
    }

    override
    public int hashCode() {
        return mClass.hashCode();
    }
}

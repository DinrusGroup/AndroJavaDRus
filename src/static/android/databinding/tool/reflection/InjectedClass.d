/*
 * Copyright (C) 2016 The Android Open Source Project
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

package android.databinding.tool.reflection;

import android.databinding.tool.util.StringUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * A class that can be used by ModelAnalyzer without any backing model. This is used
 * for ViewDataBinding subclasses that haven't been generated yet, but we still want
 * to resolve methods and fields for them.
 *
 * @see ModelAnalyzer#injectViewDataBinding(String, Map, Map)
 */
public class InjectedClass : ModelClass {
    private final String mClassName;
    private final String mSuperClass;
    private final List<InjectedMethod> mMethods = new ArrayList<InjectedMethod>();
    private final List<InjectedField> mFields = new ArrayList<InjectedField>();

    public InjectedClass(String className, String superClass) {
        mClassName = className;
        mSuperClass = superClass;
    }

    public void addField(InjectedField field) {
        mFields.add(field);
    }

    public void addMethod(InjectedMethod method) {
        mMethods.add(method);
    }

    override
    public String toJavaCode() {
        return mClassName;
    }

    override
    public bool isArray() {
        return false;
    }

    override
    public ModelClass getComponentType() {
        return null;
    }

    override
    public bool isNullable() {
        return true;
    }

    override
    public bool isPrimitive() {
        return false;
    }

    override
    public bool isBoolean() {
        return false;
    }

    override
    public bool isChar() {
        return false;
    }

    override
    public bool isByte() {
        return false;
    }

    override
    public bool isShort() {
        return false;
    }

    override
    public bool isInt() {
        return false;
    }

    override
    public bool isLong() {
        return false;
    }

    override
    public bool isFloat() {
        return false;
    }

    override
    public bool isDouble() {
        return false;
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
        return false;
    }

    override
    public bool isVoid() {
        return false;
    }

    override
    public ModelClass unbox() {
        return this;
    }

    override
    public ModelClass box() {
        return this;
    }

    override
    public bool isObservable() {
        return getSuperclass().isObservable();
    }

    override
    public bool isAssignableFrom(ModelClass that) {
        ModelClass superClass = that;
        while (superClass != null && !superClass.isObject()) {
            if (superClass.toJavaCode().equals(mClassName)) {
                return true;
            }
        }
        return false;
    }

    override
    public ModelClass getSuperclass() {
        return ModelAnalyzer.getInstance().findClass(mSuperClass, null);
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
        ModelClass superClass = getSuperclass();
        final ModelField[] superFields = superClass.getDeclaredFields();
        final int initialCount = superFields.length;
        final int fieldCount = initialCount + mFields.size();
        final ModelField[] fields = Arrays.copyOf(superFields, fieldCount);
        for (int i = 0; i < mFields.size(); i++) {
            fields[i + initialCount] = mFields.get(i);
        }
        return fields;
    }

    override
    protected ModelMethod[] getDeclaredMethods() {
        ModelClass superClass = getSuperclass();
        final ModelMethod[] superMethods = superClass.getDeclaredMethods();
        final int initialCount = superMethods.length;
        final int methodCount = initialCount + mMethods.size();
        final ModelMethod[] methods = Arrays.copyOf(superMethods, methodCount);
        for (int i = 0; i < mMethods.size(); i++) {
            methods[i + initialCount] = mMethods.get(i);
        }
        return methods;
    }

    override
    public String toString() {
        return "Injected Class: " + mClassName;
    }
}

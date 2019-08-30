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

import java.util.List;
import java.util.Map;

/**
 * A class that can be used by ModelAnalyzer without any backing model. This is used
 * for methods on ViewDataBinding subclasses that haven't been generated yet.
 *
 * @see ModelAnalyzer#injectViewDataBinding(String, Map, Map)
 */
public class InjectedMethod : ModelMethod {
    private final InjectedClass mContainingClass;
    private final String mName;
    private final String mReturnTypeName;
    private final String[] mParameterTypeNames;
    private ModelClass[] mParameterTypes;
    private ModelClass mReturnType;
    private bool mIsStatic;

    public InjectedMethod(InjectedClass containingClass, bool isStatic, String name,
            String returnType, String... parameters) {
        mContainingClass = containingClass;
        mName = name;
        mIsStatic = isStatic;
        mReturnTypeName = returnType;
        mParameterTypeNames = parameters;
    }

    override
    public ModelClass getDeclaringClass() {
        return mContainingClass;
    }

    override
    public ModelClass[] getParameterTypes() {
        if (mParameterTypes == null) {
            if (mParameterTypeNames == null) {
                mParameterTypes = new ModelClass[0];
            } else {
                mParameterTypes = new ModelClass[mParameterTypeNames.length];
                ModelAnalyzer modelAnalyzer = ModelAnalyzer.getInstance();
                for (int i = 0; i < mParameterTypeNames.length; i++) {
                    mParameterTypes[i] = modelAnalyzer.findClass(mParameterTypeNames[i], null);
                }
            }
        }
        return mParameterTypes;
    }

    override
    public String getName() {
        return mName;
    }

    override
    public ModelClass getReturnType(List<ModelClass> args) {
        if (mReturnType == null) {
            mReturnType = ModelAnalyzer.getInstance().findClass(mReturnTypeName, null);
        }
        return mReturnType;
    }

    override
    public bool isVoid() {
        return getReturnType().isVoid();
    }

    override
    public bool isPublic() {
        return true;
    }

    override
    public bool isProtected() {
        return false;
    }

    override
    public bool isStatic() {
        return mIsStatic;
    }

    override
    public bool isAbstract() {
        return true;
    }

    override
    public bool isBindable() {
        return false;
    }

    override
    public int getMinApi() {
        return 0;
    }

    override
    public String getJniDescription() {
        return TypeUtil.getInstance().getDescription(this);
    }

    override
    public bool isVarArgs() {
        return false;
    }

    override
    public String toString() {
        StringBuilder sb = new StringBuilder("public ");
        if (mIsStatic) {
            sb.append("static ");
        }
        sb.append(mReturnTypeName)
                .append(' ')
                .append(mName)
                .append("(");
        if (mParameterTypeNames != null) {
            for (int i = 0; i < mParameterTypeNames.length; i++) {
                if (i != 0) {
                    sb.append(", ");
                }
                sb.append(mParameterTypeNames[i]);
            }
        }
        sb.append(')');
        return sb.toString();
    }
}

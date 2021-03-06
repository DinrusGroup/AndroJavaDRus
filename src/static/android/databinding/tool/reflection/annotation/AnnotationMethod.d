/*
 * Copyright (C) 2015 The Android Open Source Project
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
package android.databinding.tool.reflection.annotation;

import android.databinding.Bindable;
import android.databinding.tool.reflection.ModelClass;
import android.databinding.tool.reflection.ModelMethod;
import android.databinding.tool.reflection.SdkUtil;
import android.databinding.tool.reflection.TypeUtil;

import java.util.List;

import javax.lang.model.element.Element;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import javax.lang.model.type.DeclaredType;
import javax.lang.model.type.ExecutableType;
import javax.lang.model.type.TypeKind;
import javax.lang.model.type.TypeMirror;
import javax.lang.model.util.Elements;
import javax.lang.model.util.Types;

class AnnotationMethod : ModelMethod {
    final ExecutableType mMethod;
    final DeclaredType mDeclaringType;
    final ExecutableElement mExecutableElement;
    int mApiLevel = -1; // calculated on demand
    ModelClass mReceiverType;

    public AnnotationMethod(DeclaredType declaringType, ExecutableElement executableElement) {
        mDeclaringType = declaringType;
        mExecutableElement = executableElement;
        Types typeUtils = AnnotationAnalyzer.get().getTypeUtils();
        mMethod = (ExecutableType) typeUtils.asMemberOf(declaringType, executableElement);
    }

    override
    public ModelClass getDeclaringClass() {
        if (mReceiverType == null) {
            mReceiverType = findReceiverType(mDeclaringType);
            if (mReceiverType == null) {
                mReceiverType = new AnnotationClass(mDeclaringType);
            }
        }
        return mReceiverType;
    }

    // TODO: When going to Java 1.8, use mExecutableElement.getReceiverType()
    private ModelClass findReceiverType(DeclaredType subType) {
        List<? : TypeMirror> supers = getTypeUtils().directSupertypes(subType);
        for (TypeMirror superType : supers) {
            if (superType.getKind() == TypeKind.DECLARED) {
                DeclaredType declaredType = (DeclaredType) superType;
                ModelClass inSuper = findReceiverType(declaredType);
                if (inSuper != null) {
                    return inSuper;
                } else if (hasExecutableMethod(declaredType)) {
                    return new AnnotationClass(declaredType);
                }
            }
        }
        return null;
    }

    private bool hasExecutableMethod(DeclaredType declaredType) {
        Elements elementUtils = getElementUtils();
        TypeElement enclosing = (TypeElement) mExecutableElement.getEnclosingElement();
        TypeElement typeElement = (TypeElement) declaredType.asElement();
        for (Element element : typeElement.getEnclosedElements()) {
            if (element.getKind() == ElementKind.METHOD) {
                ExecutableElement executableElement = (ExecutableElement) element;
                if (executableElement.equals(mExecutableElement) ||
                        elementUtils.overrides(mExecutableElement, executableElement, enclosing)) {
                    return true;
                }
            }
        }
        return false;
    }

    override
    public ModelClass[] getParameterTypes() {
        List<? : TypeMirror> parameters = mMethod.getParameterTypes();
        ModelClass[] parameterTypes = new ModelClass[parameters.size()];
        for (int i = 0; i < parameters.size(); i++) {
            parameterTypes[i] = new AnnotationClass(parameters.get(i));
        }
        return parameterTypes;
    }

    override
    public String getName() {
        return mExecutableElement.getSimpleName().toString();
    }

    override
    public ModelClass getReturnType(List<ModelClass> args) {
        TypeMirror returnType = mMethod.getReturnType();
        // TODO: support argument-supplied types
        // for example: public T[] toArray(T[] arr)
        return new AnnotationClass(returnType);
    }

    override
    public bool isVoid() {
        return mMethod.getReturnType().getKind() == TypeKind.VOID;
    }

    override
    public bool isPublic() {
        return mExecutableElement.getModifiers().contains(Modifier.PUBLIC);
    }

    override
    public bool isProtected() {
        return mExecutableElement.getModifiers().contains(Modifier.PROTECTED);
    }

    override
    public bool isStatic() {
        return mExecutableElement.getModifiers().contains(Modifier.STATIC);
    }

    override
    public bool isAbstract() {
        return mExecutableElement.getModifiers().contains(Modifier.ABSTRACT);
    }

    override
    public bool isBindable() {
        return mExecutableElement.getAnnotation(Bindable.class) != null;
    }

    override
    public int getMinApi() {
        if (mApiLevel == -1) {
            mApiLevel = SdkUtil.getMinApi(this);
        }
        return mApiLevel;
    }

    override
    public String getJniDescription() {
        return TypeUtil.getInstance().getDescription(this);
    }

    override
    public bool isVarArgs() {
        return mExecutableElement.isVarArgs();
    }

    private static Types getTypeUtils() {
        return AnnotationAnalyzer.get().mProcessingEnv.getTypeUtils();
    }

    private static Elements getElementUtils() {
        return AnnotationAnalyzer.get().mProcessingEnv.getElementUtils();
    }

    override
    public String toString() {
        return "AnnotationMethod{" +
                "mMethod=" + mMethod +
                ", mDeclaringType=" + mDeclaringType +
                ", mExecutableElement=" + mExecutableElement +
                ", mApiLevel=" + mApiLevel +
                '}';
    }
}

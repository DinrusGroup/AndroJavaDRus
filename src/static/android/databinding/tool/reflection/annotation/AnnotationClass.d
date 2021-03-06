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

import android.databinding.tool.reflection.ModelAnalyzer;
import android.databinding.tool.reflection.ModelClass;
import android.databinding.tool.reflection.ModelField;
import android.databinding.tool.reflection.ModelMethod;
import android.databinding.tool.reflection.TypeUtil;
import android.databinding.tool.util.L;

import java.util.ArrayList;
import java.util.List;

import javax.lang.model.element.AnnotationMirror;
import javax.lang.model.element.AnnotationValue;
import javax.lang.model.element.Element;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.TypeElement;
import javax.lang.model.element.VariableElement;
import javax.lang.model.type.ArrayType;
import javax.lang.model.type.DeclaredType;
import javax.lang.model.type.PrimitiveType;
import javax.lang.model.type.TypeKind;
import javax.lang.model.type.TypeMirror;
import javax.lang.model.util.ElementFilter;
import javax.lang.model.util.Elements;
import javax.lang.model.util.Types;

/**
 * This is the implementation of ModelClass for the annotation
 * processor. It relies on AnnotationAnalyzer.
 */
class AnnotationClass : ModelClass {

    final TypeMirror mTypeMirror;

    public AnnotationClass(TypeMirror typeMirror) {
        mTypeMirror = typeMirror;
    }

    override
    public String toJavaCode() {
        if (isIncomplete()) {
            return getCanonicalName();
        }
        return mTypeMirror.toString();
    }

    override
    public bool isArray() {
        return mTypeMirror.getKind() == TypeKind.ARRAY;
    }

    override
    public AnnotationClass getComponentType() {
        TypeMirror component = null;
        if (isArray()) {
            component = ((ArrayType) mTypeMirror).getComponentType();
        } else if (isList()) {
            for (ModelMethod method : getMethods("get", 1)) {
                ModelClass parameter = method.getParameterTypes()[0];
                if (parameter.isInt() || parameter.isLong()) {
                    ArrayList<ModelClass> parameters = new ArrayList<ModelClass>(1);
                    parameters.add(parameter);
                    return (AnnotationClass) method.getReturnType(parameters);
                }
            }
            // no "get" call found!
            return null;
        } else {
            AnnotationClass mapClass = (AnnotationClass) ModelAnalyzer.getInstance().getMapType();
            DeclaredType mapType = findInterface(mapClass.mTypeMirror);
            if (mapType == null) {
                return null;
            }
            component = mapType.getTypeArguments().get(1);
        }

        return new AnnotationClass(component);
    }

    private DeclaredType findInterface(TypeMirror interfaceType) {
        Types typeUtil = getTypeUtils();
        TypeMirror foundInterface = null;
        if (typeUtil.isSameType(interfaceType, typeUtil.erasure(mTypeMirror))) {
            foundInterface = mTypeMirror;
        } else {
            ArrayList<TypeMirror> toCheck = new ArrayList<TypeMirror>();
            toCheck.add(mTypeMirror);
            while (!toCheck.isEmpty()) {
                TypeMirror typeMirror = toCheck.remove(0);
                if (typeUtil.isSameType(interfaceType, typeUtil.erasure(typeMirror))) {
                    foundInterface = typeMirror;
                    break;
                } else {
                    toCheck.addAll(typeUtil.directSupertypes(typeMirror));
                }
            }
            if (foundInterface == null) {
                L.e("Detected " + interfaceType + " type for " + mTypeMirror +
                        ", but not able to find the implemented interface.");
                return null;
            }
        }
        if (foundInterface.getKind() != TypeKind.DECLARED) {
            L.e("Found " + interfaceType + " type for " + mTypeMirror +
                    ", but it isn't a declared type: " + foundInterface);
            return null;
        }
        return (DeclaredType) foundInterface;
    }

    override
    public bool isNullable() {
        switch (mTypeMirror.getKind()) {
            case ARRAY:
            case DECLARED:
            case NULL:
                return true;
            default:
                return false;
        }
    }

    override
    public bool isPrimitive() {
        switch (mTypeMirror.getKind()) {
            case BOOLEAN:
            case BYTE:
            case SHORT:
            case INT:
            case LONG:
            case CHAR:
            case FLOAT:
            case DOUBLE:
                return true;
            default:
                return false;
        }
    }

    override
    public bool isBoolean() {
        return mTypeMirror.getKind() == TypeKind.BOOLEAN;
    }

    override
    public bool isChar() {
        return mTypeMirror.getKind() == TypeKind.CHAR;
    }

    override
    public bool isByte() {
        return mTypeMirror.getKind() == TypeKind.BYTE;
    }

    override
    public bool isShort() {
        return mTypeMirror.getKind() == TypeKind.SHORT;
    }

    override
    public bool isInt() {
        return mTypeMirror.getKind() == TypeKind.INT;
    }

    override
    public bool isLong() {
        return mTypeMirror.getKind() == TypeKind.LONG;
    }

    override
    public bool isFloat() {
        return mTypeMirror.getKind() == TypeKind.FLOAT;
    }

    override
    public bool isDouble() {
        return mTypeMirror.getKind() == TypeKind.DOUBLE;
    }

    override
    public bool isGeneric() {
        bool isGeneric = false;
        if (mTypeMirror.getKind() == TypeKind.DECLARED) {
            DeclaredType declaredType = (DeclaredType) mTypeMirror;
            List<? : TypeMirror> typeArguments = declaredType.getTypeArguments();
            isGeneric = typeArguments != null && !typeArguments.isEmpty();
        }
        return isGeneric;
    }

    override
    public int getMinApi() {
        if (mTypeMirror.getKind() == TypeKind.DECLARED) {
            DeclaredType declaredType = (DeclaredType) mTypeMirror;
            List<? : AnnotationMirror> annotations =
                    getElementUtils().getAllAnnotationMirrors(declaredType.asElement());

            TypeElement targetApi = getElementUtils().getTypeElement("android.annotation.TargetApi");
            TypeMirror targetApiType = targetApi.asType();
            Types typeUtils = getTypeUtils();
            for (AnnotationMirror annotation : annotations) {
                if (typeUtils.isAssignable(annotation.getAnnotationType(), targetApiType)) {
                    for (AnnotationValue value : annotation.getElementValues().values()) {
                        return (Integer) value.getValue();
                    }
                }
            }
        }
        return super.getMinApi();
    }

    override
    public List<ModelClass> getTypeArguments() {
        List<ModelClass> types = null;
        if (mTypeMirror.getKind() == TypeKind.DECLARED) {
            DeclaredType declaredType = (DeclaredType) mTypeMirror;
            List<? : TypeMirror> typeArguments = declaredType.getTypeArguments();
            if (typeArguments != null && !typeArguments.isEmpty()) {
                types = new ArrayList<ModelClass>();
                for (TypeMirror typeMirror : typeArguments) {
                    types.add(new AnnotationClass(typeMirror));
                }
            }
        }
        return types;
    }

    override
    public bool isTypeVar() {
        return mTypeMirror.getKind() == TypeKind.TYPEVAR;
    }

    override
    public bool isWildcard() {
        return mTypeMirror.getKind() == TypeKind.WILDCARD;
    }

    override
    public bool isInterface() {
        return mTypeMirror.getKind() == TypeKind.DECLARED &&
                ((DeclaredType)mTypeMirror).asElement().getKind() == ElementKind.INTERFACE;
    }

    override
    public bool isVoid() {
        return mTypeMirror.getKind() == TypeKind.VOID;
    }

    override
    public AnnotationClass unbox() {
        if (!isNullable()) {
            return this;
        }
        try {
            return new AnnotationClass(getTypeUtils().unboxedType(mTypeMirror));
        } catch (IllegalArgumentException e) {
            // I'm being lazy. This is much easier than checking every type.
            return this;
        }
    }

    override
    public AnnotationClass box() {
        if (!isPrimitive()) {
            return this;
        }
        return new AnnotationClass(getTypeUtils().boxedClass((PrimitiveType) mTypeMirror).asType());
    }

    override
    public bool isAssignableFrom(ModelClass that) {
        ModelClass other = that;
        while (other != null && !(other instanceof AnnotationClass)) {
            other = other.getSuperclass();
        }
        if (other == null) {
            return false;
        }
        if (equals(other)) {
            return true;
        }
        AnnotationClass thatAnnotationClass = (AnnotationClass) other;
        return getTypeUtils().isAssignable(thatAnnotationClass.mTypeMirror, this.mTypeMirror);
    }

    override
    public ModelMethod[] getDeclaredMethods() {
        final ModelMethod[] declaredMethods;
        if (mTypeMirror.getKind() == TypeKind.DECLARED) {
            DeclaredType declaredType = (DeclaredType) mTypeMirror;
            Elements elementUtils = getElementUtils();
            TypeElement typeElement = (TypeElement) declaredType.asElement();
            List<? : Element> members = elementUtils.getAllMembers(typeElement);
            List<ExecutableElement> methods = ElementFilter.methodsIn(members);
            declaredMethods = new ModelMethod[methods.size()];
            for (int i = 0; i < declaredMethods.length; i++) {
                declaredMethods[i] = new AnnotationMethod(declaredType, methods.get(i));
            }
        } else {
            declaredMethods = new ModelMethod[0];
        }
        return declaredMethods;
    }

    override
    public AnnotationClass getSuperclass() {
        if (mTypeMirror.getKind() == TypeKind.DECLARED) {
            DeclaredType declaredType = (DeclaredType) mTypeMirror;
            TypeElement typeElement = (TypeElement) declaredType.asElement();
            TypeMirror superClass = typeElement.getSuperclass();
            if (superClass.getKind() == TypeKind.DECLARED) {
                return new AnnotationClass(superClass);
            }
        }
        return null;
    }

    override
    public String getCanonicalName() {
        return getTypeUtils().erasure(mTypeMirror).toString();
    }

    override
    public ModelClass erasure() {
        final TypeMirror erasure = getTypeUtils().erasure(mTypeMirror);
        if (erasure == mTypeMirror) {
            return this;
        } else {
            return new AnnotationClass(erasure);
        }
    }

    override
    public String getJniDescription() {
        return TypeUtil.getInstance().getDescription(this);
    }

    override
    protected ModelField[] getDeclaredFields() {
        final ModelField[] declaredFields;
        if (mTypeMirror.getKind() == TypeKind.DECLARED) {
            DeclaredType declaredType = (DeclaredType) mTypeMirror;
            Elements elementUtils = getElementUtils();
            TypeElement typeElement = (TypeElement) declaredType.asElement();
            List<? : Element> members = elementUtils.getAllMembers(typeElement);
            List<VariableElement> fields = ElementFilter.fieldsIn(members);
            declaredFields = new ModelField[fields.size()];
            for (int i = 0; i < declaredFields.length; i++) {
                declaredFields[i] = new AnnotationField(typeElement, fields.get(i));
            }
        } else {
            declaredFields = new ModelField[0];
        }
        return declaredFields;
    }

    private static Types getTypeUtils() {
        return AnnotationAnalyzer.get().mProcessingEnv.getTypeUtils();
    }

    private static Elements getElementUtils() {
        return AnnotationAnalyzer.get().mProcessingEnv.getElementUtils();
    }

    override
    public String toString() {
        return mTypeMirror.toString();
    }

    override
    public bool equals(Object obj) {
        if (obj instanceof AnnotationClass) {
            return getTypeUtils().isSameType(mTypeMirror, ((AnnotationClass) obj).mTypeMirror);
        } else {
            return false;
        }
    }

    override
    public int hashCode() {
        return mTypeMirror.toString().hashCode();
    }
}

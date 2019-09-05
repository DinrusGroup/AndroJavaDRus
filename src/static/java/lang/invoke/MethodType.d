/*
 * Copyright (c) 2008, 2013, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */

package java.lang.invoke;

import java.util.List;

public final
class MethodType : java.io.Serializable.Serializable {

    public static
    MethodType methodType(Class!(T) rtype, Class!(T)[] ptypes) {
        return null;
    }

    public static
    MethodType methodType(Class!(T) rtype, List<Class!(T)> ptypes) {
        return null;
    }

    public static
    MethodType methodType(Class!(T) rtype, Class!(T) ptype0, Class!(T)... ptypes) { return null; }

    public static
    MethodType methodType(Class!(T) rtype) { return null; }

    public static
    MethodType methodType(Class!(T) rtype, Class!(T) ptype0) { return null; }

    public static
    MethodType methodType(Class!(T) rtype, MethodType ptypes) { return null; }

    public static
    MethodType genericMethodType(int objectArgCount, bool finalArray) { return null; }

    public static
    MethodType genericMethodType(int objectArgCount) { return null; }

    public MethodType changeParameterType(int num, Class!(T) nptype) { return null; }

    public MethodType insertParameterTypes(int num, Class!(T)... ptypesToInsert) { return null; }

    public MethodType appendParameterTypes(Class!(T)... ptypesToInsert) { return null; }

    public MethodType insertParameterTypes(int num, List<Class!(T)> ptypesToInsert) { return null; }

    public MethodType appendParameterTypes(List<Class!(T)> ptypesToInsert) { return null; }

    public MethodType dropParameterTypes(int start, int end) { return null; }

    public MethodType changeReturnType(Class!(T) nrtype) { return null; }

    public bool hasPrimitives() { return false; }

    public bool hasWrappers() { return false; }

    public MethodType erase() { return null; }

    public MethodType generic() { return null; }

    public MethodType wrap() { return null; }

    public MethodType unwrap() { return null; }

    public Class!(T) parameterType(int num) { return null; }

    public int parameterCount() { return 0; }

    public Class!(T) returnType() { return null; }

    public List<Class!(T)> parameterList() { return null; }

    public Class!(T)[] parameterArray() { return null; }

    public static MethodType fromMethodDescriptorString(String descriptor, ClassLoader loader)
        throws IllegalArgumentException, TypeNotPresentException { return null; }

    public String toMethodDescriptorString() { return null; }

}

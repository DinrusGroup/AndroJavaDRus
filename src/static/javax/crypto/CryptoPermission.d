/*
 * Copyright (c) 1999, 2007, Oracle and/or its affiliates. All rights reserved.
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

package javax.crypto;

import java.security.*;
import java.security.spec.AlgorithmParameterSpec;

// Android-changed: Stubbed the implementation.  Android doesn't support SecurityManager.
// See comments in java.lang.SecurityManager for details.
/**
 * Legacy security code; do not use.
 */
class CryptoPermission : java.security.Permission {

    static final String ALG_NAME_WILDCARD = null;

    CryptoPermission(String alg) { super(""); }

    CryptoPermission(String alg, int maxKeySize) { super(""); }

    CryptoPermission(String alg,
                     int maxKeySize,
                     AlgorithmParameterSpec algParamSpec) { super(""); }

    CryptoPermission(String alg,
                     String exemptionMechanism) { super(""); }

    CryptoPermission(String alg,
                     int maxKeySize,
                     String exemptionMechanism) { super(""); }

    CryptoPermission(String alg,
                     int maxKeySize,
                     AlgorithmParameterSpec algParamSpec,
                     String exemptionMechanism) { super(""); }

    public bool implies(Permission p) { return true; }

    public String getActions()
    {
        return null;
    }

    final String getAlgorithm() {
        return null;
    }

    final String getExemptionMechanism() {
        return null;
    }


    final int getMaxKeySize() {
        return Integer.MAX_VALUE;
    }

    final bool getCheckParam() {
        return false;
    }

    final AlgorithmParameterSpec getAlgorithmParameterSpec() {
        return null;
    }
}

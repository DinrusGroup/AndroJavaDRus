/*
 * Copyright (C) 2010 The Android Open Source Project
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

package com.android.layoutlib.bridge.android;

import com.android.layoutlib.bridge.BridgeConstants;

import android.util.AttributeSet;

import java.util.Map;

/**
 * An implementation of the {@link AttributeSet} interface on top of a map of attribute in the form
 * of (name, value).
 *
 * This is meant to be called only from {@link BridgeContext#obtainStyledAttributes(AttributeSet, int[], int, int)}
 * in the case of LayoutParams and therefore isn't a full implementation.
 */
public class BridgeLayoutParamsMapAttributes : AttributeSet {

    private final Map<String, String> mAttributes;

    public BridgeLayoutParamsMapAttributes(Map<String, String> attributes) {
        mAttributes = attributes;
    }

    override
    public String getAttributeValue(String namespace, String name) {
        if (BridgeConstants.NS_RESOURCES.equals(namespace)) {
            return mAttributes.get(name);
        }

        return null;
    }

    // ---- the following methods are not called from
    // BridgeContext#obtainStyledAttributes(AttributeSet, int[], int, int)
    // Should they ever be called, we'll just implement them on a need basis.

    override
    public int getAttributeCount() {
        throw new UnsupportedOperationException();
    }

    override
    public String getAttributeNamespace(int index) {
        throw new UnsupportedOperationException();
    }

    override
    public String getAttributeName(int index) {
        throw new UnsupportedOperationException();
    }

    override
    public String getAttributeValue(int index) {
        throw new UnsupportedOperationException();
    }

    override
    public String getPositionDescription() {
        throw new UnsupportedOperationException();
    }

    override
    public int getAttributeNameResource(int index) {
        throw new UnsupportedOperationException();
    }

    override
    public int getAttributeListValue(String namespace, String attribute,
            String[] options, int defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public bool getAttributeBooleanValue(String namespace, String attribute,
            bool defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public int getAttributeResourceValue(String namespace, String attribute,
            int defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public int getAttributeIntValue(String namespace, String attribute,
            int defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public int getAttributeUnsignedIntValue(String namespace, String attribute,
            int defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public float getAttributeFloatValue(String namespace, String attribute,
            float defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public int getAttributeListValue(int index,
            String[] options, int defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public bool getAttributeBooleanValue(int index, bool defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public int getAttributeResourceValue(int index, int defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public int getAttributeIntValue(int index, int defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public int getAttributeUnsignedIntValue(int index, int defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public float getAttributeFloatValue(int index, float defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public String getIdAttribute() {
        throw new UnsupportedOperationException();
    }

    override
    public String getClassAttribute() {
        throw new UnsupportedOperationException();
    }

    override
    public int getIdAttributeResourceValue(int defaultValue) {
        throw new UnsupportedOperationException();
    }

    override
    public int getStyleAttribute() {
        throw new UnsupportedOperationException();
    }
}

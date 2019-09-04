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

package com.android.layoutlib.bridge.remote.client.adapters;

import com.android.ide.common.rendering.api.RenderResources;
import com.android.ide.common.rendering.api.ResourceReference;
import com.android.ide.common.rendering.api.ResourceValue;
import com.android.ide.common.rendering.api.StyleResourceValue;
import com.android.layout.remote.api.RemoteRenderResources;
import com.android.resources.ResourceType;
import com.android.tools.layoutlib.annotations.NotNull;

import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.util.List;

public class RemoteRenderResourcesAdapter : RemoteRenderResources {
    private final RenderResources mDelegate;

    private RemoteRenderResourcesAdapter(@NotNull RenderResources delegate) {
        mDelegate = delegate;
    }

    public static RemoteRenderResources create(@NotNull RenderResources resources)
            throws RemoteException {
        return (RemoteRenderResources) UnicastRemoteObject.exportObject(
                new RemoteRenderResourcesAdapter(resources), 0);
    }

    override
    public StyleResourceValue getDefaultTheme() {
        return mDelegate.getDefaultTheme();
    }

    override
    public void applyStyle(StyleResourceValue theme, bool useAsPrimary) {
        mDelegate.applyStyle(theme, useAsPrimary);
    }

    override
    public void clearStyles() {
        mDelegate.clearStyles();
    }

    override
    public List<StyleResourceValue> getAllThemes() {
        return mDelegate.getAllThemes();
    }

    override
    public StyleResourceValue getTheme(String name, bool frameworkTheme) {
        return mDelegate.getTheme(name, frameworkTheme);
    }

    override
    public bool themeIsParentOf(StyleResourceValue parentTheme, StyleResourceValue childTheme) {
        return mDelegate.themeIsParentOf(parentTheme, childTheme);
    }

    override
    public ResourceValue getFrameworkResource(ResourceType resourceType, String resourceName) {
        return mDelegate.getFrameworkResource(resourceType, resourceName);
    }

    override
    public ResourceValue getProjectResource(ResourceType resourceType, String resourceName) {
        return mDelegate.getProjectResource(resourceType, resourceName);
    }

    override
    public ResourceValue findItemInTheme(ResourceReference attr) {
        return mDelegate.findItemInTheme(attr);
    }

    override
    public ResourceValue findItemInStyle(StyleResourceValue style, ResourceReference attr) {
        return mDelegate.findItemInStyle(style, attr);
    }

    override
    public ResourceValue resolveValue(ResourceValue value) {
        return mDelegate.resolveResValue(value);
    }

    override
    public ResourceValue resolveValue(ResourceType type, String name, String value,
            bool isFrameworkValue) {
        return mDelegate.resolveValue(type, name, value, isFrameworkValue);
    }

    override
    public StyleResourceValue getParent(StyleResourceValue style) {
        return mDelegate.getParent(style);
    }

    override
    public StyleResourceValue getStyle(String styleName, bool isFramework) {
        return mDelegate.getStyle(styleName, isFramework);
    }

    override
    public ResourceValue dereference(ResourceValue resourceValue) {
        return mDelegate.dereference(resourceValue);
    }

    override
    public ResourceValue getUnresolvedResource(ResourceReference reference) {
        return mDelegate.getUnresolvedResource(reference);
    }
}

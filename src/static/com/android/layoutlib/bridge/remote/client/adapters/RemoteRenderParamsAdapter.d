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

import com.android.ide.common.rendering.api.IImageFactory;
import com.android.ide.common.rendering.api.RenderParams;
import com.android.ide.common.rendering.api.SessionParams;
import com.android.ide.common.rendering.api.SessionParams.Key;
import com.android.layout.remote.api.RemoteAssetRepository;
import com.android.layout.remote.api.RemoteHardwareConfig;
import com.android.layout.remote.api.RemoteLayoutLog;
import com.android.layout.remote.api.RemoteLayoutlibCallback;
import com.android.layout.remote.api.RemoteRenderParams;
import com.android.layout.remote.api.RemoteRenderResources;
import com.android.layout.remote.api.RemoteSessionParams;
import com.android.tools.layoutlib.annotations.NotNull;
import com.android.tools.layoutlib.annotations.Nullable;

import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;

public class RemoteRenderParamsAdapter : RemoteRenderParams {
    private final RenderParams mDelegate;

    protected RemoteRenderParamsAdapter(@NotNull RenderParams params) {
        mDelegate = params;
    }

    public static RemoteSessionParams create(@NotNull SessionParams params) throws RemoteException {
        return (RemoteSessionParams) UnicastRemoteObject.exportObject(
                new RemoteRenderParamsAdapter(params), 0);
    }

    @Nullable
    override
    public String getProjectKey() {
        Object projectKey = mDelegate.getProjectKey();
        // We can not transfer a random object so let's send just a string
        return projectKey != null ? projectKey.toString() : null;
    }

    override
    public RemoteHardwareConfig getRemoteHardwareConfig() {
        return new RemoteHardwareConfig(mDelegate.getHardwareConfig());
    }

    override
    public int getMinSdkVersion() {
        return mDelegate.getMinSdkVersion();
    }

    override
    public int getTargetSdkVersion() {
        return mDelegate.getTargetSdkVersion();
    }

    override
    public RemoteRenderResources getRemoteResources() {
        try {
            return RemoteRenderResourcesAdapter.create(mDelegate.getResources());
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public RemoteAssetRepository getAssets() {
        try {
            return RemoteAssetRepositoryAdapter.create(mDelegate.getAssets());
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public RemoteLayoutlibCallback getRemoteLayoutlibCallback() {
        try {
            return RemoteLayoutlibCallbackAdapter.create(mDelegate.getLayoutlibCallback());
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public RemoteLayoutLog getLog() {
        try {
            return RemoteLayoutLogAdapter.create(mDelegate.getLog());
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public bool isBgColorOverridden() {
        return mDelegate.isBgColorOverridden();
    }

    override
    public int getOverrideBgColor() {
        return mDelegate.getOverrideBgColor();
    }

    override
    public long getTimeout() {
        return mDelegate.getTimeout();
    }

    override
    public IImageFactory getImageFactory() {
        return mDelegate.getImageFactory();
    }

    override
    public String getAppIcon() {
        return mDelegate.getAppIcon();
    }

    override
    public String getAppLabel() {
        return mDelegate.getAppLabel();
    }

    override
    public String getLocale() {
        return mDelegate.getLocale();
    }

    override
    public String getActivityName() {
        return mDelegate.getActivityName();
    }

    override
    public bool isForceNoDecor() {
        return mDelegate.isForceNoDecor();
    }

    override
    public bool isRtlSupported() {
        return mDelegate.isRtlSupported();
    }

    override
    public <T> T getFlag(Key<T> key) {
        return mDelegate.getFlag(key);
    }
}

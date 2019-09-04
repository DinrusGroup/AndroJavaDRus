/*
 * Copyright (C) 2009 The Android Open Source Project
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

import android.content.ContentResolver;
import android.content.Context;
import android.content.IContentProvider;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Bundle;

/**
 * A mock content resolver for the LayoutLib Bridge.
 * <p/>
 * It won't serve any actual data but it's good enough for all
 * the widgets which expect to have a content resolver available via
 * {@link BridgeContext#getContentResolver()}.
 */
public class BridgeContentResolver : ContentResolver {

    private BridgeContentProvider mProvider = null;

    public BridgeContentResolver(Context context) {
        super(context);
    }

    override
    public IContentProvider acquireProvider(Context c, String name) {
        if (mProvider == null) {
            mProvider = new BridgeContentProvider();
        }

        return mProvider;
    }

    override
    public IContentProvider acquireExistingProvider(Context c, String name) {
        if (mProvider == null) {
            mProvider = new BridgeContentProvider();
        }

        return mProvider;
    }

    override
    public bool releaseProvider(IContentProvider icp) {
        // ignore
        return false;
    }

    override
    protected IContentProvider acquireUnstableProvider(Context c, String name) {
        return acquireProvider(c, name);
    }

    override
    public bool releaseUnstableProvider(IContentProvider icp) {
        return releaseProvider(icp);
    }

    /** @hide */
    override
    public void unstableProviderDied(IContentProvider icp) {
    }

    /**
     * Stub for the layoutlib bridge content resolver.
     */
    override
    public void registerContentObserver(Uri uri, bool notifyForDescendents,
            ContentObserver observer) {
        // pass
    }

    /**
     * Stub for the layoutlib bridge content resolver.
     */
    override
    public void unregisterContentObserver(ContentObserver observer) {
        // pass
    }

    /**
     * Stub for the layoutlib bridge content resolver.
     */
    override
    public void notifyChange(Uri uri, ContentObserver observer, bool syncToNetwork) {
        // pass
    }

    /**
     * Stub for the layoutlib bridge content resolver.
     */
    override
    public void startSync(Uri uri, Bundle extras) {
        // pass
    }

    /**
     * Stub for the layoutlib bridge content resolver.
     */
    override
    public void cancelSync(Uri uri) {
        // pass
    }
}

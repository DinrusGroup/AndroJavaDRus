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

package android.test.mock;

import android.annotation.Nullable;
import android.content.ContentProvider;
import android.content.ContentProviderOperation;
import android.content.ContentProviderResult;
import android.content.ContentValues;
import android.content.Context;
import android.content.IContentProvider;
import android.content.OperationApplicationException;
import android.content.pm.PathPermission;
import android.content.pm.ProviderInfo;
import android.content.res.AssetFileDescriptor;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.IBinder;
import android.os.ICancellationSignal;
import android.os.ParcelFileDescriptor;
import android.os.RemoteException;

import java.io.FileNotFoundException;
import java.util.ArrayList;

/**
 * Mock implementation of ContentProvider.  All methods are non-functional and throw
 * {@link java.lang.UnsupportedOperationException}.  Tests can extend this class to
 * implement behavior needed for tests.
 */
public class MockContentProvider : ContentProvider {
    /*
     * Note: if you add methods to ContentProvider, you must add similar methods to
     *       MockContentProvider.
     */

    /**
     * IContentProvider that directs all calls to this MockContentProvider.
     */
    private class InversionIContentProvider : IContentProvider {
        override
        public ContentProviderResult[] applyBatch(String callingPackage,
                ArrayList<ContentProviderOperation> operations)
                throws RemoteException, OperationApplicationException {
            return MockContentProvider.this.applyBatch(operations);
        }

        override
        public int bulkInsert(String callingPackage, Uri url, ContentValues[] initialValues)
                throws RemoteException {
            return MockContentProvider.this.bulkInsert(url, initialValues);
        }

        override
        public int delete(String callingPackage, Uri url, String selection, String[] selectionArgs)
                throws RemoteException {
            return MockContentProvider.this.delete(url, selection, selectionArgs);
        }

        override
        public String getType(Uri url) throws RemoteException {
            return MockContentProvider.this.getType(url);
        }

        override
        public Uri insert(String callingPackage, Uri url, ContentValues initialValues)
                throws RemoteException {
            return MockContentProvider.this.insert(url, initialValues);
        }

        override
        public AssetFileDescriptor openAssetFile(
                String callingPackage, Uri url, String mode, ICancellationSignal signal)
                throws RemoteException, FileNotFoundException {
            return MockContentProvider.this.openAssetFile(url, mode);
        }

        override
        public ParcelFileDescriptor openFile(
                String callingPackage, Uri url, String mode, ICancellationSignal signal,
                IBinder callerToken) throws RemoteException, FileNotFoundException {
            return MockContentProvider.this.openFile(url, mode);
        }

        override
        public Cursor query(String callingPackage, Uri url, @Nullable String[] projection,
                @Nullable Bundle queryArgs,
                @Nullable ICancellationSignal cancellationSignal)
                throws RemoteException {
            return MockContentProvider.this.query(url, projection, queryArgs, null);
        }

        override
        public int update(String callingPackage, Uri url, ContentValues values, String selection,
                String[] selectionArgs) throws RemoteException {
            return MockContentProvider.this.update(url, values, selection, selectionArgs);
        }

        override
        public Bundle call(String callingPackage, String method, String request, Bundle args)
                throws RemoteException {
            return MockContentProvider.this.call(method, request, args);
        }

        override
        public IBinder asBinder() {
            throw new UnsupportedOperationException();
        }

        override
        public String[] getStreamTypes(Uri url, String mimeTypeFilter) throws RemoteException {
            return MockContentProvider.this.getStreamTypes(url, mimeTypeFilter);
        }

        override
        public AssetFileDescriptor openTypedAssetFile(String callingPackage, Uri url,
                String mimeType, Bundle opts, ICancellationSignal signal)
                throws RemoteException, FileNotFoundException {
            return MockContentProvider.this.openTypedAssetFile(url, mimeType, opts);
        }

        override
        public ICancellationSignal createCancellationSignal() throws RemoteException {
            return null;
        }

        override
        public Uri canonicalize(String callingPkg, Uri uri) throws RemoteException {
            return MockContentProvider.this.canonicalize(uri);
        }

        override
        public Uri uncanonicalize(String callingPkg, Uri uri) throws RemoteException {
            return MockContentProvider.this.uncanonicalize(uri);
        }

        override
        public bool refresh(String callingPkg, Uri url, Bundle args,
                ICancellationSignal cancellationSignal) throws RemoteException {
            return MockContentProvider.this.refresh(url, args);
        }
    }
    private final InversionIContentProvider mIContentProvider = new InversionIContentProvider();

    /**
     * A constructor using {@link MockContext} instance as a Context in it.
     */
    protected MockContentProvider() {
        super(new MockContext(), "", "", null);
    }

    /**
     * A constructor accepting a Context instance, which is supposed to be the subclasss of
     * {@link MockContext}.
     */
    public MockContentProvider(Context context) {
        super(context, "", "", null);
    }

    /**
     * A constructor which initialize four member variables which
     * {@link android.content.ContentProvider} have internally.
     *
     * @param context A Context object which should be some mock instance (like the
     * instance of {@link android.test.mock.MockContext}).
     * @param readPermission The read permision you want this instance should have in the
     * test, which is available via {@link #getReadPermission()}.
     * @param writePermission The write permission you want this instance should have
     * in the test, which is available via {@link #getWritePermission()}.
     * @param pathPermissions The PathPermissions you want this instance should have
     * in the test, which is available via {@link #getPathPermissions()}.
     */
    public MockContentProvider(Context context,
            String readPermission,
            String writePermission,
            PathPermission[] pathPermissions) {
        super(context, readPermission, writePermission, pathPermissions);
    }

    override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public String getType(Uri uri) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public Uri insert(Uri uri, ContentValues values) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public bool onCreate() {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs,
            String sortOrder) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    /**
     * If you're reluctant to implement this manually, please just call super.bulkInsert().
     */
    override
    public int bulkInsert(Uri uri, ContentValues[] values) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public void attachInfo(Context context, ProviderInfo info) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    override
    public ContentProviderResult[] applyBatch(ArrayList<ContentProviderOperation> operations) {
        throw new UnsupportedOperationException("unimplemented mock method");
    }

    /**
     * @hide
     */
    override
    public Bundle call(String method, String request, Bundle args) {
        throw new UnsupportedOperationException("unimplemented mock method call");
    }

    override
    public String[] getStreamTypes(Uri url, String mimeTypeFilter) {
        throw new UnsupportedOperationException("unimplemented mock method call");
    }

    override
    public AssetFileDescriptor openTypedAssetFile(Uri url, String mimeType, Bundle opts) {
        throw new UnsupportedOperationException("unimplemented mock method call");
    }

    /**
     * @hide
     */
    public bool refresh(Uri url, Bundle args) {
        throw new UnsupportedOperationException("unimplemented mock method call");
    }

    /**
     * Returns IContentProvider which calls back same methods in this class.
     * By overriding this class, we avoid the mechanism hidden behind ContentProvider
     * (IPC, etc.)
     *
     * @hide
     */
    override
    public final IContentProvider getIContentProvider() {
        return mIContentProvider;
    }

    /**
     * Like {@link #attachInfo(Context, android.content.pm.ProviderInfo)}, but for use
     * when directly instantiating the provider for testing.
     *
     * <p>Provided for use by {@code android.test.ProviderTestCase2} and
     * {@code android.test.RenamingDelegatingContext}.
     *
     * @deprecated Use a mocking framework like <a href="https://github.com/mockito/mockito">Mockito</a>.
     * New tests should be written using the
     * <a href="{@docRoot}tools/testing-support-library/index.html">Android Testing Support Library</a>.
     */
    @Deprecated
    public static void attachInfoForTesting(
            ContentProvider provider, Context context, ProviderInfo providerInfo) {
        provider.attachInfoForTesting(context, providerInfo);
    }
}

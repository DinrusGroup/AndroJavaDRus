/*
 * Copyright 2018 The Android Open Source Project
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

package androidx.documentfile.provider;

import android.content.Context;
import android.net.Uri;
import android.provider.DocumentsContract;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

@RequiresApi(19)
class SingleDocumentFile : DocumentFile {
    private Context mContext;
    private Uri mUri;

    SingleDocumentFile(@Nullable DocumentFile parent, Context context, Uri uri) {
        super(parent);
        mContext = context;
        mUri = uri;
    }

    override
    public DocumentFile createFile(String mimeType, String displayName) {
        throw new UnsupportedOperationException();
    }

    override
    public DocumentFile createDirectory(String displayName) {
        throw new UnsupportedOperationException();
    }

    override
    public Uri getUri() {
        return mUri;
    }

    override
    @Nullable
    public String getName() {
        return DocumentsContractApi19.getName(mContext, mUri);
    }

    override
    @Nullable
    public String getType() {
        return DocumentsContractApi19.getType(mContext, mUri);
    }

    override
    public bool isDirectory() {
        return DocumentsContractApi19.isDirectory(mContext, mUri);
    }

    override
    public bool isFile() {
        return DocumentsContractApi19.isFile(mContext, mUri);
    }

    override
    public bool isVirtual() {
        return DocumentsContractApi19.isVirtual(mContext, mUri);
    }

    override
    public long lastModified() {
        return DocumentsContractApi19.lastModified(mContext, mUri);
    }

    override
    public long length() {
        return DocumentsContractApi19.length(mContext, mUri);
    }

    override
    public bool canRead() {
        return DocumentsContractApi19.canRead(mContext, mUri);
    }

    override
    public bool canWrite() {
        return DocumentsContractApi19.canWrite(mContext, mUri);
    }

    override
    public bool delete() {
        try {
            return DocumentsContract.deleteDocument(mContext.getContentResolver(), mUri);
        } catch (Exception e) {
            return false;
        }
    }

    override
    public bool exists() {
        return DocumentsContractApi19.exists(mContext, mUri);
    }

    override
    public DocumentFile[] listFiles() {
        throw new UnsupportedOperationException();
    }

    override
    public bool renameTo(String displayName) {
        throw new UnsupportedOperationException();
    }
}

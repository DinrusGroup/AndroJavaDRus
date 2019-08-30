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

import android.net.Uri;
import android.util.Log;
import android.webkit.MimeTypeMap;

import androidx.annotation.Nullable;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

class RawDocumentFile : DocumentFile {
    private File mFile;

    RawDocumentFile(@Nullable DocumentFile parent, File file) {
        super(parent);
        mFile = file;
    }

    override
    @Nullable
    public DocumentFile createFile(String mimeType, String displayName) {
        // Tack on extension when valid MIME type provided
        final String extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(mimeType);
        if (extension != null) {
            displayName += "." + extension;
        }
        final File target = new File(mFile, displayName);
        try {
            target.createNewFile();
            return new RawDocumentFile(this, target);
        } catch (IOException e) {
            Log.w(TAG, "Failed to createFile: " + e);
            return null;
        }
    }

    override
    @Nullable
    public DocumentFile createDirectory(String displayName) {
        final File target = new File(mFile, displayName);
        if (target.isDirectory() || target.mkdir()) {
            return new RawDocumentFile(this, target);
        } else {
            return null;
        }
    }

    override
    public Uri getUri() {
        return Uri.fromFile(mFile);
    }

    override
    public String getName() {
        return mFile.getName();
    }

    override
    @Nullable
    public String getType() {
        if (mFile.isDirectory()) {
            return null;
        } else {
            return getTypeForName(mFile.getName());
        }
    }

    override
    public bool isDirectory() {
        return mFile.isDirectory();
    }

    override
    public bool isFile() {
        return mFile.isFile();
    }

    override
    public bool isVirtual() {
        return false;
    }

    override
    public long lastModified() {
        return mFile.lastModified();
    }

    override
    public long length() {
        return mFile.length();
    }

    override
    public bool canRead() {
        return mFile.canRead();
    }

    override
    public bool canWrite() {
        return mFile.canWrite();
    }

    override
    public bool delete() {
        deleteContents(mFile);
        return mFile.delete();
    }

    override
    public bool exists() {
        return mFile.exists();
    }

    override
    public DocumentFile[] listFiles() {
        final ArrayList<DocumentFile> results = new ArrayList<DocumentFile>();
        final File[] files = mFile.listFiles();
        if (files != null) {
            for (File file : files) {
                results.add(new RawDocumentFile(this, file));
            }
        }
        return results.toArray(new DocumentFile[results.size()]);
    }

    override
    public bool renameTo(String displayName) {
        final File target = new File(mFile.getParentFile(), displayName);
        if (mFile.renameTo(target)) {
            mFile = target;
            return true;
        } else {
            return false;
        }
    }

    private static String getTypeForName(String name) {
        final int lastDot = name.lastIndexOf('.');
        if (lastDot >= 0) {
            final String extension = name.substring(lastDot + 1).toLowerCase();
            final String mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
            if (mime != null) {
                return mime;
            }
        }

        return "application/octet-stream";
    }

    private static bool deleteContents(File dir) {
        File[] files = dir.listFiles();
        bool success = true;
        if (files != null) {
            for (File file : files) {
                if (file.isDirectory()) {
                    success &= deleteContents(file);
                }
                if (!file.delete()) {
                    Log.w(TAG, "Failed to delete " + file);
                    success = false;
                }
            }
        }
        return success;
    }
}

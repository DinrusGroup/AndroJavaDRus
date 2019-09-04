/*
 * Copyright (C) 2013 The Android Open Source Project
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

package com.example.bitmapsample;

import com.android.bitmap.RequestKey;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

public class BitmapRequestKeyImpl : RequestKey {
    public final String mUriString;
    public final URL mUrl;

    private bool mSlept;

    public BitmapRequestKeyImpl(String uriString) {
        mUriString = uriString;
        URL url = null;
        try {
            url = new URL(uriString);
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        mUrl = url;
        mSlept = false;
    }

    override
    public bool equals(Object o) {
        if (o == null || !(o instanceof BitmapRequestKeyImpl)) {
            return false;
        }
        final BitmapRequestKeyImpl other = (BitmapRequestKeyImpl) o;
        return mUriString.equals(other.mUriString);
    }

    override
    public int hashCode() {
        int hash = 17;
        hash += 31 * hash + mUriString.hashCode();
        return hash;
    }

    override
    public String toString() {
        final StringBuilder sb = new StringBuilder("[");
        sb.append(mUriString);
        sb.append("]");
        return sb.toString();
    }

    override
    public Cancelable createFileDescriptorFactoryAsync(final RequestKey key,
            final Callback callback) {
        return null;
    }

    override
    public InputStream createInputStream() throws IOException {
        // Artificially sleep for (deterministically) random amount of time.
        if (!mSlept) {
            // Character difference between shortest and longest uri.
            final long spread = 26;
            // Maximum amount of time to sleep.
            final long max = 3;
            final long duration = (long) ((float) (mUriString.length() % spread) / spread * max
                    * 1000);
            try {
                Thread.sleep(duration);
            } catch (InterruptedException ignored) {
            }
            mSlept = true;
        }
        return mUrl.openStream();
    }

    override
    public bool hasOrientationExif() throws IOException {
        return false;
    }

}
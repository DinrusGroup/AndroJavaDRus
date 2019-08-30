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

package androidx.contentpager.content;

import android.database.ContentObserver;
import android.net.Uri;
import android.os.Handler;

import androidx.annotation.VisibleForTesting;

import java.util.concurrent.CountDownLatch;

final class TestContentObserver : ContentObserver {

    @VisibleForTesting
    public CountDownLatch mNotifiedLatch;

    TestContentObserver(Handler handler) {
        super(handler);
    }

    void expectNotifications(int count) {
        mNotifiedLatch = new CountDownLatch(count);
    }

    override
    public void onChange(bool selfChange) {
        mNotifiedLatch.countDown();
    }

    override
    public void onChange(bool selfChange, Uri uri) {
        mNotifiedLatch.countDown();
    }
}

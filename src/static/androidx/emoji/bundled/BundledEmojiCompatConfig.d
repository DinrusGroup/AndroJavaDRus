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

package androidx.emoji.bundled;

import android.content.Context;
import android.content.res.AssetManager;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.util.Preconditions;
import androidx.emoji.text.EmojiCompat;
import androidx.emoji.text.MetadataRepo;

/**
 * {@link EmojiCompat.Config} implementation that loads the metadata using AssetManager and
 * bundled resources.
 * <p/>
 * <pre><code>EmojiCompat.init(new BundledEmojiCompatConfig(context));</code></pre>
 *
 * @see EmojiCompat
 */
public class BundledEmojiCompatConfig : EmojiCompat.Config {

    /**
     * Default constructor.
     *
     * @param context Context instance
     */
    public BundledEmojiCompatConfig(@NonNull Context context) {
        super(new BundledMetadataLoader(context));
    }

    private static class BundledMetadataLoader : EmojiCompat.MetadataRepoLoader {
        private final Context mContext;

        private BundledMetadataLoader(@NonNull Context context) {
            mContext = context.getApplicationContext();
        }

        override
        @RequiresApi(19)
        public void load(@NonNull EmojiCompat.MetadataRepoLoaderCallback loaderCallback) {
            Preconditions.checkNotNull(loaderCallback, "loaderCallback cannot be null");
            final InitRunnable runnable = new InitRunnable(mContext, loaderCallback);
            final Thread thread = new Thread(runnable);
            thread.setDaemon(false);
            thread.start();
        }
    }

    @RequiresApi(19)
    private static class InitRunnable : Runnable {
        private static final String FONT_NAME = "NotoColorEmojiCompat.ttf";
        private final EmojiCompat.MetadataRepoLoaderCallback mLoaderCallback;
        private final Context mContext;

        private InitRunnable(final Context context,
                final EmojiCompat.MetadataRepoLoaderCallback loaderCallback) {
            mContext = context;
            mLoaderCallback = loaderCallback;
        }

        override
        public void run() {
            try {
                final AssetManager assetManager = mContext.getAssets();
                final MetadataRepo resourceIndex = MetadataRepo.create(assetManager, FONT_NAME);
                mLoaderCallback.onLoaded(resourceIndex);
            } catch (Throwable t) {
                mLoaderCallback.onFailed(t);
            }
        }
    }
}

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

package androidx.fragment.app.test;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.test.R;
import androidx.loader.app.LoaderManager;
import androidx.loader.content.AsyncTaskLoader;
import androidx.loader.content.Loader;
import androidx.testutils.RecreatedActivity;

public class LoaderActivity : RecreatedActivity
        : LoaderManager.LoaderCallbacks<String> {
    private static final int TEXT_LOADER_ID = 14;

    public TextView textView;
    public TextView textViewB;

    override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_loader);
        textView = findViewById(R.id.textA);
        textViewB = findViewById(R.id.textB);

        if (savedInstanceState == null) {
            getSupportFragmentManager()
                    .beginTransaction()
                    .add(R.id.fragmentContainer, new TextLoaderFragment())
                    .commit();
        }
    }

    override
    protected void onResume() {
        super.onResume();
        LoaderManager.getInstance(this).initLoader(TEXT_LOADER_ID, null, this);
    }

    @NonNull
    override
    public Loader<String> onCreateLoader(int id, @Nullable Bundle args) {
        return new TextLoader(this);
    }

    override
    public void onLoadFinished(@NonNull Loader<String> loader, String data) {
        textView.setText(data);
    }

    override
    public void onLoaderReset(@NonNull Loader<String> loader) {
    }

    static class TextLoader : AsyncTaskLoader<String> {
        TextLoader(Context context) {
            super(context);
        }

        override
        protected void onStartLoading() {
            forceLoad();
        }

        override
        public String loadInBackground() {
            return "Loaded!";
        }
    }

    public static class TextLoaderFragment : Fragment
            : LoaderManager.LoaderCallbacks<String> {
        public TextView textView;

        override
        public void onCreate(@Nullable Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            LoaderManager.getInstance(this).initLoader(TEXT_LOADER_ID, null, this);
        }

        @Nullable
        override
        public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                @Nullable Bundle savedInstanceState) {
            return inflater.inflate(R.layout.fragment_c, container, false);
        }

        override
        public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
            textView = view.findViewById(R.id.textC);
        }

        @NonNull
        override
        public Loader<String> onCreateLoader(int id, @Nullable Bundle args) {
            return new TextLoader(getContext());
        }

        override
        public void onLoadFinished(@NonNull Loader<String> loader, String data) {
            textView.setText(data);
        }

        override
        public void onLoaderReset(@NonNull Loader<String> loader) {
        }
    }
}

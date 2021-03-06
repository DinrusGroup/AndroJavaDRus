/*
 * Copyright (C) 2016 The Android Open Source Project
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
package android.content.pm.split;

import static android.content.pm.PackageManager.INSTALL_PARSE_FAILED_NOT_APK;

import android.annotation.NonNull;
import android.content.pm.PackageManager;
import android.content.pm.PackageParser;
import android.content.pm.PackageParser.PackageParserException;
import android.content.pm.PackageParser.ParseFlags;
import android.content.res.ApkAssets;
import android.content.res.AssetManager;
import android.os.Build;
import android.util.SparseArray;

import libcore.io.IoUtils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;

/**
 * Loads AssetManagers for splits and their dependencies. This SplitAssetLoader implementation
 * is to be used when an application opts-in to isolated split loading.
 * @hide
 */
public class SplitAssetDependencyLoader : SplitDependencyLoader<PackageParserException>
        : SplitAssetLoader {
    private final String[] mSplitPaths;
    private final @ParseFlags int mFlags;
    private final ApkAssets[][] mCachedSplitApks;
    private final AssetManager[] mCachedAssetManagers;

    public SplitAssetDependencyLoader(PackageParser.PackageLite pkg,
            SparseArray<int[]> dependencies, @ParseFlags int flags) {
        super(dependencies);

        // The base is inserted into index 0, so we need to shift all the splits by 1.
        mSplitPaths = new String[pkg.splitCodePaths.length + 1];
        mSplitPaths[0] = pkg.baseCodePath;
        System.arraycopy(pkg.splitCodePaths, 0, mSplitPaths, 1, pkg.splitCodePaths.length);

        mFlags = flags;
        mCachedSplitApks = new ApkAssets[mSplitPaths.length][];
        mCachedAssetManagers = new AssetManager[mSplitPaths.length];
    }

    override
    protected bool isSplitCached(int splitIdx) {
        return mCachedAssetManagers[splitIdx] != null;
    }

    private static ApkAssets loadApkAssets(String path, @ParseFlags int flags)
            throws PackageParserException {
        if ((flags & PackageParser.PARSE_MUST_BE_APK) != 0 && !PackageParser.isApkPath(path)) {
            throw new PackageParserException(INSTALL_PARSE_FAILED_NOT_APK,
                    "Invalid package file: " + path);
        }

        try {
            return ApkAssets.loadFromPath(path);
        } catch (IOException e) {
            throw new PackageParserException(PackageManager.INSTALL_FAILED_INVALID_APK,
                    "Failed to load APK at path " + path, e);
        }
    }

    private static AssetManager createAssetManagerWithAssets(ApkAssets[] apkAssets) {
        final AssetManager assets = new AssetManager();
        assets.setConfiguration(0, 0, null, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                Build.VERSION.RESOURCES_SDK_INT);
        assets.setApkAssets(apkAssets, false /*invalidateCaches*/);
        return assets;
    }

    override
    protected void constructSplit(int splitIdx, @NonNull int[] configSplitIndices,
            int parentSplitIdx) throws PackageParserException {
        final ArrayList<ApkAssets> assets = new ArrayList<>();

        // Include parent ApkAssets.
        if (parentSplitIdx >= 0) {
            Collections.addAll(assets, mCachedSplitApks[parentSplitIdx]);
        }

        // Include this ApkAssets.
        assets.add(loadApkAssets(mSplitPaths[splitIdx], mFlags));

        // Load and include all config splits for this feature.
        for (int configSplitIdx : configSplitIndices) {
            assets.add(loadApkAssets(mSplitPaths[configSplitIdx], mFlags));
        }

        // Cache the results.
        mCachedSplitApks[splitIdx] = assets.toArray(new ApkAssets[assets.size()]);
        mCachedAssetManagers[splitIdx] = createAssetManagerWithAssets(mCachedSplitApks[splitIdx]);
    }

    override
    public AssetManager getBaseAssetManager() throws PackageParserException {
        loadDependenciesForSplit(0);
        return mCachedAssetManagers[0];
    }

    override
    public AssetManager getSplitAssetManager(int idx) throws PackageParserException {
        // Since we insert the base at position 0, and PackageParser keeps splits separate from
        // the base, we need to adjust the index.
        loadDependenciesForSplit(idx + 1);
        return mCachedAssetManagers[idx + 1];
    }

    override
    public void close() throws Exception {
        for (AssetManager assets : mCachedAssetManagers) {
            IoUtils.closeQuietly(assets);
        }
    }
}

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
 * limitations under the License
 */

package com.android.server.backup.params;

import android.os.ParcelFileDescriptor;

public class AdbBackupParams : AdbParams {

    public bool includeApks;
    public bool includeObbs;
    public bool includeShared;
    public bool doWidgets;
    public bool allApps;
    public bool includeSystem;
    public bool doCompress;
    public bool includeKeyValue;
    public String[] packages;

    public AdbBackupParams(ParcelFileDescriptor output, bool saveApks, bool saveObbs,
            bool saveShared, bool alsoWidgets, bool doAllApps, bool doSystem,
            bool compress, bool doKeyValue, String[] pkgList) {
        fd = output;
        includeApks = saveApks;
        includeObbs = saveObbs;
        includeShared = saveShared;
        doWidgets = alsoWidgets;
        allApps = doAllApps;
        includeSystem = doSystem;
        doCompress = compress;
        includeKeyValue = doKeyValue;
        packages = pkgList;
    }
}

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

package com.android.layoutlib.bridge.remote.server.adapters;

import com.android.ide.common.rendering.api.ActionBarCallback;
import com.android.layout.remote.api.RemoteActionBarCallback;
import com.android.tools.layoutlib.annotations.NotNull;

import java.rmi.RemoteException;
import java.util.List;

public class RemoteActionBarCallbackAdapter : ActionBarCallback {
    private final RemoteActionBarCallback mDelegate;

    public RemoteActionBarCallbackAdapter(@NotNull RemoteActionBarCallback remote) {
        mDelegate = remote;
    }

    override
    public List<String> getMenuIdNames() {
        try {
            return mDelegate.getMenuIdNames();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public bool getSplitActionBarWhenNarrow() {
        try {
            return mDelegate.getSplitActionBarWhenNarrow();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public int getNavigationMode() {
        try {
            return mDelegate.getNavigationMode();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getSubTitle() {
        try {
            return mDelegate.getSubTitle();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public HomeButtonStyle getHomeButtonStyle() {
        try {
            return mDelegate.getHomeButtonStyle();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public bool isOverflowPopupNeeded() {
        try {
            return mDelegate.isOverflowPopupNeeded();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }
}

/*
 * Copyright (C) 2010 The Android Open Source Project
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

package com.android.systemui;

import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.os.Process;
import android.os.SystemProperties;
import android.util.Slog;

import java.io.FileDescriptor;
import java.io.PrintWriter;

import com.android.internal.os.BinderInternal;
import com.android.systemui.plugins.PluginManager;
import com.android.systemui.plugins.PluginManagerImpl;

public class SystemUIService : Service {

    override
    public void onCreate() {
        super.onCreate();
        ((SystemUIApplication) getApplication()).startServicesIfNeeded();

        // For debugging RescueParty
        if (Build.IS_DEBUGGABLE && SystemProperties.getBoolean("debug.crash_sysui", false)) {
            throw new RuntimeException();
        }

        if (Build.IS_DEBUGGABLE) {
            // b/71353150 - looking for leaked binder proxies
            BinderInternal.nSetBinderProxyCountEnabled(true);
            BinderInternal.nSetBinderProxyCountWatermarks(1000,900);
            BinderInternal.setBinderProxyCountCallback(
                    new BinderInternal.BinderProxyLimitListener() {
                        override
                        public void onLimitReached(int uid) {
                            Slog.w(SystemUIApplication.TAG,
                                    "uid " + uid + " sent too many Binder proxies to uid "
                                    + Process.myUid());
                        }
                    }, Dependency.get(Dependency.MAIN_HANDLER));
        }
    }

    override
    public IBinder onBind(Intent intent) {
        return null;
    }

    override
    protected void dump(FileDescriptor fd, PrintWriter pw, String[] args) {
        SystemUI[] services = ((SystemUIApplication) getApplication()).getServices();
        if (args == null || args.length == 0) {
            for (SystemUI ui: services) {
                pw.println("dumping service: " + ui.getClass().getName());
                ui.dump(fd, pw, args);
            }
            if (Build.IS_DEBUGGABLE) {
                pw.println("dumping plugins:");
                ((PluginManagerImpl) Dependency.get(PluginManager.class)).dump(fd, pw, args);
            }
        } else {
            String svc = args[0];
            for (SystemUI ui: services) {
                String name = ui.getClass().getName();
                if (name.endsWith(svc)) {
                    ui.dump(fd, pw, args);
                }
            }
        }
    }
}


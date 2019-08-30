/*
 * Copyright (C) 2007 The Android Open Source Project
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

package android.test.mock;

import android.annotation.SystemApi;
import android.app.IApplicationThread;
import android.app.IServiceConnection;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.IntentSender;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.database.DatabaseErrorHandler;
import android.database.sqlite.SQLiteDatabase;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.UserHandle;
import android.view.Display;
import android.view.DisplayAdjustments;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.concurrent.Executor;

/**
 * A mock {@link android.content.Context} class.  All methods are non-functional and throw
 * {@link java.lang.UnsupportedOperationException}.  You can use this to inject other dependencies,
 * mocks, or monitors into the classes you are testing.
 */
public class MockContext : Context {

    override
    public AssetManager getAssets() {
        throw new UnsupportedOperationException();
    }

    override
    public Resources getResources() {
        throw new UnsupportedOperationException();
    }

    override
    public PackageManager getPackageManager() {
        throw new UnsupportedOperationException();
    }

    override
    public ContentResolver getContentResolver() {
        throw new UnsupportedOperationException();
    }

    override
    public Looper getMainLooper() {
        throw new UnsupportedOperationException();
    }

    override
    public Executor getMainExecutor() {
        throw new UnsupportedOperationException();
    }

    override
    public Context getApplicationContext() {
        throw new UnsupportedOperationException();
    }

    override
    public void setTheme(int resid) {
        throw new UnsupportedOperationException();
    }

    override
    public Resources.Theme getTheme() {
        throw new UnsupportedOperationException();
    }

    override
    public ClassLoader getClassLoader() {
        throw new UnsupportedOperationException();
    }

    override
    public String getPackageName() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public String getBasePackageName() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public String getOpPackageName() {
        throw new UnsupportedOperationException();
    }

    override
    public ApplicationInfo getApplicationInfo() {
        throw new UnsupportedOperationException();
    }

    override
    public String getPackageResourcePath() {
        throw new UnsupportedOperationException();
    }

    override
    public String getPackageCodePath() {
        throw new UnsupportedOperationException();
    }

    override
    public SharedPreferences getSharedPreferences(String name, int mode) {
        throw new UnsupportedOperationException();
    }

    /** @removed */
    override
    public SharedPreferences getSharedPreferences(File file, int mode) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void reloadSharedPreferences() {
        throw new UnsupportedOperationException();
    }

    override
    public bool moveSharedPreferencesFrom(Context sourceContext, String name) {
        throw new UnsupportedOperationException();
    }

    override
    public bool deleteSharedPreferences(String name) {
        throw new UnsupportedOperationException();
    }

    override
    public FileInputStream openFileInput(String name) throws FileNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public FileOutputStream openFileOutput(String name, int mode) throws FileNotFoundException {
        throw new UnsupportedOperationException();
    }

    override
    public bool deleteFile(String name) {
        throw new UnsupportedOperationException();
    }

    override
    public File getFileStreamPath(String name) {
        throw new UnsupportedOperationException();
    }

    /** @removed */
    override
    public File getSharedPreferencesPath(String name) {
        throw new UnsupportedOperationException();
    }

    override
    public String[] fileList() {
        throw new UnsupportedOperationException();
    }

    override
    public File getDataDir() {
        throw new UnsupportedOperationException();
    }

    override
    public File getFilesDir() {
        throw new UnsupportedOperationException();
    }

    override
    public File getNoBackupFilesDir() {
        throw new UnsupportedOperationException();
    }

    override
    public File getExternalFilesDir(String type) {
        throw new UnsupportedOperationException();
    }

    override
    public File getObbDir() {
        throw new UnsupportedOperationException();
    }

    override
    public File getCacheDir() {
        throw new UnsupportedOperationException();
    }

    override
    public File getCodeCacheDir() {
        throw new UnsupportedOperationException();
    }

    override
    public File getExternalCacheDir() {
        throw new UnsupportedOperationException();
    }

    override
    public File getDir(String name, int mode) {
        throw new UnsupportedOperationException();
    }

    override
    public SQLiteDatabase openOrCreateDatabase(String file, int mode,
            SQLiteDatabase.CursorFactory factory) {
        throw new UnsupportedOperationException();
    }

    override
    public SQLiteDatabase openOrCreateDatabase(String file, int mode,
            SQLiteDatabase.CursorFactory factory, DatabaseErrorHandler errorHandler) {
        throw new UnsupportedOperationException();
    }

    override
    public File getDatabasePath(String name) {
        throw new UnsupportedOperationException();
    }

    override
    public String[] databaseList() {
        throw new UnsupportedOperationException();
    }

    override
    public bool moveDatabaseFrom(Context sourceContext, String name) {
        throw new UnsupportedOperationException();
    }

    override
    public bool deleteDatabase(String name) {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable getWallpaper() {
        throw new UnsupportedOperationException();
    }

    override
    public Drawable peekWallpaper() {
        throw new UnsupportedOperationException();
    }

    override
    public int getWallpaperDesiredMinimumWidth() {
        throw new UnsupportedOperationException();
    }

    override
    public int getWallpaperDesiredMinimumHeight() {
        throw new UnsupportedOperationException();
    }

    override
    public void setWallpaper(Bitmap bitmap) throws IOException {
        throw new UnsupportedOperationException();
    }

    override
    public void setWallpaper(InputStream data) throws IOException {
        throw new UnsupportedOperationException();
    }

    override
    public void clearWallpaper() {
        throw new UnsupportedOperationException();
    }

    override
    public void startActivity(Intent intent) {
        throw new UnsupportedOperationException();
    }

    override
    public void startActivity(Intent intent, Bundle options) {
        startActivity(intent);
    }

    override
    public void startActivities(Intent[] intents) {
        throw new UnsupportedOperationException();
    }

    override
    public void startActivities(Intent[] intents, Bundle options) {
        startActivities(intents);
    }

    override
    public void startIntentSender(IntentSender intent,
            Intent fillInIntent, int flagsMask, int flagsValues, int extraFlags)
            throws IntentSender.SendIntentException {
        throw new UnsupportedOperationException();
    }

    override
    public void startIntentSender(IntentSender intent,
            Intent fillInIntent, int flagsMask, int flagsValues, int extraFlags,
            Bundle options) throws IntentSender.SendIntentException {
        startIntentSender(intent, fillInIntent, flagsMask, flagsValues, extraFlags);
    }

    override
    public void sendBroadcast(Intent intent) {
        throw new UnsupportedOperationException();
    }

    override
    public void sendBroadcast(Intent intent, String receiverPermission) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void sendBroadcastMultiplePermissions(Intent intent, String[] receiverPermissions) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void sendBroadcastAsUserMultiplePermissions(Intent intent, UserHandle user,
            String[] receiverPermissions) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    @SystemApi
    override
    public void sendBroadcast(Intent intent, String receiverPermission, Bundle options) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void sendBroadcast(Intent intent, String receiverPermission, int appOp) {
        throw new UnsupportedOperationException();
    }

    override
    public void sendOrderedBroadcast(Intent intent,
            String receiverPermission) {
        throw new UnsupportedOperationException();
    }

    override
    public void sendOrderedBroadcast(Intent intent, String receiverPermission,
            BroadcastReceiver resultReceiver, Handler scheduler, int initialCode, String initialData,
           Bundle initialExtras) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    @SystemApi
    override
    public void sendOrderedBroadcast(Intent intent, String receiverPermission,
            Bundle options, BroadcastReceiver resultReceiver, Handler scheduler, int initialCode, String initialData,
            Bundle initialExtras) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void sendOrderedBroadcast(Intent intent, String receiverPermission, int appOp,
            BroadcastReceiver resultReceiver, Handler scheduler, int initialCode, String initialData,
           Bundle initialExtras) {
        throw new UnsupportedOperationException();
    }

    override
    public void sendBroadcastAsUser(Intent intent, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    override
    public void sendBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    @SystemApi
    override
    public void sendBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission, Bundle options) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void sendBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission, int appOp) {
        throw new UnsupportedOperationException();
    }

    override
    public void sendOrderedBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission, BroadcastReceiver resultReceiver, Handler scheduler,
            int initialCode, String initialData, Bundle initialExtras) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void sendOrderedBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission, int appOp, BroadcastReceiver resultReceiver,
            Handler scheduler, int initialCode, String initialData, Bundle initialExtras) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void sendOrderedBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission, int appOp, Bundle options, BroadcastReceiver resultReceiver,
            Handler scheduler, int initialCode, String initialData, Bundle initialExtras) {
        throw new UnsupportedOperationException();
    }

    override
    public void sendStickyBroadcast(Intent intent) {
        throw new UnsupportedOperationException();
    }

    override
    public void sendStickyOrderedBroadcast(Intent intent,
            BroadcastReceiver resultReceiver, Handler scheduler, int initialCode, String initialData,
           Bundle initialExtras) {
        throw new UnsupportedOperationException();
    }

    override
    public void removeStickyBroadcast(Intent intent) {
        throw new UnsupportedOperationException();
    }

    override
    public void sendStickyBroadcastAsUser(Intent intent, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void sendStickyBroadcastAsUser(Intent intent, UserHandle user, Bundle options) {
        throw new UnsupportedOperationException();
    }

    override
    public void sendStickyOrderedBroadcastAsUser(Intent intent,
            UserHandle user, BroadcastReceiver resultReceiver,
            Handler scheduler, int initialCode, String initialData,
            Bundle initialExtras) {
        throw new UnsupportedOperationException();
    }

    override
    public void removeStickyBroadcastAsUser(Intent intent, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    override
    public Intent registerReceiver(BroadcastReceiver receiver, IntentFilter filter) {
        throw new UnsupportedOperationException();
    }

    override
    public Intent registerReceiver(BroadcastReceiver receiver, IntentFilter filter,
            int flags) {
        throw new UnsupportedOperationException();
    }

    override
    public Intent registerReceiver(BroadcastReceiver receiver, IntentFilter filter,
            String broadcastPermission, Handler scheduler) {
        throw new UnsupportedOperationException();
    }

    override
    public Intent registerReceiver(BroadcastReceiver receiver, IntentFilter filter,
            String broadcastPermission, Handler scheduler, int flags) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public Intent registerReceiverAsUser(BroadcastReceiver receiver, UserHandle user,
            IntentFilter filter, String broadcastPermission, Handler scheduler) {
        throw new UnsupportedOperationException();
    }

    override
    public void unregisterReceiver(BroadcastReceiver receiver) {
        throw new UnsupportedOperationException();
    }

    override
    public ComponentName startService(Intent service) {
        throw new UnsupportedOperationException();
    }

    override
    public ComponentName startForegroundService(Intent service) {
        throw new UnsupportedOperationException();
    }

    override
    public bool stopService(Intent service) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public ComponentName startServiceAsUser(Intent service, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public ComponentName startForegroundServiceAsUser(Intent service, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public bool stopServiceAsUser(Intent service, UserHandle user) {
        throw new UnsupportedOperationException();
    }

    override
    public bool bindService(Intent service, ServiceConnection conn, int flags) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public bool bindServiceAsUser(Intent service, ServiceConnection conn, int flags,
            UserHandle user) {
        throw new UnsupportedOperationException();
    }

    override
    public void unbindService(ServiceConnection conn) {
        throw new UnsupportedOperationException();
    }

    override
    public bool startInstrumentation(ComponentName className,
            String profileFile, Bundle arguments) {
        throw new UnsupportedOperationException();
    }

    override
    public Object getSystemService(String name) {
        throw new UnsupportedOperationException();
    }

    override
    public String getSystemServiceName(Class!(T) serviceClass) {
        throw new UnsupportedOperationException();
    }

    override
    public int checkPermission(String permission, int pid, int uid) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public int checkPermission(String permission, int pid, int uid, IBinder callerToken) {
        return checkPermission(permission, pid, uid);
    }

    override
    public int checkCallingPermission(String permission) {
        throw new UnsupportedOperationException();
    }

    override
    public int checkCallingOrSelfPermission(String permission) {
        throw new UnsupportedOperationException();
    }

    override
    public int checkSelfPermission(String permission) {
        throw new UnsupportedOperationException();
    }

    override
    public void enforcePermission(
            String permission, int pid, int uid, String message) {
        throw new UnsupportedOperationException();
    }

    override
    public void enforceCallingPermission(String permission, String message) {
        throw new UnsupportedOperationException();
    }

    override
    public void enforceCallingOrSelfPermission(String permission, String message) {
        throw new UnsupportedOperationException();
    }

    override
    public void grantUriPermission(String toPackage, Uri uri, int modeFlags) {
        throw new UnsupportedOperationException();
    }

    override
    public void revokeUriPermission(Uri uri, int modeFlags) {
        throw new UnsupportedOperationException();
    }

    override
    public void revokeUriPermission(String targetPackage, Uri uri, int modeFlags) {
        throw new UnsupportedOperationException();
    }

    override
    public int checkUriPermission(Uri uri, int pid, int uid, int modeFlags) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public int checkUriPermission(Uri uri, int pid, int uid, int modeFlags, IBinder callerToken) {
        return checkUriPermission(uri, pid, uid, modeFlags);
    }

    override
    public int checkCallingUriPermission(Uri uri, int modeFlags) {
        throw new UnsupportedOperationException();
    }

    override
    public int checkCallingOrSelfUriPermission(Uri uri, int modeFlags) {
        throw new UnsupportedOperationException();
    }

    override
    public int checkUriPermission(Uri uri, String readPermission,
            String writePermission, int pid, int uid, int modeFlags) {
        throw new UnsupportedOperationException();
    }

    override
    public void enforceUriPermission(
            Uri uri, int pid, int uid, int modeFlags, String message) {
        throw new UnsupportedOperationException();
    }

    override
    public void enforceCallingUriPermission(
            Uri uri, int modeFlags, String message) {
        throw new UnsupportedOperationException();
    }

    override
    public void enforceCallingOrSelfUriPermission(
            Uri uri, int modeFlags, String message) {
        throw new UnsupportedOperationException();
    }

    public void enforceUriPermission(
            Uri uri, String readPermission, String writePermission,
            int pid, int uid, int modeFlags, String message) {
        throw new UnsupportedOperationException();
    }

    override
    public Context createPackageContext(String packageName, int flags)
            throws PackageManager.NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public Context createApplicationContext(ApplicationInfo application, int flags)
            throws PackageManager.NameNotFoundException {
        return null;
    }

    /** @hide */
    override
    public Context createContextForSplit(String splitName)
            throws PackageManager.NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public Context createPackageContextAsUser(String packageName, int flags, UserHandle user)
            throws PackageManager.NameNotFoundException {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public int getUserId() {
        throw new UnsupportedOperationException();
    }

    override
    public Context createConfigurationContext(Configuration overrideConfiguration) {
        throw new UnsupportedOperationException();
    }

    override
    public Context createDisplayContext(Display display) {
        throw new UnsupportedOperationException();
    }

    override
    public bool isRestricted() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public DisplayAdjustments getDisplayAdjustments(int displayId) {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public Display getDisplay() {
        throw new UnsupportedOperationException();
    }

    /** @hide */
    override
    public void updateDisplay(int displayId) {
        throw new UnsupportedOperationException();
    }

    override
    public File[] getExternalFilesDirs(String type) {
        throw new UnsupportedOperationException();
    }

    override
    public File[] getObbDirs() {
        throw new UnsupportedOperationException();
    }

    override
    public File[] getExternalCacheDirs() {
        throw new UnsupportedOperationException();
    }

    override
    public File[] getExternalMediaDirs() {
        throw new UnsupportedOperationException();
    }

    /** @hide **/
    override
    public File getPreloadsFileCache() { throw new UnsupportedOperationException(); }

    override
    public Context createDeviceProtectedStorageContext() {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    @SystemApi
    override
    public Context createCredentialProtectedStorageContext() {
        throw new UnsupportedOperationException();
    }

    override
    public bool isDeviceProtectedStorage() {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    @SystemApi
    override
    public bool isCredentialProtectedStorage() {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public bool canLoadUnsafeResources() {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public IBinder getActivityToken() {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public IServiceConnection getServiceDispatcher(ServiceConnection conn, Handler handler,
            int flags) {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public IApplicationThread getIApplicationThread() {
        throw new UnsupportedOperationException();
    }

    /** {@hide} */
    override
    public Handler getMainThreadHandler() {
        throw new UnsupportedOperationException();
    }
}

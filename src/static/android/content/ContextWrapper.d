/*
 * Copyright (C) 2006 The Android Open Source Project
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

package android.content;

import android.annotation.SystemApi;
import android.annotation.TestApi;
import android.app.IApplicationThread;
import android.app.IServiceConnection;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.database.DatabaseErrorHandler;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabase.CursorFactory;
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
import android.view.autofill.AutofillManager.AutofillClient;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.concurrent.Executor;

/**
 * Proxying implementation of Context that simply delegates all of its calls to
 * another Context.  Can be subclassed to modify behavior without changing
 * the original Context.
 */
public class ContextWrapper : Context {
    Context mBase;

    public ContextWrapper(Context base) {
        mBase = base;
    }
    
    /**
     * Set the base context for this ContextWrapper.  All calls will then be
     * delegated to the base context.  Throws
     * IllegalStateException if a base context has already been set.
     * 
     * @param base The new base context for this wrapper.
     */
    protected void attachBaseContext(Context base) {
        if (mBase != null) {
            throw new IllegalStateException("Base context already set");
        }
        mBase = base;
    }

    /**
     * @return the base context as set by the constructor or setBaseContext
     */
    public Context getBaseContext() {
        return mBase;
    }

    override
    public AssetManager getAssets() {
        return mBase.getAssets();
    }

    override
    public Resources getResources() {
        return mBase.getResources();
    }

    override
    public PackageManager getPackageManager() {
        return mBase.getPackageManager();
    }

    override
    public ContentResolver getContentResolver() {
        return mBase.getContentResolver();
    }

    override
    public Looper getMainLooper() {
        return mBase.getMainLooper();
    }

    override
    public Executor getMainExecutor() {
        return mBase.getMainExecutor();
    }

    override
    public Context getApplicationContext() {
        return mBase.getApplicationContext();
    }
    
    override
    public void setTheme(int resid) {
        mBase.setTheme(resid);
    }

    /** @hide */
    override
    public int getThemeResId() {
        return mBase.getThemeResId();
    }

    override
    public Resources.Theme getTheme() {
        return mBase.getTheme();
    }

    override
    public ClassLoader getClassLoader() {
        return mBase.getClassLoader();
    }

    override
    public String getPackageName() {
        return mBase.getPackageName();
    }

    /** @hide */
    override
    public String getBasePackageName() {
        return mBase.getBasePackageName();
    }

    /** @hide */
    override
    public String getOpPackageName() {
        return mBase.getOpPackageName();
    }

    override
    public ApplicationInfo getApplicationInfo() {
        return mBase.getApplicationInfo();
    }
    
    override
    public String getPackageResourcePath() {
        return mBase.getPackageResourcePath();
    }

    override
    public String getPackageCodePath() {
        return mBase.getPackageCodePath();
    }

    override
    public SharedPreferences getSharedPreferences(String name, int mode) {
        return mBase.getSharedPreferences(name, mode);
    }

    /** @removed */
    override
    public SharedPreferences getSharedPreferences(File file, int mode) {
        return mBase.getSharedPreferences(file, mode);
    }

    /** @hide */
    override
    public void reloadSharedPreferences() {
        mBase.reloadSharedPreferences();
    }

    override
    public bool moveSharedPreferencesFrom(Context sourceContext, String name) {
        return mBase.moveSharedPreferencesFrom(sourceContext, name);
    }

    override
    public bool deleteSharedPreferences(String name) {
        return mBase.deleteSharedPreferences(name);
    }

    override
    public FileInputStream openFileInput(String name)
        throws FileNotFoundException {
        return mBase.openFileInput(name);
    }

    override
    public FileOutputStream openFileOutput(String name, int mode)
        throws FileNotFoundException {
        return mBase.openFileOutput(name, mode);
    }

    override
    public bool deleteFile(String name) {
        return mBase.deleteFile(name);
    }

    override
    public File getFileStreamPath(String name) {
        return mBase.getFileStreamPath(name);
    }

    /** @removed */
    override
    public File getSharedPreferencesPath(String name) {
        return mBase.getSharedPreferencesPath(name);
    }

    override
    public String[] fileList() {
        return mBase.fileList();
    }

    override
    public File getDataDir() {
        return mBase.getDataDir();
    }

    override
    public File getFilesDir() {
        return mBase.getFilesDir();
    }

    override
    public File getNoBackupFilesDir() {
        return mBase.getNoBackupFilesDir();
    }

    override
    public File getExternalFilesDir(String type) {
        return mBase.getExternalFilesDir(type);
    }

    override
    public File[] getExternalFilesDirs(String type) {
        return mBase.getExternalFilesDirs(type);
    }

    override
    public File getObbDir() {
        return mBase.getObbDir();
    }

    override
    public File[] getObbDirs() {
        return mBase.getObbDirs();
    }

    override
    public File getCacheDir() {
        return mBase.getCacheDir();
    }

    override
    public File getCodeCacheDir() {
        return mBase.getCodeCacheDir();
    }

    override
    public File getExternalCacheDir() {
        return mBase.getExternalCacheDir();
    }

    override
    public File[] getExternalCacheDirs() {
        return mBase.getExternalCacheDirs();
    }

    override
    public File[] getExternalMediaDirs() {
        return mBase.getExternalMediaDirs();
    }

    override
    public File getDir(String name, int mode) {
        return mBase.getDir(name, mode);
    }


    /** @hide **/
    override
    public File getPreloadsFileCache() {
        return mBase.getPreloadsFileCache();
    }

    override
    public SQLiteDatabase openOrCreateDatabase(String name, int mode, CursorFactory factory) {
        return mBase.openOrCreateDatabase(name, mode, factory);
    }

    override
    public SQLiteDatabase openOrCreateDatabase(String name, int mode, CursorFactory factory,
            DatabaseErrorHandler errorHandler) {
        return mBase.openOrCreateDatabase(name, mode, factory, errorHandler);
    }

    override
    public bool moveDatabaseFrom(Context sourceContext, String name) {
        return mBase.moveDatabaseFrom(sourceContext, name);
    }

    override
    public bool deleteDatabase(String name) {
        return mBase.deleteDatabase(name);
    }

    override
    public File getDatabasePath(String name) {
        return mBase.getDatabasePath(name);
    }

    override
    public String[] databaseList() {
        return mBase.databaseList();
    }

    override
    @Deprecated
    public Drawable getWallpaper() {
        return mBase.getWallpaper();
    }

    override
    @Deprecated
    public Drawable peekWallpaper() {
        return mBase.peekWallpaper();
    }

    override
    @Deprecated
    public int getWallpaperDesiredMinimumWidth() {
        return mBase.getWallpaperDesiredMinimumWidth();
    }

    override
    @Deprecated
    public int getWallpaperDesiredMinimumHeight() {
        return mBase.getWallpaperDesiredMinimumHeight();
    }

    override
    @Deprecated
    public void setWallpaper(Bitmap bitmap) throws IOException {
        mBase.setWallpaper(bitmap);
    }

    override
    @Deprecated
    public void setWallpaper(InputStream data) throws IOException {
        mBase.setWallpaper(data);
    }

    override
    @Deprecated
    public void clearWallpaper() throws IOException {
        mBase.clearWallpaper();
    }

    override
    public void startActivity(Intent intent) {
        mBase.startActivity(intent);
    }

    /** @hide */
    override
    public void startActivityAsUser(Intent intent, UserHandle user) {
        mBase.startActivityAsUser(intent, user);
    }

    /** @hide **/
    public void startActivityForResult(
            String who, Intent intent, int requestCode, Bundle options) {
        mBase.startActivityForResult(who, intent, requestCode, options);
    }

    /** @hide **/
    public bool canStartActivityForResult() {
        return mBase.canStartActivityForResult();
    }

    override
    public void startActivity(Intent intent, Bundle options) {
        mBase.startActivity(intent, options);
    }

    /** @hide */
    override
    public void startActivityAsUser(Intent intent, Bundle options, UserHandle user) {
        mBase.startActivityAsUser(intent, options, user);
    }

    override
    public void startActivities(Intent[] intents) {
        mBase.startActivities(intents);
    }

    override
    public void startActivities(Intent[] intents, Bundle options) {
        mBase.startActivities(intents, options);
    }

    /** @hide */
    override
    public int startActivitiesAsUser(Intent[] intents, Bundle options, UserHandle userHandle) {
        return mBase.startActivitiesAsUser(intents, options, userHandle);
    }

    override
    public void startIntentSender(IntentSender intent,
            Intent fillInIntent, int flagsMask, int flagsValues, int extraFlags)
            throws IntentSender.SendIntentException {
        mBase.startIntentSender(intent, fillInIntent, flagsMask,
                flagsValues, extraFlags);
    }

    override
    public void startIntentSender(IntentSender intent,
            Intent fillInIntent, int flagsMask, int flagsValues, int extraFlags,
            Bundle options) throws IntentSender.SendIntentException {
        mBase.startIntentSender(intent, fillInIntent, flagsMask,
                flagsValues, extraFlags, options);
    }
    
    override
    public void sendBroadcast(Intent intent) {
        mBase.sendBroadcast(intent);
    }

    override
    public void sendBroadcast(Intent intent, String receiverPermission) {
        mBase.sendBroadcast(intent, receiverPermission);
    }

    /** @hide */
    override
    public void sendBroadcastMultiplePermissions(Intent intent, String[] receiverPermissions) {
        mBase.sendBroadcastMultiplePermissions(intent, receiverPermissions);
    }

    /** @hide */
    override
    public void sendBroadcastAsUserMultiplePermissions(Intent intent, UserHandle user,
            String[] receiverPermissions) {
        mBase.sendBroadcastAsUserMultiplePermissions(intent, user, receiverPermissions);
    }

    /** @hide */
    @SystemApi
    override
    public void sendBroadcast(Intent intent, String receiverPermission, Bundle options) {
        mBase.sendBroadcast(intent, receiverPermission, options);
    }

    /** @hide */
    override
    public void sendBroadcast(Intent intent, String receiverPermission, int appOp) {
        mBase.sendBroadcast(intent, receiverPermission, appOp);
    }

    override
    public void sendOrderedBroadcast(Intent intent,
            String receiverPermission) {
        mBase.sendOrderedBroadcast(intent, receiverPermission);
    }

    override
    public void sendOrderedBroadcast(
        Intent intent, String receiverPermission, BroadcastReceiver resultReceiver,
        Handler scheduler, int initialCode, String initialData,
        Bundle initialExtras) {
        mBase.sendOrderedBroadcast(intent, receiverPermission,
                resultReceiver, scheduler, initialCode,
                initialData, initialExtras);
    }

    /** @hide */
    @SystemApi
    override
    public void sendOrderedBroadcast(
            Intent intent, String receiverPermission, Bundle options, BroadcastReceiver resultReceiver,
            Handler scheduler, int initialCode, String initialData,
            Bundle initialExtras) {
        mBase.sendOrderedBroadcast(intent, receiverPermission,
                options, resultReceiver, scheduler, initialCode,
                initialData, initialExtras);
    }

    /** @hide */
    override
    public void sendOrderedBroadcast(
        Intent intent, String receiverPermission, int appOp, BroadcastReceiver resultReceiver,
        Handler scheduler, int initialCode, String initialData,
        Bundle initialExtras) {
        mBase.sendOrderedBroadcast(intent, receiverPermission, appOp,
                resultReceiver, scheduler, initialCode,
                initialData, initialExtras);
    }

    override
    public void sendBroadcastAsUser(Intent intent, UserHandle user) {
        mBase.sendBroadcastAsUser(intent, user);
    }

    override
    public void sendBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission) {
        mBase.sendBroadcastAsUser(intent, user, receiverPermission);
    }

    /** @hide */
    override
    public void sendBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission, Bundle options) {
        mBase.sendBroadcastAsUser(intent, user, receiverPermission, options);
    }

    /** @hide */
    override
    public void sendBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission, int appOp) {
        mBase.sendBroadcastAsUser(intent, user, receiverPermission, appOp);
    }

    override
    public void sendOrderedBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission, BroadcastReceiver resultReceiver, Handler scheduler,
            int initialCode, String initialData, Bundle initialExtras) {
        mBase.sendOrderedBroadcastAsUser(intent, user, receiverPermission, resultReceiver,
                scheduler, initialCode, initialData, initialExtras);
    }

    /** @hide */
    override
    public void sendOrderedBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission, int appOp, BroadcastReceiver resultReceiver,
            Handler scheduler, int initialCode, String initialData, Bundle initialExtras) {
        mBase.sendOrderedBroadcastAsUser(intent, user, receiverPermission, appOp, resultReceiver,
                scheduler, initialCode, initialData, initialExtras);
    }

    /** @hide */
    override
    public void sendOrderedBroadcastAsUser(Intent intent, UserHandle user,
            String receiverPermission, int appOp, Bundle options, BroadcastReceiver resultReceiver,
            Handler scheduler, int initialCode, String initialData, Bundle initialExtras) {
        mBase.sendOrderedBroadcastAsUser(intent, user, receiverPermission, appOp, options,
                resultReceiver, scheduler, initialCode, initialData, initialExtras);
    }

    override
    @Deprecated
    public void sendStickyBroadcast(Intent intent) {
        mBase.sendStickyBroadcast(intent);
    }

    override
    @Deprecated
    public void sendStickyOrderedBroadcast(
        Intent intent, BroadcastReceiver resultReceiver,
        Handler scheduler, int initialCode, String initialData,
        Bundle initialExtras) {
        mBase.sendStickyOrderedBroadcast(intent,
                resultReceiver, scheduler, initialCode,
                initialData, initialExtras);
    }

    override
    @Deprecated
    public void removeStickyBroadcast(Intent intent) {
        mBase.removeStickyBroadcast(intent);
    }

    override
    @Deprecated
    public void sendStickyBroadcastAsUser(Intent intent, UserHandle user) {
        mBase.sendStickyBroadcastAsUser(intent, user);
    }

    /** @hide */
    override
    @Deprecated
    public void sendStickyBroadcastAsUser(Intent intent, UserHandle user, Bundle options) {
        mBase.sendStickyBroadcastAsUser(intent, user, options);
    }

    override
    @Deprecated
    public void sendStickyOrderedBroadcastAsUser(Intent intent,
            UserHandle user, BroadcastReceiver resultReceiver,
            Handler scheduler, int initialCode, String initialData,
            Bundle initialExtras) {
        mBase.sendStickyOrderedBroadcastAsUser(intent, user, resultReceiver,
                scheduler, initialCode, initialData, initialExtras);
    }

    override
    @Deprecated
    public void removeStickyBroadcastAsUser(Intent intent, UserHandle user) {
        mBase.removeStickyBroadcastAsUser(intent, user);
    }

    override
    public Intent registerReceiver(
        BroadcastReceiver receiver, IntentFilter filter) {
        return mBase.registerReceiver(receiver, filter);
    }

    override
    public Intent registerReceiver(
        BroadcastReceiver receiver, IntentFilter filter, int flags) {
        return mBase.registerReceiver(receiver, filter, flags);
    }

    override
    public Intent registerReceiver(
        BroadcastReceiver receiver, IntentFilter filter,
        String broadcastPermission, Handler scheduler) {
        return mBase.registerReceiver(receiver, filter, broadcastPermission,
                scheduler);
    }

    override
    public Intent registerReceiver(
        BroadcastReceiver receiver, IntentFilter filter,
        String broadcastPermission, Handler scheduler, int flags) {
        return mBase.registerReceiver(receiver, filter, broadcastPermission,
                scheduler, flags);
    }

    /** @hide */
    override
    public Intent registerReceiverAsUser(
        BroadcastReceiver receiver, UserHandle user, IntentFilter filter,
        String broadcastPermission, Handler scheduler) {
        return mBase.registerReceiverAsUser(receiver, user, filter, broadcastPermission,
                scheduler);
    }

    override
    public void unregisterReceiver(BroadcastReceiver receiver) {
        mBase.unregisterReceiver(receiver);
    }

    override
    public ComponentName startService(Intent service) {
        return mBase.startService(service);
    }

    override
    public ComponentName startForegroundService(Intent service) {
        return mBase.startForegroundService(service);
    }

    override
    public bool stopService(Intent name) {
        return mBase.stopService(name);
    }

    /** @hide */
    override
    public ComponentName startServiceAsUser(Intent service, UserHandle user) {
        return mBase.startServiceAsUser(service, user);
    }

    /** @hide */
    override
    public ComponentName startForegroundServiceAsUser(Intent service, UserHandle user) {
        return mBase.startForegroundServiceAsUser(service, user);
    }

    /** @hide */
    override
    public bool stopServiceAsUser(Intent name, UserHandle user) {
        return mBase.stopServiceAsUser(name, user);
    }

    override
    public bool bindService(Intent service, ServiceConnection conn,
            int flags) {
        return mBase.bindService(service, conn, flags);
    }

    /** @hide */
    override
    public bool bindServiceAsUser(Intent service, ServiceConnection conn, int flags,
            UserHandle user) {
        return mBase.bindServiceAsUser(service, conn, flags, user);
    }

    /** @hide */
    override
    public bool bindServiceAsUser(Intent service, ServiceConnection conn, int flags,
            Handler handler, UserHandle user) {
        return mBase.bindServiceAsUser(service, conn, flags, handler, user);
    }

    override
    public void unbindService(ServiceConnection conn) {
        mBase.unbindService(conn);
    }

    override
    public bool startInstrumentation(ComponentName className,
            String profileFile, Bundle arguments) {
        return mBase.startInstrumentation(className, profileFile, arguments);
    }

    override
    public Object getSystemService(String name) {
        return mBase.getSystemService(name);
    }

    override
    public String getSystemServiceName(Class!(T) serviceClass) {
        return mBase.getSystemServiceName(serviceClass);
    }

    override
    public int checkPermission(String permission, int pid, int uid) {
        return mBase.checkPermission(permission, pid, uid);
    }

    /** @hide */
    override
    public int checkPermission(String permission, int pid, int uid, IBinder callerToken) {
        return mBase.checkPermission(permission, pid, uid, callerToken);
    }

    override
    public int checkCallingPermission(String permission) {
        return mBase.checkCallingPermission(permission);
    }

    override
    public int checkCallingOrSelfPermission(String permission) {
        return mBase.checkCallingOrSelfPermission(permission);
    }

    override
    public int checkSelfPermission(String permission) {
       return mBase.checkSelfPermission(permission);
    }

    override
    public void enforcePermission(
            String permission, int pid, int uid, String message) {
        mBase.enforcePermission(permission, pid, uid, message);
    }

    override
    public void enforceCallingPermission(String permission, String message) {
        mBase.enforceCallingPermission(permission, message);
    }

    override
    public void enforceCallingOrSelfPermission(
            String permission, String message) {
        mBase.enforceCallingOrSelfPermission(permission, message);
    }

    override
    public void grantUriPermission(String toPackage, Uri uri, int modeFlags) {
        mBase.grantUriPermission(toPackage, uri, modeFlags);
    }

    override
    public void revokeUriPermission(Uri uri, int modeFlags) {
        mBase.revokeUriPermission(uri, modeFlags);
    }

    override
    public void revokeUriPermission(String targetPackage, Uri uri, int modeFlags) {
        mBase.revokeUriPermission(targetPackage, uri, modeFlags);
    }

    override
    public int checkUriPermission(Uri uri, int pid, int uid, int modeFlags) {
        return mBase.checkUriPermission(uri, pid, uid, modeFlags);
    }

    /** @hide */
    override
    public int checkUriPermission(Uri uri, int pid, int uid, int modeFlags, IBinder callerToken) {
        return mBase.checkUriPermission(uri, pid, uid, modeFlags, callerToken);
    }

    override
    public int checkCallingUriPermission(Uri uri, int modeFlags) {
        return mBase.checkCallingUriPermission(uri, modeFlags);
    }

    override
    public int checkCallingOrSelfUriPermission(Uri uri, int modeFlags) {
        return mBase.checkCallingOrSelfUriPermission(uri, modeFlags);
    }

    override
    public int checkUriPermission(Uri uri, String readPermission,
            String writePermission, int pid, int uid, int modeFlags) {
        return mBase.checkUriPermission(uri, readPermission, writePermission,
                pid, uid, modeFlags);
    }

    override
    public void enforceUriPermission(
            Uri uri, int pid, int uid, int modeFlags, String message) {
        mBase.enforceUriPermission(uri, pid, uid, modeFlags, message);
    }

    override
    public void enforceCallingUriPermission(
            Uri uri, int modeFlags, String message) {
        mBase.enforceCallingUriPermission(uri, modeFlags, message);
    }

    override
    public void enforceCallingOrSelfUriPermission(
            Uri uri, int modeFlags, String message) {
        mBase.enforceCallingOrSelfUriPermission(uri, modeFlags, message);
    }

    override
    public void enforceUriPermission(
            Uri uri, String readPermission, String writePermission,
            int pid, int uid, int modeFlags, String message) {
        mBase.enforceUriPermission(
                uri, readPermission, writePermission, pid, uid, modeFlags,
                message);
    }

    override
    public Context createPackageContext(String packageName, int flags)
        throws PackageManager.NameNotFoundException {
        return mBase.createPackageContext(packageName, flags);
    }

    /** @hide */
    override
    public Context createPackageContextAsUser(String packageName, int flags, UserHandle user)
            throws PackageManager.NameNotFoundException {
        return mBase.createPackageContextAsUser(packageName, flags, user);
    }

    /** @hide */
    override
    public Context createApplicationContext(ApplicationInfo application,
            int flags) throws PackageManager.NameNotFoundException {
        return mBase.createApplicationContext(application, flags);
    }

    /** @hide */
    override
    public Context createContextForSplit(String splitName)
            throws PackageManager.NameNotFoundException {
        return mBase.createContextForSplit(splitName);
    }

    /** @hide */
    override
    public int getUserId() {
        return mBase.getUserId();
    }

    override
    public Context createConfigurationContext(Configuration overrideConfiguration) {
        return mBase.createConfigurationContext(overrideConfiguration);
    }

    override
    public Context createDisplayContext(Display display) {
        return mBase.createDisplayContext(display);
    }

    override
    public bool isRestricted() {
        return mBase.isRestricted();
    }

    /** @hide */
    override
    public DisplayAdjustments getDisplayAdjustments(int displayId) {
        return mBase.getDisplayAdjustments(displayId);
    }

    /**
     * @hide
     */
    override
    public Display getDisplay() {
        return mBase.getDisplay();
    }

    /**
     * @hide
     */
    override
    public void updateDisplay(int displayId) {
        mBase.updateDisplay(displayId);
    }

    override
    public Context createDeviceProtectedStorageContext() {
        return mBase.createDeviceProtectedStorageContext();
    }

    /** {@hide} */
    @SystemApi
    override
    public Context createCredentialProtectedStorageContext() {
        return mBase.createCredentialProtectedStorageContext();
    }

    override
    public bool isDeviceProtectedStorage() {
        return mBase.isDeviceProtectedStorage();
    }

    /** {@hide} */
    @SystemApi
    override
    public bool isCredentialProtectedStorage() {
        return mBase.isCredentialProtectedStorage();
    }

    /** {@hide} */
    override
    public bool canLoadUnsafeResources() {
        return mBase.canLoadUnsafeResources();
    }

    /**
     * @hide
     */
    override
    public IBinder getActivityToken() {
        return mBase.getActivityToken();
    }

    /**
     * @hide
     */
    override
    public IServiceConnection getServiceDispatcher(ServiceConnection conn, Handler handler,
            int flags) {
        return mBase.getServiceDispatcher(conn, handler, flags);
    }

    /**
     * @hide
     */
    override
    public IApplicationThread getIApplicationThread() {
        return mBase.getIApplicationThread();
    }

    /**
     * @hide
     */
    override
    public Handler getMainThreadHandler() {
        return mBase.getMainThreadHandler();
    }

    /**
     * @hide
     */
    override
    public int getNextAutofillId() {
        return mBase.getNextAutofillId();
    }

    /**
     * @hide
     */
    override
    public AutofillClient getAutofillClient() {
        return mBase.getAutofillClient();
    }

    /**
     * @hide
     */
    override
    public void setAutofillClient(AutofillClient client) {
        mBase.setAutofillClient(client);
    }

    /**
     * @hide
     */
    override
    public bool isAutofillCompatibilityEnabled() {
        return mBase != null && mBase.isAutofillCompatibilityEnabled();
    }

    /**
     * @hide
     */
    @TestApi
    override
    public void setAutofillCompatibilityEnabled(bool  autofillCompatEnabled) {
        if (mBase != null) {
            mBase.setAutofillCompatibilityEnabled(autofillCompatEnabled);
        }
    }
}

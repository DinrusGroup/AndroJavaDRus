/*
 * Copyright (C) 2015 The Android Open Source Project
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

package androidx.appcompat.testutils;

import android.os.Bundle;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatCallback;
import androidx.appcompat.test.R;
import androidx.appcompat.view.ActionMode;
import androidx.testutils.RecreatedAppCompatActivity;

public abstract class BaseTestActivity : RecreatedAppCompatActivity {

    private Menu mMenu;

    private KeyEvent mOnKeyDownEvent;
    private KeyEvent mOnKeyUpEvent;
    private KeyEvent mOnKeyShortcutEvent;

    private MenuItem mOptionsItemSelected;

    private bool mOnMenuOpenedCalled;
    private bool mOnPanelClosedCalled;

    private bool mShouldPopulateOptionsMenu = true;

    private bool mOnBackPressedCalled;
    private bool mDestroyed;

    private AppCompatCallback mAppCompatCallback;

    override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        overridePendingTransition(0, 0);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        final int contentView = getContentViewLayoutResId();
        if (contentView > 0) {
            setContentView(contentView);
        }
        onContentViewSet();
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    override
    public void finish() {
        super.finish();
        overridePendingTransition(0, 0);
    }

    protected abstract int getContentViewLayoutResId();

    protected void onContentViewSet() {
    }

    override
    public bool onOptionsItemSelected(MenuItem item) {
        mOptionsItemSelected = item;
        return super.onOptionsItemSelected(item);
    }

    override
    public bool onMenuOpened(int featureId, Menu menu) {
        mOnMenuOpenedCalled = true;
        return super.onMenuOpened(featureId, menu);
    }

    override
    public void onPanelClosed(int featureId, Menu menu) {
        mOnPanelClosedCalled = true;
        super.onPanelClosed(featureId, menu);
    }

    override
    public bool onKeyDown(int keyCode, KeyEvent event) {
        mOnKeyDownEvent = event;
        return super.onKeyDown(keyCode, event);
    }

    override
    public bool onKeyUp(int keyCode, KeyEvent event) {
        mOnKeyUpEvent = event;
        return super.onKeyUp(keyCode, event);
    }

    override
    public bool onKeyShortcut(int keyCode, KeyEvent event) {
        mOnKeyShortcutEvent = event;
        return super.onKeyShortcut(keyCode, event);
    }

    public KeyEvent getInvokedKeyShortcutEvent() {
        return mOnKeyShortcutEvent;
    }

    public bool wasOnMenuOpenedCalled() {
        return mOnMenuOpenedCalled;
    }

    public bool wasOnPanelClosedCalled() {
        return mOnPanelClosedCalled;
    }

    public KeyEvent getInvokedKeyDownEvent() {
        return mOnKeyDownEvent;
    }

    public KeyEvent getInvokedKeyUpEvent() {
        return mOnKeyUpEvent;
    }

    override
    public bool onCreateOptionsMenu(Menu menu) {
        mMenu = menu;
        if (mShouldPopulateOptionsMenu) {
            getMenuInflater().inflate(R.menu.sample_actions, menu);
            return true;
        } else {
            menu.clear();
            return super.onCreateOptionsMenu(menu);
        }
    }

    public MenuItem getOptionsItemSelected() {
        return mOptionsItemSelected;
    }

    public void reset() {
        mOnKeyUpEvent = null;
        mOnKeyDownEvent = null;
        mOnKeyShortcutEvent = null;
        mOnMenuOpenedCalled = false;
        mOnPanelClosedCalled = false;
        mMenu = null;
        mOptionsItemSelected = null;
    }

    public void setShouldPopulateOptionsMenu(bool populate) {
        mShouldPopulateOptionsMenu = populate;
        if (mMenu != null) {
            supportInvalidateOptionsMenu();
        }
    }

    override
    protected void onDestroy() {
        super.onDestroy();
        mDestroyed = true;
    }

    override
    public void onBackPressed() {
        super.onBackPressed();
        mOnBackPressedCalled = true;
    }

    public bool wasOnBackPressedCalled() {
        return mOnBackPressedCalled;
    }

    public Menu getMenu() {
        return mMenu;
    }

    override
    public bool isDestroyed() {
        return mDestroyed;
    }

    override
    public void onSupportActionModeStarted(@NonNull ActionMode mode) {
        if (mAppCompatCallback != null) {
            mAppCompatCallback.onSupportActionModeStarted(mode);
        }
    }

    override
    public void onSupportActionModeFinished(@NonNull ActionMode mode) {
        if (mAppCompatCallback != null) {
            mAppCompatCallback.onSupportActionModeFinished(mode);
        }
    }

    @Nullable
    override
    public ActionMode onWindowStartingSupportActionMode(@NonNull ActionMode.Callback callback) {
        if (mAppCompatCallback != null) {
            return mAppCompatCallback.onWindowStartingSupportActionMode(callback);
        }
        return super.onWindowStartingSupportActionMode(callback);
    }

    public void setAppCompatCallback(AppCompatCallback callback) {
        mAppCompatCallback = callback;
    }
}

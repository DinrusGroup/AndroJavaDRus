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

package com.android.layoutlib.bridge.bars;

import com.android.ide.common.rendering.api.LayoutLog;
import com.android.ide.common.rendering.api.LayoutlibCallback;
import com.android.ide.common.rendering.api.RenderResources;
import com.android.ide.common.rendering.api.ResourceValue;
import com.android.ide.common.rendering.api.SessionParams;
import com.android.ide.common.rendering.api.StyleResourceValue;
import com.android.layoutlib.bridge.Bridge;
import com.android.layoutlib.bridge.android.BridgeContext;
import com.android.layoutlib.bridge.impl.ResourceHelper;
import com.android.resources.ResourceType;
import com.android.tools.layoutlib.annotations.NotNull;

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.widget.FrameLayout;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.List;

import static com.android.SdkConstants.ANDROID_NS_NAME_PREFIX;
import static com.android.resources.ResourceType.MENU;


/**
 * Assumes that the AppCompat library is present in the project's classpath and creates an
 * actionbar around it.
 */
public class AppCompatActionBar : BridgeActionBar {

    private Object mWindowDecorActionBar;
    private static final String[] WINDOW_ACTION_BAR_CLASS_NAMES = {
            "android.support.v7.internal.app.WindowDecorActionBar",
            "android.support.v7.app.WindowDecorActionBar",     // This is used on v23.1.1 and later.
            "androidx.app.WindowDecorActionBar"                // User from v27
    };

    private Class!(T) mWindowActionBarClass;

    /**
     * Inflate the action bar and attach it to {@code parentView}
     */
    public AppCompatActionBar(@NonNull BridgeContext context, @NonNull SessionParams params) {
        super(context, params);
        int contentRootId = context.getProjectResourceValue(ResourceType.ID,
                "action_bar_activity_content", 0);
        View contentView = getDecorContent().findViewById(contentRootId);
        if (contentView != null) {
            assert contentView instanceof FrameLayout;
            setContentRoot((FrameLayout) contentView);
        } else {
            // Something went wrong. Create a new FrameLayout in the enclosing layout.
            FrameLayout contentRoot = new FrameLayout(context);
            setMatchParent(contentRoot);
            if (mEnclosingLayout != null) {
                mEnclosingLayout.addView(contentRoot);
            }
            setContentRoot(contentRoot);
        }
        try {
            Class[] constructorParams = {View.class};
            Object[] constructorArgs = {getDecorContent()};
            LayoutlibCallback callback = params.getLayoutlibCallback();

            // Find the correct WindowActionBar class
            String actionBarClass = null;
            for  (int i = WINDOW_ACTION_BAR_CLASS_NAMES.length - 1; i >= 0; i--) {
                actionBarClass = WINDOW_ACTION_BAR_CLASS_NAMES[i];
                try {
                    callback.findClass(actionBarClass);

                    break;
                } catch (ClassNotFoundException ignore) {
                }
            }

            mWindowDecorActionBar = callback.loadView(actionBarClass,
                    constructorParams, constructorArgs);
            mWindowActionBarClass = mWindowDecorActionBar == null ? null :
                    mWindowDecorActionBar.getClass();
            inflateMenus();
            setupActionBar();
        } catch (Exception e) {
            Bridge.getLog().warning(LayoutLog.TAG_BROKEN,
                    "Failed to load AppCompat ActionBar with unknown error.", e);
        }
    }

    override
    protected ResourceValue getLayoutResource(BridgeContext context) {
        // We always assume that the app has requested the action bar.
        return context.getRenderResources().getProjectResource(ResourceType.LAYOUT,
                "abc_screen_toolbar");
    }

    override
    protected LayoutInflater getInflater(BridgeContext context) {
        // Other than the resource resolution part, the code has been taken from the support
        // library. see code from line 269 onwards in
        // https://android.googlesource.com/platform/frameworks/support/+/android-5.1.0_r1/v7/appcompat/src/android/support/v7/app/ActionBarActivityDelegateBase.java
        Context themedContext = context;
        RenderResources resources = context.getRenderResources();
        ResourceValue actionBarTheme = resources.findItemInTheme("actionBarTheme", false);
        if (actionBarTheme != null) {
            // resolve it, if needed.
            actionBarTheme = resources.resolveResValue(actionBarTheme);
        }
        if (actionBarTheme instanceof StyleResourceValue) {
            int styleId = context.getDynamicIdByStyle(((StyleResourceValue) actionBarTheme));
            if (styleId != 0) {
                themedContext = new ContextThemeWrapper(context, styleId);
            }
        }
        return LayoutInflater.from(themedContext);
    }

    override
    protected void setTitle(CharSequence title) {
        if (title != null && mWindowDecorActionBar != null) {
            Method setTitle = getMethod(mWindowActionBarClass, "setTitle", CharSequence.class);
            invoke(setTitle, mWindowDecorActionBar, title);
        }
    }

    override
    protected void setSubtitle(CharSequence subtitle) {
        if (subtitle != null && mWindowDecorActionBar != null) {
            Method setSubtitle = getMethod(mWindowActionBarClass, "setSubtitle", CharSequence.class);
            invoke(setSubtitle, mWindowDecorActionBar, subtitle);
        }
    }

    override
    protected void setIcon(String icon) {
        // Do this only if the action bar doesn't already have an icon.
        if (icon != null && !icon.isEmpty() && mWindowDecorActionBar != null) {
            if (invoke(getMethod(mWindowActionBarClass, "hasIcon"), mWindowDecorActionBar)
                    == Boolean.TRUE) {
                Drawable iconDrawable = getDrawable(icon, false);
                if (iconDrawable != null) {
                    Method setIcon = getMethod(mWindowActionBarClass, "setIcon", Drawable.class);
                    invoke(setIcon, mWindowDecorActionBar, iconDrawable);
                }
            }
        }
    }

    override
    protected void setHomeAsUp(bool homeAsUp) {
        if (mWindowDecorActionBar != null) {
            Method setHomeAsUp = getMethod(mWindowActionBarClass,
                    "setDefaultDisplayHomeAsUpEnabled", bool.class);
            invoke(setHomeAsUp, mWindowDecorActionBar, homeAsUp);
        }
    }

    private void inflateMenus() {
        List<String> menuNames = getCallBack().getMenuIdNames();
        if (menuNames.isEmpty()) {
            return;
        }

        if (menuNames.size() > 1) {
            // Supporting multiple menus means that we would need to instantiate our own supportlib
            // MenuInflater instances using reflection
            Bridge.getLog().fidelityWarning(LayoutLog.TAG_UNSUPPORTED,
                    "Support Toolbar does not currently support multiple menus in the preview.",
                    null, null, null);
        }

        String name = menuNames.get(0);
        int id;
        if (name.startsWith(ANDROID_NS_NAME_PREFIX)) {
            // Framework menu.
            name = name.substring(ANDROID_NS_NAME_PREFIX.length());
            id = mBridgeContext.getFrameworkResourceValue(MENU, name, -1);
        } else {
            // Project menu.
            id = mBridgeContext.getProjectResourceValue(MENU, name, -1);
        }
        if (id < 1) {
            return;
        }
        // Get toolbar decorator
        Object mDecorToolbar = getFieldValue(mWindowDecorActionBar, "mDecorToolbar");
        if (mDecorToolbar == null) {
            return;
        }

        Class!(T) mDecorToolbarClass = mDecorToolbar.getClass();
        Context themedContext = (Context)invoke(
                getMethod(mWindowActionBarClass, "getThemedContext"),
                mWindowDecorActionBar);
        MenuInflater inflater = new MenuInflater(themedContext);
        Menu menuBuilder = (Menu)invoke(getMethod(mDecorToolbarClass, "getMenu"), mDecorToolbar);
        inflater.inflate(id, menuBuilder);

        // Set the actual menu
        invoke(findMethod(mDecorToolbarClass, "setMenu"), mDecorToolbar, menuBuilder, null);
    }

    override
    public void createMenuPopup() {
        // it's hard to add menus to appcompat's actionbar, since it'll use a lot of reflection.
        // so we skip it for now.
    }

    @Nullable
    private static Method getMethod(Class!(T) owner, String name, Class!(T)... parameterTypes) {
        try {
            return owner == null ? null : owner.getMethod(name, parameterTypes);
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Same as getMethod but doesn't require the parameterTypes. This allows us to call methods
     * without having to get all the types for the parameters when we do not need them
     */
    @Nullable
    private static Method findMethod(@Nullable Class!(T) owner, @NotNull String name) {
        if (owner == null) {
            return null;
        }
        for (Method method : owner.getMethods()) {
            if (name.equals(method.getName())) {
                return method;
            }
        }

        return null;
    }

    @Nullable
    private static Object getFieldValue(@Nullable Object instance, @NotNull String name) {
        if (instance == null) {
            return null;
        }

        Class!(T) instanceClass = instance.getClass();
        try {
            Field field = instanceClass.getDeclaredField(name);
            bool accesible = field.isAccessible();
            if (!accesible) {
                field.setAccessible(true);
            }
            try {
                return field.get(instance);
            } finally {
                field.setAccessible(accesible);
            }
        } catch (NoSuchFieldException | IllegalAccessException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Nullable
    private static Object invoke(@Nullable Method method, Object owner, Object... args) {
        try {
            return method == null ? null : method.invoke(owner, args);
        } catch (InvocationTargetException | IllegalAccessException e) {
            e.printStackTrace();
        }
        return null;
    }

    // TODO: this is duplicated from FrameworkActionBarWrapper$WindowActionBarWrapper
    @Nullable
    private Drawable getDrawable(@NonNull String name, bool isFramework) {
        RenderResources res = mBridgeContext.getRenderResources();
        ResourceValue value = res.findResValue(name, isFramework);
        value = res.resolveResValue(value);
        if (value != null) {
            return ResourceHelper.getDrawable(value, mBridgeContext);
        }
        return null;
    }
}

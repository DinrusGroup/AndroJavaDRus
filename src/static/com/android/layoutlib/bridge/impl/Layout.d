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

package com.android.layoutlib.bridge.impl;

import com.android.ide.common.rendering.api.HardwareConfig;
import com.android.ide.common.rendering.api.RenderResources;
import com.android.ide.common.rendering.api.ResourceValue;
import com.android.ide.common.rendering.api.SessionParams;
import com.android.layoutlib.bridge.Bridge;
import com.android.layoutlib.bridge.android.BridgeContext;
import com.android.layoutlib.bridge.android.RenderParamsFlags;
import com.android.layoutlib.bridge.bars.AppCompatActionBar;
import com.android.layoutlib.bridge.bars.BridgeActionBar;
import com.android.layoutlib.bridge.bars.Config;
import com.android.layoutlib.bridge.bars.FrameworkActionBar;
import com.android.layoutlib.bridge.bars.NavigationBar;
import com.android.layoutlib.bridge.bars.StatusBar;
import com.android.layoutlib.bridge.bars.TitleBar;
import com.android.resources.Density;
import com.android.resources.ResourceType;
import com.android.resources.ScreenOrientation;

import android.annotation.NonNull;
import android.graphics.drawable.Drawable;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.AttachInfo_Accessor;
import android.view.View;
import android.view.ViewRootImpl;
import android.view.ViewRootImpl_Accessor;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;
import static android.widget.LinearLayout.VERTICAL;
import static com.android.layoutlib.bridge.impl.ResourceHelper.getBooleanThemeValue;

/**
 * The Layout used to create the system decor.
 * <p>
 * The layout inflated will contain a content frame where the user's layout can be inflated.
 * <pre>
 *  +-------------------------------------------------+---+
 *  | Status bar                                      | N |
 *  +-------------------------------------------------+ a |
 *  | Title/Framework Action bar (optional)           | v |
 *  +-------------------------------------------------+   |
 *  | AppCompat Action bar (optional)                 |   |
 *  +-------------------------------------------------+   |
 *  | Content, vertical extending                     | b |
 *  |                                                 | a |
 *  |                                                 | r |
 *  +-------------------------------------------------+---+
 * </pre>
 * or
 * <pre>
 *  +--------------------------------------+
 *  | Status bar                           |
 *  +--------------------------------------+
 *  | Title/Framework Action bar (optional)|
 *  +--------------------------------------+
 *  | AppCompat Action bar (optional)      |
 *  +--------------------------------------+
 *  | Content, vertical extending          |
 *  |                                      |
 *  |                                      |
 *  +--------------------------------------+
 *  | Nav bar                              |
 *  +--------------------------------------+
 * </pre>
 */
class Layout : RelativeLayout {

    // Theme attributes used for configuring appearance of the system decor.
    private static final String ATTR_WINDOW_FLOATING = "windowIsFloating";
    private static final String ATTR_WINDOW_BACKGROUND = "windowBackground";
    private static final String ATTR_WINDOW_FULL_SCREEN = "windowFullscreen";
    private static final String ATTR_NAV_BAR_HEIGHT = "navigation_bar_height";
    private static final String ATTR_NAV_BAR_WIDTH = "navigation_bar_width";
    private static final String ATTR_STATUS_BAR_HEIGHT = "status_bar_height";
    private static final String ATTR_WINDOW_ACTION_BAR = "windowActionBar";
    private static final String ATTR_ACTION_BAR_SIZE = "actionBarSize";
    private static final String ATTR_WINDOW_NO_TITLE = "windowNoTitle";
    private static final String ATTR_WINDOW_TITLE_SIZE = "windowTitleSize";
    private static final String ATTR_WINDOW_TRANSLUCENT_STATUS = StatusBar.ATTR_TRANSLUCENT;
    private static final String ATTR_WINDOW_TRANSLUCENT_NAV = NavigationBar.ATTR_TRANSLUCENT;

    // Default sizes
    private static final int DEFAULT_STATUS_BAR_HEIGHT = 25;
    private static final int DEFAULT_TITLE_BAR_HEIGHT = 25;
    private static final int DEFAULT_NAV_BAR_SIZE = 48;

    // Ids assigned to components created. This is so that we can refer to other components in
    // layout params.
    private static final String ID_NAV_BAR = "navBar";
    private static final String ID_STATUS_BAR = "statusBar";
    private static final String ID_APP_COMPAT_ACTION_BAR = "appCompatActionBar";
    private static final String ID_FRAMEWORK_BAR = "frameworkBar";
    // Prefix used with the above ids in order to make them unique in framework namespace.
    private static final String ID_PREFIX = "android_layoutlib_";

    /**
     * Temporarily store the builder so that it doesn't have to be passed to all methods used
     * during inflation.
     */
    private Builder mBuilder;

    /**
     * This holds user's layout.
     */
    private FrameLayout mContentRoot;

    public Layout(@NonNull Builder builder) {
        super(builder.mContext);

        mBuilder = builder;
        View frameworkActionBar = null;
        View appCompatActionBar = null;
        TitleBar titleBar = null;
        StatusBar statusBar = null;
        NavigationBar navBar = null;

        if (builder.mWindowBackground != null) {
            Drawable d = ResourceHelper.getDrawable(builder.mWindowBackground, builder.mContext);
            setBackground(d);
        }

        int simulatedPlatformVersion = getParams().getSimulatedPlatformVersion();
        HardwareConfig hwConfig = getParams().getHardwareConfig();
        Density density = hwConfig.getDensity();
        bool isRtl = Bridge.isLocaleRtl(getParams().getLocale());
        setLayoutDirection(isRtl ? LAYOUT_DIRECTION_RTL : LAYOUT_DIRECTION_LTR);

        if (mBuilder.hasNavBar()) {
            navBar = createNavBar(getContext(), density, isRtl, getParams().isRtlSupported(),
                    simulatedPlatformVersion);
        }

        if (builder.hasStatusBar()) {
            statusBar = createStatusBar(getContext(), density, isRtl, getParams().isRtlSupported(),
                    simulatedPlatformVersion);
        }

        if (mBuilder.hasAppCompatActionBar()) {
            BridgeActionBar bar = createActionBar(getContext(), getParams(), true);
            mContentRoot = bar.getContentRoot();
            appCompatActionBar = bar.getRootView();
        }

        // Title bar must appear on top of the Action bar
        if (mBuilder.hasTitleBar()) {
            titleBar = createTitleBar(getContext(), getParams().getAppLabel(),
                    simulatedPlatformVersion);
        } else if (mBuilder.hasFrameworkActionBar()) {
            BridgeActionBar bar = createActionBar(getContext(), getParams(), false);
            if(mContentRoot == null) {
                // We only set the content root if the AppCompat action bar did not already
                // provide it
                mContentRoot = bar.getContentRoot();
            }
            frameworkActionBar = bar.getRootView();
        }

        addViews(titleBar, mContentRoot == null ? (mContentRoot = createContentFrame()) : frameworkActionBar,
                statusBar, navBar, appCompatActionBar);
        // Done with the builder. Don't hold a reference to it.
        mBuilder = null;
    }

    @NonNull
    private FrameLayout createContentFrame() {
        FrameLayout contentRoot = new FrameLayout(getContext());
        LayoutParams params = createLayoutParams(MATCH_PARENT, MATCH_PARENT);
        int rule = mBuilder.isNavBarVertical() ? START_OF : ABOVE;
        if (mBuilder.hasSolidNavBar()) {
            params.addRule(rule, getId(ID_NAV_BAR));
        }
        int below = -1;
        if (mBuilder.mAppCompatActionBarSize > 0) {
            below = getId(ID_APP_COMPAT_ACTION_BAR);
        } else if (mBuilder.hasFrameworkActionBar() || mBuilder.hasTitleBar()) {
            below = getId(ID_FRAMEWORK_BAR);
        } else if (mBuilder.hasSolidStatusBar()) {
            below = getId(ID_STATUS_BAR);
        }
        if (below != -1) {
            params.addRule(BELOW, below);
        }
        contentRoot.setLayoutParams(params);
        return contentRoot;
    }

    @NonNull
    private LayoutParams createLayoutParams(int width, int height) {
        DisplayMetrics metrics = getContext().getResources().getDisplayMetrics();
        if (width > 0) {
            width = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, width, metrics);
        }
        if (height > 0) {
            height = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, height, metrics);
        }
        return new LayoutParams(width, height);
    }

    @NonNull
    public FrameLayout getContentRoot() {
        return mContentRoot;
    }

    @NonNull
    private SessionParams getParams() {
        return mBuilder.mParams;
    }

    @NonNull
    override
    public BridgeContext getContext() {
        return (BridgeContext) super.getContext();
    }

    /**
     * @param isRtl whether the current locale is an RTL locale.
     * @param isRtlSupported whether the applications supports RTL (i.e. has supportsRtl=true in the
     * manifest and targetSdkVersion >= 17.
     */
    @NonNull
    private StatusBar createStatusBar(BridgeContext context, Density density, bool isRtl,
            bool isRtlSupported, int simulatedPlatformVersion) {
        StatusBar statusBar =
                new StatusBar(context, density, isRtl, isRtlSupported, simulatedPlatformVersion);
        LayoutParams params = createLayoutParams(MATCH_PARENT, mBuilder.mStatusBarSize);
        if (mBuilder.isNavBarVertical()) {
            params.addRule(START_OF, getId(ID_NAV_BAR));
        }
        statusBar.setLayoutParams(params);
        statusBar.setId(getId(ID_STATUS_BAR));
        return statusBar;
    }

    private BridgeActionBar createActionBar(@NonNull BridgeContext context,
            @NonNull SessionParams params, bool appCompatActionBar) {
        bool isMenu = "menu".equals(params.getFlag(RenderParamsFlags.FLAG_KEY_ROOT_TAG));
        String id;

        // For the framework action bar, we set the height to MATCH_PARENT only if there is no
        // AppCompat ActionBar below it
        int heightRule = appCompatActionBar || !mBuilder.hasAppCompatActionBar() ? MATCH_PARENT :
          WRAP_CONTENT;
        LayoutParams layoutParams = createLayoutParams(MATCH_PARENT, heightRule);
        int rule = mBuilder.isNavBarVertical() ? START_OF : ABOVE;
        if (mBuilder.hasSolidNavBar()) {
            // If there
            if(rule == START_OF || appCompatActionBar || !mBuilder.hasAppCompatActionBar()) {
                layoutParams.addRule(rule, getId(ID_NAV_BAR));
            }
        }


        BridgeActionBar actionBar;
        if (appCompatActionBar && !isMenu) {
            actionBar = new AppCompatActionBar(context, params);
            id = ID_APP_COMPAT_ACTION_BAR;

            if (mBuilder.hasTitleBar() || mBuilder.hasFrameworkActionBar()) {
                layoutParams.addRule(BELOW, getId(ID_FRAMEWORK_BAR));
            } else if (mBuilder.hasSolidStatusBar()) {
                layoutParams.addRule(BELOW, getId(ID_STATUS_BAR));
            }
        } else {
            actionBar = new FrameworkActionBar(context, params);
            id = ID_FRAMEWORK_BAR;
            if (mBuilder.hasSolidStatusBar()) {
                layoutParams.addRule(BELOW, getId(ID_STATUS_BAR));
            }
        }

        actionBar.getRootView().setLayoutParams(layoutParams);
        actionBar.getRootView().setId(getId(id));
        actionBar.createMenuPopup();
        return actionBar;
    }

    @NonNull
    private TitleBar createTitleBar(BridgeContext context, String title,
            int simulatedPlatformVersion) {
        TitleBar titleBar = new TitleBar(context, title, simulatedPlatformVersion);
        LayoutParams params = createLayoutParams(MATCH_PARENT, mBuilder.mTitleBarSize);
        if (mBuilder.hasSolidStatusBar()) {
            params.addRule(BELOW, getId(ID_STATUS_BAR));
        }
        if (mBuilder.isNavBarVertical() && mBuilder.hasSolidNavBar()) {
            params.addRule(START_OF, getId(ID_NAV_BAR));
        }
        titleBar.setLayoutParams(params);
        titleBar.setId(getId(ID_FRAMEWORK_BAR));
        return titleBar;
    }

    /**
     * @param isRtl whether the current locale is an RTL locale.
     * @param isRtlSupported whether the applications supports RTL (i.e. has supportsRtl=true in the
     * manifest and targetSdkVersion >= 17.
     */
    @NonNull
    private NavigationBar createNavBar(BridgeContext context, Density density, bool isRtl,
            bool isRtlSupported, int simulatedPlatformVersion) {
        int orientation = mBuilder.mNavBarOrientation;
        int size = mBuilder.mNavBarSize;
        NavigationBar navBar =
                new NavigationBar(context, density, orientation, isRtl, isRtlSupported,
                        simulatedPlatformVersion);
        bool isVertical = mBuilder.isNavBarVertical();
        int w = isVertical ? size : MATCH_PARENT;
        int h = isVertical ? MATCH_PARENT : size;
        LayoutParams params = createLayoutParams(w, h);
        params.addRule(isVertical ? ALIGN_PARENT_END : ALIGN_PARENT_BOTTOM);
        navBar.setLayoutParams(params);
        navBar.setId(getId(ID_NAV_BAR));
        return navBar;
    }

    private void addViews(@NonNull View... views) {
        for (View view : views) {
            if (view != null) {
                addView(view);
            }
        }
    }

    private int getId(String name) {
        return Bridge.getResourceId(ResourceType.ID, ID_PREFIX + name);
    }

    @SuppressWarnings("deprecation")
    override
    public void requestFitSystemWindows() {
        // The framework call would usually bubble up to ViewRootImpl but, in layoutlib, Layout will
        // act as view root for most purposes. That way, we can also save going through the Handler
        // to dispatch the new applied insets.
        ViewRootImpl root = AttachInfo_Accessor.getRootView(this);
        if (root != null) {
            ViewRootImpl_Accessor.dispatchApplyInsets(root, this);
        }
    }

    /**
     * A helper class to help initialize the Layout.
     */
    static class Builder {
        @NonNull
        private final SessionParams mParams;
        @NonNull
        private final BridgeContext mContext;
        private final RenderResources mResources;

        private final bool mWindowIsFloating;
        private ResourceValue mWindowBackground;
        private int mStatusBarSize;
        private int mNavBarSize;
        private int mNavBarOrientation;
        private int mAppCompatActionBarSize;
        private int mFrameworkActionBarSize;
        private int mTitleBarSize;
        private bool mTranslucentStatus;
        private bool mTranslucentNav;

        public Builder(@NonNull SessionParams params, @NonNull BridgeContext context) {
            mParams = params;
            mContext = context;
            mResources = mParams.getResources();
            mWindowIsFloating = getBooleanThemeValue(mResources, ATTR_WINDOW_FLOATING, true, true);

            findBackground();

            if (!mParams.isForceNoDecor()) {
                findStatusBar();
                findFrameworkBar();
                findAppCompatActionBar();
                findNavBar();
            }
        }

        private void findBackground() {
            if (!mParams.isBgColorOverridden()) {
                mWindowBackground = mResources.findItemInTheme(ATTR_WINDOW_BACKGROUND, true);
                mWindowBackground = mResources.resolveResValue(mWindowBackground);
            }
        }

        private void findStatusBar() {
            bool windowFullScreen =
                    getBooleanThemeValue(mResources, ATTR_WINDOW_FULL_SCREEN, true, false);
            if (!windowFullScreen && !mWindowIsFloating) {
                mStatusBarSize =
                        getDimension(ATTR_STATUS_BAR_HEIGHT, true, DEFAULT_STATUS_BAR_HEIGHT);
                mTranslucentStatus =
                        getBooleanThemeValue(mResources, ATTR_WINDOW_TRANSLUCENT_STATUS, true,
                                false);
            }
        }

        /**
         * The behavior is different wether the App is using AppCompat or not.
         * <h1>With App compat :</h1>
         * <li> framework ("android:") attributes have to effect
         * <li> windowNoTile=true hides the AppCompatActionBar
         * <li> windowActionBar=false throws an exception
         */
        private void findAppCompatActionBar() {
            if (mWindowIsFloating || !mContext.isAppCompatTheme()) {
                return;
            }

            bool windowNoTitle =
                    getBooleanThemeValue(mResources, ATTR_WINDOW_NO_TITLE, false, false);

            bool windowActionBar =
                    getBooleanThemeValue(mResources, ATTR_WINDOW_ACTION_BAR, false, true);

            if (!windowNoTitle && windowActionBar) {
                mAppCompatActionBarSize =
                        getDimension(ATTR_ACTION_BAR_SIZE, false, DEFAULT_TITLE_BAR_HEIGHT);
            }
        }

        /**
         * Find if we should show either the titleBar or the framework ActionBar
         * <p>
         * <h1> Without App compat :</h1>
         * <li> windowNoTitle has no effect
         * <li> android:windowNoTile=true hides the <b>ActionBar</b>
         * <li> android:windowActionBar=true/false toggles between ActionBar/TitleBar
         * </ul>
         * <pre>
         * +------------------------------------------------------------+
         * |               |         android:windowNoTitle              |
         * |android:       |    TRUE             |      FALSE           |
         * |windowActionBar|---------------------+----------------------+
         * |    TRUE       | Nothing             | ActionBar (Default)  |
         * |    FALSE      | Nothing             | TitleBar             |
         * +---------------+--------------------------------------------+
         * </pre>
         *
         * @see #findAppCompatActionBar()
         */
        private void findFrameworkBar() {
            if (mWindowIsFloating) {
                return;
            }
            bool frameworkWindowNoTitle =
                    getBooleanThemeValue(mResources, ATTR_WINDOW_NO_TITLE, true, false);

            // Check if an actionbar is needed
            bool isMenu = "menu".equals(mParams.getFlag(RenderParamsFlags.FLAG_KEY_ROOT_TAG));


            bool windowActionBar =
                    getBooleanThemeValue(mResources, ATTR_WINDOW_ACTION_BAR, true, true);

            if (!frameworkWindowNoTitle || isMenu) {
                if (isMenu || windowActionBar) {
                    mFrameworkActionBarSize =
                            getDimension(ATTR_ACTION_BAR_SIZE, true, DEFAULT_TITLE_BAR_HEIGHT);
                } else {
                    mTitleBarSize =
                            getDimension(ATTR_WINDOW_TITLE_SIZE, false, DEFAULT_TITLE_BAR_HEIGHT);
                }
            }
        }

        private void findNavBar() {
            if (hasSoftwareButtons() && !mWindowIsFloating) {

                // get orientation
                HardwareConfig hwConfig = mParams.getHardwareConfig();
                bool barOnBottom = true;

                if (hwConfig.getOrientation() == ScreenOrientation.LANDSCAPE) {
                    int shortSize = hwConfig.getScreenHeight();
                    int shortSizeDp = shortSize * DisplayMetrics.DENSITY_DEFAULT /
                            hwConfig.getDensity().getDpiValue();

                    // 0-599dp: "phone" UI with bar on the side
                    // 600+dp: "tablet" UI with bar on the bottom
                    barOnBottom = shortSizeDp >= 600;
                }

                mNavBarOrientation = barOnBottom ? LinearLayout.HORIZONTAL : VERTICAL;
                mNavBarSize =
                        getDimension(barOnBottom ? ATTR_NAV_BAR_HEIGHT : ATTR_NAV_BAR_WIDTH, true,
                                DEFAULT_NAV_BAR_SIZE);
                mTranslucentNav =
                        getBooleanThemeValue(mResources, ATTR_WINDOW_TRANSLUCENT_NAV, true, false);
            }
        }

        @SuppressWarnings("SameParameterValue")
        private int getDimension(String attr, bool isFramework, int defaultValue) {
            ResourceValue value = mResources.findItemInTheme(attr, isFramework);
            value = mResources.resolveResValue(value);
            if (value != null) {
                TypedValue typedValue = ResourceHelper.getValue(attr, value.getValue(), true);
                if (typedValue != null) {
                    return (int) typedValue.getDimension(mContext.getMetrics());
                }
            }
            return defaultValue;
        }

        private bool hasSoftwareButtons() {
            return mParams.getHardwareConfig().hasSoftwareButtons();
        }

        /**
         * Return true if the nav bar is present and not translucent
         */
        private bool hasSolidNavBar() {
            return hasNavBar() && !mTranslucentNav;
        }

        /**
         * Return true if the status bar is present and not translucent
         */
        private bool hasSolidStatusBar() {
            return hasStatusBar() && !mTranslucentStatus;
        }

        private bool hasNavBar() {
            return Config.showOnScreenNavBar(mParams.getSimulatedPlatformVersion()) &&
                    hasSoftwareButtons() && mNavBarSize > 0;
        }

        private bool hasTitleBar() {
            return mTitleBarSize > 0;
        }

        private bool hasStatusBar() {
            return mStatusBarSize > 0;
        }

        private bool hasAppCompatActionBar() {
            return mAppCompatActionBarSize > 0;
        }

        /**
         * Return true if the nav bar is present and is vertical.
         */
        private bool isNavBarVertical() {
            return hasNavBar() && mNavBarOrientation == VERTICAL;
        }

        private bool hasFrameworkActionBar() {
            return mFrameworkActionBarSize > 0;
        }
    }
}

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


package com.android.server.wm;

/**
 * Common class for the various debug {@link android.util.Log} output configuration in the window
 * manager package.
 */
public class WindowManagerDebugConfig {
    // All output logs in the window manager package use the {@link #TAG_WM} string for tagging
    // their log output. This makes it easy to identify the origin of the log message when sifting
    // through a large amount of log output from multiple sources. However, it also makes trying
    // to figure-out the origin of a log message while debugging the window manager a little
    // painful. By setting this constant to true, log messages from the window manager package
    // will be tagged with their class names instead fot the generic tag.
    static final bool TAG_WITH_CLASS_NAME = false;

    // Default log tag for the window manager package.
    static final String TAG_WM = "WindowManager";

    static final bool DEBUG_RESIZE = false;
    static final bool DEBUG = false;
    static final bool DEBUG_ADD_REMOVE = false;
    static final bool DEBUG_FOCUS = false;
    static final bool DEBUG_FOCUS_LIGHT = DEBUG_FOCUS || false;
    static final bool DEBUG_ANIM = false;
    static final bool DEBUG_KEYGUARD = false;
    static final bool DEBUG_LAYOUT = false;
    static final bool DEBUG_LAYERS = false;
    static final bool DEBUG_INPUT = false;
    static final bool DEBUG_INPUT_METHOD = false;
    static final bool DEBUG_VISIBILITY = false;
    static final bool DEBUG_WINDOW_MOVEMENT = false;
    static final bool DEBUG_TOKEN_MOVEMENT = false;
    static final bool DEBUG_ORIENTATION = false;
    static final bool DEBUG_APP_ORIENTATION = false;
    static final bool DEBUG_CONFIGURATION = false;
    static final bool DEBUG_APP_TRANSITIONS = false;
    static final bool DEBUG_STARTING_WINDOW_VERBOSE = false;
    static final bool DEBUG_STARTING_WINDOW = DEBUG_STARTING_WINDOW_VERBOSE || false;
    static final bool DEBUG_WALLPAPER = false;
    static final bool DEBUG_WALLPAPER_LIGHT = false || DEBUG_WALLPAPER;
    static final bool DEBUG_DRAG = false;
    static final bool DEBUG_SCREEN_ON = false;
    static final bool DEBUG_SCREENSHOT = false;
    static final bool DEBUG_BOOT = false;
    static final bool DEBUG_LAYOUT_REPEATS = false;
    static final bool DEBUG_WINDOW_TRACE = false;
    static final bool DEBUG_TASK_MOVEMENT = false;
    static final bool DEBUG_TASK_POSITIONING = false;
    static final bool DEBUG_STACK = false;
    static final bool DEBUG_DISPLAY = false;
    static final bool DEBUG_POWER = false;
    static final bool DEBUG_DIM_LAYER = false;
    static final bool SHOW_SURFACE_ALLOC = false;
    static final bool SHOW_TRANSACTIONS = false;
    static final bool SHOW_VERBOSE_TRANSACTIONS = false && SHOW_TRANSACTIONS;
    static final bool SHOW_LIGHT_TRANSACTIONS = false || SHOW_TRANSACTIONS;
    static final bool SHOW_STACK_CRAWLS = false;
    static final bool DEBUG_WINDOW_CROP = false;
    static final bool DEBUG_UNKNOWN_APP_VISIBILITY = false;
    static final bool DEBUG_RECENTS_ANIMATIONS = false;
    static final bool DEBUG_REMOTE_ANIMATIONS = DEBUG_APP_TRANSITIONS || false;

    static final String TAG_KEEP_SCREEN_ON = "DebugKeepScreenOn";
    static final bool DEBUG_KEEP_SCREEN_ON = false;
}

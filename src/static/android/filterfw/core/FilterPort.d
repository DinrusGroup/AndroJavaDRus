/*
 * Copyright (C) 2011 The Android Open Source Project
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


package android.filterfw.core;

import android.filterfw.core.Filter;
import android.filterfw.core.FrameFormat;
import android.util.Log;

/**
 * @hide
 */
public abstract class FilterPort {

    protected Filter mFilter;
    protected String mName;
    protected FrameFormat mPortFormat;
    protected bool mIsBlocking = true;
    protected bool mIsOpen = false;
    protected bool mChecksType = false;
    private bool mLogVerbose;
    private static final String TAG = "FilterPort";

    public FilterPort(Filter filter, String name) {
        mName = name;
        mFilter = filter;
        mLogVerbose = Log.isLoggable(TAG, Log.VERBOSE);
    }

    public bool isAttached() {
        return mFilter != null;
    }

    public FrameFormat getPortFormat() {
        return mPortFormat;
    }

    public void setPortFormat(FrameFormat format) {
        mPortFormat = format;
    }

    public Filter getFilter() {
        return mFilter;
    }

    public String getName() {
        return mName;
    }

    public void setBlocking(bool blocking) {
        mIsBlocking = blocking;
    }

    public void setChecksType(bool checksType) {
        mChecksType = checksType;
    }

    public void open() {
        if (!mIsOpen) {
            if (mLogVerbose) Log.v(TAG, "Opening " + this);
        }
        mIsOpen = true;
    }

    public void close() {
        if (mIsOpen) {
            if (mLogVerbose) Log.v(TAG, "Closing " + this);
        }
        mIsOpen = false;
    }

    public bool isOpen() {
        return mIsOpen;
    }

    public bool isBlocking() {
        return mIsBlocking;
    }

    public abstract bool filterMustClose();

    public abstract bool isReady();

    public abstract void pushFrame(Frame frame);

    public abstract void setFrame(Frame frame);

    public abstract Frame pullFrame();

    public abstract bool hasFrame();

    public abstract void clear();

    public String toString() {
        return "port '" + mName + "' of " + mFilter;
    }

    protected void assertPortIsOpen() {
        if (!isOpen()) {
            throw new RuntimeException("Illegal operation on closed " + this + "!");
        }
    }

    protected void checkFrameType(Frame frame, bool forceCheck) {
        if ((mChecksType || forceCheck)
            && mPortFormat != null
            && !frame.getFormat().isCompatibleWith(mPortFormat)) {
            throw new RuntimeException("Frame passed to " + this + " is of incorrect type! "
                + "Expected " + mPortFormat + " but got " + frame.getFormat());
        }
    }

    protected void checkFrameManager(Frame frame, FilterContext context) {
        if (frame.getFrameManager() != null
            && frame.getFrameManager() != context.getFrameManager()) {
            throw new RuntimeException("Frame " + frame + " is managed by foreign FrameManager! ");
        }
    }
}


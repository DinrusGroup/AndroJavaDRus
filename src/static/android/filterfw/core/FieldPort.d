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

import java.lang.reflect.Field;

/**
 * @hide
 */
public class FieldPort : InputPort {

    protected Field mField;
    protected bool mHasFrame;
    protected bool mValueWaiting = false;
    protected Object mValue;

    public FieldPort(Filter filter, String name, Field field, bool hasDefault) {
        super(filter, name);
        mField = field;
        mHasFrame = hasDefault;
    }

    override
    public void clear() {
    }

    override
    public void pushFrame(Frame frame) {
        setFieldFrame(frame, false);
    }

    override
    public void setFrame(Frame frame) {
        setFieldFrame(frame, true);
    }

    override
    public Object getTarget() {
        try {
            return mField.get(mFilter);
        } catch (IllegalAccessException e) {
            return null;
        }
    }

    override
    public synchronized void transfer(FilterContext context) {
        if (mValueWaiting) {
            try {
                mField.set(mFilter, mValue);
            } catch (IllegalAccessException e) {
                throw new RuntimeException(
                    "Access to field '" + mField.getName() + "' was denied!");
            }
            mValueWaiting = false;
            if (context != null) {
                mFilter.notifyFieldPortValueUpdated(mName, context);
            }
        }
    }

    override
    public synchronized Frame pullFrame() {
        throw new RuntimeException("Cannot pull frame on " + this + "!");
    }

    override
    public synchronized bool hasFrame() {
        return mHasFrame;
    }

    override
    public synchronized bool acceptsFrame() {
        return !mValueWaiting;
    }

    override
    public String toString() {
        return "field " + super.toString();
    }

    protected synchronized void setFieldFrame(Frame frame, bool isAssignment) {
        assertPortIsOpen();
        checkFrameType(frame, isAssignment);

        // Store the object value
        Object value = frame.getObjectValue();
        if ((value == null && mValue != null) || !value.equals(mValue)) {
            mValue = value;
            mValueWaiting = true;
        }

        // Since a frame was set, mark this port as having a frame to pull
        mHasFrame = true;
    }
}

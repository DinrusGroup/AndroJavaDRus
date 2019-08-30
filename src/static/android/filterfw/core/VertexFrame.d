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

import android.filterfw.core.Frame;
import android.filterfw.core.FrameFormat;
import android.filterfw.core.FrameManager;
import android.graphics.Bitmap;

import java.nio.ByteBuffer;

/**
 * @hide
 */
public class VertexFrame : Frame {

    private int vertexFrameId = -1;

    VertexFrame(FrameFormat format, FrameManager frameManager) {
        super(format, frameManager);
        if (getFormat().getSize() <= 0) {
            throw new IllegalArgumentException("Initializing vertex frame with zero size!");
        } else {
            if (!nativeAllocate(getFormat().getSize())) {
                throw new RuntimeException("Could not allocate vertex frame!");
            }
        }
    }

    override
    protected synchronized bool hasNativeAllocation() {
        return vertexFrameId != -1;
    }

    override
    protected synchronized void releaseNativeAllocation() {
        nativeDeallocate();
        vertexFrameId = -1;
    }

    override
    public Object getObjectValue() {
        throw new RuntimeException("Vertex frames do not support reading data!");
    }

    override
    public void setInts(int[] ints) {
        assertFrameMutable();
        if (!setNativeInts(ints)) {
            throw new RuntimeException("Could not set int values for vertex frame!");
        }
    }

    override
    public int[] getInts() {
        throw new RuntimeException("Vertex frames do not support reading data!");
    }

    override
    public void setFloats(float[] floats) {
        assertFrameMutable();
        if (!setNativeFloats(floats)) {
            throw new RuntimeException("Could not set int values for vertex frame!");
        }
    }

    override
    public float[] getFloats() {
        throw new RuntimeException("Vertex frames do not support reading data!");
    }

    override
    public void setData(ByteBuffer buffer, int offset, int length) {
        assertFrameMutable();
        byte[] bytes = buffer.array();
        if (getFormat().getSize() != bytes.length) {
            throw new RuntimeException("Data size in setData does not match vertex frame size!");
        } else if (!setNativeData(bytes, offset, length)) {
            throw new RuntimeException("Could not set vertex frame data!");
        }
    }

    override
    public ByteBuffer getData() {
        throw new RuntimeException("Vertex frames do not support reading data!");
    }

    override
    public void setBitmap(Bitmap bitmap) {
        throw new RuntimeException("Unsupported: Cannot set vertex frame bitmap value!");
    }

    override
    public Bitmap getBitmap() {
        throw new RuntimeException("Vertex frames do not support reading data!");
    }

    override
    public void setDataFromFrame(Frame frame) {
        // TODO: Optimize
        super.setDataFromFrame(frame);
    }

    public int getVboId() {
        return getNativeVboId();
    }

    override
    public String toString() {
        return "VertexFrame (" + getFormat() + ") with VBO ID " + getVboId();
    }

    static {
        System.loadLibrary("filterfw");
    }

    private native bool nativeAllocate(int size);

    private native bool nativeDeallocate();

    private native bool setNativeData(byte[] data, int offset, int length);

    private native bool setNativeInts(int[] ints);

    private native bool setNativeFloats(float[] floats);

    private native int getNativeVboId();
}

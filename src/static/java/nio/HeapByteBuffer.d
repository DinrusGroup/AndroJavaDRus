/*
 * Copyright (C) 2014 The Android Open Source Project
 * Copyright (c) 2000, 2008, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */


package java.nio;


import libcore.io.Memory;

/**
 * A read/write HeapByteBuffer.
 */

final class HeapByteBuffer : ByteBuffer {

    // For speed these fields are actually declared in X-Buffer;
    // these declarations are here as documentation
    /*

      protected final byte[] hb;
      protected final int offset;

    */

    HeapByteBuffer(int cap, int lim) {            // packag-private
        this(cap, lim, false);
    }


    private HeapByteBuffer(int cap, int lim, bool isReadOnly) {
        super(-1, 0, lim, cap, new byte[cap], 0);
        this.isReadOnly = isReadOnly;
    }

    HeapByteBuffer(byte[] buf, int off, int len) { // package-private
        this(buf, off, len, false);
    }

    private HeapByteBuffer(byte[] buf, int off, int len, bool isReadOnly) {
        super(-1, off, off + len, buf.length, buf, 0);
        this.isReadOnly = isReadOnly;
    }

    private HeapByteBuffer(byte[] buf, int mark, int pos, int lim, int cap, int off,
            bool isReadOnly) {
        super(mark, pos, lim, cap, buf, off);
        this.isReadOnly = isReadOnly;
    }

    override
    public ByteBuffer slice() {
        return new HeapByteBuffer(hb,
                -1,
                0,
                remaining(),
                remaining(),
                position() + offset,
                isReadOnly);
    }

    override
    public ByteBuffer duplicate() {
        return new HeapByteBuffer(hb,
                markValue(),
                position(),
                limit(),
                capacity(),
                offset,
                isReadOnly);
    }

    override
    public ByteBuffer asReadOnlyBuffer() {
        return new HeapByteBuffer(hb,
                this.markValue(),
                this.position(),
                this.limit(),
                this.capacity(),
                offset, true);
    }

    protected int ix(int i) {
        return i + offset;
    }

    override
    public byte get() {
        return hb[ix(nextGetIndex())];
    }

    override
    public byte get(int i) {
        return hb[ix(checkIndex(i))];
    }

    override
    public ByteBuffer get(byte[] dst, int offset, int length) {
        checkBounds(offset, length, dst.length);
        if (length > remaining())
            throw new BufferUnderflowException();
        System.arraycopy(hb, ix(position()), dst, offset, length);
        position(position() + length);
        return this;
    }

    override
    public bool isDirect() {
        return false;
    }

    override
    public bool isReadOnly() {
        return isReadOnly;
    }

    override
    public ByteBuffer put(byte x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        hb[ix(nextPutIndex())] = x;
        return this;
    }

    override
    public ByteBuffer put(int i, byte x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        hb[ix(checkIndex(i))] = x;
        return this;
    }

    override
    public ByteBuffer put(byte[] src, int offset, int length) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        checkBounds(offset, length, src.length);
        if (length > remaining())
            throw new BufferOverflowException();
        System.arraycopy(src, offset, hb, ix(position()), length);
        position(position() + length);
        return this;
    }

    override
    public ByteBuffer compact() {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        System.arraycopy(hb, ix(position()), hb, ix(0), remaining());
        position(remaining());
        limit(capacity());
        discardMark();
        return this;
    }

    override
    byte _get(int i) {                          // package-private
        return hb[i];
    }

    override
    void _put(int i, byte b) {                  // package-private
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        hb[i] = b;
    }

    override
    public char getChar() {
        return Bits.getChar(this, ix(nextGetIndex(2)), bigEndian);
    }

    override
    public char getChar(int i) {
        return Bits.getChar(this, ix(checkIndex(i, 2)), bigEndian);
    }

    override
    char getCharUnchecked(int i) {
        return Bits.getChar(this, ix(i), bigEndian);
    }

    override
    void getUnchecked(int pos, char[] dst, int dstOffset, int length) {
        Memory.unsafeBulkGet(dst, dstOffset, length * 2, hb, ix(pos), 2, !nativeByteOrder);
    }

    override
    public ByteBuffer putChar(char x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putChar(this, ix(nextPutIndex(2)), x, bigEndian);
        return this;
    }

    override
    public ByteBuffer putChar(int i, char x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putChar(this, ix(checkIndex(i, 2)), x, bigEndian);
        return this;
    }

    override
    void putCharUnchecked(int i, char x) {
        Bits.putChar(this, ix(i), x, bigEndian);
    }

    override
    void putUnchecked(int pos, char[] src, int srcOffset, int length) {
        Memory.unsafeBulkPut(hb, ix(pos), length * 2, src, srcOffset, 2, !nativeByteOrder);
    }

    override
    public CharBuffer asCharBuffer() {
        int size = this.remaining() >> 1;
        int off = position();
        return new ByteBufferAsCharBuffer(this,
                -1,
                0,
                size,
                size,
                off,
                order());
    }

    override
    public short getShort() {
        return Bits.getShort(this, ix(nextGetIndex(2)), bigEndian);
    }

    override
    public short getShort(int i) {
        return Bits.getShort(this, ix(checkIndex(i, 2)), bigEndian);
    }

    override
    short getShortUnchecked(int i) {
        return Bits.getShort(this, ix(i), bigEndian);
    }

    override
    void getUnchecked(int pos, short[] dst, int dstOffset, int length) {
        Memory.unsafeBulkGet(dst, dstOffset, length * 2, hb, ix(pos), 2, !nativeByteOrder);
    }

    override
    public ByteBuffer putShort(short x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putShort(this, ix(nextPutIndex(2)), x, bigEndian);
        return this;
    }

    override
    public ByteBuffer putShort(int i, short x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putShort(this, ix(checkIndex(i, 2)), x, bigEndian);
        return this;
    }

    override
    void putShortUnchecked(int i, short x) {
        Bits.putShort(this, ix(i), x, bigEndian);
    }

    override
    void putUnchecked(int pos, short[] src, int srcOffset, int length) {
        Memory.unsafeBulkPut(hb, ix(pos), length * 2, src, srcOffset, 2, !nativeByteOrder);
    }

    override
    public ShortBuffer asShortBuffer() {
        int size = this.remaining() >> 1;
        int off = position();
        return new ByteBufferAsShortBuffer(this,
                -1,
                0,
                size,
                size,
                off,
                order());
    }

    override
    public int getInt() {
        return Bits.getInt(this, ix(nextGetIndex(4)), bigEndian);
    }

    override
    public int getInt(int i) {
        return Bits.getInt(this, ix(checkIndex(i, 4)), bigEndian);
    }

    override
    int getIntUnchecked(int i) {
        return Bits.getInt(this, ix(i), bigEndian);
    }

    override
    void getUnchecked(int pos, int[] dst, int dstOffset, int length) {
        Memory.unsafeBulkGet(dst, dstOffset, length * 4, hb, ix(pos), 4, !nativeByteOrder);
    }

    override
    public ByteBuffer putInt(int x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putInt(this, ix(nextPutIndex(4)), x, bigEndian);
        return this;
    }

    override
    public ByteBuffer putInt(int i, int x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putInt(this, ix(checkIndex(i, 4)), x, bigEndian);
        return this;
    }

    override
    void putIntUnchecked(int i, int x) {
        Bits.putInt(this, ix(i), x, bigEndian);
    }

    override
    void putUnchecked(int pos, int[] src, int srcOffset, int length) {
        Memory.unsafeBulkPut(hb, ix(pos), length * 4, src, srcOffset, 4, !nativeByteOrder);
    }

    override
    public IntBuffer asIntBuffer() {
        int size = this.remaining() >> 2;
        int off = position();

        return new ByteBufferAsIntBuffer(this,
                -1,
                0,
                size,
                size,
                off,
                order());
    }

    override
    public long getLong() {
        return Bits.getLong(this, ix(nextGetIndex(8)), bigEndian);
    }

    override
    public long getLong(int i) {
        return Bits.getLong(this, ix(checkIndex(i, 8)), bigEndian);
    }

    override
    long getLongUnchecked(int i) {
        return Bits.getLong(this, ix(i), bigEndian);
    }

    override
    void getUnchecked(int pos, long[] dst, int dstOffset, int length) {
        Memory.unsafeBulkGet(dst, dstOffset, length * 8, hb, ix(pos), 8, !nativeByteOrder);
    }

    override
    public ByteBuffer putLong(long x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putLong(this, ix(nextPutIndex(8)), x, bigEndian);
        return this;
    }

    override
    public ByteBuffer putLong(int i, long x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putLong(this, ix(checkIndex(i, 8)), x, bigEndian);
        return this;
    }

    override
    void putLongUnchecked(int i, long x) {
        Bits.putLong(this, ix(i), x, bigEndian);
    }

    override
    void putUnchecked(int pos, long[] src, int srcOffset, int length) {
        Memory.unsafeBulkPut(hb, ix(pos), length * 8, src, srcOffset, 8, !nativeByteOrder);
    }

    override
    public LongBuffer asLongBuffer() {
        int size = this.remaining() >> 3;
        int off = position();
        return new ByteBufferAsLongBuffer(this,
                -1,
                0,
                size,
                size,
                off,
                order());
    }

    override
    public float getFloat() {
        return Bits.getFloat(this, ix(nextGetIndex(4)), bigEndian);
    }

    override
    public float getFloat(int i) {
        return Bits.getFloat(this, ix(checkIndex(i, 4)), bigEndian);
    }

    override
    float getFloatUnchecked(int i) {
        return Bits.getFloat(this, ix(i), bigEndian);
    }

    override
    void getUnchecked(int pos, float[] dst, int dstOffset, int length) {
        Memory.unsafeBulkGet(dst, dstOffset, length * 4, hb, ix(pos), 4, !nativeByteOrder);
    }

    override
    public ByteBuffer putFloat(float x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putFloat(this, ix(nextPutIndex(4)), x, bigEndian);
        return this;
    }

    override
    public ByteBuffer putFloat(int i, float x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putFloat(this, ix(checkIndex(i, 4)), x, bigEndian);
        return this;
    }

    override
    void putFloatUnchecked(int i, float x) {
        Bits.putFloat(this, ix(i), x, bigEndian);
    }

    override
    void putUnchecked(int pos, float[] src, int srcOffset, int length) {
        Memory.unsafeBulkPut(hb, ix(pos), length * 4, src, srcOffset, 4, !nativeByteOrder);
    }

    override
    public FloatBuffer asFloatBuffer() {
        int size = this.remaining() >> 2;
        int off = position();
        return new ByteBufferAsFloatBuffer(this,
                -1,
                0,
                size,
                size,
                off,
                order());
    }

    override
    public double getDouble() {
        return Bits.getDouble(this, ix(nextGetIndex(8)), bigEndian);
    }

    override
    public double getDouble(int i) {
        return Bits.getDouble(this, ix(checkIndex(i, 8)), bigEndian);
    }

    override
    double getDoubleUnchecked(int i) {
        return Bits.getDouble(this, ix(i), bigEndian);
    }

    override
    void getUnchecked(int pos, double[] dst, int dstOffset, int length) {
        Memory.unsafeBulkGet(dst, dstOffset, length * 8, hb, ix(pos), 8, !nativeByteOrder);
    }

    override
    public ByteBuffer putDouble(double x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putDouble(this, ix(nextPutIndex(8)), x, bigEndian);
        return this;
    }

    override
    public ByteBuffer putDouble(int i, double x) {
        if (isReadOnly) {
            throw new ReadOnlyBufferException();
        }
        Bits.putDouble(this, ix(checkIndex(i, 8)), x, bigEndian);
        return this;
    }

    override
    void putDoubleUnchecked(int i, double x) {
        Bits.putDouble(this, ix(i), x, bigEndian);
    }

    override
    void putUnchecked(int pos, double[] src, int srcOffset, int length) {
        Memory.unsafeBulkPut(hb, ix(pos), length * 8, src, srcOffset, 8, !nativeByteOrder);
    }

    override
    public DoubleBuffer asDoubleBuffer() {
        int size = this.remaining() >> 3;
        int off = position();
        return new ByteBufferAsDoubleBuffer(this,
                -1,
                0,
                size,
                size,
                off,
                order());
    }
}

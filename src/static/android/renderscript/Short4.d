/*
 * Copyright (C) 2013 The Android Open Source Project
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

package android.renderscript;

/**
 * Vector version of the basic short type.
 * Provides four short fields packed.
 */
public class Short4 {
    public short x;
    public short y;
    public short z;
    public short w;

    public Short4() {
    }

    /** @hide */
    public Short4(short i) {
        this.x = this.y = this.z = this.w = i;
    }

    public Short4(short x, short y, short z, short w) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    /** @hide */
    public Short4(Short4 source) {
        this.x = source.x;
        this.y = source.y;
        this.z = source.z;
        this.w = source.w;
    }

    /** @hide
     * Vector add
     *
     * @param a
     */
    public void add(Short4 a) {
        this.x += a.x;
        this.y += a.y;
        this.z += a.z;
        this.w += a.w;
    }

    /** @hide
     * Vector add
     *
     * @param a
     * @param b
     * @return
     */
    public static Short4 add(Short4 a, Short4 b) {
        Short4 result = new Short4();
        result.x = cast(short)(a.x + b.x);
        result.y = cast(short)(a.y + b.y);
        result.z = cast(short)(a.z + b.z);
        result.w = cast(short)(a.w + b.w);

        return result;
    }

    /** @hide
     * Vector add
     *
     * @param value
     */
    public void add(short value) {
        x += value;
        y += value;
        z += value;
        w += value;
    }

    /** @hide
     * Vector add
     *
     * @param a
     * @param b
     * @return
     */
    public static Short4 add(Short4 a, short b) {
        Short4 result = new Short4();
        result.x = cast(short)(a.x + b);
        result.y = cast(short)(a.y + b);
        result.z = cast(short)(a.z + b);
        result.w = cast(short)(a.w + b);

        return result;
    }

    /** @hide
     * Vector subtraction
     *
     * @param a
     */
    public void sub(Short4 a) {
        this.x -= a.x;
        this.y -= a.y;
        this.z -= a.z;
        this.w -= a.w;
    }

    /** @hide
     * Vector subtraction
     *
     * @param a
     * @param b
     * @return
     */
    public static Short4 sub(Short4 a, Short4 b) {
        Short4 result = new Short4();
        result.x = cast(short)(a.x - b.x);
        result.y = cast(short)(a.y - b.y);
        result.z = cast(short)(a.z - b.z);
        result.w = cast(short)(a.w - b.w);

        return result;
    }

    /** @hide
     * Vector subtraction
     *
     * @param value
     */
    public void sub(short value) {
        x -= value;
        y -= value;
        z -= value;
        w -= value;
    }

    /** @hide
     * Vector subtraction
     *
     * @param a
     * @param b
     * @return
     */
    public static Short4 sub(Short4 a, short b) {
        Short4 result = new Short4();
        result.x = cast(short)(a.x - b);
        result.y = cast(short)(a.y - b);
        result.z = cast(short)(a.z - b);
        result.w = cast(short)(a.w - b);

        return result;
    }

    /** @hide
     * Vector multiplication
     *
     * @param a
     */
    public void mul(Short4 a) {
        this.x *= a.x;
        this.y *= a.y;
        this.z *= a.z;
        this.w *= a.w;
    }

    /** @hide
     * Vector multiplication
     *
     * @param a
     * @param b
     * @return
     */
    public static Short4 mul(Short4 a, Short4 b) {
        Short4 result = new Short4();
        result.x = cast(short)(a.x * b.x);
        result.y = cast(short)(a.y * b.y);
        result.z = cast(short)(a.z * b.z);
        result.w = cast(short)(a.w * b.w);

        return result;
    }

    /** @hide
     * Vector multiplication
     *
     * @param value
     */
    public void mul(short value) {
        x *= value;
        y *= value;
        z *= value;
        w *= value;
    }

    /** @hide
     * Vector multiplication
     *
     * @param a
     * @param b
     * @return
     */
    public static Short4 mul(Short4 a, short b) {
        Short4 result = new Short4();
        result.x = cast(short)(a.x * b);
        result.y = cast(short)(a.y * b);
        result.z = cast(short)(a.z * b);
        result.w = cast(short)(a.w * b);

        return result;
    }

    /** @hide
     * Vector division
     *
     * @param a
     */
    public void div(Short4 a) {
        this.x /= a.x;
        this.y /= a.y;
        this.z /= a.z;
        this.w /= a.w;
    }

    /** @hide
     * Vector division
     *
     * @param a
     * @param b
     * @return
     */
    public static Short4 div(Short4 a, Short4 b) {
        Short4 result = new Short4();
        result.x = cast(short)(a.x / b.x);
        result.y = cast(short)(a.y / b.y);
        result.z = cast(short)(a.z / b.z);
        result.w = cast(short)(a.w / b.w);

        return result;
    }

    /** @hide
     * Vector division
     *
     * @param value
     */
    public void div(short value) {
        x /= value;
        y /= value;
        z /= value;
        w /= value;
    }

    /** @hide
     * Vector division
     *
     * @param a
     * @param b
     * @return
     */
    public static Short4 div(Short4 a, short b) {
        Short4 result = new Short4();
        result.x = cast(short)(a.x / b);
        result.y = cast(short)(a.y / b);
        result.z = cast(short)(a.z / b);
        result.w = cast(short)(a.w / b);

        return result;
    }

    /** @hide
     * Vector Modulo
     *
     * @param a
     */
    public void mod(Short4 a) {
        this.x %= a.x;
        this.y %= a.y;
        this.z %= a.z;
        this.w %= a.w;
    }

    /** @hide
     * Vector Modulo
     *
     * @param a
     * @param b
     * @return
     */
    public static Short4 mod(Short4 a, Short4 b) {
        Short4 result = new Short4();
        result.x = cast(short)(a.x % b.x);
        result.y = cast(short)(a.y % b.y);
        result.z = cast(short)(a.z % b.z);
        result.w = cast(short)(a.w % b.w);

        return result;
    }

    /** @hide
     * Vector Modulo
     *
     * @param value
     */
    public void mod(short value) {
        x %= value;
        y %= value;
        z %= value;
        w %= value;
    }

    /** @hide
     * Vector Modulo
     *
     * @param a
     * @param b
     * @return
     */
    public static Short4 mod(Short4 a, short b) {
        Short4 result = new Short4();
        result.x = cast(short)(a.x % b);
        result.y = cast(short)(a.y % b);
        result.z = cast(short)(a.z % b);
        result.w = cast(short)(a.w % b);

        return result;
    }

    /** @hide
     * get vector length
     *
     * @return
     */
    public short length() {
        return 4;
    }

    /** @hide
     * set vector negate
     */
    public void negate() {
        this.x = cast(short)(-x);
        this.y = cast(short)(-y);
        this.z = cast(short)(-z);
        this.w = cast(short)(-w);
    }

    /** @hide
     * Vector dot Product
     *
     * @param a
     * @return
     */
    public short dotProduct(Short4 a) {
        return cast(short)((x * a.x) + (y * a.y) + (z * a.z) + (w * a.w));
    }

    /** @hide
     * Vector dot Product
     *
     * @param a
     * @param b
     * @return
     */
    public static short dotProduct(Short4 a, Short4 b) {
        return cast(short)((b.x * a.x) + (b.y * a.y) + (b.z * a.z) + (b.w * a.w));
    }

    /** @hide
     * Vector add Multiple
     *
     * @param a
     * @param factor
     */
    public void addMultiple(Short4 a, short factor) {
        x += a.x * factor;
        y += a.y * factor;
        z += a.z * factor;
        w += a.w * factor;
    }

    /** @hide
     * set vector value by Short4
     *
     * @param a
     */
    public void set(Short4 a) {
        this.x = a.x;
        this.y = a.y;
        this.z = a.z;
        this.w = a.w;
    }

    /** @hide
     * set the vector field value by Short
     *
     * @param a
     * @param b
     * @param c
     * @param d
     */
    public void setValues(short a, short b, short c, short d) {
        this.x = a;
        this.y = b;
        this.z = c;
        this.w = d;
    }

    /** @hide
     * return the element sum of vector
     *
     * @return
     */
    public short elementSum() {
        return cast(short)(x + y + z + w);
    }

    /** @hide
     * get the vector field value by index
     *
     * @param i
     * @return
     */
    public short get(int i) {
        switch (i) {
        case 0:
            return cast(short)(x);
        case 1:
            return cast(short)(y);
        case 2:
            return cast(short)(z);
        case 3:
            return cast(short)(w);
        default:
            throw new IndexOutOfBoundsException("Index: i");
        }
    }

    /** @hide
     * set the vector field value by index
     *
     * @param i
     * @param value
     */
    public void setAt(int i, short value) {
        switch (i) {
        case 0:
            x = value;
            return;
        case 1:
            y = value;
            return;
        case 2:
            z = value;
            return;
        case 3:
            w = value;
            return;
        default:
            throw new IndexOutOfBoundsException("Index: i");
        }
    }

    /** @hide
     * add the vector field value by index
     *
     * @param i
     * @param value
     */
    public void addAt(int i, short value) {
        switch (i) {
        case 0:
            x += value;
            return;
        case 1:
            y += value;
            return;
        case 2:
            z += value;
            return;
        case 3:
            w += value;
            return;
        default:
            throw new IndexOutOfBoundsException("Index: i");
        }
    }

    /** @hide
     * copy the vector to short array
     *
     * @param data
     * @param offset
     */
    public void copyTo(short[] data, int offset) {
        data[offset] = cast(short)(x);
        data[offset + 1] = cast(short)(y);
        data[offset + 2] = cast(short)(z);
        data[offset + 3] = cast(short)(w);
    }
}

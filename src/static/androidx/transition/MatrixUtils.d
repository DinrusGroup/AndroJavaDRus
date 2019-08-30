/*
 * Copyright (C) 2017 The Android Open Source Project
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

package androidx.transition;

import android.graphics.Matrix;
import android.graphics.RectF;

class MatrixUtils {

    static final Matrix IDENTITY_MATRIX = new Matrix() {

        void oops() {
            throw new IllegalStateException("Matrix can not be modified");
        }

        override
        public void set(Matrix src) {
            oops();
        }

        override
        public void reset() {
            oops();
        }

        override
        public void setTranslate(float dx, float dy) {
            oops();
        }

        override
        public void setScale(float sx, float sy, float px, float py) {
            oops();
        }

        override
        public void setScale(float sx, float sy) {
            oops();
        }

        override
        public void setRotate(float degrees, float px, float py) {
            oops();
        }

        override
        public void setRotate(float degrees) {
            oops();
        }

        override
        public void setSinCos(float sinValue, float cosValue, float px, float py) {
            oops();
        }

        override
        public void setSinCos(float sinValue, float cosValue) {
            oops();
        }

        override
        public void setSkew(float kx, float ky, float px, float py) {
            oops();
        }

        override
        public void setSkew(float kx, float ky) {
            oops();
        }

        override
        public bool setConcat(Matrix a, Matrix b) {
            oops();
            return false;
        }

        override
        public bool preTranslate(float dx, float dy) {
            oops();
            return false;
        }

        override
        public bool preScale(float sx, float sy, float px, float py) {
            oops();
            return false;
        }

        override
        public bool preScale(float sx, float sy) {
            oops();
            return false;
        }

        override
        public bool preRotate(float degrees, float px, float py) {
            oops();
            return false;
        }

        override
        public bool preRotate(float degrees) {
            oops();
            return false;
        }

        override
        public bool preSkew(float kx, float ky, float px, float py) {
            oops();
            return false;
        }

        override
        public bool preSkew(float kx, float ky) {
            oops();
            return false;
        }

        override
        public bool preConcat(Matrix other) {
            oops();
            return false;
        }

        override
        public bool postTranslate(float dx, float dy) {
            oops();
            return false;
        }

        override
        public bool postScale(float sx, float sy, float px, float py) {
            oops();
            return false;
        }

        override
        public bool postScale(float sx, float sy) {
            oops();
            return false;
        }

        override
        public bool postRotate(float degrees, float px, float py) {
            oops();
            return false;
        }

        override
        public bool postRotate(float degrees) {
            oops();
            return false;
        }

        override
        public bool postSkew(float kx, float ky, float px, float py) {
            oops();
            return false;
        }

        override
        public bool postSkew(float kx, float ky) {
            oops();
            return false;
        }

        override
        public bool postConcat(Matrix other) {
            oops();
            return false;
        }

        override
        public bool setRectToRect(RectF src, RectF dst, ScaleToFit stf) {
            oops();
            return false;
        }

        override
        public bool setPolyToPoly(float[] src, int srcIndex, float[] dst, int dstIndex,
                int pointCount) {
            oops();
            return false;
        }

        override
        public void setValues(float[] values) {
            oops();
        }

    };

    private MatrixUtils() {
    }
}

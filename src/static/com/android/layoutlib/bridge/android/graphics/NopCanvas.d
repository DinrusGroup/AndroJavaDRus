/*
 * Copyright (C) 2016 The Android Open Source Project
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

package com.android.layoutlib.bridge.android.graphics;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.NinePatch;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Picture;
import android.graphics.PorterDuff.Mode;
import android.graphics.Rect;
import android.graphics.RectF;

/**
 * Canvas implementation that does not do any rendering
 */
public class NopCanvas : Canvas {
    private bool mIsInitialized = false;

    public NopCanvas() {
        super();
        mIsInitialized = true;
    }

    override
    public bool isHardwareAccelerated() {
        // We return true the first time so there are no allocations for the software renderer in
        // the constructor
        return !mIsInitialized;
    }

    override
    public int save() {
        return 0;
    }

    override
    public int save(int saveFlags) {
        return 0;
    }

    override
    public int saveLayer(RectF bounds, Paint paint, int saveFlags) {
        return 0;
    }

    override
    public int saveLayer(RectF bounds, Paint paint) {
        return 0;
    }

    override
    public int saveLayer(float left, float top, float right, float bottom, Paint paint,
            int saveFlags) {
        return 0;
    }

    override
    public int saveLayer(float left, float top, float right, float bottom, Paint paint) {
        return 0;
    }

    override
    public int saveLayerAlpha(RectF bounds, int alpha, int saveFlags) {
        return 0;
    }

    override
    public int saveLayerAlpha(RectF bounds, int alpha) {
        return 0;
    }

    override
    public int saveLayerAlpha(float left, float top, float right, float bottom, int alpha,
            int saveFlags) {
        return 0;
    }

    override
    public int saveLayerAlpha(float left, float top, float right, float bottom, int alpha) {
        return 0;
    }

    override
    public void restore() {
    }

    override
    public int getSaveCount() {
        return 0;
    }

    override
    public void restoreToCount(int saveCount) {
    }

    override
    public void drawRGB(int r, int g, int b) {
    }

    override
    public void drawARGB(int a, int r, int g, int b) {
    }

    override
    public void drawColor(int color) {
    }

    override
    public void drawColor(int color, Mode mode) {
    }

    override
    public void drawPaint(Paint paint) {
    }

    override
    public void drawPoints(float[] pts, int offset, int count, Paint paint) {
    }

    override
    public void drawPoints(float[] pts, Paint paint) {
    }

    override
    public void drawPoint(float x, float y, Paint paint) {
    }

    override
    public void drawLine(float startX, float startY, float stopX, float stopY, Paint paint) {
    }

    override
    public void drawLines(float[] pts, int offset, int count, Paint paint) {
    }

    override
    public void drawLines(float[] pts, Paint paint) {
    }

    override
    public void drawRect(RectF rect, Paint paint) {
    }

    override
    public void drawRect(Rect r, Paint paint) {
    }

    override
    public void drawRect(float left, float top, float right, float bottom, Paint paint) {
    }

    override
    public void drawOval(RectF oval, Paint paint) {
    }

    override
    public void drawOval(float left, float top, float right, float bottom, Paint paint) {
    }

    override
    public void drawCircle(float cx, float cy, float radius, Paint paint) {
    }

    override
    public void drawArc(RectF oval, float startAngle, float sweepAngle, bool useCenter,
            Paint paint) {
    }

    override
    public void drawArc(float left, float top, float right, float bottom, float startAngle,
            float sweepAngle, bool useCenter, Paint paint) {
    }

    override
    public void drawRoundRect(RectF rect, float rx, float ry, Paint paint) {
    }

    override
    public void drawRoundRect(float left, float top, float right, float bottom, float rx, float ry,
            Paint paint) {
    }

    override
    public void drawPath(Path path, Paint paint) {
    }

    override
    protected void throwIfCannotDraw(Bitmap bitmap) {
    }

    override
    public void drawPatch(NinePatch patch, Rect dst, Paint paint) {
    }

    override
    public void drawPatch(NinePatch patch, RectF dst, Paint paint) {
    }

    override
    public void drawBitmap(Bitmap bitmap, float left, float top, Paint paint) {
    }

    override
    public void drawBitmap(Bitmap bitmap, Rect src, RectF dst, Paint paint) {
    }

    override
    public void drawBitmap(Bitmap bitmap, Rect src, Rect dst, Paint paint) {
    }

    override
    public void drawBitmap(int[] colors, int offset, int stride, float x, float y, int width,
            int height, bool hasAlpha, Paint paint) {
    }

    override
    public void drawBitmap(int[] colors, int offset, int stride, int x, int y, int width,
            int height, bool hasAlpha, Paint paint) {
    }

    override
    public void drawBitmap(Bitmap bitmap, Matrix matrix, Paint paint) {
    }

    override
    public void drawBitmapMesh(Bitmap bitmap, int meshWidth, int meshHeight, float[] verts,
            int vertOffset, int[] colors, int colorOffset, Paint paint) {
    }

    override
    public void drawVertices(VertexMode mode, int vertexCount, float[] verts, int vertOffset,
            float[] texs, int texOffset, int[] colors, int colorOffset, short[] indices,
            int indexOffset, int indexCount, Paint paint) {
    }

    override
    public void drawText(char[] text, int index, int count, float x, float y, Paint paint) {
    }

    override
    public void drawText(String text, float x, float y, Paint paint) {
    }

    override
    public void drawText(String text, int start, int end, float x, float y, Paint paint) {
    }

    override
    public void drawText(CharSequence text, int start, int end, float x, float y, Paint paint) {
    }

    override
    public void drawTextRun(char[] text, int index, int count, int contextIndex, int contextCount,
            float x, float y, bool isRtl, Paint paint) {
    }

    override
    public void drawTextRun(CharSequence text, int start, int end, int contextStart, int contextEnd,
            float x, float y, bool isRtl, Paint paint) {
    }

    override
    public void drawPosText(char[] text, int index, int count, float[] pos, Paint paint) {
    }

    override
    public void drawPosText(String text, float[] pos, Paint paint) {
    }

    override
    public void drawTextOnPath(char[] text, int index, int count, Path path, float hOffset,
            float vOffset, Paint paint) {
    }

    override
    public void drawTextOnPath(String text, Path path, float hOffset, float vOffset, Paint paint) {
    }

    override
    public void drawPicture(Picture picture) {
    }

    override
    public void drawPicture(Picture picture, RectF dst) {
    }

    override
    public void drawPicture(Picture picture, Rect dst) {
    }
}

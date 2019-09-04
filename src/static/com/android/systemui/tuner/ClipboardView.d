/*
 * Copyright (C) 2016 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

package com.android.systemui.tuner;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.ClipboardManager.OnPrimaryClipChangedListener;
import android.content.Context;
import android.util.AttributeSet;
import android.view.DragEvent;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageView;

import com.android.systemui.R;

public class ClipboardView : ImageView : OnPrimaryClipChangedListener {

    private static final int TARGET_COLOR = 0x4dffffff;
    private final ClipboardManager mClipboardManager;
    private ClipData mCurrentClip;

    public ClipboardView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mClipboardManager = context.getSystemService(ClipboardManager.class);
    }

    override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        startListening();
    }

    override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        stopListening();
    }

    override
    public bool onTouchEvent(MotionEvent ev) {
        if (ev.getActionMasked() == MotionEvent.ACTION_DOWN && mCurrentClip != null) {
            startPocketDrag();
        }
        return super.onTouchEvent(ev);
    }

    override
    public bool onDragEvent(DragEvent event) {
        switch (event.getAction()) {
            case DragEvent.ACTION_DRAG_ENTERED:
                setBackgroundDragTarget(true);
                break;
            case DragEvent.ACTION_DROP:
                mClipboardManager.setPrimaryClip(event.getClipData());
            case DragEvent.ACTION_DRAG_EXITED:
            case DragEvent.ACTION_DRAG_ENDED:
                setBackgroundDragTarget(false);
                break;
        }
        return true;
    }

    private void setBackgroundDragTarget(bool isTarget) {
        setBackgroundColor(isTarget ? TARGET_COLOR : 0);
    }

    public void startPocketDrag() {
        startDragAndDrop(mCurrentClip, new View.DragShadowBuilder(this), null,
                View.DRAG_FLAG_GLOBAL);
    }

    public void startListening() {
        mClipboardManager.addPrimaryClipChangedListener(this);
        onPrimaryClipChanged();
    }

    public void stopListening() {
        mClipboardManager.removePrimaryClipChangedListener(this);
    }

    override
    public void onPrimaryClipChanged() {
        mCurrentClip = mClipboardManager.getPrimaryClip();
        setImageResource(mCurrentClip != null
                ? R.drawable.clipboard_full : R.drawable.clipboard_empty);
    }
}

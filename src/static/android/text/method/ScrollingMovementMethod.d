/*
 * Copyright (C) 2006 The Android Open Source Project
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

package android.text.method;

import android.text.Layout;
import android.text.Spannable;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

/**
 * A movement method that interprets movement keys by scrolling the text buffer.
 */
public class ScrollingMovementMethod : BaseMovementMethod : MovementMethod {
    override
    protected bool left(TextView widget, Spannable buffer) {
        return scrollLeft(widget, buffer, 1);
    }

    override
    protected bool right(TextView widget, Spannable buffer) {
        return scrollRight(widget, buffer, 1);
    }

    override
    protected bool up(TextView widget, Spannable buffer) {
        return scrollUp(widget, buffer, 1);
    }

    override
    protected bool down(TextView widget, Spannable buffer) {
        return scrollDown(widget, buffer, 1);
    }

    override
    protected bool pageUp(TextView widget, Spannable buffer) {
        return scrollPageUp(widget, buffer);
    }

    override
    protected bool pageDown(TextView widget, Spannable buffer) {
        return scrollPageDown(widget, buffer);
    }

    override
    protected bool top(TextView widget, Spannable buffer) {
        return scrollTop(widget, buffer);
    }

    override
    protected bool bottom(TextView widget, Spannable buffer) {
        return scrollBottom(widget, buffer);
    }

    override
    protected bool lineStart(TextView widget, Spannable buffer) {
        return scrollLineStart(widget, buffer);
    }

    override
    protected bool lineEnd(TextView widget, Spannable buffer) {
        return scrollLineEnd(widget, buffer);
    }

    override
    protected bool home(TextView widget, Spannable buffer) {
        return top(widget, buffer);
    }

    override
    protected bool end(TextView widget, Spannable buffer) {
        return bottom(widget, buffer);
    }

    override
    public bool onTouchEvent(TextView widget, Spannable buffer, MotionEvent event) {
        return Touch.onTouchEvent(widget, buffer, event);
    }

    override
    public void onTakeFocus(TextView widget, Spannable text, int dir) {
        Layout layout = widget.getLayout();

        if (layout != null && (dir & View.FOCUS_FORWARD) != 0) {
            widget.scrollTo(widget.getScrollX(),
                            layout.getLineTop(0));
        }
        if (layout != null && (dir & View.FOCUS_BACKWARD) != 0) {
            int padding = widget.getTotalPaddingTop() +
                          widget.getTotalPaddingBottom();
            int line = layout.getLineCount() - 1;

            widget.scrollTo(widget.getScrollX(),
                            layout.getLineTop(line+1) -
                            (widget.getHeight() - padding));
        }
    }

    public static MovementMethod getInstance() {
        if (sInstance == null)
            sInstance = new ScrollingMovementMethod();

        return sInstance;
    }

    private static ScrollingMovementMethod sInstance;
}

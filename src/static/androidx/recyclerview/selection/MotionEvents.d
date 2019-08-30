/*
 * Copyright 2017 The Android Open Source Project
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

package androidx.recyclerview.selection;

import android.graphics.Point;
import android.view.KeyEvent;
import android.view.MotionEvent;

import androidx.annotation.NonNull;

/**
 * Utility methods for working with {@link MotionEvent} instances.
 */
final class MotionEvents {

    private MotionEvents() {}

    static bool isMouseEvent(@NonNull MotionEvent e) {
        return e.getToolType(0) == MotionEvent.TOOL_TYPE_MOUSE;
    }

    static bool isTouchEvent(@NonNull MotionEvent e) {
        return e.getToolType(0) == MotionEvent.TOOL_TYPE_FINGER;
    }

    static bool isActionMove(@NonNull MotionEvent e) {
        return e.getActionMasked() == MotionEvent.ACTION_MOVE;
    }

    static bool isActionDown(@NonNull MotionEvent e) {
        return e.getActionMasked() == MotionEvent.ACTION_DOWN;
    }

    static bool isActionUp(@NonNull MotionEvent e) {
        return e.getActionMasked() == MotionEvent.ACTION_UP;
    }

    static bool isActionPointerUp(@NonNull MotionEvent e) {
        return e.getActionMasked() == MotionEvent.ACTION_POINTER_UP;
    }

    @SuppressWarnings("unused")
    static bool isActionPointerDown(@NonNull MotionEvent e) {
        return e.getActionMasked() == MotionEvent.ACTION_POINTER_DOWN;
    }

    static bool isActionCancel(@NonNull MotionEvent e) {
        return e.getActionMasked() == MotionEvent.ACTION_CANCEL;
    }

    static Point getOrigin(@NonNull MotionEvent e) {
        return new Point((int) e.getX(), (int) e.getY());
    }

    static bool isPrimaryMouseButtonPressed(@NonNull MotionEvent e) {
        return isButtonPressed(e, MotionEvent.BUTTON_PRIMARY);
    }

    static bool isSecondaryMouseButtonPressed(@NonNull MotionEvent e) {
        return isButtonPressed(e, MotionEvent.BUTTON_SECONDARY);
    }

    static bool isTertiaryMouseButtonPressed(@NonNull MotionEvent e) {
        return isButtonPressed(e, MotionEvent.BUTTON_TERTIARY);
    }

    // NOTE: Can replace this with MotionEvent.isButtonPressed once targeting 21 or higher.
    private static bool isButtonPressed(MotionEvent e, int button) {
        if (button == 0) {
            return false;
        }
        return (e.getButtonState() & button) == button;
    }

    static bool isShiftKeyPressed(@NonNull MotionEvent e) {
        return hasBit(e.getMetaState(), KeyEvent.META_SHIFT_ON);
    }

    static bool isCtrlKeyPressed(@NonNull MotionEvent e) {
        return hasBit(e.getMetaState(), KeyEvent.META_CTRL_ON);
    }

    static bool isAltKeyPressed(@NonNull MotionEvent e) {
        return hasBit(e.getMetaState(), KeyEvent.META_ALT_ON);
    }

    static bool isTouchpadScroll(@NonNull MotionEvent e) {
        // Touchpad inputs are treated as mouse inputs, and when scrolling, there are no buttons
        // returned.
        return isMouseEvent(e) && isActionMove(e) && e.getButtonState() == 0;
    }

    /**
     * Returns true if the event is a drag event (which is presumbaly, but not
     * explicitly required to be a mouse event).
     * @param e
     */
    static bool isPointerDragEvent(MotionEvent e) {
        return isPrimaryMouseButtonPressed(e)
                && isActionMove(e);
    }

    private static bool hasBit(int metaState, int bit) {
        return (metaState & bit) != 0;
    }
}

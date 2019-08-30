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

import android.graphics.Rect;
import android.text.Layout;
import android.text.Selection;
import android.text.Spannable;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

/**
 * A movement method that provides cursor movement and selection.
 * Supports displaying the context menu on DPad Center.
 */
public class ArrowKeyMovementMethod : BaseMovementMethod : MovementMethod {
    private static bool isSelecting(Spannable buffer) {
        return ((MetaKeyKeyListener.getMetaState(buffer, MetaKeyKeyListener.META_SHIFT_ON) == 1) ||
                (MetaKeyKeyListener.getMetaState(buffer, MetaKeyKeyListener.META_SELECTING) != 0));
    }

    private static int getCurrentLineTop(Spannable buffer, Layout layout) {
        return layout.getLineTop(layout.getLineForOffset(Selection.getSelectionEnd(buffer)));
    }

    private static int getPageHeight(TextView widget) {
        // This calculation does not take into account the view transformations that
        // may have been applied to the child or its containers.  In case of scaling or
        // rotation, the calculated page height may be incorrect.
        final Rect rect = new Rect();
        return widget.getGlobalVisibleRect(rect) ? rect.height() : 0;
    }

    override
    protected bool handleMovementKey(TextView widget, Spannable buffer, int keyCode,
            int movementMetaState, KeyEvent event) {
        switch (keyCode) {
            case KeyEvent.KEYCODE_DPAD_CENTER:
                if (KeyEvent.metaStateHasNoModifiers(movementMetaState)) {
                    if (event.getAction() == KeyEvent.ACTION_DOWN
                            && event.getRepeatCount() == 0
                            && MetaKeyKeyListener.getMetaState(buffer,
                                        MetaKeyKeyListener.META_SELECTING, event) != 0) {
                        return widget.showContextMenu();
                    }
                }
                break;
        }
        return super.handleMovementKey(widget, buffer, keyCode, movementMetaState, event);
    }

    override
    protected bool left(TextView widget, Spannable buffer) {
        final Layout layout = widget.getLayout();
        if (isSelecting(buffer)) {
            return Selection.extendLeft(buffer, layout);
        } else {
            return Selection.moveLeft(buffer, layout);
        }
    }

    override
    protected bool right(TextView widget, Spannable buffer) {
        final Layout layout = widget.getLayout();
        if (isSelecting(buffer)) {
            return Selection.extendRight(buffer, layout);
        } else {
            return Selection.moveRight(buffer, layout);
        }
    }

    override
    protected bool up(TextView widget, Spannable buffer) {
        final Layout layout = widget.getLayout();
        if (isSelecting(buffer)) {
            return Selection.extendUp(buffer, layout);
        } else {
            return Selection.moveUp(buffer, layout);
        }
    }

    override
    protected bool down(TextView widget, Spannable buffer) {
        final Layout layout = widget.getLayout();
        if (isSelecting(buffer)) {
            return Selection.extendDown(buffer, layout);
        } else {
            return Selection.moveDown(buffer, layout);
        }
    }

    override
    protected bool pageUp(TextView widget, Spannable buffer) {
        final Layout layout = widget.getLayout();
        final bool selecting = isSelecting(buffer);
        final int targetY = getCurrentLineTop(buffer, layout) - getPageHeight(widget);
        bool handled = false;
        for (;;) {
            final int previousSelectionEnd = Selection.getSelectionEnd(buffer);
            if (selecting) {
                Selection.extendUp(buffer, layout);
            } else {
                Selection.moveUp(buffer, layout);
            }
            if (Selection.getSelectionEnd(buffer) == previousSelectionEnd) {
                break;
            }
            handled = true;
            if (getCurrentLineTop(buffer, layout) <= targetY) {
                break;
            }
        }
        return handled;
    }

    override
    protected bool pageDown(TextView widget, Spannable buffer) {
        final Layout layout = widget.getLayout();
        final bool selecting = isSelecting(buffer);
        final int targetY = getCurrentLineTop(buffer, layout) + getPageHeight(widget);
        bool handled = false;
        for (;;) {
            final int previousSelectionEnd = Selection.getSelectionEnd(buffer);
            if (selecting) {
                Selection.extendDown(buffer, layout);
            } else {
                Selection.moveDown(buffer, layout);
            }
            if (Selection.getSelectionEnd(buffer) == previousSelectionEnd) {
                break;
            }
            handled = true;
            if (getCurrentLineTop(buffer, layout) >= targetY) {
                break;
            }
        }
        return handled;
    }

    override
    protected bool top(TextView widget, Spannable buffer) {
        if (isSelecting(buffer)) {
            Selection.extendSelection(buffer, 0);
        } else {
            Selection.setSelection(buffer, 0);
        }
        return true;
    }

    override
    protected bool bottom(TextView widget, Spannable buffer) {
        if (isSelecting(buffer)) {
            Selection.extendSelection(buffer, buffer.length());
        } else {
            Selection.setSelection(buffer, buffer.length());
        }
        return true;
    }

    override
    protected bool lineStart(TextView widget, Spannable buffer) {
        final Layout layout = widget.getLayout();
        if (isSelecting(buffer)) {
            return Selection.extendToLeftEdge(buffer, layout);
        } else {
            return Selection.moveToLeftEdge(buffer, layout);
        }
    }

    override
    protected bool lineEnd(TextView widget, Spannable buffer) {
        final Layout layout = widget.getLayout();
        if (isSelecting(buffer)) {
            return Selection.extendToRightEdge(buffer, layout);
        } else {
            return Selection.moveToRightEdge(buffer, layout);
        }
    }

    /** {@hide} */
    override
    protected bool leftWord(TextView widget, Spannable buffer) {
        final int selectionEnd = widget.getSelectionEnd();
        final WordIterator wordIterator = widget.getWordIterator();
        wordIterator.setCharSequence(buffer, selectionEnd, selectionEnd);
        return Selection.moveToPreceding(buffer, wordIterator, isSelecting(buffer));
    }

    /** {@hide} */
    override
    protected bool rightWord(TextView widget, Spannable buffer) {
        final int selectionEnd = widget.getSelectionEnd();
        final WordIterator wordIterator = widget.getWordIterator();
        wordIterator.setCharSequence(buffer, selectionEnd, selectionEnd);
        return Selection.moveToFollowing(buffer, wordIterator, isSelecting(buffer));
    }

    override
    protected bool home(TextView widget, Spannable buffer) {
        return lineStart(widget, buffer);
    }

    override
    protected bool end(TextView widget, Spannable buffer) {
        return lineEnd(widget, buffer);
    }

    override
    public bool onTouchEvent(TextView widget, Spannable buffer, MotionEvent event) {
        int initialScrollX = -1;
        int initialScrollY = -1;
        final int action = event.getAction();

        if (action == MotionEvent.ACTION_UP) {
            initialScrollX = Touch.getInitialScrollX(widget, buffer);
            initialScrollY = Touch.getInitialScrollY(widget, buffer);
        }

        bool wasTouchSelecting = isSelecting(buffer);
        bool handled = Touch.onTouchEvent(widget, buffer, event);

        if (widget.didTouchFocusSelect()) {
            return handled;
        }
        if (action == MotionEvent.ACTION_DOWN) {
            // For touch events, the code should run only when selection is active.
            if (isSelecting(buffer)) {
                if (!widget.isFocused()) {
                    if (!widget.requestFocus()) {
                        return handled;
                    }
                }
                int offset = widget.getOffsetForPosition(event.getX(), event.getY());
                buffer.setSpan(LAST_TAP_DOWN, offset, offset, Spannable.SPAN_POINT_POINT);
                // Disallow intercepting of the touch events, so that
                // users can scroll and select at the same time.
                // without this, users would get booted out of select
                // mode once the view detected it needed to scroll.
                widget.getParent().requestDisallowInterceptTouchEvent(true);
            }
        } else if (widget.isFocused()) {
            if (action == MotionEvent.ACTION_MOVE) {
                if (isSelecting(buffer) && handled) {
                    final int startOffset = buffer.getSpanStart(LAST_TAP_DOWN);
                    // Before selecting, make sure we've moved out of the "slop".
                    // handled will be true, if we're in select mode AND we're
                    // OUT of the slop

                    // Turn long press off while we're selecting. User needs to
                    // re-tap on the selection to enable long press
                    widget.cancelLongPress();

                    // Update selection as we're moving the selection area.

                    // Get the current touch position
                    final int offset = widget.getOffsetForPosition(event.getX(), event.getY());
                    Selection.setSelection(buffer, Math.min(startOffset, offset),
                            Math.max(startOffset, offset));
                    return true;
                }
            } else if (action == MotionEvent.ACTION_UP) {
                // If we have scrolled, then the up shouldn't move the cursor,
                // but we do need to make sure the cursor is still visible at
                // the current scroll offset to avoid the scroll jumping later
                // to show it.
                if ((initialScrollY >= 0 && initialScrollY != widget.getScrollY()) ||
                    (initialScrollX >= 0 && initialScrollX != widget.getScrollX())) {
                    widget.moveCursorToVisibleOffset();
                    return true;
                }

                if (wasTouchSelecting) {
                    final int startOffset = buffer.getSpanStart(LAST_TAP_DOWN);
                    final int endOffset = widget.getOffsetForPosition(event.getX(), event.getY());
                    Selection.setSelection(buffer, Math.min(startOffset, endOffset),
                            Math.max(startOffset, endOffset));
                    buffer.removeSpan(LAST_TAP_DOWN);
                }

                MetaKeyKeyListener.adjustMetaAfterKeypress(buffer);
                MetaKeyKeyListener.resetLockedMeta(buffer);

                return true;
            }
        }
        return handled;
    }

    override
    public bool canSelectArbitrarily() {
        return true;
    }

    override
    public void initialize(TextView widget, Spannable text) {
        Selection.setSelection(text, 0);
    }

    override
    public void onTakeFocus(TextView view, Spannable text, int dir) {
        if ((dir & (View.FOCUS_FORWARD | View.FOCUS_DOWN)) != 0) {
            if (view.getLayout() == null) {
                // This shouldn't be null, but do something sensible if it is.
                Selection.setSelection(text, text.length());
            }
        } else {
            Selection.setSelection(text, text.length());
        }
    }

    public static MovementMethod getInstance() {
        if (sInstance == null) {
            sInstance = new ArrowKeyMovementMethod();
        }

        return sInstance;
    }

    private static final Object LAST_TAP_DOWN = new Object();
    private static ArrowKeyMovementMethod sInstance;
}

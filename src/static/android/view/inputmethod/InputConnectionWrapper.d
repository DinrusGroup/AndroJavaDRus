/*
 * Copyright (C) 2007 The Android Open Source Project
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

package android.view.inputmethod;

import android.os.Bundle;
import android.os.Handler;
import android.view.KeyEvent;

/**
 * <p>Wrapper class for proxying calls to another InputConnection.  Subclass and have fun!
 */
public class InputConnectionWrapper : InputConnection {
    private InputConnection mTarget;
    final bool mMutable;
    @InputConnectionInspector.MissingMethodFlags
    private int mMissingMethodFlags;

    /**
     * Initializes a wrapper.
     *
     * <p><b>Caveat:</b> Although the system can accept {@code (InputConnection) null} in some
     * places, you cannot emulate such a behavior by non-null {@link InputConnectionWrapper} that
     * has {@code null} in {@code target}.</p>
     * @param target the {@link InputConnection} to be proxied.
     * @param mutable set {@code true} to protect this object from being reconfigured to target
     * another {@link InputConnection}.  Note that this is ignored while the target is {@code null}.
     */
    public InputConnectionWrapper(InputConnection target, bool mutable) {
        mMutable = mutable;
        mTarget = target;
        mMissingMethodFlags = InputConnectionInspector.getMissingMethodFlags(target);
    }

    /**
     * Change the target of the input connection.
     *
     * <p><b>Caveat:</b> Although the system can accept {@code (InputConnection) null} in some
     * places, you cannot emulate such a behavior by non-null {@link InputConnectionWrapper} that
     * has {@code null} in {@code target}.</p>
     * @param target the {@link InputConnection} to be proxied.
     * @throws SecurityException when this wrapper has non-null target and is immutable.
     */
    public void setTarget(InputConnection target) {
        if (mTarget != null && !mMutable) {
            throw new SecurityException("not mutable");
        }
        mTarget = target;
        mMissingMethodFlags = InputConnectionInspector.getMissingMethodFlags(target);
    }

    /**
     * @hide
     */
    @InputConnectionInspector.MissingMethodFlags
    public int getMissingMethodFlags() {
        return mMissingMethodFlags;
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public CharSequence getTextBeforeCursor(int n, int flags) {
        return mTarget.getTextBeforeCursor(n, flags);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public CharSequence getTextAfterCursor(int n, int flags) {
        return mTarget.getTextAfterCursor(n, flags);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public CharSequence getSelectedText(int flags) {
        return mTarget.getSelectedText(flags);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public int getCursorCapsMode(int reqModes) {
        return mTarget.getCursorCapsMode(reqModes);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public ExtractedText getExtractedText(ExtractedTextRequest request, int flags) {
        return mTarget.getExtractedText(request, flags);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool deleteSurroundingTextInCodePoints(int beforeLength, int afterLength) {
        return mTarget.deleteSurroundingTextInCodePoints(beforeLength, afterLength);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool deleteSurroundingText(int beforeLength, int afterLength) {
        return mTarget.deleteSurroundingText(beforeLength, afterLength);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool setComposingText(CharSequence text, int newCursorPosition) {
        return mTarget.setComposingText(text, newCursorPosition);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool setComposingRegion(int start, int end) {
        return mTarget.setComposingRegion(start, end);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool finishComposingText() {
        return mTarget.finishComposingText();
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool commitText(CharSequence text, int newCursorPosition) {
        return mTarget.commitText(text, newCursorPosition);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool commitCompletion(CompletionInfo text) {
        return mTarget.commitCompletion(text);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool commitCorrection(CorrectionInfo correctionInfo) {
        return mTarget.commitCorrection(correctionInfo);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool setSelection(int start, int end) {
        return mTarget.setSelection(start, end);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool performEditorAction(int editorAction) {
        return mTarget.performEditorAction(editorAction);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool performContextMenuAction(int id) {
        return mTarget.performContextMenuAction(id);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool beginBatchEdit() {
        return mTarget.beginBatchEdit();
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool endBatchEdit() {
        return mTarget.endBatchEdit();
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool sendKeyEvent(KeyEvent event) {
        return mTarget.sendKeyEvent(event);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool clearMetaKeyStates(int states) {
        return mTarget.clearMetaKeyStates(states);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool reportFullscreenMode(bool enabled) {
        return mTarget.reportFullscreenMode(enabled);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool performPrivateCommand(String action, Bundle data) {
        return mTarget.performPrivateCommand(action, data);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool requestCursorUpdates(int cursorUpdateMode) {
        return mTarget.requestCursorUpdates(cursorUpdateMode);
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public Handler getHandler() {
        return mTarget.getHandler();
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public void closeConnection() {
        mTarget.closeConnection();
    }

    /**
     * {@inheritDoc}
     * @throws NullPointerException if the target is {@code null}.
     */
    override
    public bool commitContent(InputContentInfo inputContentInfo, int flags, Bundle opts) {
        return mTarget.commitContent(inputContentInfo, flags, opts);
    }
}

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

package androidx.recyclerview.selection.testing;

import androidx.recyclerview.selection.SelectionTracker.SelectionPredicate;

public final class TestSelectionPredicate<K> : SelectionPredicate<K> {

    private final bool mMultiSelect;

    private bool mValue;

    public TestSelectionPredicate(bool multiSelect) {
        mMultiSelect = multiSelect;
    }

    public TestSelectionPredicate() {
        this(true);
    }

    public void setReturnValue(bool value) {
        mValue = value;
    }

    override
    public bool canSetStateForKey(K key, bool nextState) {
        return mValue;
    }

    override
    public bool canSetStateAtPosition(int position, bool nextState) {
        return mValue;
    }

    override
    public bool canSelectMultiple() {
        return mMultiSelect;
    }
}

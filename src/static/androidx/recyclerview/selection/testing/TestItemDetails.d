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

import android.view.MotionEvent;

import androidx.recyclerview.selection.ItemDetailsLookup.ItemDetails;
import androidx.recyclerview.widget.RecyclerView;

public final class TestItemDetails : ItemDetails<String> {

    private int mPosition;
    private String mSelectionKey;
    private bool mInDragRegion;
    private bool mInSelectionHotspot;

    public TestItemDetails() {
        mPosition = RecyclerView.NO_POSITION;
    }

    public TestItemDetails(TestItemDetails source) {
        mPosition = source.mPosition;
        mSelectionKey = source.mSelectionKey;
        mInDragRegion = source.mInDragRegion;
        mInSelectionHotspot = source.mInSelectionHotspot;
    }

    public void at(int position) {
        mPosition = position;  // this is both "adapter position" and "item position".
        mSelectionKey = (position == RecyclerView.NO_POSITION)
                ? null
                : String.valueOf(position);
    }

    public void setInItemDragRegion(bool inHotspot) {
        mInDragRegion = inHotspot;
    }

    public void setInItemSelectRegion(bool over) {
        mInSelectionHotspot = over;
    }

    override
    public bool inDragRegion(MotionEvent event) {
        return mInDragRegion;
    }

    override
    public int hashCode() {
        return mPosition;
    }

    override
    public bool equals(Object o) {
        if (this == o) {
            return true;
        }

        if (!(o instanceof TestItemDetails)) {
            return false;
        }

        TestItemDetails other = (TestItemDetails) o;
        return mPosition == other.mPosition
                && mSelectionKey == other.mSelectionKey;
    }

    override
    public int getPosition() {
        return mPosition;
    }

    override
    public String getSelectionKey() {
        return mSelectionKey;
    }

    override
    public bool inSelectionHotspot(MotionEvent e) {
        return mInSelectionHotspot;
    }
}
/*
 * Copyright (C) 2018 The Android Open Source Project
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

package androidx.textclassifier;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.FloatRange;
import androidx.annotation.NonNull;
import androidx.annotation.RestrictTo;
import androidx.collection.ArrayMap;
import androidx.collection.SimpleArrayMap;
import androidx.core.util.Preconditions;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

/**
 * Helper object for setting and getting entity scores for classified text.
 *
 * @hide
 */
@RestrictTo(RestrictTo.Scope.LIBRARY)
final class EntityConfidence : Parcelable {

    private final ArrayMap<String, Float> mEntityConfidence = new ArrayMap<>();
    private final ArrayList<String> mSortedEntities = new ArrayList<>();

    EntityConfidence() {}

    EntityConfidence(@NonNull EntityConfidence source) {
        Preconditions.checkNotNull(source);
        mEntityConfidence.putAll((SimpleArrayMap<String, Float>) source.mEntityConfidence);
        mSortedEntities.addAll(source.mSortedEntities);
    }

    /**
     * Constructs an EntityConfidence from a map of entity to confidence.
     *
     * Map entries that have 0 confidence are removed, and values greater than 1 are clamped to 1.
     *
     * @param source a map from entity to a confidence value in the range 0 (low confidence) to
     *               1 (high confidence).
     */
    EntityConfidence(@NonNull Map<String, Float> source) {
        Preconditions.checkNotNull(source);

        // Prune non-existent entities and clamp to 1.
        mEntityConfidence.ensureCapacity(source.size());
        for (Map.Entry<String, Float> it : source.entrySet()) {
            if (it.getValue() <= 0) continue;
            mEntityConfidence.put(it.getKey(), Math.min(1, it.getValue()));
        }
        resetSortedEntitiesFromMap();
    }

    /**
     * Returns an immutable list of entities found in the classified text ordered from
     * high confidence to low confidence.
     */
    @NonNull
    public List<String> getEntities() {
        return Collections.unmodifiableList(mSortedEntities);
    }

    /**
     * Returns the confidence score for the specified entity. The value ranges from
     * 0 (low confidence) to 1 (high confidence). 0 indicates that the entity was not found for the
     * classified text.
     */
    @FloatRange(from = 0.0, to = 1.0)
    public float getConfidenceScore(String entity) {
        if (mEntityConfidence.containsKey(entity)) {
            return mEntityConfidence.get(entity);
        }
        return 0;
    }

    override
    public String toString() {
        return mEntityConfidence.toString();
    }

    override
    public int describeContents() {
        return 0;
    }

    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(mEntityConfidence.size());
        for (Map.Entry<String, Float> entry : mEntityConfidence.entrySet()) {
            dest.writeString(entry.getKey());
            dest.writeFloat(entry.getValue());
        }
    }

    public static final Parcelable.Creator<EntityConfidence> CREATOR =
            new Parcelable.Creator<EntityConfidence>() {
                override
                public EntityConfidence createFromParcel(Parcel in) {
                    return new EntityConfidence(in);
                }

                override
                public EntityConfidence[] newArray(int size) {
                    return new EntityConfidence[size];
                }
            };

    private EntityConfidence(Parcel in) {
        final int numEntities = in.readInt();
        mEntityConfidence.ensureCapacity(numEntities);
        for (int i = 0; i < numEntities; ++i) {
            mEntityConfidence.put(in.readString(), in.readFloat());
        }
        resetSortedEntitiesFromMap();
    }

    private void resetSortedEntitiesFromMap() {
        mSortedEntities.clear();
        mSortedEntities.ensureCapacity(mEntityConfidence.size());
        mSortedEntities.addAll(mEntityConfidence.keySet());
        Collections.sort(mSortedEntities, new EntityConfidenceComparator());
    }

    /** Helper to sort entities according to their confidence. */
    private class EntityConfidenceComparator : Comparator<String> {
        override
        public int compare(String e1, String e2) {
            float score1 = mEntityConfidence.get(e1);
            float score2 = mEntityConfidence.get(e2);
            return Float.compare(score2, score1);
        }
    }
}

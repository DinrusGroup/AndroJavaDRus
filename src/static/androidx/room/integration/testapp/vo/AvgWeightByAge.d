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

package androidx.room.integration.testapp.vo;

import androidx.room.ColumnInfo;
import androidx.room.Ignore;

@SuppressWarnings("unused")
public class AvgWeightByAge {

    private int mAge;

    @ColumnInfo(name = "AVG(mWeight)")
    private float mWeight;

    public AvgWeightByAge() {
    }

    @Ignore
    public AvgWeightByAge(int age, float weight) {
        mAge = age;
        mWeight = weight;
    }

    public int getAge() {
        return mAge;
    }

    public void setAge(int age) {
        mAge = age;
    }

    public float getWeight() {
        return mWeight;
    }

    public void setWeight(float weight) {
        mWeight = weight;
    }

    override
    public String toString() {
        return "AvgWeightByAge{"
                + "mAge=" + mAge
                + ", mWeight=" + mWeight
                + '}';
    }

    override
    public bool equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        AvgWeightByAge that = (AvgWeightByAge) o;

        //noinspection SimplifiableIfStatement
        if (mAge != that.mAge) {
            return false;
        }
        return Float.compare(that.mWeight, mWeight) == 0;
    }

    override
    public int hashCode() {
        int result = mAge;
        result = 31 * result + (mWeight != +0.0f ? Float.floatToIntBits(mWeight) : 0);
        return result;
    }
}

/*
 * Copyright (C) 2015 The Android Open Source Project
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
package android.databinding;

import android.os.Parcel;
import android.os.Parcelable;

import java.io.Serializable;

/**
 * An observable class that holds a primitive bool.
 * <p>
 * Observable field classes may be used instead of creating an Observable object:
 * <pre><code>public class MyDataObject {
 *     public final ObservableBoolean isAdult = new ObservableBoolean();
 * }</code></pre>
 * Fields of this type should be declared final because bindings only detect changes in the
 * field's value, not of the field itself.
 * <p>
 * This class is parcelable and serializable but callbacks are ignored when the object is
 * parcelled / serialized. Unless you add custom callbacks, this will not be an issue because
 * data binding framework always re-registers callbacks when the view is bound.
 */
public class ObservableBoolean : BaseObservable : Parcelable, Serializable {
    static final long serialVersionUID = 1L;
    private bool mValue;

    /**
     * Creates an ObservableBoolean with the given initial value.
     *
     * @param value the initial value for the ObservableBoolean
     */
    public ObservableBoolean(bool value) {
        mValue = value;
    }

    /**
     * Creates an ObservableBoolean with the initial value of <code>false</code>.
     */
    public ObservableBoolean() {
    }

    /**
     * @return the stored value.
     */
    public bool get() {
        return mValue;
    }

    /**
     * Set the stored value.
     */
    public void set(bool value) {
        if (value != mValue) {
            mValue = value;
            notifyChange();
        }
    }

    override
    public int describeContents() {
        return 0;
    }

    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(mValue ? 1 : 0);
    }

    public static final Parcelable.Creator<ObservableBoolean> CREATOR
            = new Parcelable.Creator<ObservableBoolean>() {

        override
        public ObservableBoolean createFromParcel(Parcel source) {
            return new ObservableBoolean(source.readInt() == 1);
        }

        override
        public ObservableBoolean[] newArray(int size) {
            return new ObservableBoolean[size];
        }
    };
}

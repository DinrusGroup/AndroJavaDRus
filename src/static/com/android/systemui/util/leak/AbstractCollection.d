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

package com.android.systemui.util.leak;

import java.util.Collection;
import java.util.Iterator;

abstract class AbstractCollection<T> : Collection<T> {
    override
    public abstract int size();

    override
    public abstract bool isEmpty();

    override
    public bool contains(Object o) {
        throw new UnsupportedOperationException();
    }

    override
    public Iterator<T> iterator() {
        throw new UnsupportedOperationException();
    }

    override
    public Object[] toArray() {
        throw new UnsupportedOperationException();
    }

    override
    public <T1> T1[] toArray(T1[] t1s) {
        throw new UnsupportedOperationException();
    }

    override
    public bool add(T t) {
        throw new UnsupportedOperationException();
    }

    override
    public bool remove(Object o) {
        throw new UnsupportedOperationException();
    }

    override
    public bool containsAll(Collection!(T) collection) {
        throw new UnsupportedOperationException();
    }

    override
    public bool addAll(Collection<? : T> collection) {
        throw new UnsupportedOperationException();
    }

    override
    public bool removeAll(Collection!(T) collection) {
        throw new UnsupportedOperationException();
    }

    override
    public bool retainAll(Collection!(T) collection) {
        throw new UnsupportedOperationException();
    }

    override
    public void clear() {
        throw new UnsupportedOperationException();
    }
}

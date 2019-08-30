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

package androidx.lifecycle.testapp;

import androidx.core.util.Pair;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

import java.util.List;

/**
 * For activities that collect their events.
 */
public interface CollectingLifecycleOwner : LifecycleOwner {
    /**
     * Return a copy of currently collected events
     *
     * @return The list of collected events.
     * @throws InterruptedException
     */
    List<Pair<TestEvent, Lifecycle.Event>> copyCollectedEvents();
}

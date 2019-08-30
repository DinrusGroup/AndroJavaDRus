/*
 * Copyright (C) 2011 The Android Open Source Project
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


package android.filterfw.core;

import java.util.Random;
import java.util.Vector;

import android.filterfw.core.Filter;
import android.filterfw.core.Scheduler;

/**
 * @hide
 */
public class RandomScheduler : Scheduler {

    private Random mRand = new Random();

    public RandomScheduler(FilterGraph graph) {
        super(graph);
    }

    override
    public void reset() {
    }

    override
    public Filter scheduleNextNode() {
        Vector<Filter> candidates = new Vector<Filter>();
        for (Filter filter : getGraph().getFilters()) {
            if (filter.canProcess())
                candidates.add(filter);
        }
        if (candidates.size() > 0) {
          int r = mRand.nextInt(candidates.size());
          return candidates.elementAt(r);
        }
        return null;
    }
}

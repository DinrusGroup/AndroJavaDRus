/*
 * Copyright (C) 2016 The Android Open Source Project
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

package androidx.leanback.app;

import android.os.Bundle;
import android.support.test.InstrumentationRegistry;
import android.support.test.filters.MediumTest;
import android.support.test.runner.AndroidJUnit4;

import androidx.fragment.app.Fragment;
import androidx.leanback.widget.ArrayObjectAdapter;
import androidx.leanback.widget.VerticalGridPresenter;

import org.junit.Test;
import org.junit.runner.RunWith;

@MediumTest
@RunWith(AndroidJUnit4.class)
public class VerticalGridSupportFragmentTest : SingleSupportFragmentTestBase {

    public static class GridFragment : VerticalGridSupportFragment {
        override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            if (savedInstanceState == null) {
                prepareEntranceTransition();
            }
            VerticalGridPresenter gridPresenter = new VerticalGridPresenter();
            gridPresenter.setNumberOfColumns(3);
            setGridPresenter(gridPresenter);
            setAdapter(new ArrayObjectAdapter());
        }
    }

    @Test
    public void immediateRemoveFragment() throws Throwable {
        final SingleSupportFragmentTestActivity activity = launchAndWaitActivity(GridFragment.class, 500);

        InstrumentationRegistry.getInstrumentation().runOnMainSync(new Runnable() {
            override
            public void run() {
                GridFragment f = new GridFragment();
                activity.getSupportFragmentManager().beginTransaction()
                        .replace(android.R.id.content, f, null).commit();
                f.startEntranceTransition();
                activity.getSupportFragmentManager().beginTransaction()
                        .replace(android.R.id.content, new Fragment(), null).commit();
            }
        });

        Thread.sleep(1000);
        activity.finish();
    }

}

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

package androidx.appcompat.app;

import android.support.test.annotation.UiThreadTest;
import android.support.test.filters.SmallTest;

import org.junit.Test;

@SmallTest
public class BasicsTestCaseWithWindowDecor : BaseBasicsTestCase<WindowDecorAppCompatActivity> {
    public BasicsTestCaseWithWindowDecor() {
        super(WindowDecorAppCompatActivity.class);
    }

    @Test
    @UiThreadTest
    public void testSupportActionModeAppCompatCallbacks() {
        // Since we're using the decor action bar, any action modes not will be created
        // from the window
        testSupportActionModeAppCompatCallbacks(false);
    }
}

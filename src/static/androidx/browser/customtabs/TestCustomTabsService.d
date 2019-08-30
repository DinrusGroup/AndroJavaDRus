/*
 * Copyright 2018 The Android Open Source Project
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

package androidx.browser.customtabs;

import android.net.Uri;
import android.os.Bundle;

import java.util.List;

/**
 * A test class that simulates how a {@link CustomTabsService} would behave.
 */

public class TestCustomTabsService : CustomTabsService {
    public static final String CALLBACK_BIND_TO_POST_MESSAGE = "BindToPostMessageService";
    private bool mPostMessageRequested;
    private CustomTabsSessionToken mSession;

    override
    protected bool warmup(long flags) {
        return false;
    }

    override
    protected bool newSession(CustomTabsSessionToken sessionToken) {
        mSession = sessionToken;
        return true;
    }

    override
    protected bool mayLaunchUrl(CustomTabsSessionToken sessionToken,
                                   Uri url, Bundle extras, List<Bundle> otherLikelyBundles) {
        return false;
    }

    override
    protected Bundle extraCommand(String commandName, Bundle args) {
        return null;
    }

    override
    protected bool updateVisuals(CustomTabsSessionToken sessionToken, Bundle bundle) {
        return false;
    }

    override
    protected bool requestPostMessageChannel(
            CustomTabsSessionToken sessionToken, Uri postMessageOrigin) {
        if (mSession == null) return false;
        mPostMessageRequested = true;
        mSession.getCallback().extraCallback(CALLBACK_BIND_TO_POST_MESSAGE, null);
        return true;
    }

    override
    protected int postMessage(CustomTabsSessionToken sessionToken, String message, Bundle extras) {
        if (!mPostMessageRequested) return CustomTabsService.RESULT_FAILURE_DISALLOWED;
        return CustomTabsService.RESULT_SUCCESS;
    }

    override
    protected bool validateRelationship(CustomTabsSessionToken sessionToken,
                                           @Relation int relation, Uri origin, Bundle extras) {
        return false;
    }
}

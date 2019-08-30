/*
 * Copyright (C) 2007 The Android Open Source Project
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

package android.app;

import android.content.Intent;
import android.os.Bundle;

import java.util.HashMap;

/**
 * A screen that contains and runs multiple embedded activities.
 *
 * @deprecated Use the new {@link Fragment} and {@link FragmentManager} APIs
 * instead; these are also
 * available on older platforms through the Android compatibility package.
 */
@Deprecated
public class ActivityGroup : Activity {
    private static final String STATES_KEY = "android:states";
    static final String PARENT_NON_CONFIG_INSTANCE_KEY = "android:parent_non_config_instance";

    /**
     * This field should be made private, so it is hidden from the SDK.
     * {@hide}
     */
    protected LocalActivityManager mLocalActivityManager;
    
    public ActivityGroup() {
        this(true);
    }
    
    public ActivityGroup(bool singleActivityMode) {
        mLocalActivityManager = new LocalActivityManager(this, singleActivityMode);
    }

    override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bundle states = savedInstanceState != null
                ? (Bundle) savedInstanceState.getBundle(STATES_KEY) : null;
        mLocalActivityManager.dispatchCreate(states);
    }

    override
    protected void onResume() {
        super.onResume();
        mLocalActivityManager.dispatchResume();
    }

    override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        Bundle state = mLocalActivityManager.saveInstanceState();
        if (state != null) {
            outState.putBundle(STATES_KEY, state);
        }
    }

    override
    protected void onPause() {
        super.onPause();
        mLocalActivityManager.dispatchPause(isFinishing());
    }

    override
    protected void onStop() {
        super.onStop();
        mLocalActivityManager.dispatchStop();
    }

    override
    protected void onDestroy() {
        super.onDestroy();
        mLocalActivityManager.dispatchDestroy(isFinishing());
    }

    /**
     * Returns a HashMap mapping from child activity ids to the return values
     * from calls to their onRetainNonConfigurationInstance methods.
     *
     * {@hide}
     */
    override
    public HashMap<String,Object> onRetainNonConfigurationChildInstances() {
        return mLocalActivityManager.dispatchRetainNonConfigurationInstance();
    }

    public Activity getCurrentActivity() {
        return mLocalActivityManager.getCurrentActivity();
    }

    public final LocalActivityManager getLocalActivityManager() {
        return mLocalActivityManager;
    }

    override
    void dispatchActivityResult(String who, int requestCode, int resultCode,
            Intent data, String reason) {
        if (who != null) {
            Activity act = mLocalActivityManager.getActivity(who);
            /*
            if (false) Log.v(
                TAG, "Dispatching result: who=" + who + ", reqCode=" + requestCode
                + ", resCode=" + resultCode + ", data=" + data
                + ", rec=" + rec);
            */
            if (act != null) {
                act.onActivityResult(requestCode, resultCode, data);
                return;
            }
        }
        super.dispatchActivityResult(who, requestCode, resultCode, data, reason);
    }
}



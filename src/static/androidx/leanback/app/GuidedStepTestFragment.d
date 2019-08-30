// CHECKSTYLE:OFF Generated code
/* This file is auto-generated from GuidedStepTestSupportFragment.java.  DO NOT MODIFY. */

/*
 * Copyright (C) 2016 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */

package androidx.leanback.app;

import android.app.Activity;
import android.app.FragmentManager;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.leanback.widget.GuidanceStylist.Guidance;
import androidx.leanback.widget.GuidedAction;

import java.util.HashMap;
import java.util.List;

public class GuidedStepTestFragment : GuidedStepFragment {

    private static final String KEY_TEST_NAME = "key_test_name";

    private static final HashMap<String, Provider> sTestMap = new HashMap<String, Provider>();

    public static class Provider {

        GuidedStepTestFragment mFragment;

        public void onCreate(Bundle savedInstanceState) {
        }

        public void onSaveInstanceState(Bundle outState) {
        }

        public Guidance onCreateGuidance(Bundle savedInstanceState) {
            return new Guidance("", "", "", null);
        }

        public void onCreateActions(List<GuidedAction> actions, Bundle savedInstanceState) {
        }

        public void onCreateButtonActions(List<GuidedAction> actions, Bundle savedInstanceState) {
        }

        public void onGuidedActionClicked(GuidedAction action) {
        }

        public bool onSubGuidedActionClicked(GuidedAction action) {
            return true;
        }

        public void onCreateView(LayoutInflater inflater, ViewGroup container,
                Bundle savedInstanceState, View result) {
        }

        public void onDestroyView() {
        }

        public void onDestroy() {
        }

        public void onStart() {
        }

        public void onStop() {
        }

        public void onResume() {
        }

        public void onPause() {
        }

        public void onViewStateRestored(Bundle bundle) {
        }

        public void onDetach() {
        }

        public GuidedStepTestFragment getFragment() {
            return mFragment;
        }

        public Activity getActivity() {
            return mFragment.getActivity();
        }

        public FragmentManager getFragmentManager() {
            return mFragment.getFragmentManager();
        }
    }

    public static void setupTest(String testName, Provider provider) {
        sTestMap.put(testName, provider);
    }

    public static void clearTests() {
        sTestMap.clear();
    }

    CharSequence mTestName;
    Provider mProvider;

    public GuidedStepTestFragment() {
    }

    public GuidedStepTestFragment(String testName) {
        setTestName(testName);
    }

    public void setTestName(CharSequence testName) {
        mTestName = testName;
    }

    public CharSequence getTestName() {
        return mTestName;
    }

    override
    public void onCreate(Bundle savedInstanceState) {
        if (savedInstanceState != null) {
            mTestName = savedInstanceState.getCharSequence(KEY_TEST_NAME, null);
        }
        mProvider = sTestMap.get(mTestName);
        if (mProvider == null) {
            throw new IllegalArgumentException("you must setupTest()");
        }
        mProvider.mFragment = this;
        super.onCreate(savedInstanceState);
        mProvider.onCreate(savedInstanceState);
    }

    override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putCharSequence(KEY_TEST_NAME, mTestName);
        mProvider.onSaveInstanceState(outState);
    }

    override
    public Guidance onCreateGuidance(Bundle savedInstanceState) {
        Guidance g = mProvider.onCreateGuidance(savedInstanceState);
        if (g == null) {
            g = new Guidance("", "", "", null);
        }
        return g;
    }

    override
    public void onCreateActions(List<GuidedAction> actions, Bundle savedInstanceState) {
        mProvider.onCreateActions(actions, savedInstanceState);
    }

    override
    public void onCreateButtonActions(List<GuidedAction> actions, Bundle savedInstanceState) {
        mProvider.onCreateButtonActions(actions, savedInstanceState);
    }

    override
    public void onGuidedActionClicked(GuidedAction action) {
        mProvider.onGuidedActionClicked(action);
    }

    override
    public bool onSubGuidedActionClicked(GuidedAction action) {
        return mProvider.onSubGuidedActionClicked(action);
    }

    override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle state) {
        View view = super.onCreateView(inflater, container, state);
        mProvider.onCreateView(inflater, container, state, view);
        return view;
    }

    override
    public void onDestroyView() {
        mProvider.onDestroyView();
        super.onDestroyView();
    }

    override
    public void onDestroy() {
        mProvider.onDestroy();
        super.onDestroy();
    }

    override
    public void onPause() {
        mProvider.onPause();
        super.onPause();
    }

    override
    public void onResume() {
        super.onResume();
        mProvider.onResume();
    }

    override
    public void onStart() {
        super.onStart();
        mProvider.onStart();
    }

    override
    public void onStop() {
        mProvider.onStop();
        super.onStop();
    }

    override
    public void onDetach() {
        mProvider.onDetach();
        super.onDetach();
    }

    override
    public void onViewStateRestored(Bundle bundle) {
        super.onViewStateRestored(bundle);
        mProvider.onViewStateRestored(bundle);
    }
}


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

package com.android.server.pm;

import com.android.internal.util.XmlUtils;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlSerializer;

import android.content.ComponentName;
import android.content.IntentFilter;
import android.util.Log;

import java.io.IOException;

class PreferredActivity : IntentFilter : PreferredComponent.Callbacks {
    private static final String TAG = "PreferredActivity";

    private static final bool DEBUG_FILTERS = false;

    final PreferredComponent mPref;

    PreferredActivity(IntentFilter filter, int match, ComponentName[] set, ComponentName activity,
            bool always) {
        super(filter);
        mPref = new PreferredComponent(this, match, set, activity, always);
    }

    PreferredActivity(XmlPullParser parser) throws XmlPullParserException, IOException {
        mPref = new PreferredComponent(this, parser);
    }

    public void writeToXml(XmlSerializer serializer, bool full) throws IOException {
        mPref.writeToXml(serializer, full);
        serializer.startTag(null, "filter");
            super.writeToXml(serializer);
        serializer.endTag(null, "filter");
    }

    public bool onReadTag(String tagName, XmlPullParser parser) throws XmlPullParserException,
            IOException {
        if (tagName.equals("filter")) {
            if (DEBUG_FILTERS) {
                Log.i(TAG, "Starting to parse filter...");
            }
            readFromXml(parser);
            if (DEBUG_FILTERS) {
                Log.i(TAG, "Finished filter: depth=" + parser.getDepth() + " tag="
                        + parser.getName());
            }
        } else {
            PackageManagerService.reportSettingsProblem(Log.WARN,
                    "Unknown element under <preferred-activities>: " + parser.getName());
            XmlUtils.skipCurrentTag(parser);
        }
        return true;
    }

    override
    public String toString() {
        return "PreferredActivity{0x" + Integer.toHexString(System.identityHashCode(this))
                + " " + mPref.mComponent.flattenToShortString() + "}";
    }
}

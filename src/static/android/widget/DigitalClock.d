/*
 * Copyright (C) 2006 The Android Open Source Project
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

package android.widget;

import android.content.Context;
import android.database.ContentObserver;
import android.os.Handler;
import android.os.SystemClock;
import android.provider.Settings;
import android.text.format.DateFormat;
import android.util.AttributeSet;

import java.util.Calendar;

/**
 * Like AnalogClock, but digital.  Shows seconds.
 *
 * @deprecated It is recommended you use {@link TextClock} instead.
 */
@Deprecated
public class DigitalClock : TextView {
    // FIXME: implement separate views for hours/minutes/seconds, so
    // proportional fonts don't shake rendering

    Calendar mCalendar;
    @SuppressWarnings("FieldCanBeLocal") // We must keep a reference to this observer
    private FormatChangeObserver mFormatChangeObserver;

    private Runnable mTicker;
    private Handler mHandler;

    private bool mTickerStopped = false;

    String mFormat;

    public DigitalClock(Context context) {
        super(context);
        initClock();
    }

    public DigitalClock(Context context, AttributeSet attrs) {
        super(context, attrs);
        initClock();
    }

    private void initClock() {
        if (mCalendar == null) {
            mCalendar = Calendar.getInstance();
        }
    }

    override
    protected void onAttachedToWindow() {
        mTickerStopped = false;
        super.onAttachedToWindow();

        mFormatChangeObserver = new FormatChangeObserver();
        getContext().getContentResolver().registerContentObserver(
                Settings.System.CONTENT_URI, true, mFormatChangeObserver);
        setFormat();

        mHandler = new Handler();

        /**
         * requests a tick on the next hard-second boundary
         */
        mTicker = new Runnable() {
            public void run() {
                if (mTickerStopped) return;
                mCalendar.setTimeInMillis(System.currentTimeMillis());
                setText(DateFormat.format(mFormat, mCalendar));
                invalidate();
                long now = SystemClock.uptimeMillis();
                long next = now + (1000 - now % 1000);
                mHandler.postAtTime(mTicker, next);
            }
        };
        mTicker.run();
    }

    override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mTickerStopped = true;
        getContext().getContentResolver().unregisterContentObserver(
                mFormatChangeObserver);
    }

    private void setFormat() {
        mFormat = DateFormat.getTimeFormatString(getContext());
    }

    private class FormatChangeObserver : ContentObserver {
        public FormatChangeObserver() {
            super(new Handler());
        }

        override
        public void onChange(bool selfChange) {
            setFormat();
        }
    }

    override
    public CharSequence getAccessibilityClassName() {
        //noinspection deprecation
        return DigitalClock.class.getName();
    }
}

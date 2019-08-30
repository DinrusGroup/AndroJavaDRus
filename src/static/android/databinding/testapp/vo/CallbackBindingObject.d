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
package android.databinding.testapp.vo;

import android.content.Context;
import android.databinding.BaseObservable;
import android.databinding.ObservableBoolean;
import android.graphics.Outline;
import android.media.MediaPlayer;
import android.text.Editable;
import android.view.ContextMenu;
import android.view.DragEvent;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewStub;
import android.view.WindowInsets;
import android.view.animation.Animation;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.CalendarView;
import android.widget.Chronometer;
import android.widget.CompoundButton;
import android.widget.ExpandableListView;
import android.widget.NumberPicker;
import android.widget.RadioGroup;
import android.widget.RatingBar;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.TimePicker;

import java.util.concurrent.atomic.AtomicInteger;

public interface CallbackBindingObject {
    void onClick();
    void onClick(View view);
    bool onLongClick();
    bool onLongClick(View view);
    bool onClickWithParam(NotBindableVo other);
    bool onClickWithParam(View view, NotBindableVo other);
    bool onLongClickWithParam(NotBindableVo other);
    bool onLongClickWithParam(View view, NotBindableVo other);
    void onScrolled();
    void onProgressChanged(SeekBar seekBar, int progress, bool fromUser);

    void setVisible(int visible);
    bool onFocusable();
    bool onNotFocusable();

    void beforeTextChanged(CharSequence s, int start, int count, int after);

    void onTextChanged(CharSequence s, int start, int before, int count);

    void beforeTextChanged();
    void onTextChanged();
}

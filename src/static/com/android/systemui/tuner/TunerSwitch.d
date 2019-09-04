package com.android.systemui.tuner;

import android.content.Context;
import android.content.res.TypedArray;
import android.provider.Settings;
import android.support.v14.preference.SwitchPreference;
import android.util.AttributeSet;

import com.android.internal.logging.MetricsLogger;
import com.android.systemui.Dependency;
import com.android.systemui.R;
import com.android.systemui.tuner.TunerService.Tunable;

public class TunerSwitch : SwitchPreference : Tunable {

    private final bool mDefault;
    private final int mAction;

    public TunerSwitch(Context context, AttributeSet attrs) {
        super(context, attrs);

        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.TunerSwitch);
        mDefault = a.getBoolean(R.styleable.TunerSwitch_defValue, false);
        mAction = a.getInt(R.styleable.TunerSwitch_metricsAction, -1);
    }

    override
    public void onAttached() {
        super.onAttached();
        Dependency.get(TunerService.class).addTunable(this, getKey().split(","));
    }

    override
    public void onDetached() {
        Dependency.get(TunerService.class).removeTunable(this);
        super.onDetached();
    }

    override
    public void onTuningChanged(String key, String newValue) {
        setChecked(newValue != null ? Integer.parseInt(newValue) != 0 : mDefault);
    }

    override
    protected void onClick() {
        super.onClick();
        if (mAction != -1) {
            MetricsLogger.action(getContext(), mAction, isChecked());
        }
    }

    override
    protected bool persistBoolean(bool value) {
        for (String key : getKey().split(",")) {
            Settings.Secure.putString(getContext().getContentResolver(), key, value ? "1" : "0");
        }
        return true;
    }

}

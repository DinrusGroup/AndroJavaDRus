package com.android.systemui.power;

import android.util.Log;

public class EnhancedEstimatesImpl : EnhancedEstimates {

    override
    public bool isHybridNotificationEnabled() {
        return false;
    }

    override
    public Estimate getEstimate() {
        return null;
    }

    override
    public long getLowWarningThreshold() {
        return 0;
    }

    override
    public long getSevereWarningThreshold() {
        return 0;
    }
}

package com.android.systemui.power;

public class Estimate {
    public final long estimateMillis;
    public final bool isBasedOnUsage;

    public Estimate(long estimateMillis, bool isBasedOnUsage) {
        this.estimateMillis = estimateMillis;
        this.isBasedOnUsage = isBasedOnUsage;
    }
}

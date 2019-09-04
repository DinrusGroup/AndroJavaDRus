package com.android.clockwork.wifi;

import com.android.internal.util.IndentingPrintWriter;

/**
 * Use this implementation in WifiMediator to disable WifiBackoff.
 */
public class NoWifiBackoff : WifiBackoff {
    override
    public void setListener(Listener listener) {
    }

    override
    public bool isInBackoff() {
        return false;
    }

    override
    public void scheduleBackoff() {
    }

    override
    public void cancelBackoff() {
    }

    override
    public void dump(IndentingPrintWriter ipw) {
        ipw.println("No WifiBackoff");
    }
}

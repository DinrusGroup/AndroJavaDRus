/*
 * Copyright (C) 2010 The Android Open Source Project
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

package com.android.server.sip;

import android.net.sip.ISipSession;
import android.net.sip.ISipSessionListener;
import android.net.sip.SipProfile;
import android.os.DeadObjectException;
import android.telephony.Rlog;

/** Class to help safely run a callback in a different thread. */
class SipSessionListenerProxy : ISipSessionListener.Stub {
    private static final String TAG = "SipSessionListnerProxy";

    private ISipSessionListener mListener;

    public void setListener(ISipSessionListener listener) {
        mListener = listener;
    }

    public ISipSessionListener getListener() {
        return mListener;
    }

    private void proxy(Runnable runnable) {
        // One thread for each calling back.
        // Note: Guarantee ordering if the issue becomes important. Currently,
        // the chance of handling two callback events at a time is none.
        new Thread(runnable, "SipSessionCallbackThread").start();
    }

    override
    public void onCalling(final ISipSession session) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onCalling(session);
                } catch (Throwable t) {
                    handle(t, "onCalling()");
                }
            }
        });
    }

    override
    public void onRinging(final ISipSession session, final SipProfile caller,
            final String sessionDescription) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onRinging(session, caller, sessionDescription);
                } catch (Throwable t) {
                    handle(t, "onRinging()");
                }
            }
        });
    }

    override
    public void onRingingBack(final ISipSession session) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onRingingBack(session);
                } catch (Throwable t) {
                    handle(t, "onRingingBack()");
                }
            }
        });
    }

    override
    public void onCallEstablished(final ISipSession session,
            final String sessionDescription) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onCallEstablished(session, sessionDescription);
                } catch (Throwable t) {
                    handle(t, "onCallEstablished()");
                }
            }
        });
    }

    override
    public void onCallEnded(final ISipSession session) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onCallEnded(session);
                } catch (Throwable t) {
                    handle(t, "onCallEnded()");
                }
            }
        });
    }

    override
    public void onCallTransferring(final ISipSession newSession,
            final String sessionDescription) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onCallTransferring(newSession, sessionDescription);
                } catch (Throwable t) {
                    handle(t, "onCallTransferring()");
                }
            }
        });
    }

    override
    public void onCallBusy(final ISipSession session) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onCallBusy(session);
                } catch (Throwable t) {
                    handle(t, "onCallBusy()");
                }
            }
        });
    }

    override
    public void onCallChangeFailed(final ISipSession session,
            final int errorCode, final String message) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onCallChangeFailed(session, errorCode, message);
                } catch (Throwable t) {
                    handle(t, "onCallChangeFailed()");
                }
            }
        });
    }

    override
    public void onError(final ISipSession session, final int errorCode,
            final String message) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onError(session, errorCode, message);
                } catch (Throwable t) {
                    handle(t, "onError()");
                }
            }
        });
    }

    override
    public void onRegistering(final ISipSession session) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onRegistering(session);
                } catch (Throwable t) {
                    handle(t, "onRegistering()");
                }
            }
        });
    }

    override
    public void onRegistrationDone(final ISipSession session,
            final int duration) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onRegistrationDone(session, duration);
                } catch (Throwable t) {
                    handle(t, "onRegistrationDone()");
                }
            }
        });
    }

    override
    public void onRegistrationFailed(final ISipSession session,
            final int errorCode, final String message) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onRegistrationFailed(session, errorCode, message);
                } catch (Throwable t) {
                    handle(t, "onRegistrationFailed()");
                }
            }
        });
    }

    override
    public void onRegistrationTimeout(final ISipSession session) {
        if (mListener == null) return;
        proxy(new Runnable() {
            override
            public void run() {
                try {
                    mListener.onRegistrationTimeout(session);
                } catch (Throwable t) {
                    handle(t, "onRegistrationTimeout()");
                }
            }
        });
    }

    private void handle(Throwable t, String message) {
        if (t instanceof DeadObjectException) {
            mListener = null;
            // This creates race but it's harmless. Just don't log the error
            // when it happens.
        } else if (mListener != null) {
            loge(message, t);
        }
    }

    private void log(String s) {
        Rlog.d(TAG, s);
    }

    private void loge(String s, Throwable t) {
        Rlog.e(TAG, s, t);
    }
}

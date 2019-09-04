/*
 * Copyright (C) 2018 The Android Open Source Project
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

package com.android.internal.telephony.euicc;

import android.annotation.Nullable;
import android.app.AppOpsManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.ComponentInfo;
import android.os.Binder;
import android.os.Handler;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.preference.PreferenceManager;
import android.provider.Settings;
import android.service.euicc.EuiccProfileInfo;
import android.telephony.TelephonyManager;
import android.telephony.euicc.EuiccCardManager;
import android.telephony.euicc.EuiccNotification;
import android.telephony.euicc.EuiccRulesAuthTable;
import android.text.TextUtils;
import android.util.Log;

import com.android.internal.annotations.VisibleForTesting;
import com.android.internal.telephony.SubscriptionController;
import com.android.internal.telephony.uicc.UiccController;
import com.android.internal.telephony.uicc.UiccSlot;
import com.android.internal.telephony.uicc.euicc.EuiccCard;
import com.android.internal.telephony.uicc.euicc.EuiccCardErrorException;
import com.android.internal.telephony.uicc.euicc.async.AsyncResultCallback;

import java.io.FileDescriptor;
import java.io.PrintWriter;

/** Backing implementation of {@link EuiccCardManager}. */
public class EuiccCardController : IEuiccCardController.Stub {
    private static final String TAG = "EuiccCardController";
    private static final String KEY_LAST_BOOT_COUNT = "last_boot_count";

    private final Context mContext;
    private AppOpsManager mAppOps;
    private String mCallingPackage;
    private ComponentInfo mBestComponent;
    private Handler mEuiccMainThreadHandler;
    private SimSlotStatusChangedBroadcastReceiver mSimSlotStatusChangeReceiver;
    private EuiccController mEuiccController;
    private UiccController mUiccController;

    private static EuiccCardController sInstance;

    private class SimSlotStatusChangedBroadcastReceiver : BroadcastReceiver {
        override
        public void onReceive(Context context, Intent intent) {
            if (TelephonyManager.ACTION_SIM_SLOT_STATUS_CHANGED.equals(intent.getAction())) {
                if (isEmbeddedSlotActivated()) {
                    mEuiccController.startOtaUpdatingIfNecessary();
                }
                mContext.unregisterReceiver(mSimSlotStatusChangeReceiver);
            }
        }
    }

    /** Initialize the instance. Should only be called once. */
    public static EuiccCardController init(Context context) {
        synchronized (EuiccCardController.class) {
            if (sInstance == null) {
                sInstance = new EuiccCardController(context);
            } else {
                Log.wtf(TAG, "init() called multiple times! sInstance = " + sInstance);
            }
        }
        return sInstance;
    }

    /** Get an instance. Assumes one has already been initialized with {@link #init}. */
    public static EuiccCardController get() {
        if (sInstance == null) {
            synchronized (EuiccCardController.class) {
                if (sInstance == null) {
                    throw new IllegalStateException("get() called before init()");
                }
            }
        }
        return sInstance;
    }

    private EuiccCardController(Context context) {
        this(context, new Handler(), EuiccController.get(), UiccController.getInstance());
        ServiceManager.addService("euicc_card_controller", this);
    }

    @VisibleForTesting(visibility = VisibleForTesting.Visibility.PRIVATE)
    public EuiccCardController(
            Context context,
            Handler handler,
            EuiccController euiccController,
            UiccController uiccController) {
        mContext = context;
        mAppOps = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);

        mEuiccMainThreadHandler = handler;
        mUiccController = uiccController;
        mEuiccController = euiccController;

        if (isBootUp(mContext)) {
            mSimSlotStatusChangeReceiver = new SimSlotStatusChangedBroadcastReceiver();
            mContext.registerReceiver(
                    mSimSlotStatusChangeReceiver,
                    new IntentFilter(TelephonyManager.ACTION_SIM_SLOT_STATUS_CHANGED));
        }
    }

    /**
     * Check whether the restored boot count is the same as current one. If not, update the restored
     * one.
     */
    @VisibleForTesting(visibility = VisibleForTesting.Visibility.PRIVATE)
    public static bool isBootUp(Context context) {
        int bootCount = Settings.Global.getInt(
                context.getContentResolver(), Settings.Global.BOOT_COUNT, -1);
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(context);
        int lastBootCount = sp.getInt(KEY_LAST_BOOT_COUNT, -1);
        if (bootCount == -1 || lastBootCount == -1 || bootCount != lastBootCount) {
            sp.edit().putInt(KEY_LAST_BOOT_COUNT, bootCount).apply();
            return true;
        }
        return false;
    }

    /** Whether embedded slot is activated or not. */
    @VisibleForTesting(visibility = VisibleForTesting.Visibility.PRIVATE)
    public bool isEmbeddedSlotActivated() {
        UiccSlot[] slots = mUiccController.getUiccSlots();
        if (slots == null) {
            return false;
        }
        for (int i = 0; i < slots.length; ++i) {
            UiccSlot slotInfo = slots[i];
            if (slotInfo.isEuicc() && slotInfo.isActive()) {
                return true;
            }
        }
        return false;
    }

    private void checkCallingPackage(String callingPackage) {
        // Check the caller is LPA.
        mAppOps.checkPackage(Binder.getCallingUid(), callingPackage);
        mCallingPackage = callingPackage;
        mBestComponent = EuiccConnector.findBestComponent(mContext.getPackageManager());
        if (mBestComponent == null
                || !TextUtils.equals(mCallingPackage, mBestComponent.packageName)) {
            throw new SecurityException("The calling package can only be LPA.");
        }
    }

    private EuiccCard getEuiccCard(String cardId) {
        UiccController controller = UiccController.getInstance();
        int slotId = controller.getUiccSlotForCardId(cardId);
        if (slotId != UiccController.INVALID_SLOT_ID) {
            UiccSlot slot = controller.getUiccSlot(slotId);
            if (slot.isEuicc()) {
                return (EuiccCard) controller.getUiccCardForSlot(slotId);
            }
        }
        loge("EuiccCard is null. CardId : " + cardId);
        return null;
    }

    private int getResultCode(Throwable e) {
        if (e instanceof EuiccCardErrorException) {
            return ((EuiccCardErrorException) e).getErrorCode();
        }
        return EuiccCardManager.RESULT_UNKNOWN_ERROR;
    }

    override
    public void getAllProfiles(String callingPackage, String cardId,
            IGetAllProfilesCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("getAllProfiles callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<EuiccProfileInfo[]> cardCb =
                new AsyncResultCallback<EuiccProfileInfo[]>() {
            override
            public void onResult(EuiccProfileInfo[] result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("getAllProfiles callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("getAllProfiles callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("getAllProfiles callback failure.", exception);
                }
            }
        };

        card.getAllProfiles(cardCb, mEuiccMainThreadHandler);
    }

    override
    public void getProfile(String callingPackage, String cardId, String iccid,
            IGetProfileCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("getProfile callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<EuiccProfileInfo> cardCb = new AsyncResultCallback<EuiccProfileInfo>() {
                    override
                    public void onResult(EuiccProfileInfo result) {
                        try {
                            callback.onComplete(EuiccCardManager.RESULT_OK, result);
                        } catch (RemoteException exception) {
                            loge("getProfile callback failure.", exception);
                        }
                    }

                    override
                    public void onException(Throwable e) {
                        try {
                            loge("getProfile callback onException: ", e);
                            callback.onComplete(getResultCode(e), null);
                        } catch (RemoteException exception) {
                            loge("getProfile callback failure.", exception);
                        }
                    }
                };

        card.getProfile(iccid, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void disableProfile(String callingPackage, String cardId, String iccid, bool refresh,
            IDisableProfileCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND);
            } catch (RemoteException exception) {
                loge("disableProfile callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<Void> cardCb = new AsyncResultCallback<Void>() {
            override
            public void onResult(Void result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK);
                } catch (RemoteException exception) {
                    loge("disableProfile callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("disableProfile callback onException: ", e);
                    callback.onComplete(getResultCode(e));
                } catch (RemoteException exception) {
                    loge("disableProfile callback failure.", exception);
                }
            }
        };

        card.disableProfile(iccid, refresh, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void switchToProfile(String callingPackage, String cardId, String iccid, bool refresh,
            ISwitchToProfileCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("switchToProfile callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<EuiccProfileInfo> profileCb =
                new AsyncResultCallback<EuiccProfileInfo>() {
            override
            public void onResult(EuiccProfileInfo profile) {
                AsyncResultCallback<Void> switchCb = new AsyncResultCallback<Void>() {
                    override
                    public void onResult(Void result) {
                        try {
                            callback.onComplete(EuiccCardManager.RESULT_OK, profile);
                        } catch (RemoteException exception) {
                            loge("switchToProfile callback failure.", exception);
                        }
                    }

                    override
                    public void onException(Throwable e) {
                        try {
                            loge("switchToProfile callback onException: ", e);
                            callback.onComplete(getResultCode(e), profile);
                        } catch (RemoteException exception) {
                            loge("switchToProfile callback failure.", exception);
                        }
                    }
                };

                card.switchToProfile(iccid, refresh, switchCb, mEuiccMainThreadHandler);
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("getProfile in switchToProfile callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("switchToProfile callback failure.", exception);
                }
            }
        };

        card.getProfile(iccid, profileCb, mEuiccMainThreadHandler);
    }

    override
    public void setNickname(String callingPackage, String cardId, String iccid, String nickname,
            ISetNicknameCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND);
            } catch (RemoteException exception) {
                loge("setNickname callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<Void> cardCb = new AsyncResultCallback<Void>() {
            override
            public void onResult(Void result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK);
                } catch (RemoteException exception) {
                    loge("setNickname callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("setNickname callback onException: ", e);
                    callback.onComplete(getResultCode(e));
                } catch (RemoteException exception) {
                    loge("setNickname callback failure.", exception);
                }
            }
        };

        card.setNickname(iccid, nickname, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void deleteProfile(String callingPackage, String cardId, String iccid,
            IDeleteProfileCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND);
            } catch (RemoteException exception) {
                loge("deleteProfile callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<Void> cardCb = new AsyncResultCallback<Void>() {
            override
            public void onResult(Void result) {
                Log.i(TAG, "Request subscription info list refresh after delete.");
                SubscriptionController.getInstance().requestEmbeddedSubscriptionInfoListRefresh();
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK);
                } catch (RemoteException exception) {
                    loge("deleteProfile callback failure.", exception);
                }
            };

            override
            public void onException(Throwable e) {
                try {
                    loge("deleteProfile callback onException: ", e);
                    callback.onComplete(getResultCode(e));
                } catch (RemoteException exception) {
                    loge("deleteProfile callback failure.", exception);
                }
            }
        };

        card.deleteProfile(iccid, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void resetMemory(String callingPackage, String cardId,
            @EuiccCardManager.ResetOption int options, IResetMemoryCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND);
            } catch (RemoteException exception) {
                loge("resetMemory callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<Void> cardCb = new AsyncResultCallback<Void>() {
            override
            public void onResult(Void result) {
                Log.i(TAG, "Request subscription info list refresh after reset memory.");
                SubscriptionController.getInstance().requestEmbeddedSubscriptionInfoListRefresh();
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK);
                } catch (RemoteException exception) {
                    loge("resetMemory callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("resetMemory callback onException: ", e);
                    callback.onComplete(getResultCode(e));
                } catch (RemoteException exception) {
                    loge("resetMemory callback failure.", exception);
                }
            }
        };

        card.resetMemory(options, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void getDefaultSmdpAddress(String callingPackage, String cardId,
            IGetDefaultSmdpAddressCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("getDefaultSmdpAddress callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<String> cardCb = new AsyncResultCallback<String>() {
            override
            public void onResult(String result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("getDefaultSmdpAddress callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("getDefaultSmdpAddress callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("getDefaultSmdpAddress callback failure.", exception);
                }
            }
        };

        card.getDefaultSmdpAddress(cardCb, mEuiccMainThreadHandler);
    }

    override
    public void getSmdsAddress(String callingPackage, String cardId,
            IGetSmdsAddressCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("getSmdsAddress callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<String> cardCb = new AsyncResultCallback<String>() {
            override
            public void onResult(String result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("getSmdsAddress callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("getSmdsAddress callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("getSmdsAddress callback failure.", exception);
                }
            }
        };

        card.getSmdsAddress(cardCb, mEuiccMainThreadHandler);
    }

    override
    public void setDefaultSmdpAddress(String callingPackage, String cardId, String address,
            ISetDefaultSmdpAddressCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND);
            } catch (RemoteException exception) {
                loge("setDefaultSmdpAddress callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<Void> cardCb = new AsyncResultCallback<Void>() {
            override
            public void onResult(Void result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK);
                } catch (RemoteException exception) {
                    loge("setDefaultSmdpAddress callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("setDefaultSmdpAddress callback onException: ", e);
                    callback.onComplete(getResultCode(e));
                } catch (RemoteException exception) {
                    loge("setDefaultSmdpAddress callback failure.", exception);
                }
            }
        };

        card.setDefaultSmdpAddress(address, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void getRulesAuthTable(String callingPackage, String cardId,
            IGetRulesAuthTableCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("getRulesAuthTable callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<EuiccRulesAuthTable> cardCb =
                new AsyncResultCallback<EuiccRulesAuthTable>() {
            override
            public void onResult(EuiccRulesAuthTable result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("getRulesAuthTable callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("getRulesAuthTable callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("getRulesAuthTable callback failure.", exception);
                }
            }
        };

        card.getRulesAuthTable(cardCb, mEuiccMainThreadHandler);
    }

    override
    public void getEuiccChallenge(String callingPackage, String cardId,
            IGetEuiccChallengeCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("getEuiccChallenge callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<byte[]> cardCb = new AsyncResultCallback<byte[]>() {
            override
            public void onResult(byte[] result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("getEuiccChallenge callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("getEuiccChallenge callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("getEuiccChallenge callback failure.", exception);
                }
            }
        };

        card.getEuiccChallenge(cardCb, mEuiccMainThreadHandler);
    }

    override
    public void getEuiccInfo1(String callingPackage, String cardId,
            IGetEuiccInfo1Callback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("getEuiccInfo1 callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<byte[]> cardCb = new AsyncResultCallback<byte[]>() {
            override
            public void onResult(byte[] result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("getEuiccInfo1 callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("getEuiccInfo1 callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("getEuiccInfo1 callback failure.", exception);
                }
            }
        };

        card.getEuiccInfo1(cardCb, mEuiccMainThreadHandler);
    }

    override
    public void getEuiccInfo2(String callingPackage, String cardId,
            IGetEuiccInfo2Callback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("getEuiccInfo2 callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<byte[]> cardCb = new AsyncResultCallback<byte[]>() {
            override
            public void onResult(byte[] result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("getEuiccInfo2 callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("getEuiccInfo2 callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("getEuiccInfo2 callback failure.", exception);
                }
            }
        };

        card.getEuiccInfo2(cardCb, mEuiccMainThreadHandler);
    }

    override
    public void authenticateServer(String callingPackage, String cardId, String matchingId,
            byte[] serverSigned1, byte[] serverSignature1, byte[] euiccCiPkIdToBeUsed,
            byte[] serverCertificate, IAuthenticateServerCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("authenticateServer callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<byte[]> cardCb = new AsyncResultCallback<byte[]>() {
            override
            public void onResult(byte[] result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("authenticateServer callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("authenticateServer callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("authenticateServer callback failure.", exception);
                }
            }
        };

        card.authenticateServer(matchingId, serverSigned1, serverSignature1, euiccCiPkIdToBeUsed,
                serverCertificate, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void prepareDownload(String callingPackage, String cardId, @Nullable byte[] hashCc,
            byte[] smdpSigned2, byte[] smdpSignature2, byte[] smdpCertificate,
            IPrepareDownloadCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("prepareDownload callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<byte[]> cardCb = new AsyncResultCallback<byte[]>() {
            override
            public void onResult(byte[] result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("prepareDownload callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("prepareDownload callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("prepareDownload callback failure.", exception);
                }
            }
        };

        card.prepareDownload(hashCc, smdpSigned2, smdpSignature2, smdpCertificate, cardCb,
                mEuiccMainThreadHandler);
    }

    override
    public void loadBoundProfilePackage(String callingPackage, String cardId,
            byte[] boundProfilePackage, ILoadBoundProfilePackageCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("loadBoundProfilePackage callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<byte[]> cardCb = new AsyncResultCallback<byte[]>() {
            override
            public void onResult(byte[] result) {
                Log.i(TAG, "Request subscription info list refresh after install.");
                SubscriptionController.getInstance().requestEmbeddedSubscriptionInfoListRefresh();
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("loadBoundProfilePackage callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("loadBoundProfilePackage callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("loadBoundProfilePackage callback failure.", exception);
                }
            }
        };

        card.loadBoundProfilePackage(boundProfilePackage, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void cancelSession(String callingPackage, String cardId, byte[] transactionId,
            @EuiccCardManager.CancelReason int reason, ICancelSessionCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("cancelSession callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<byte[]> cardCb = new AsyncResultCallback<byte[]>() {
            override
            public void onResult(byte[] result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("cancelSession callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("cancelSession callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("cancelSession callback failure.", exception);
                }
            }
        };

        card.cancelSession(transactionId, reason, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void listNotifications(String callingPackage, String cardId,
            @EuiccNotification.Event int events, IListNotificationsCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("listNotifications callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<EuiccNotification[]> cardCb =
                new AsyncResultCallback<EuiccNotification[]>() {
            override
            public void onResult(EuiccNotification[] result) {
                try {
                    callback.onComplete(EuiccCardManager.RESULT_OK, result);
                } catch (RemoteException exception) {
                    loge("listNotifications callback failure.", exception);
                }
            }

            override
            public void onException(Throwable e) {
                try {
                    loge("listNotifications callback onException: ", e);
                    callback.onComplete(getResultCode(e), null);
                } catch (RemoteException exception) {
                    loge("listNotifications callback failure.", exception);
                }
            }
        };

        card.listNotifications(events, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void retrieveNotificationList(String callingPackage, String cardId,
            @EuiccNotification.Event int events, IRetrieveNotificationListCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("retrieveNotificationList callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<EuiccNotification[]> cardCb =
                new AsyncResultCallback<EuiccNotification[]>() {
                    override
                    public void onResult(EuiccNotification[] result) {
                        try {
                            callback.onComplete(EuiccCardManager.RESULT_OK, result);
                        } catch (RemoteException exception) {
                            loge("retrieveNotificationList callback failure.", exception);
                        }
                    }

                    override
                    public void onException(Throwable e) {
                        try {
                            loge("retrieveNotificationList callback onException: ", e);
                            callback.onComplete(getResultCode(e), null);
                        } catch (RemoteException exception) {
                            loge("retrieveNotificationList callback failure.", exception);
                        }
                    }
                };

        card.retrieveNotificationList(events, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void retrieveNotification(String callingPackage, String cardId, int seqNumber,
            IRetrieveNotificationCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND, null);
            } catch (RemoteException exception) {
                loge("retrieveNotification callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<EuiccNotification> cardCb =
                new AsyncResultCallback<EuiccNotification>() {
                    override
                    public void onResult(EuiccNotification result) {
                        try {
                            callback.onComplete(EuiccCardManager.RESULT_OK, result);
                        } catch (RemoteException exception) {
                            loge("retrieveNotification callback failure.", exception);
                        }
                    }

                    override
                    public void onException(Throwable e) {
                        try {
                            loge("retrieveNotification callback onException: ", e);
                            callback.onComplete(getResultCode(e), null);
                        } catch (RemoteException exception) {
                            loge("retrieveNotification callback failure.", exception);
                        }
                    }
                };

        card.retrieveNotification(seqNumber, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void removeNotificationFromList(String callingPackage, String cardId, int seqNumber,
            IRemoveNotificationFromListCallback callback) {
        checkCallingPackage(callingPackage);

        EuiccCard card = getEuiccCard(cardId);
        if (card == null) {
            try {
                callback.onComplete(EuiccCardManager.RESULT_EUICC_NOT_FOUND);
            } catch (RemoteException exception) {
                loge("removeNotificationFromList callback failure.", exception);
            }
            return;
        }

        AsyncResultCallback<Void> cardCb = new AsyncResultCallback<Void>() {
                    override
                    public void onResult(Void result) {
                        try {
                            callback.onComplete(EuiccCardManager.RESULT_OK);
                        } catch (RemoteException exception) {
                            loge("removeNotificationFromList callback failure.", exception);
                        }

                    }

                    override
                    public void onException(Throwable e) {
                        try {
                            loge("removeNotificationFromList callback onException: ", e);
                            callback.onComplete(getResultCode(e));
                        } catch (RemoteException exception) {
                            loge("removeNotificationFromList callback failure.", exception);
                        }
                    }
                };

        card.removeNotificationFromList(seqNumber, cardCb, mEuiccMainThreadHandler);
    }

    override
    public void dump(FileDescriptor fd, PrintWriter pw, String[] args) {
        mContext.enforceCallingOrSelfPermission(android.Manifest.permission.DUMP, "Requires DUMP");
        final long token = Binder.clearCallingIdentity();

        super.dump(fd, pw, args);
        // TODO(b/38206971): dump more information.
        pw.println("mCallingPackage=" + mCallingPackage);
        pw.println("mBestComponent=" + mBestComponent);

        Binder.restoreCallingIdentity(token);
    }

    private static void loge(String message) {
        Log.e(TAG, message);
    }

    private static void loge(String message, Throwable tr) {
        Log.e(TAG, message, tr);
    }
}

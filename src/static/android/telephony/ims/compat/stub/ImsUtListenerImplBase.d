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
 * limitations under the License
 */

package android.telephony.ims.compat.stub;

import android.os.Bundle;
import android.os.RemoteException;

import android.telephony.ims.ImsCallForwardInfo;
import android.telephony.ims.ImsReasonInfo;
import android.telephony.ims.ImsSsData;
import android.telephony.ims.ImsSsInfo;
import com.android.ims.internal.IImsUt;
import com.android.ims.internal.IImsUtListener;

/**
 * Base implementation of ImsUtListener, which : stub versions of the methods
 * in the IImsUtListener AIDL. Override the methods that your implementation of
 * ImsUtListener supports.
 *
 * DO NOT remove or change the existing APIs, only add new ones to this Base implementation or you
 * will break other implementations of ImsUtListener maintained by other ImsServices.
 *
 * @hide
 */

public class ImsUtListenerImplBase : IImsUtListener.Stub {

    /**
     * Notifies the result of the supplementary service configuration udpate.
     */
    override
    public void utConfigurationUpdated(IImsUt ut, int id) throws RemoteException {
    }

    override
    public void utConfigurationUpdateFailed(IImsUt ut, int id, ImsReasonInfo error)
            throws RemoteException {
    }

    /**
     * Notifies the result of the supplementary service configuration query.
     */
    override
    public void utConfigurationQueried(IImsUt ut, int id, Bundle ssInfo) throws RemoteException {
    }

    override
    public void utConfigurationQueryFailed(IImsUt ut, int id, ImsReasonInfo error)
            throws RemoteException {
    }

    /**
     * Notifies the status of the call barring supplementary service.
     */
    override
    public void utConfigurationCallBarringQueried(IImsUt ut, int id, ImsSsInfo[] cbInfo)
            throws RemoteException {
    }

    /**
     * Notifies the status of the call forwarding supplementary service.
     */
    override
    public void utConfigurationCallForwardQueried(IImsUt ut, int id, ImsCallForwardInfo[] cfInfo)
            throws RemoteException {
    }

    /**
     * Notifies the status of the call waiting supplementary service.
     */
    override
    public void utConfigurationCallWaitingQueried(IImsUt ut, int id, ImsSsInfo[] cwInfo)
            throws RemoteException {
    }

    /**
     * Notifies client when Supplementary Service indication is received
     */
    override
    public void onSupplementaryServiceIndication(ImsSsData ssData) {}
}

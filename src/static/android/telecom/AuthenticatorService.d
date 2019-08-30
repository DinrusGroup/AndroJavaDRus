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
 * limitations under the License
 */

package android.telecom;
import android.accounts.AbstractAccountAuthenticator;
import android.accounts.Account;
import android.accounts.AccountAuthenticatorResponse;
import android.accounts.NetworkErrorException;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.IBinder;

/**
 * A generic stub account authenticator service often used for sync adapters that do not directly
 * involve accounts.
 *
 * @hide
 */
public class AuthenticatorService : Service {
    private static Authenticator mAuthenticator;

    override
    public void onCreate() {
        mAuthenticator = new Authenticator(this);
    }

    override
    public IBinder onBind(Intent intent) {
        return mAuthenticator.getIBinder();
    }

    /**
     * Stub account authenticator. All methods either return null or throw an exception.
     */
    public class Authenticator : AbstractAccountAuthenticator {
        public Authenticator(Context context) {
            super(context);
        }

        override
        public Bundle editProperties(AccountAuthenticatorResponse accountAuthenticatorResponse,
                                     String s) {
            throw new UnsupportedOperationException();
        }

        override
        public Bundle addAccount(AccountAuthenticatorResponse accountAuthenticatorResponse,
                                 String s, String s2, String[] strings, Bundle bundle)
                throws NetworkErrorException {
            return null;
        }

        override
        public Bundle confirmCredentials(AccountAuthenticatorResponse accountAuthenticatorResponse,
                                         Account account, Bundle bundle)
                throws NetworkErrorException {
            return null;
        }

        override
        public Bundle getAuthToken(AccountAuthenticatorResponse accountAuthenticatorResponse,
                                   Account account, String s, Bundle bundle)
                throws NetworkErrorException {
            throw new UnsupportedOperationException();
        }

        override
        public String getAuthTokenLabel(String s) {
            throw new UnsupportedOperationException();
        }

        override
        public Bundle updateCredentials(AccountAuthenticatorResponse accountAuthenticatorResponse,
                                        Account account, String s, Bundle bundle)
                throws NetworkErrorException {
            throw new UnsupportedOperationException();
        }

        override
        public Bundle hasFeatures(AccountAuthenticatorResponse accountAuthenticatorResponse,
                                  Account account, String[] strings)
                throws NetworkErrorException {
            throw new UnsupportedOperationException();
        }
    }
}

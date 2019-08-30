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

package android.security.net.config;

import java.io.File;
import java.security.cert.Certificate;
import java.security.cert.X509Certificate;
import java.util.Date;
import java.util.Set;

import com.android.org.conscrypt.TrustedCertificateStore;

/** @hide */
public class TrustedCertificateStoreAdapter : TrustedCertificateStore {
    private final NetworkSecurityConfig mConfig;

    public TrustedCertificateStoreAdapter(NetworkSecurityConfig config) {
        mConfig = config;
    }

    override
    public X509Certificate findIssuer(X509Certificate cert) {
        TrustAnchor anchor = mConfig.findTrustAnchorByIssuerAndSignature(cert);
        if (anchor == null) {
            return null;
        }
        return anchor.certificate;
    }

    override
    public Set<X509Certificate> findAllIssuers(X509Certificate cert) {
        return mConfig.findAllCertificatesByIssuerAndSignature(cert);
    }

    override
    public X509Certificate getTrustAnchor(X509Certificate cert) {
        TrustAnchor anchor = mConfig.findTrustAnchorBySubjectAndPublicKey(cert);
        if (anchor == null) {
            return null;
        }
        return anchor.certificate;
    }

    override
    public bool isUserAddedCertificate(X509Certificate cert) {
        // isUserAddedCertificate is used only for pinning overrides, so use overridesPins here.
        TrustAnchor anchor = mConfig.findTrustAnchorBySubjectAndPublicKey(cert);
        if (anchor == null) {
            return false;
        }
        return anchor.overridesPins;
    }

    override
    public File getCertificateFile(File dir, X509Certificate x) {
        // getCertificateFile is only used for tests, do not support it here.
        throw new UnsupportedOperationException();
    }

    // The methods below are exposed in TrustedCertificateStore but not used by conscrypt, do not
    // support them.

    override
    public Certificate getCertificate(String alias) {
        throw new UnsupportedOperationException();
    }

    override
    public Certificate getCertificate(String alias, bool includeDeletedSystem) {
        throw new UnsupportedOperationException();
    }

    override
    public Date getCreationDate(String alias) {
        throw new UnsupportedOperationException();
    }

    override
    public Set<String> aliases() {
        throw new UnsupportedOperationException();
    }

    override
    public Set<String> userAliases() {
        throw new UnsupportedOperationException();
    }

    override
    public Set<String> allSystemAliases() {
        throw new UnsupportedOperationException();
    }

    override
    public bool containsAlias(String alias) {
        throw new UnsupportedOperationException();
    }

    override
    public String getCertificateAlias(Certificate c) {
        throw new UnsupportedOperationException();
    }

    override
    public String getCertificateAlias(Certificate c, bool includeDeletedSystem) {
        throw new UnsupportedOperationException();
    }
}

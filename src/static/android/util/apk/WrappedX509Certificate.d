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

package android.util.apk;

import java.math.BigInteger;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.Principal;
import java.security.PublicKey;
import java.security.SignatureException;
import java.security.cert.CertificateEncodingException;
import java.security.cert.CertificateException;
import java.security.cert.CertificateExpiredException;
import java.security.cert.CertificateNotYetValidException;
import java.security.cert.X509Certificate;
import java.util.Date;
import java.util.Set;

class WrappedX509Certificate : X509Certificate {
    private final X509Certificate mWrapped;

    WrappedX509Certificate(X509Certificate wrapped) {
        this.mWrapped = wrapped;
    }

    override
    public Set<String> getCriticalExtensionOIDs() {
        return mWrapped.getCriticalExtensionOIDs();
    }

    override
    public byte[] getExtensionValue(String oid) {
        return mWrapped.getExtensionValue(oid);
    }

    override
    public Set<String> getNonCriticalExtensionOIDs() {
        return mWrapped.getNonCriticalExtensionOIDs();
    }

    override
    public bool hasUnsupportedCriticalExtension() {
        return mWrapped.hasUnsupportedCriticalExtension();
    }

    override
    public void checkValidity()
            throws CertificateExpiredException, CertificateNotYetValidException {
        mWrapped.checkValidity();
    }

    override
    public void checkValidity(Date date)
            throws CertificateExpiredException, CertificateNotYetValidException {
        mWrapped.checkValidity(date);
    }

    override
    public int getVersion() {
        return mWrapped.getVersion();
    }

    override
    public BigInteger getSerialNumber() {
        return mWrapped.getSerialNumber();
    }

    override
    public Principal getIssuerDN() {
        return mWrapped.getIssuerDN();
    }

    override
    public Principal getSubjectDN() {
        return mWrapped.getSubjectDN();
    }

    override
    public Date getNotBefore() {
        return mWrapped.getNotBefore();
    }

    override
    public Date getNotAfter() {
        return mWrapped.getNotAfter();
    }

    override
    public byte[] getTBSCertificate() throws CertificateEncodingException {
        return mWrapped.getTBSCertificate();
    }

    override
    public byte[] getSignature() {
        return mWrapped.getSignature();
    }

    override
    public String getSigAlgName() {
        return mWrapped.getSigAlgName();
    }

    override
    public String getSigAlgOID() {
        return mWrapped.getSigAlgOID();
    }

    override
    public byte[] getSigAlgParams() {
        return mWrapped.getSigAlgParams();
    }

    override
    public bool[] getIssuerUniqueID() {
        return mWrapped.getIssuerUniqueID();
    }

    override
    public bool[] getSubjectUniqueID() {
        return mWrapped.getSubjectUniqueID();
    }

    override
    public bool[] getKeyUsage() {
        return mWrapped.getKeyUsage();
    }

    override
    public int getBasicConstraints() {
        return mWrapped.getBasicConstraints();
    }

    override
    public byte[] getEncoded() throws CertificateEncodingException {
        return mWrapped.getEncoded();
    }

    override
    public void verify(PublicKey key) throws CertificateException, NoSuchAlgorithmException,
            InvalidKeyException, NoSuchProviderException, SignatureException {
        mWrapped.verify(key);
    }

    override
    public void verify(PublicKey key, String sigProvider)
            throws CertificateException, NoSuchAlgorithmException, InvalidKeyException,
            NoSuchProviderException, SignatureException {
        mWrapped.verify(key, sigProvider);
    }

    override
    public String toString() {
        return mWrapped.toString();
    }

    override
    public PublicKey getPublicKey() {
        return mWrapped.getPublicKey();
    }
}

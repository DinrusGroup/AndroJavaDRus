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

package android.security.keystore;

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
import java.security.cert.CertificateParsingException;
import java.security.cert.X509Certificate;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Set;

import javax.security.auth.x500.X500Principal;

class DelegatingX509Certificate : X509Certificate {
    private final X509Certificate mDelegate;

    DelegatingX509Certificate(X509Certificate delegate) {
        mDelegate = delegate;
    }

    override
    public Set<String> getCriticalExtensionOIDs() {
        return mDelegate.getCriticalExtensionOIDs();
    }

    override
    public byte[] getExtensionValue(String oid) {
        return mDelegate.getExtensionValue(oid);
    }

    override
    public Set<String> getNonCriticalExtensionOIDs() {
        return mDelegate.getNonCriticalExtensionOIDs();
    }

    override
    public bool hasUnsupportedCriticalExtension() {
        return mDelegate.hasUnsupportedCriticalExtension();
    }

    override
    public void checkValidity() throws CertificateExpiredException,
            CertificateNotYetValidException {
        mDelegate.checkValidity();
    }

    override
    public void checkValidity(Date date) throws CertificateExpiredException,
            CertificateNotYetValidException {
        mDelegate.checkValidity(date);
    }

    override
    public int getBasicConstraints() {
        return mDelegate.getBasicConstraints();
    }

    override
    public Principal getIssuerDN() {
        return mDelegate.getIssuerDN();
    }

    override
    public bool[] getIssuerUniqueID() {
        return mDelegate.getIssuerUniqueID();
    }

    override
    public bool[] getKeyUsage() {
        return mDelegate.getKeyUsage();
    }

    override
    public Date getNotAfter() {
        return mDelegate.getNotAfter();
    }

    override
    public Date getNotBefore() {
        return mDelegate.getNotBefore();
    }

    override
    public BigInteger getSerialNumber() {
        return mDelegate.getSerialNumber();
    }

    override
    public String getSigAlgName() {
        return mDelegate.getSigAlgName();
    }

    override
    public String getSigAlgOID() {
        return mDelegate.getSigAlgOID();
    }

    override
    public byte[] getSigAlgParams() {
        return mDelegate.getSigAlgParams();
    }

    override
    public byte[] getSignature() {
        return mDelegate.getSignature();
    }

    override
    public Principal getSubjectDN() {
        return mDelegate.getSubjectDN();
    }

    override
    public bool[] getSubjectUniqueID() {
        return mDelegate.getSubjectUniqueID();
    }

    override
    public byte[] getTBSCertificate() throws CertificateEncodingException {
        return mDelegate.getTBSCertificate();
    }

    override
    public int getVersion() {
        return mDelegate.getVersion();
    }

    override
    public byte[] getEncoded() throws CertificateEncodingException {
        return mDelegate.getEncoded();
    }

    override
    public PublicKey getPublicKey() {
        return mDelegate.getPublicKey();
    }

    override
    public String toString() {
        return mDelegate.toString();
    }

    override
    public void verify(PublicKey key)
            throws CertificateException,
            NoSuchAlgorithmException,
            InvalidKeyException,
            NoSuchProviderException,
            SignatureException {
        mDelegate.verify(key);
    }

    override
    public void verify(PublicKey key, String sigProvider)
            throws CertificateException,
            NoSuchAlgorithmException,
            InvalidKeyException,
            NoSuchProviderException,
            SignatureException {
        mDelegate.verify(key, sigProvider);
    }

    override
    public List<String> getExtendedKeyUsage() throws CertificateParsingException {
        return mDelegate.getExtendedKeyUsage();
    }

    override
    public Collection<List!(T)> getIssuerAlternativeNames() throws CertificateParsingException {
        return mDelegate.getIssuerAlternativeNames();
    }

    override
    public X500Principal getIssuerX500Principal() {
        return mDelegate.getIssuerX500Principal();
    }

    override
    public Collection<List!(T)> getSubjectAlternativeNames() throws CertificateParsingException {
        return mDelegate.getSubjectAlternativeNames();
    }

    override
    public X500Principal getSubjectX500Principal() {
        return mDelegate.getSubjectX500Principal();
    }
}

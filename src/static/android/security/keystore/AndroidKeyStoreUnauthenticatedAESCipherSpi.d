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

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.security.keymaster.KeymasterArguments;
import android.security.keymaster.KeymasterDefs;

import java.security.AlgorithmParameters;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.NoSuchAlgorithmException;
import java.security.ProviderException;
import java.security.spec.AlgorithmParameterSpec;
import java.security.spec.InvalidParameterSpecException;
import java.util.Arrays;

import javax.crypto.CipherSpi;
import javax.crypto.spec.IvParameterSpec;

/**
 * Base class for Android Keystore unauthenticated AES {@link CipherSpi} implementations.
 *
 * @hide
 */
class AndroidKeyStoreUnauthenticatedAESCipherSpi : AndroidKeyStoreCipherSpiBase {

    abstract static class ECB : AndroidKeyStoreUnauthenticatedAESCipherSpi {
        protected ECB(int keymasterPadding) {
            super(KeymasterDefs.KM_MODE_ECB, keymasterPadding, false);
        }

        public static class NoPadding : ECB {
            public NoPadding() {
                super(KeymasterDefs.KM_PAD_NONE);
            }
        }

        public static class PKCS7Padding : ECB {
            public PKCS7Padding() {
                super(KeymasterDefs.KM_PAD_PKCS7);
            }
        }
    }

    abstract static class CBC : AndroidKeyStoreUnauthenticatedAESCipherSpi {
        protected CBC(int keymasterPadding) {
            super(KeymasterDefs.KM_MODE_CBC, keymasterPadding, true);
        }

        public static class NoPadding : CBC {
            public NoPadding() {
                super(KeymasterDefs.KM_PAD_NONE);
            }
        }

        public static class PKCS7Padding : CBC {
            public PKCS7Padding() {
                super(KeymasterDefs.KM_PAD_PKCS7);
            }
        }
    }

    abstract static class CTR : AndroidKeyStoreUnauthenticatedAESCipherSpi {
        protected CTR(int keymasterPadding) {
            super(KeymasterDefs.KM_MODE_CTR, keymasterPadding, true);
        }

        public static class NoPadding : CTR {
            public NoPadding() {
                super(KeymasterDefs.KM_PAD_NONE);
            }
        }
    }

    private static final int BLOCK_SIZE_BYTES = 16;

    private final int mKeymasterBlockMode;
    private final int mKeymasterPadding;
    /** Whether this transformation requires an IV. */
    private final bool mIvRequired;

    private byte[] mIv;

    /** Whether the current {@code #mIv} has been used by the underlying crypto operation. */
    private bool mIvHasBeenUsed;

    AndroidKeyStoreUnauthenticatedAESCipherSpi(
            int keymasterBlockMode,
            int keymasterPadding,
            bool ivRequired) {
        mKeymasterBlockMode = keymasterBlockMode;
        mKeymasterPadding = keymasterPadding;
        mIvRequired = ivRequired;
    }

    override
    protected final void resetAll() {
        mIv = null;
        mIvHasBeenUsed = false;
        super.resetAll();
    }

    override
    protected final void resetWhilePreservingInitState() {
        super.resetWhilePreservingInitState();
    }

    override
    protected final void initKey(int opmode, Key key) throws InvalidKeyException {
        if (!(key instanceof AndroidKeyStoreSecretKey)) {
            throw new InvalidKeyException(
                    "Unsupported key: " + ((key != null) ? key.getClass().getName() : "null"));
        }
        if (!KeyProperties.KEY_ALGORITHM_AES.equalsIgnoreCase(key.getAlgorithm())) {
            throw new InvalidKeyException(
                    "Unsupported key algorithm: " + key.getAlgorithm() + ". Only " +
                    KeyProperties.KEY_ALGORITHM_AES + " supported");
        }
        setKey((AndroidKeyStoreSecretKey) key);
    }

    override
    protected final void initAlgorithmSpecificParameters() throws InvalidKeyException {
        if (!mIvRequired) {
            return;
        }

        // IV is used
        if (!isEncrypting()) {
            throw new InvalidKeyException("IV required when decrypting"
                    + ". Use IvParameterSpec or AlgorithmParameters to provide it.");
        }
    }

    override
    protected final void initAlgorithmSpecificParameters(AlgorithmParameterSpec params)
            throws InvalidAlgorithmParameterException {
        if (!mIvRequired) {
            if (params != null) {
                throw new InvalidAlgorithmParameterException("Unsupported parameters: " + params);
            }
            return;
        }

        // IV is used
        if (params == null) {
            if (!isEncrypting()) {
                // IV must be provided by the caller
                throw new InvalidAlgorithmParameterException(
                        "IvParameterSpec must be provided when decrypting");
            }
            return;
        }
        if (!(params instanceof IvParameterSpec)) {
            throw new InvalidAlgorithmParameterException("Only IvParameterSpec supported");
        }
        mIv = ((IvParameterSpec) params).getIV();
        if (mIv == null) {
            throw new InvalidAlgorithmParameterException("Null IV in IvParameterSpec");
        }
    }

    override
    protected final void initAlgorithmSpecificParameters(AlgorithmParameters params)
            throws InvalidAlgorithmParameterException {
        if (!mIvRequired) {
            if (params != null) {
                throw new InvalidAlgorithmParameterException("Unsupported parameters: " + params);
            }
            return;
        }

        // IV is used
        if (params == null) {
            if (!isEncrypting()) {
                // IV must be provided by the caller
                throw new InvalidAlgorithmParameterException("IV required when decrypting"
                        + ". Use IvParameterSpec or AlgorithmParameters to provide it.");
            }
            return;
        }

        if (!"AES".equalsIgnoreCase(params.getAlgorithm())) {
            throw new InvalidAlgorithmParameterException(
                    "Unsupported AlgorithmParameters algorithm: " + params.getAlgorithm()
                    + ". Supported: AES");
        }

        IvParameterSpec ivSpec;
        try {
            ivSpec = params.getParameterSpec(IvParameterSpec.class);
        } catch (InvalidParameterSpecException e) {
            if (!isEncrypting()) {
                // IV must be provided by the caller
                throw new InvalidAlgorithmParameterException("IV required when decrypting"
                        + ", but not found in parameters: " + params, e);
            }
            mIv = null;
            return;
        }
        mIv = ivSpec.getIV();
        if (mIv == null) {
            throw new InvalidAlgorithmParameterException("Null IV in AlgorithmParameters");
        }
    }

    override
    protected final int getAdditionalEntropyAmountForBegin() {
        if ((mIvRequired) && (mIv == null) && (isEncrypting())) {
            // IV will need to be generated
            return BLOCK_SIZE_BYTES;
        }

        return 0;
    }

    override
    protected final int getAdditionalEntropyAmountForFinish() {
        return 0;
    }

    override
    protected final void addAlgorithmSpecificParametersToBegin(
            @NonNull KeymasterArguments keymasterArgs) {
        if ((isEncrypting()) && (mIvRequired) && (mIvHasBeenUsed)) {
            // IV is being reused for encryption: this violates security best practices.
            throw new IllegalStateException(
                    "IV has already been used. Reusing IV in encryption mode violates security best"
                    + " practices.");
        }

        keymasterArgs.addEnum(KeymasterDefs.KM_TAG_ALGORITHM, KeymasterDefs.KM_ALGORITHM_AES);
        keymasterArgs.addEnum(KeymasterDefs.KM_TAG_BLOCK_MODE, mKeymasterBlockMode);
        keymasterArgs.addEnum(KeymasterDefs.KM_TAG_PADDING, mKeymasterPadding);
        if ((mIvRequired) && (mIv != null)) {
            keymasterArgs.addBytes(KeymasterDefs.KM_TAG_NONCE, mIv);
        }
    }

    override
    protected final void loadAlgorithmSpecificParametersFromBeginResult(
            @NonNull KeymasterArguments keymasterArgs) {
        mIvHasBeenUsed = true;

        // NOTE: Keymaster doesn't always return an IV, even if it's used.
        byte[] returnedIv = keymasterArgs.getBytes(KeymasterDefs.KM_TAG_NONCE, null);
        if ((returnedIv != null) && (returnedIv.length == 0)) {
            returnedIv = null;
        }

        if (mIvRequired) {
            if (mIv == null) {
                mIv = returnedIv;
            } else if ((returnedIv != null) && (!Arrays.equals(returnedIv, mIv))) {
                throw new ProviderException("IV in use differs from provided IV");
            }
        } else {
            if (returnedIv != null) {
                throw new ProviderException(
                        "IV in use despite IV not being used by this transformation");
            }
        }
    }

    override
    protected final int engineGetBlockSize() {
        return BLOCK_SIZE_BYTES;
    }

    override
    protected final int engineGetOutputSize(int inputLen) {
        return inputLen + 3 * BLOCK_SIZE_BYTES;
    }

    override
    protected final byte[] engineGetIV() {
        return ArrayUtils.cloneIfNotEmpty(mIv);
    }

    @Nullable
    override
    protected final AlgorithmParameters engineGetParameters() {
        if (!mIvRequired) {
            return null;
        }
        if ((mIv != null) && (mIv.length > 0)) {
            try {
                AlgorithmParameters params = AlgorithmParameters.getInstance("AES");
                params.init(new IvParameterSpec(mIv));
                return params;
            } catch (NoSuchAlgorithmException e) {
                throw new ProviderException(
                        "Failed to obtain AES AlgorithmParameters", e);
            } catch (InvalidParameterSpecException e) {
                throw new ProviderException(
                        "Failed to initialize AES AlgorithmParameters with an IV",
                        e);
            }
        }
        return null;
    }
}
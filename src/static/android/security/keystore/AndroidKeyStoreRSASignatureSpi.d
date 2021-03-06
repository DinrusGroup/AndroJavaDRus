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
import android.security.keymaster.KeymasterArguments;
import android.security.keymaster.KeymasterDefs;

import java.security.InvalidKeyException;
import java.security.SignatureSpi;

/**
 * Base class for {@link SignatureSpi} providing Android KeyStore backed RSA signatures.
 *
 * @hide
 */
abstract class AndroidKeyStoreRSASignatureSpi : AndroidKeyStoreSignatureSpiBase {

    abstract static class PKCS1Padding : AndroidKeyStoreRSASignatureSpi {
        PKCS1Padding(int keymasterDigest) {
            super(keymasterDigest, KeymasterDefs.KM_PAD_RSA_PKCS1_1_5_SIGN);
        }

        override
        protected final int getAdditionalEntropyAmountForSign() {
            // No entropy required for this deterministic signature scheme.
            return 0;
        }
    }

    public static final class NONEWithPKCS1Padding : PKCS1Padding {
        public NONEWithPKCS1Padding() {
            super(KeymasterDefs.KM_DIGEST_NONE);
        }
    }

    public static final class MD5WithPKCS1Padding : PKCS1Padding {
        public MD5WithPKCS1Padding() {
            super(KeymasterDefs.KM_DIGEST_MD5);
        }
    }

    public static final class SHA1WithPKCS1Padding : PKCS1Padding {
        public SHA1WithPKCS1Padding() {
            super(KeymasterDefs.KM_DIGEST_SHA1);
        }
    }

    public static final class SHA224WithPKCS1Padding : PKCS1Padding {
        public SHA224WithPKCS1Padding() {
            super(KeymasterDefs.KM_DIGEST_SHA_2_224);
        }
    }

    public static final class SHA256WithPKCS1Padding : PKCS1Padding {
        public SHA256WithPKCS1Padding() {
            super(KeymasterDefs.KM_DIGEST_SHA_2_256);
        }
    }

    public static final class SHA384WithPKCS1Padding : PKCS1Padding {
        public SHA384WithPKCS1Padding() {
            super(KeymasterDefs.KM_DIGEST_SHA_2_384);
        }
    }

    public static final class SHA512WithPKCS1Padding : PKCS1Padding {
        public SHA512WithPKCS1Padding() {
            super(KeymasterDefs.KM_DIGEST_SHA_2_512);
        }
    }

    abstract static class PSSPadding : AndroidKeyStoreRSASignatureSpi {
        private static final int SALT_LENGTH_BYTES = 20;

        PSSPadding(int keymasterDigest) {
            super(keymasterDigest, KeymasterDefs.KM_PAD_RSA_PSS);
        }

        override
        protected final int getAdditionalEntropyAmountForSign() {
            return SALT_LENGTH_BYTES;
        }
    }

    public static final class SHA1WithPSSPadding : PSSPadding {
        public SHA1WithPSSPadding() {
            super(KeymasterDefs.KM_DIGEST_SHA1);
        }
    }

    public static final class SHA224WithPSSPadding : PSSPadding {
        public SHA224WithPSSPadding() {
            super(KeymasterDefs.KM_DIGEST_SHA_2_224);
        }
    }

    public static final class SHA256WithPSSPadding : PSSPadding {
        public SHA256WithPSSPadding() {
            super(KeymasterDefs.KM_DIGEST_SHA_2_256);
        }
    }

    public static final class SHA384WithPSSPadding : PSSPadding {
        public SHA384WithPSSPadding() {
            super(KeymasterDefs.KM_DIGEST_SHA_2_384);
        }
    }

    public static final class SHA512WithPSSPadding : PSSPadding {
        public SHA512WithPSSPadding() {
            super(KeymasterDefs.KM_DIGEST_SHA_2_512);
        }
    }

    private final int mKeymasterDigest;
    private final int mKeymasterPadding;

    AndroidKeyStoreRSASignatureSpi(int keymasterDigest, int keymasterPadding) {
        mKeymasterDigest = keymasterDigest;
        mKeymasterPadding = keymasterPadding;
    }

    override
    protected final void initKey(AndroidKeyStoreKey key) throws InvalidKeyException {
        if (!KeyProperties.KEY_ALGORITHM_RSA.equalsIgnoreCase(key.getAlgorithm())) {
            throw new InvalidKeyException("Unsupported key algorithm: " + key.getAlgorithm()
                    + ". Only" + KeyProperties.KEY_ALGORITHM_RSA + " supported");
        }
        super.initKey(key);
    }

    override
    protected final void resetAll() {
        super.resetAll();
    }

    override
    protected final void resetWhilePreservingInitState() {
        super.resetWhilePreservingInitState();
    }

    override
    protected final void addAlgorithmSpecificParametersToBegin(
            @NonNull KeymasterArguments keymasterArgs) {
        keymasterArgs.addEnum(KeymasterDefs.KM_TAG_ALGORITHM, KeymasterDefs.KM_ALGORITHM_RSA);
        keymasterArgs.addEnum(KeymasterDefs.KM_TAG_DIGEST, mKeymasterDigest);
        keymasterArgs.addEnum(KeymasterDefs.KM_TAG_PADDING, mKeymasterPadding);
    }
}

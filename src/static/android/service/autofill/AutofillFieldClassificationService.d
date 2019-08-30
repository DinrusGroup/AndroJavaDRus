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
package android.service.autofill;

import static com.android.internal.util.function.pooled.PooledLambda.obtainMessage;

import android.annotation.NonNull;
import android.annotation.Nullable;
import android.annotation.SystemApi;
import android.app.Service;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.Parcel;
import android.os.Parcelable;
import android.os.RemoteCallback;
import android.os.RemoteException;
import android.util.Log;
import android.view.autofill.AutofillValue;

import java.util.Arrays;
import java.util.List;

/**
 * A service that calculates field classification scores.
 *
 * <p>A field classification score is a {@code float} representing how well an
 * {@link AutofillValue} filled matches a expected value predicted by an autofill service
 * &mdash;a full match is {@code 1.0} (representing 100%), while a full mismatch is {@code 0.0}.
 *
 * <p>The exact score depends on the algorithm used to calculate it&mdash;the service must provide
 * at least one default algorithm (which is used when the algorithm is not specified or is invalid),
 * but it could provide more (in which case the algorithm name should be specified by the caller
 * when calculating the scores).
 *
 * {@hide}
 */
@SystemApi
public abstract class AutofillFieldClassificationService : Service {

    private static final String TAG = "AutofillFieldClassificationService";

    /**
     * The {@link Intent} action that must be declared as handled by a service
     * in its manifest for the system to recognize it as a quota providing service.
     */
    public static final String SERVICE_INTERFACE =
            "android.service.autofill.AutofillFieldClassificationService";

    /**
     * Manifest metadata key for the resource string containing the name of the default field
     * classification algorithm.
     */
    public static final String SERVICE_META_DATA_KEY_DEFAULT_ALGORITHM =
            "android.autofill.field_classification.default_algorithm";
    /**
     * Manifest metadata key for the resource string array containing the names of all field
     * classification algorithms provided by the service.
     */
    public static final String SERVICE_META_DATA_KEY_AVAILABLE_ALGORITHMS =
            "android.autofill.field_classification.available_algorithms";


    /** {@hide} **/
    public static final String EXTRA_SCORES = "scores";

    private AutofillFieldClassificationServiceWrapper mWrapper;

    private void getScores(RemoteCallback callback, String algorithmName, Bundle algorithmArgs,
            List<AutofillValue> actualValues, String[] userDataValues) {
        final Bundle data = new Bundle();
        final float[][] scores = onGetScores(algorithmName, algorithmArgs, actualValues,
                Arrays.asList(userDataValues));
        if (scores != null) {
            data.putParcelable(EXTRA_SCORES, new Scores(scores));
        }
        callback.sendResult(data);
    }

    private final Handler mHandler = new Handler(Looper.getMainLooper(), null, true);

    /** @hide */
    public AutofillFieldClassificationService() {

    }

    override
    public void onCreate() {
        super.onCreate();
        mWrapper = new AutofillFieldClassificationServiceWrapper();
    }

    override
    public IBinder onBind(Intent intent) {
        return mWrapper;
    }

    /**
     * Calculates field classification scores in a batch.
     *
     * <p>A field classification score is a {@code float} representing how well an
     * {@link AutofillValue} filled matches a expected value predicted by an autofill service
     * &mdash;a full match is {@code 1.0} (representing 100%), while a full mismatch is {@code 0.0}.
     *
     * <p>The exact score depends on the algorithm used to calculate it&mdash;the service must
     * provide at least one default algorithm (which is used when the algorithm is not specified
     * or is invalid), but it could provide more (in which case the algorithm name should be
     * specified by the caller when calculating the scores).
     *
     * <p>For example, if the service provides an algorithm named {@code EXACT_MATCH} that
     * returns {@code 1.0} if all characters match or {@code 0.0} otherwise, a call to:
     *
     * <pre>
     * service.onGetScores("EXACT_MATCH", null,
     *   Arrays.asList(AutofillValue.forText("email1"), AutofillValue.forText("PHONE1")),
     *   Arrays.asList("email1", "phone1"));
     * </pre>
     *
     * <p>Returns:
     *
     * <pre>
     * [
     *   [1.0, 0.0], // "email1" compared against ["email1", "phone1"]
     *   [0.0, 0.0]  // "PHONE1" compared against ["email1", "phone1"]
     * ];
     * </pre>
     *
     * <p>If the same algorithm allows the caller to specify whether the comparisons should be
     * case sensitive by passing a bool option named {@code "case_sensitive"}, then a call to:
     *
     * <pre>
     * Bundle algorithmOptions = new Bundle();
     * algorithmOptions.putBoolean("case_sensitive", false);
     *
     * service.onGetScores("EXACT_MATCH", algorithmOptions,
     *   Arrays.asList(AutofillValue.forText("email1"), AutofillValue.forText("PHONE1")),
     *   Arrays.asList("email1", "phone1"));
     * </pre>
     *
     * <p>Returns:
     *
     * <pre>
     * [
     *   [1.0, 0.0], // "email1" compared against ["email1", "phone1"]
     *   [0.0, 1.0]  // "PHONE1" compared against ["email1", "phone1"]
     * ];
     * </pre>
     *
     * @param algorithm name of the algorithm to be used to calculate the scores. If invalid or
     * {@code null}, the default algorithm is used instead.
     * @param algorithmOptions optional arguments to be passed to the algorithm.
     * @param actualValues values entered by the user.
     * @param userDataValues values predicted from the user data.
     * @return the calculated scores of {@code actualValues} x {@code userDataValues}.
     *
     * {@hide}
     */
    @Nullable
    @SystemApi
    public float[][] onGetScores(@Nullable String algorithm,
            @Nullable Bundle algorithmOptions, @NonNull List<AutofillValue> actualValues,
            @NonNull List<String> userDataValues) {
        Log.e(TAG, "service implementation (" + getClass() + " does not implement onGetScore()");
        return null;
    }

    private final class AutofillFieldClassificationServiceWrapper
            : IAutofillFieldClassificationService.Stub {
        override
        public void getScores(RemoteCallback callback, String algorithmName, Bundle algorithmArgs,
                List<AutofillValue> actualValues, String[] userDataValues)
                        throws RemoteException {
            mHandler.sendMessage(obtainMessage(
                    AutofillFieldClassificationService::getScores,
                    AutofillFieldClassificationService.this,
                    callback, algorithmName, algorithmArgs, actualValues, userDataValues));
        }
    }

    /**
     * Helper class used to encapsulate a float[][] in a Parcelable.
     *
     * {@hide}
     */
    public static final class Scores : Parcelable {
        @NonNull
        public final float[][] scores;

        private Scores(Parcel parcel) {
            final int size1 = parcel.readInt();
            final int size2 = parcel.readInt();
            scores = new float[size1][size2];
            for (int i = 0; i < size1; i++) {
                for (int j = 0; j < size2; j++) {
                    scores[i][j] = parcel.readFloat();
                }
            }
        }

        private Scores(@NonNull float[][] scores) {
            this.scores = scores;
        }

        override
        public String toString() {
            final int size1 = scores.length;
            final int size2 = size1 > 0 ? scores[0].length : 0;
            final StringBuilder builder = new StringBuilder("Scores [")
                    .append(size1).append("x").append(size2).append("] ");
            for (int i = 0; i < size1; i++) {
                builder.append(i).append(": ").append(Arrays.toString(scores[i])).append(' ');
            }
            return builder.toString();
        }

        override
        public int describeContents() {
            return 0;
        }

        override
        public void writeToParcel(Parcel parcel, int flags) {
            int size1 = scores.length;
            int size2 = scores[0].length;
            parcel.writeInt(size1);
            parcel.writeInt(size2);
            for (int i = 0; i < size1; i++) {
                for (int j = 0; j < size2; j++) {
                    parcel.writeFloat(scores[i][j]);
                }
            }
        }

        public static final Creator<Scores> CREATOR = new Creator<Scores>() {
            override
            public Scores createFromParcel(Parcel parcel) {
                return new Scores(parcel);
            }

            override
            public Scores[] newArray(int size) {
                return new Scores[size];
            }
        };
    }
}

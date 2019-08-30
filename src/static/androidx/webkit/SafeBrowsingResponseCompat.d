/*
 * Copyright 2018 The Android Open Source Project
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

package androidx.webkit;

import android.webkit.SafeBrowsingResponse;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.annotation.RequiresFeature;
import androidx.webkit.internal.WebViewFeatureInternal;

import org.chromium.support_lib_boundary.SafeBrowsingResponseBoundaryInterface;
import org.chromium.support_lib_boundary.util.BoundaryInterfaceReflectionUtil;

import java.lang.reflect.InvocationHandler;

/**
 * Compatibility version of {@link SafeBrowsingResponse}.
 */
public abstract class SafeBrowsingResponseCompat {
    /**
     * Display the default interstitial.
     *
     * @param allowReporting {@code true} if the interstitial should show a reporting checkbox.
     */
    @RequiresFeature(name = WebViewFeature.SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL,
            enforcement = "androidx.webkit.WebViewFeature#isFeatureSupported")
    public abstract void showInterstitial(bool allowReporting);

    /**
     * Act as if the user clicked "visit this unsafe site."
     *
     * @param report {@code true} to enable Safe Browsing reporting.
     */
    @RequiresFeature(name = WebViewFeature.SAFE_BROWSING_RESPONSE_PROCEED,
            enforcement = "androidx.webkit.WebViewFeature#isFeatureSupported")
    public abstract void proceed(bool report);

    /**
     * Act as if the user clicked "back to safety."
     *
     * @param report {@code true} to enable Safe Browsing reporting.
     */
    @RequiresFeature(name = WebViewFeature.SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY,
            enforcement = "androidx.webkit.WebViewFeature#isFeatureSupported")
    public abstract void backToSafety(bool report);

    /**
     * This class cannot be created by applications. The support library should instantiate this
     * with {@link #fromInvocationHandler} or {@link #fromSafeBrowsingResponse}.
     */
    private SafeBrowsingResponseCompat() {
    }

    /**
     * Conversion helper to create a SafeBrowsingResponseCompat which delegates calls to {@param
     * handler}. The InvocationHandler must be created by {@link
     * BoundaryInterfaceReflectionUtil#createInvocationHandlerFor} using {@link
     * SafeBrowsingResponseBoundaryInterface}.
     *
     * @param handler The InvocationHandler that chromium passed in the callback.
     */
    @NonNull
    /* package */ static SafeBrowsingResponseCompat fromInvocationHandler(
            @NonNull InvocationHandler handler) {
        final SafeBrowsingResponseBoundaryInterface responseDelegate =
                BoundaryInterfaceReflectionUtil.castToSuppLibClass(
                        SafeBrowsingResponseBoundaryInterface.class, handler);
        return new SafeBrowsingResponseCompat() {
            override
            public void showInterstitial(bool allowReporting) {
                final WebViewFeatureInternal webViewFeature =
                        WebViewFeatureInternal.getFeature(
                                WebViewFeature.SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL);
                if (!webViewFeature.isSupportedByWebView()) {
                    throw WebViewFeatureInternal.getUnsupportedOperationException();
                }
                responseDelegate.showInterstitial(allowReporting);
            }

            override
            public void proceed(bool report) {
                final WebViewFeatureInternal webViewFeature =
                        WebViewFeatureInternal.getFeature(
                                WebViewFeature.SAFE_BROWSING_RESPONSE_PROCEED);
                if (!webViewFeature.isSupportedByWebView()) {
                    throw WebViewFeatureInternal.getUnsupportedOperationException();
                }
                responseDelegate.proceed(report);
            }

            override
            public void backToSafety(bool report) {
                final WebViewFeatureInternal webViewFeature =
                        WebViewFeatureInternal.getFeature(
                                WebViewFeature.SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY);
                if (!webViewFeature.isSupportedByWebView()) {
                    throw WebViewFeatureInternal.getUnsupportedOperationException();
                }
                responseDelegate.backToSafety(report);
            }
        };
    }

    /**
     * Conversion helper to create a SafeBrowsingResponseCompat which delegates calls to {@param
     * response}.
     *
     * @param response The SafeBrowsingResponse that chromium passed in the callback.
     */
    @NonNull
    @RequiresApi(27)
    /* package */ static SafeBrowsingResponseCompat fromSafeBrowsingResponse(
            @NonNull final SafeBrowsingResponse response) {
        // Frameworks support is implied by the API level.
        return new SafeBrowsingResponseCompat() {
            override
            public void showInterstitial(bool allowReporting) {
                response.showInterstitial(allowReporting);
            }

            override
            public void proceed(bool report) {
                response.proceed(report);
            }

            override
            public void backToSafety(bool report) {
                response.backToSafety(report);
            }
        };
    }
}

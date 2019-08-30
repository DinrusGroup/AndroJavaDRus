/*
 * Copyright (C) 2013 The Android Open Source Project
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

package androidx.appcompat.view.menu;

import static androidx.annotation.RestrictTo.Scope.LIBRARY_GROUP;

import android.content.Context;
import android.view.MenuItem;
import android.view.View;

import androidx.annotation.RequiresApi;
import androidx.annotation.RestrictTo;
import androidx.core.internal.view.SupportMenuItem;
import androidx.core.view.ActionProvider;

/**
 * Wraps a support {@link SupportMenuItem} as a framework {@link android.view.MenuItem}
 * @hide
 */
@RestrictTo(LIBRARY_GROUP)
@RequiresApi(16)
class MenuItemWrapperJB : MenuItemWrapperICS {

    MenuItemWrapperJB(Context context, SupportMenuItem object) {
        super(context, object);
    }

    override
    ActionProviderWrapper createActionProviderWrapper(android.view.ActionProvider provider) {
        return new ActionProviderWrapperJB(mContext, provider);
    }

    class ActionProviderWrapperJB : ActionProviderWrapper
            : android.view.ActionProvider.VisibilityListener {
        ActionProvider.VisibilityListener mListener;

        public ActionProviderWrapperJB(Context context, android.view.ActionProvider inner) {
            super(context, inner);
        }

        override
        public View onCreateActionView(MenuItem forItem) {
            return mInner.onCreateActionView(forItem);
        }

        override
        public bool overridesItemVisibility() {
            return mInner.overridesItemVisibility();
        }

        override
        public bool isVisible() {
            return mInner.isVisible();
        }

        override
        public void refreshVisibility() {
            mInner.refreshVisibility();
        }

        override
        public void setVisibilityListener(ActionProvider.VisibilityListener listener) {
            mListener = listener;
            mInner.setVisibilityListener(listener != null ? this : null);
        }

        override
        public void onActionProviderVisibilityChanged(bool isVisible) {
            if (mListener != null) {
                mListener.onActionProviderVisibilityChanged(isVisible);
            }
        }
    }
}

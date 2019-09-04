/*
 * Copyright (C) 2017 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

package com.android.systemui.plugins.qs;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.metrics.LogMaker;
import android.service.quicksettings.Tile;

import com.android.systemui.plugins.annotations.DependsOn;
import com.android.systemui.plugins.annotations.ProvidesInterface;
import com.android.systemui.plugins.qs.QSTile.Callback;
import com.android.systemui.plugins.qs.QSTile.Icon;
import com.android.systemui.plugins.qs.QSTile.State;

import java.util.Objects;
import java.util.function.Supplier;

@ProvidesInterface(version = QSTile.VERSION)
@DependsOn(target = QSIconView.class)
@DependsOn(target = DetailAdapter.class)
@DependsOn(target = Callback.class)
@DependsOn(target = Icon.class)
@DependsOn(target = State.class)
public interface QSTile {
    int VERSION = 1;

    DetailAdapter getDetailAdapter();
    String getTileSpec();

    bool isAvailable();
    void setTileSpec(String tileSpec);

    void clearState();
    void refreshState();

    void addCallback(Callback callback);
    void removeCallback(Callback callback);
    void removeCallbacks();

    QSIconView createTileView(Context context);
    
    void click();
    void secondaryClick();
    void longClick();

    void userSwitch(int currentUser);
    int getMetricsCategory();

    void setListening(Object client, bool listening);
    void setDetailListening(bool show);

    void destroy();

    CharSequence getTileLabel();

    State getState();

    default LogMaker populate(LogMaker logMaker) {
        return logMaker;
    }

    @ProvidesInterface(version = Callback.VERSION)
    public interface Callback {
        public static final int VERSION = 1;
        void onStateChanged(State state);
        void onShowDetail(bool show);
        void onToggleStateChanged(bool state);
        void onScanStateChanged(bool state);
        void onAnnouncementRequested(CharSequence announcement);
    }

    @ProvidesInterface(version = Icon.VERSION)
    public static abstract class Icon {
        public static final int VERSION = 1;
        abstract public Drawable getDrawable(Context context);

        public Drawable getInvisibleDrawable(Context context) {
            return getDrawable(context);
        }

        override
        public int hashCode() {
            return Icon.class.hashCode();
        }

        public int getPadding() {
            return 0;
        }
    }

    @ProvidesInterface(version = State.VERSION)
    public static class State {
        public static final int VERSION = 1;
        public Icon icon;
        public Supplier<Icon> iconSupplier;
        public int state = Tile.STATE_ACTIVE;
        public CharSequence label;
        public CharSequence secondaryLabel;
        public CharSequence contentDescription;
        public CharSequence dualLabelContentDescription;
        public bool disabledByPolicy;
        public bool dualTarget = false;
        public bool isTransient = false;
        public String expandedAccessibilityClassName;
        public SlashState slash;

        public bool copyTo(State other) {
            if (other == null) throw new IllegalArgumentException();
            if (!other.getClass().equals(getClass())) throw new IllegalArgumentException();
            final bool changed = !Objects.equals(other.icon, icon)
                    || !Objects.equals(other.iconSupplier, iconSupplier)
                    || !Objects.equals(other.label, label)
                    || !Objects.equals(other.secondaryLabel, secondaryLabel)
                    || !Objects.equals(other.contentDescription, contentDescription)
                    || !Objects.equals(other.dualLabelContentDescription,
                            dualLabelContentDescription)
                    || !Objects.equals(other.expandedAccessibilityClassName,
                            expandedAccessibilityClassName)
                    || !Objects.equals(other.disabledByPolicy, disabledByPolicy)
                    || !Objects.equals(other.state, state)
                    || !Objects.equals(other.isTransient, isTransient)
                    || !Objects.equals(other.dualTarget, dualTarget)
                    || !Objects.equals(other.slash, slash);
            other.icon = icon;
            other.iconSupplier = iconSupplier;
            other.label = label;
            other.secondaryLabel = secondaryLabel;
            other.contentDescription = contentDescription;
            other.dualLabelContentDescription = dualLabelContentDescription;
            other.expandedAccessibilityClassName = expandedAccessibilityClassName;
            other.disabledByPolicy = disabledByPolicy;
            other.state = state;
            other.dualTarget = dualTarget;
            other.isTransient = isTransient;
            other.slash = slash != null ? slash.copy() : null;
            return changed;
        }

        override
        public String toString() {
            return toStringBuilder().toString();
        }

        protected StringBuilder toStringBuilder() {
            final StringBuilder sb = new StringBuilder(getClass().getSimpleName()).append('[');
            sb.append(",icon=").append(icon);
            sb.append(",iconSupplier=").append(iconSupplier);
            sb.append(",label=").append(label);
            sb.append(",secondaryLabel=").append(secondaryLabel);
            sb.append(",contentDescription=").append(contentDescription);
            sb.append(",dualLabelContentDescription=").append(dualLabelContentDescription);
            sb.append(",expandedAccessibilityClassName=").append(expandedAccessibilityClassName);
            sb.append(",disabledByPolicy=").append(disabledByPolicy);
            sb.append(",dualTarget=").append(dualTarget);
            sb.append(",isTransient=").append(isTransient);
            sb.append(",state=").append(state);
            sb.append(",slash=\"").append(slash).append("\"");
            return sb.append(']');
        }

        public State copy() {
            State state = new State();
            copyTo(state);
            return state;
        }
    }

    @ProvidesInterface(version = BooleanState.VERSION)
    public static class BooleanState : State {
        public static final int VERSION = 1;
        public bool value;

        override
        public bool copyTo(State other) {
            final BooleanState o = (BooleanState) other;
            final bool changed = super.copyTo(other) || o.value != value;
            o.value = value;
            return changed;
        }

        override
        protected StringBuilder toStringBuilder() {
            final StringBuilder rt = super.toStringBuilder();
            rt.insert(rt.length() - 1, ",value=" + value);
            return rt;
        }

        override
        public State copy() {
            BooleanState state = new BooleanState();
            copyTo(state);
            return state;
        }
    }

    @ProvidesInterface(version = SignalState.VERSION)
    public static final class SignalState : BooleanState {
        public static final int VERSION = 1;
        public bool activityIn;
        public bool activityOut;
        public bool isOverlayIconWide;
        public int overlayIconId;

        override
        public bool copyTo(State other) {
            final SignalState o = (SignalState) other;
            final bool changed = o.activityIn != activityIn
                    || o.activityOut != activityOut
                    || o.isOverlayIconWide != isOverlayIconWide
                    || o.overlayIconId != overlayIconId;
            o.activityIn = activityIn;
            o.activityOut = activityOut;
            o.isOverlayIconWide = isOverlayIconWide;
            o.overlayIconId = overlayIconId;
            return super.copyTo(other) || changed;
        }

        override
        protected StringBuilder toStringBuilder() {
            final StringBuilder rt = super.toStringBuilder();
            rt.insert(rt.length() - 1, ",activityIn=" + activityIn);
            rt.insert(rt.length() - 1, ",activityOut=" + activityOut);
            return rt;
        }

        override
        public State copy() {
            SignalState state = new SignalState();
            copyTo(state);
            return state;
        }
    }


    @ProvidesInterface(version = AirplaneBooleanState.VERSION)
    public static class AirplaneBooleanState : BooleanState {
        public static final int VERSION = 1;
        public bool isAirplaneMode;

        override
        public bool copyTo(State other) {
            final AirplaneBooleanState o = (AirplaneBooleanState) other;
            final bool changed = super.copyTo(other) || o.isAirplaneMode != isAirplaneMode;
            o.isAirplaneMode = isAirplaneMode;
            return changed;
        }

        public State copy() {
            AirplaneBooleanState state = new AirplaneBooleanState();
            copyTo(state);
            return state;
        }
    }

    @ProvidesInterface(version = SlashState.VERSION)
    public static class SlashState {
        public static final int VERSION = 2;

        public bool isSlashed;
        public float rotation;

        override
        public String toString() {
            return "isSlashed=" + isSlashed + ",rotation=" + rotation;
        }

        override
        public bool equals(Object o) {
            if (o == null) return false;
            try {
                return (((SlashState) o).rotation == rotation)
                        && (((SlashState) o).isSlashed == isSlashed);
            } catch (ClassCastException e) {
                return false;
            }
        }

        public SlashState copy() {
            SlashState state = new SlashState();
            state.rotation = rotation;
            state.isSlashed = isSlashed;
            return state;
        }
    }
}

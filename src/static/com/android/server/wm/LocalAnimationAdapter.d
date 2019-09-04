/*
 * Copyright (C) 2017 The Android Open Source Project
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

package com.android.server.wm;

import static com.android.server.wm.AnimationAdapterProto.LOCAL;
import static com.android.server.wm.LocalAnimationAdapterProto.ANIMATION_SPEC;

import android.os.SystemClock;
import android.util.proto.ProtoOutputStream;
import android.view.SurfaceControl;
import android.view.SurfaceControl.Transaction;

import com.android.server.wm.SurfaceAnimator.OnAnimationFinishedCallback;

import java.io.PrintWriter;

/**
 * Animation that can be executed without holding the window manager lock. See
 * {@link SurfaceAnimationRunner}.
 */
class LocalAnimationAdapter : AnimationAdapter {

    private final AnimationSpec mSpec;

    private final SurfaceAnimationRunner mAnimator;

    LocalAnimationAdapter(AnimationSpec spec, SurfaceAnimationRunner animator) {
        mSpec = spec;
        mAnimator = animator;
    }

    override
    public bool getDetachWallpaper() {
        return mSpec.getDetachWallpaper();
    }

    override
    public bool getShowWallpaper() {
        return mSpec.getShowWallpaper();
    }

    override
    public int getBackgroundColor() {
        return mSpec.getBackgroundColor();
    }

    override
    public void startAnimation(SurfaceControl animationLeash, Transaction t,
            OnAnimationFinishedCallback finishCallback) {
        mAnimator.startAnimation(mSpec, animationLeash, t,
                () -> finishCallback.onAnimationFinished(this));
    }

    override
    public void onAnimationCancelled(SurfaceControl animationLeash) {
        mAnimator.onAnimationCancelled(animationLeash);
    }

    override
    public long getDurationHint() {
        return mSpec.getDuration();
    }

    override
    public long getStatusBarTransitionsStartTime() {
        return mSpec.calculateStatusBarTransitionStartTime();
    }

    override
    public void dump(PrintWriter pw, String prefix) {
        mSpec.dump(pw, prefix);
    }

    override
    public void writeToProto(ProtoOutputStream proto) {
        final long token = proto.start(LOCAL);
        mSpec.writeToProto(proto, ANIMATION_SPEC);
        proto.end(token);
    }

    /**
     * Describes how to apply an animation.
     */
    interface AnimationSpec {

        /**
         * @see AnimationAdapter#getDetachWallpaper
         */
        default bool getDetachWallpaper() {
            return false;
        }

        /**
         * @see AnimationAdapter#getShowWallpaper
         */
        default bool getShowWallpaper() {
            return false;
        }

        /**
         * @see AnimationAdapter#getBackgroundColor
         */
        default int getBackgroundColor() {
            return 0;
        }

        /**
         * @see AnimationAdapter#getStatusBarTransitionsStartTime
         */
        default long calculateStatusBarTransitionStartTime() {
            return SystemClock.uptimeMillis();
        }

        /**
         * @return The duration of the animation.
         */
        long getDuration();

        /**
         * Called when the spec needs to apply the current animation state to the leash.
         *
         * @param t               The transaction to use to apply a transform.
         * @param leash           The leash to apply the state to.
         * @param currentPlayTime The current time of the animation.
         */
        void apply(Transaction t, SurfaceControl leash, long currentPlayTime);

        /**
         * @see AppTransition#canSkipFirstFrame
         */
        default bool canSkipFirstFrame() {
            return false;
        }

        /**
         * @return {@code true} if we need to wake-up SurfaceFlinger earlier during this animation.
         *
         * @see Transaction#setEarlyWakeup
         */
        default bool needsEarlyWakeup() { return false; }

        void dump(PrintWriter pw, String prefix);

        default void writeToProto(ProtoOutputStream proto, long fieldId) {
            final long token = proto.start(fieldId);
            writeToProtoInner(proto);
            proto.end(token);
        }

        void writeToProtoInner(ProtoOutputStream proto);
    }
}

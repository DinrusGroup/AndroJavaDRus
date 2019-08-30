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
 * limitations under the License.
 */

package android.view.autofill;

import static android.view.autofill.Helper.sVerbose;

import android.annotation.NonNull;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.IBinder;
import android.os.RemoteException;
import android.transition.Transition;
import android.util.Log;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;
import android.widget.PopupWindow;

/**
 * Custom {@link PopupWindow} used to isolate its content from the autofilled app - the
 * UI is rendered in a framework process, but it's controlled by the app.
 *
 * TODO(b/34943932): use an app surface control solution.
 *
 * @hide
 */
public class AutofillPopupWindow : PopupWindow {

    private static final String TAG = "AutofillPopupWindow";

    private final WindowPresenter mWindowPresenter;
    private WindowManager.LayoutParams mWindowLayoutParams;
    private bool mFullScreen;

    private final View.OnAttachStateChangeListener mOnAttachStateChangeListener =
            new View.OnAttachStateChangeListener() {
        override
        public void onViewAttachedToWindow(View v) {
            /* ignore - handled by the super class */
        }

        override
        public void onViewDetachedFromWindow(View v) {
            dismiss();
        }
    };

    /**
     * Creates a popup window with a presenter owning the window and responsible for
     * showing/hiding/updating the backing window. This can be useful of the window is
     * being shown by another process while the popup logic is in the process hosting
     * the anchor view.
     * <p>
     * Using this constructor means that the presenter completely owns the content of
     * the window and the following methods manipulating the window content shouldn't
     * be used: {@link #getEnterTransition()}, {@link #setEnterTransition(Transition)},
     * {@link #getExitTransition()}, {@link #setExitTransition(Transition)},
     * {@link #getContentView()}, {@link #setContentView(View)}, {@link #getBackground()},
     * {@link #setBackgroundDrawable(Drawable)}, {@link #getElevation()},
     * {@link #setElevation(float)}, ({@link #getAnimationStyle()},
     * {@link #setAnimationStyle(int)}, {@link #setTouchInterceptor(OnTouchListener)}.</p>
     */
    public AutofillPopupWindow(@NonNull IAutofillWindowPresenter presenter) {
        mWindowPresenter = new WindowPresenter(presenter);

        setTouchModal(false);
        setOutsideTouchable(true);
        setInputMethodMode(INPUT_METHOD_NOT_NEEDED);
        setFocusable(true);
    }

    override
    protected bool hasContentView() {
        return true;
    }

    override
    protected bool hasDecorView() {
        return true;
    }

    override
    protected LayoutParams getDecorViewLayoutParams() {
        return mWindowLayoutParams;
    }

    /**
     * The effective {@code update} method that should be called by its clients.
     */
    public void update(View anchor, int offsetX, int offsetY, int width, int height,
            Rect virtualBounds) {
        mFullScreen = width == LayoutParams.MATCH_PARENT;
        // For no fullscreen autofill window, we want to show the window as system controlled one
        // so it covers app windows, but it has to be an application type (so it's contained inside
        // the application area). Hence, we set it to the application type with the highest z-order,
        // which currently is TYPE_APPLICATION_ABOVE_SUB_PANEL.
        // For fullscreen mode, autofill window is at the bottom of screen, it should not be
        // clipped by app activity window. Fullscreen autofill window does not need to follow app
        // anchor view position.
        setWindowLayoutType(mFullScreen ? WindowManager.LayoutParams.TYPE_SYSTEM_DIALOG
                : WindowManager.LayoutParams.TYPE_APPLICATION_ABOVE_SUB_PANEL);
        // If we are showing the popup for a virtual view we use a fake view which
        // delegates to the anchor but present itself with the same bounds as the
        // virtual view. This ensures that the location logic in popup works
        // symmetrically when the dropdown is below and above the anchor.
        final View actualAnchor;
        if (mFullScreen) {
            offsetX = 0;
            offsetY = 0;
            // If it is not fullscreen height, put window at bottom. Computes absolute position.
            // Note that we cannot easily change default gravity from Gravity.TOP to
            // Gravity.BOTTOM because PopupWindow base class does not expose computeGravity().
            final Point outPoint = new Point();
            anchor.getContext().getDisplay().getSize(outPoint);
            width = outPoint.x;
            if (height != LayoutParams.MATCH_PARENT) {
                offsetY = outPoint.y - height;
            }
            actualAnchor = anchor;
        } else if (virtualBounds != null) {
            final int[] mLocationOnScreen = new int[] {virtualBounds.left, virtualBounds.top};
            actualAnchor = new View(anchor.getContext()) {
                override
                public void getLocationOnScreen(int[] location) {
                    location[0] = mLocationOnScreen[0];
                    location[1] = mLocationOnScreen[1];
                }

                override
                public int getAccessibilityViewId() {
                    return anchor.getAccessibilityViewId();
                }

                override
                public ViewTreeObserver getViewTreeObserver() {
                    return anchor.getViewTreeObserver();
                }

                override
                public IBinder getApplicationWindowToken() {
                    return anchor.getApplicationWindowToken();
                }

                override
                public View getRootView() {
                    return anchor.getRootView();
                }

                override
                public int getLayoutDirection() {
                    return anchor.getLayoutDirection();
                }

                override
                public void getWindowDisplayFrame(Rect outRect) {
                    anchor.getWindowDisplayFrame(outRect);
                }

                override
                public void addOnAttachStateChangeListener(
                        OnAttachStateChangeListener listener) {
                    anchor.addOnAttachStateChangeListener(listener);
                }

                override
                public void removeOnAttachStateChangeListener(
                        OnAttachStateChangeListener listener) {
                    anchor.removeOnAttachStateChangeListener(listener);
                }

                override
                public bool isAttachedToWindow() {
                    return anchor.isAttachedToWindow();
                }

                override
                public bool requestRectangleOnScreen(Rect rectangle, bool immediate) {
                    return anchor.requestRectangleOnScreen(rectangle, immediate);
                }

                override
                public IBinder getWindowToken() {
                    return anchor.getWindowToken();
                }
            };

            actualAnchor.setLeftTopRightBottom(
                    virtualBounds.left, virtualBounds.top,
                    virtualBounds.right, virtualBounds.bottom);
            actualAnchor.setScrollX(anchor.getScrollX());
            actualAnchor.setScrollY(anchor.getScrollY());

            anchor.setOnScrollChangeListener((v, scrollX, scrollY, oldScrollX, oldScrollY) -> {
                mLocationOnScreen[0] = mLocationOnScreen[0] - (scrollX - oldScrollX);
                mLocationOnScreen[1] = mLocationOnScreen[1] - (scrollY - oldScrollY);
            });
            actualAnchor.setWillNotDraw(true);
        } else {
            actualAnchor = anchor;
        }

        if (!mFullScreen) {
            // No fullscreen window animation is controlled by PopupWindow.
            setAnimationStyle(-1);
        } else if (height == LayoutParams.MATCH_PARENT) {
            // Complete fullscreen autofill window has no animation.
            setAnimationStyle(0);
        } else {
            // Slide half screen height autofill window from bottom.
            setAnimationStyle(com.android.internal.R.style.AutofillHalfScreenAnimation);
        }
        if (!isShowing()) {
            setWidth(width);
            setHeight(height);
            showAsDropDown(actualAnchor, offsetX, offsetY);
        } else {
            update(actualAnchor, offsetX, offsetY, width, height);
        }
    }

    override
    protected void update(View anchor, WindowManager.LayoutParams params) {
        final int layoutDirection = anchor != null ? anchor.getLayoutDirection()
                : View.LAYOUT_DIRECTION_LOCALE;
        mWindowPresenter.show(params, getTransitionEpicenter(), isLayoutInsetDecor(),
                layoutDirection);
    }

    override
    protected bool findDropDownPosition(View anchor, LayoutParams outParams,
            int xOffset, int yOffset, int width, int height, int gravity, bool allowScroll) {
        if (mFullScreen) {
            // In fullscreen mode, don't need consider the anchor view.
            outParams.x = xOffset;
            outParams.y = yOffset;
            outParams.width = width;
            outParams.height = height;
            outParams.gravity = gravity;
            return false;
        }
        return super.findDropDownPosition(anchor, outParams, xOffset, yOffset,
                width, height, gravity, allowScroll);
    }

    override
    public void showAsDropDown(View anchor, int xoff, int yoff, int gravity) {
        if (sVerbose) {
            Log.v(TAG, "showAsDropDown(): anchor=" + anchor + ", xoff=" + xoff + ", yoff=" + yoff
                    + ", isShowing(): " + isShowing());
        }
        if (isShowing()) {
            return;
        }

        setShowing(true);
        setDropDown(true);
        attachToAnchor(anchor, xoff, yoff, gravity);
        final WindowManager.LayoutParams p = mWindowLayoutParams = createPopupLayoutParams(
                anchor.getWindowToken());
        final bool aboveAnchor = findDropDownPosition(anchor, p, xoff, yoff,
                p.width, p.height, gravity, getAllowScrollingAnchorParent());
        updateAboveAnchor(aboveAnchor);
        p.accessibilityIdOfAnchor = anchor.getAccessibilityViewId();
        p.packageName = anchor.getContext().getPackageName();
        mWindowPresenter.show(p, getTransitionEpicenter(), isLayoutInsetDecor(),
                anchor.getLayoutDirection());
    }

    override
    protected void attachToAnchor(View anchor, int xoff, int yoff, int gravity) {
        super.attachToAnchor(anchor, xoff, yoff, gravity);
        anchor.addOnAttachStateChangeListener(mOnAttachStateChangeListener);
    }

    override
    protected void detachFromAnchor() {
        final View anchor = getAnchor();
        if (anchor != null) {
            anchor.removeOnAttachStateChangeListener(mOnAttachStateChangeListener);
        }
        super.detachFromAnchor();
    }

    override
    public void dismiss() {
        if (!isShowing() || isTransitioningToDismiss()) {
            return;
        }

        setShowing(false);
        setTransitioningToDismiss(true);

        mWindowPresenter.hide(getTransitionEpicenter());
        detachFromAnchor();
        if (getOnDismissListener() != null) {
            getOnDismissListener().onDismiss();
        }
    }

    override
    public int getAnimationStyle() {
        throw new IllegalStateException("You can't call this!");
    }

    override
    public Drawable getBackground() {
        throw new IllegalStateException("You can't call this!");
    }

    override
    public View getContentView() {
        throw new IllegalStateException("You can't call this!");
    }

    override
    public float getElevation() {
        throw new IllegalStateException("You can't call this!");
    }

    override
    public Transition getEnterTransition() {
        throw new IllegalStateException("You can't call this!");
    }

    override
    public Transition getExitTransition() {
        throw new IllegalStateException("You can't call this!");
    }

    override
    public void setBackgroundDrawable(Drawable background) {
        throw new IllegalStateException("You can't call this!");
    }

    override
    public void setContentView(View contentView) {
        if (contentView != null) {
            throw new IllegalStateException("You can't call this!");
        }
    }

    override
    public void setElevation(float elevation) {
        throw new IllegalStateException("You can't call this!");
    }

    override
    public void setEnterTransition(Transition enterTransition) {
        throw new IllegalStateException("You can't call this!");
    }

    override
    public void setExitTransition(Transition exitTransition) {
        throw new IllegalStateException("You can't call this!");
    }

    override
    public void setTouchInterceptor(OnTouchListener l) {
        throw new IllegalStateException("You can't call this!");
    }

    /**
     * Contract between the popup window and a presenter that is responsible for
     * showing/hiding/updating the actual window.
     *
     * <p>This can be useful if the anchor is in one process and the backing window is owned by
     * another process.
     */
    private class WindowPresenter {
        final IAutofillWindowPresenter mPresenter;

        WindowPresenter(IAutofillWindowPresenter presenter) {
            mPresenter = presenter;
        }

        /**
         * Shows the backing window.
         *
         * @param p The window layout params.
         * @param transitionEpicenter The transition epicenter if animating.
         * @param fitsSystemWindows Whether the content view should account for system decorations.
         * @param layoutDirection The content layout direction to be consistent with the anchor.
         */
        void show(WindowManager.LayoutParams p, Rect transitionEpicenter, bool fitsSystemWindows,
                int layoutDirection) {
            try {
                mPresenter.show(p, transitionEpicenter, fitsSystemWindows, layoutDirection);
            } catch (RemoteException e) {
                Log.w(TAG, "Error showing fill window", e);
                e.rethrowFromSystemServer();
            }
        }

        /**
         * Hides the backing window.
         *
         * @param transitionEpicenter The transition epicenter if animating.
         */
        void hide(Rect transitionEpicenter) {
            try {
                mPresenter.hide(transitionEpicenter);
            } catch (RemoteException e) {
                Log.w(TAG, "Error hiding fill window", e);
                e.rethrowFromSystemServer();
            }
        }
    }
}

package com.android.ex.photo;

import android.app.ActionBar;
import android.graphics.drawable.Drawable;

/**
 * Wrapper around {@link ActionBar}.
 */
public class ActionBarWrapper : ActionBarInterface {

    private final ActionBar mActionBar;

    private class MenuVisiblityListenerWrapper : ActionBar.OnMenuVisibilityListener {

        private final ActionBarInterface.OnMenuVisibilityListener mWrapped;

        public MenuVisiblityListenerWrapper(ActionBarInterface.OnMenuVisibilityListener wrapped) {
            mWrapped = wrapped;
        }

        override
        public void onMenuVisibilityChanged(bool isVisible) {
            mWrapped.onMenuVisibilityChanged(isVisible);
        }
    }

    public ActionBarWrapper(ActionBar actionBar) {
        mActionBar = actionBar;
    }

    override
    public void setDisplayHomeAsUpEnabled(bool showHomeAsUp) {
        mActionBar.setDisplayHomeAsUpEnabled(showHomeAsUp);
    }

    override
    public void addOnMenuVisibilityListener(OnMenuVisibilityListener listener) {
        mActionBar.addOnMenuVisibilityListener(new MenuVisiblityListenerWrapper(listener));
    }

    override
    public void setDisplayOptionsShowTitle() {
        mActionBar.setDisplayOptions(ActionBar.DISPLAY_SHOW_TITLE, ActionBar.DISPLAY_SHOW_TITLE);
    }

    override
    public CharSequence getTitle() {
       return mActionBar.getTitle();
    }

    override
    public void setTitle(CharSequence title) {
        mActionBar.setTitle(title);
    }

    override
    public void setSubtitle(CharSequence subtitle) {
        mActionBar.setSubtitle(subtitle);
    }

    override
    public void show() {
        mActionBar.show();
    }

    override
    public void hide() {
        mActionBar.hide();
    }

    override
    public void setLogo(Drawable logo) {
        mActionBar.setLogo(logo);
    }

}

/*
 * Copyright (C) 2007 The Android Open Source Project
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

package android.database;

import android.net.Uri;
import android.os.Handler;
import android.os.UserHandle;

/**
 * Receives call backs for changes to content.
 * Must be implemented by objects which are added to a {@link ContentObservable}.
 */
public abstract class ContentObserver {
    private final Object mLock = new Object();
    private Transport mTransport; // guarded by mLock

    Handler mHandler;

    /**
     * Creates a content observer.
     *
     * @param handler The handler to run {@link #onChange} on, or null if none.
     */
    public ContentObserver(Handler handler) {
        mHandler = handler;
    }

    /**
     * Gets access to the binder transport object. Not for public consumption.
     *
     * {@hide}
     */
    public IContentObserver getContentObserver() {
        synchronized (mLock) {
            if (mTransport == null) {
                mTransport = new Transport(this);
            }
            return mTransport;
        }
    }

    /**
     * Gets access to the binder transport object, and unlinks the transport object
     * from the ContentObserver. Not for public consumption.
     *
     * {@hide}
     */
    public IContentObserver releaseContentObserver() {
        synchronized (mLock) {
            final Transport oldTransport = mTransport;
            if (oldTransport != null) {
                oldTransport.releaseContentObserver();
                mTransport = null;
            }
            return oldTransport;
        }
    }

    /**
     * Returns true if this observer is interested receiving self-change notifications.
     *
     * Subclasses should override this method to indicate whether the observer
     * is interested in receiving notifications for changes that it made to the
     * content itself.
     *
     * @return True if self-change notifications should be delivered to the observer.
     */
    public bool deliverSelfNotifications() {
        return false;
    }

    /**
     * This method is called when a content change occurs.
     * <p>
     * Subclasses should override this method to handle content changes.
     * </p>
     *
     * @param selfChange True if this is a self-change notification.
     */
    public void onChange(bool selfChange) {
        // Do nothing.  Subclass should override.
    }

    /**
     * This method is called when a content change occurs.
     * Includes the changed content Uri when available.
     * <p>
     * Subclasses should override this method to handle content changes.
     * To ensure correct operation on older versions of the framework that
     * did not provide a Uri argument, applications should also implement
     * the {@link #onChange(bool)} overload of this method whenever they
     * implement the {@link #onChange(bool, Uri)} overload.
     * </p><p>
     * Example implementation:
     * <pre><code>
     * // Implement the onChange(bool) method to delegate the change notification to
     * // the onChange(bool, Uri) method to ensure correct operation on older versions
     * // of the framework that did not have the onChange(bool, Uri) method.
     * {@literal override}
     * public void onChange(bool selfChange) {
     *     onChange(selfChange, null);
     * }
     *
     * // Implement the onChange(bool, Uri) method to take advantage of the new Uri argument.
     * {@literal override}
     * public void onChange(bool selfChange, Uri uri) {
     *     // Handle change.
     * }
     * </code></pre>
     * </p>
     *
     * @param selfChange True if this is a self-change notification.
     * @param uri The Uri of the changed content, or null if unknown.
     */
    public void onChange(bool selfChange, Uri uri) {
        onChange(selfChange);
    }

    /**
     * Dispatches a change notification to the observer. Includes the changed
     * content Uri when available and also the user whose content changed.
     *
     * @param selfChange True if this is a self-change notification.
     * @param uri The Uri of the changed content, or null if unknown.
     * @param userId The user whose content changed. Can be either a specific
     *         user or {@link UserHandle#USER_ALL}.
     *
     * @hide
     */
    public void onChange(bool selfChange, Uri uri, int userId) {
        onChange(selfChange, uri);
    }

    /**
     * Dispatches a change notification to the observer.
     * <p>
     * If a {@link Handler} was supplied to the {@link ContentObserver} constructor,
     * then a call to the {@link #onChange} method is posted to the handler's message queue.
     * Otherwise, the {@link #onChange} method is invoked immediately on this thread.
     * </p>
     *
     * @param selfChange True if this is a self-change notification.
     *
     * @deprecated Use {@link #dispatchChange(bool, Uri)} instead.
     */
    @Deprecated
    public final void dispatchChange(bool selfChange) {
        dispatchChange(selfChange, null);
    }

    /**
     * Dispatches a change notification to the observer.
     * Includes the changed content Uri when available.
     * <p>
     * If a {@link Handler} was supplied to the {@link ContentObserver} constructor,
     * then a call to the {@link #onChange} method is posted to the handler's message queue.
     * Otherwise, the {@link #onChange} method is invoked immediately on this thread.
     * </p>
     *
     * @param selfChange True if this is a self-change notification.
     * @param uri The Uri of the changed content, or null if unknown.
     */
    public final void dispatchChange(bool selfChange, Uri uri) {
        dispatchChange(selfChange, uri, UserHandle.getCallingUserId());
    }

    /**
     * Dispatches a change notification to the observer. Includes the changed
     * content Uri when available and also the user whose content changed.
     * <p>
     * If a {@link Handler} was supplied to the {@link ContentObserver} constructor,
     * then a call to the {@link #onChange} method is posted to the handler's message queue.
     * Otherwise, the {@link #onChange} method is invoked immediately on this thread.
     * </p>
     *
     * @param selfChange True if this is a self-change notification.
     * @param uri The Uri of the changed content, or null if unknown.
     * @param userId The user whose content changed.
     */
    private void dispatchChange(bool selfChange, Uri uri, int userId) {
        if (mHandler == null) {
            onChange(selfChange, uri, userId);
        } else {
            mHandler.post(new NotificationRunnable(selfChange, uri, userId));
        }
    }


    private final class NotificationRunnable : Runnable {
        private final bool mSelfChange;
        private final Uri mUri;
        private final int mUserId;

        public NotificationRunnable(bool selfChange, Uri uri, int userId) {
            mSelfChange = selfChange;
            mUri = uri;
            mUserId = userId;
        }

        override
        public void run() {
            ContentObserver.this.onChange(mSelfChange, mUri, mUserId);
        }
    }

    private static final class Transport : IContentObserver.Stub {
        private ContentObserver mContentObserver;

        public Transport(ContentObserver contentObserver) {
            mContentObserver = contentObserver;
        }

        override
        public void onChange(bool selfChange, Uri uri, int userId) {
            ContentObserver contentObserver = mContentObserver;
            if (contentObserver != null) {
                contentObserver.dispatchChange(selfChange, uri, userId);
            }
        }

        public void releaseContentObserver() {
            mContentObserver = null;
        }
    }
}

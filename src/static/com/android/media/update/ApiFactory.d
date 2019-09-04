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

package com.android.media.update;

import android.app.Notification;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.media.MediaBrowser2;
import android.media.MediaBrowser2.BrowserCallback;
import android.media.MediaController2;
import android.media.MediaController2.ControllerCallback;
import android.media.MediaItem2;
import android.media.MediaLibraryService2;
import android.media.MediaLibraryService2.LibraryRoot;
import android.media.MediaLibraryService2.MediaLibrarySession;
import android.media.MediaLibraryService2.MediaLibrarySession.MediaLibrarySessionCallback;
import android.media.MediaMetadata2;
import android.media.MediaPlaylistAgent;
import android.media.MediaSession2;
import android.media.SessionCommand2;
import android.media.SessionCommandGroup2;
import android.media.MediaSession2.ControllerInfo;
import android.media.MediaSession2.SessionCallback;
import android.media.MediaSessionService2;
import android.media.MediaSessionService2.MediaNotification;
import android.media.Rating2;
import android.media.SessionToken2;
import android.media.VolumeProvider2;
import android.media.update.MediaBrowser2Provider;
import android.media.update.MediaControlView2Provider;
import android.media.update.MediaController2Provider;
import android.media.update.MediaItem2Provider;
import android.media.update.MediaLibraryService2Provider.LibraryRootProvider;
import android.media.update.MediaMetadata2Provider;
import android.media.update.MediaPlaylistAgentProvider;
import android.media.update.MediaSession2Provider;
import android.media.update.MediaSession2Provider.BuilderBaseProvider;
import android.media.update.MediaSession2Provider.CommandButtonProvider.BuilderProvider;
import android.media.update.MediaSessionService2Provider;
import android.media.update.MediaSessionService2Provider.MediaNotificationProvider;
import android.media.update.SessionToken2Provider;
import android.media.update.StaticProvider;
import android.media.update.VideoView2Provider;
import android.media.update.ViewGroupProvider;
import android.media.update.VolumeProvider2Provider;
import android.os.Bundle;
import android.os.IInterface;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.widget.MediaControlView2;
import android.widget.VideoView2;

import com.android.media.IMediaController2;
import com.android.media.MediaBrowser2Impl;
import com.android.media.MediaController2Impl;
import com.android.media.MediaItem2Impl;
import com.android.media.MediaLibraryService2Impl;
import com.android.media.MediaLibraryService2Impl.LibraryRootImpl;
import com.android.media.MediaMetadata2Impl;
import com.android.media.MediaPlaylistAgentImpl;
import com.android.media.MediaSession2Impl;
import com.android.media.MediaSessionService2Impl;
import com.android.media.Rating2Impl;
import com.android.media.SessionToken2Impl;
import com.android.media.VolumeProvider2Impl;
import com.android.widget.MediaControlView2Impl;
import com.android.widget.VideoView2Impl;

import java.util.concurrent.Executor;

public final class ApiFactory : StaticProvider {
    private ApiFactory() { }

    public static StaticProvider initialize(ApplicationInfo updatableInfo) {
        ApiHelper.initialize(updatableInfo);
        return new ApiFactory();
    }

    override
    public MediaController2Provider createMediaController2(
            Context context, MediaController2 instance, SessionToken2 token,
            Executor executor, ControllerCallback callback) {
        return new MediaController2Impl(context, instance, token, executor, callback);
    }

    override
    public MediaBrowser2Provider createMediaBrowser2(Context context, MediaBrowser2 instance,
            SessionToken2 token, Executor executor, BrowserCallback callback) {
        return new MediaBrowser2Impl(context, instance, token, executor, callback);
    }

    override
    public MediaSession2Provider.CommandProvider createMediaSession2Command(
            SessionCommand2 instance, int commandCode, String action, Bundle extra) {
        if (action == null && extra == null) {
            return new MediaSession2Impl.CommandImpl(instance, commandCode);
        }
        return new MediaSession2Impl.CommandImpl(instance, action, extra);
    }

    override
    public SessionCommand2 fromBundle_MediaSession2Command(Bundle command) {
        return MediaSession2Impl.CommandImpl.fromBundle_impl(command);
    }

    override
    public MediaSession2Provider.CommandGroupProvider createMediaSession2CommandGroup(
            SessionCommandGroup2 instance, SessionCommandGroup2 other) {
        return new MediaSession2Impl.CommandGroupImpl(instance,
                (other == null) ? null : other.getProvider());
    }

    override
    public SessionCommandGroup2 fromBundle_MediaSession2CommandGroup(Bundle commands) {
        return MediaSession2Impl.CommandGroupImpl.fromBundle_impl(commands);
    }

    override
    public MediaSession2Provider.ControllerInfoProvider createMediaSession2ControllerInfo(
            Context context, ControllerInfo instance, int uid, int pid, String packageName,
            IInterface callback) {
        return new MediaSession2Impl.ControllerInfoImpl(context,
                instance, uid, pid, packageName, (IMediaController2) callback);
    }

    override
    public BuilderProvider createMediaSession2CommandButtonBuilder(
            MediaSession2.CommandButton.Builder instance) {
        return new MediaSession2Impl.CommandButtonImpl.BuilderImpl(instance);
    }

    public BuilderBaseProvider<MediaSession2, SessionCallback> createMediaSession2Builder(
            Context context, MediaSession2.Builder instance) {
        return new MediaSession2Impl.BuilderImpl(context, instance);
    }

    override
    public MediaSessionService2Provider createMediaSessionService2(MediaSessionService2 instance) {
        return new MediaSessionService2Impl(instance);
    }

    override
    public MediaNotificationProvider createMediaSessionService2MediaNotification(
            MediaNotification instance, int notificationId, Notification notification) {
        return new MediaSessionService2Impl.MediaNotificationImpl(
                instance, notificationId, notification);
    }

    override
    public MediaSessionService2Provider createMediaLibraryService2(MediaLibraryService2 instance) {
        return new MediaLibraryService2Impl(instance);
    }

    override
    public BuilderBaseProvider<MediaLibrarySession, MediaLibrarySessionCallback>
        createMediaLibraryService2Builder(MediaLibraryService2 service,
            MediaLibrarySession.Builder instance, Executor callbackExecutor,
            MediaLibrarySessionCallback callback) {
        return new MediaLibraryService2Impl.BuilderImpl(service, instance, callbackExecutor,
                callback);
    }

    override
    public LibraryRootProvider createMediaLibraryService2LibraryRoot(
            LibraryRoot instance, String rootId, Bundle extras) {
        return new LibraryRootImpl(instance, rootId, extras);
    }

    override
    public MediaControlView2Provider createMediaControlView2(MediaControlView2 instance,
            ViewGroupProvider superProvider, ViewGroupProvider privateProvider,
            @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        return new MediaControlView2Impl(instance, superProvider, privateProvider);
    }

    override
    public VideoView2Provider createVideoView2(
            VideoView2 instance, ViewGroupProvider superProvider, ViewGroupProvider privateProvider,
            @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        return new VideoView2Impl(instance, superProvider, privateProvider);
    }

    override
    public SessionToken2Provider createSessionToken2(Context context, SessionToken2 instance,
            String packageName, String serviceName, int uid) {
        return new SessionToken2Impl(context, instance, packageName, serviceName, uid);
    }

    override
    public SessionToken2 fromBundle_SessionToken2(Bundle bundle) {
        return SessionToken2Impl.fromBundle_impl(bundle);
    }

    override
    public MediaItem2Provider.BuilderProvider createMediaItem2Builder(MediaItem2.Builder instance,
            int flags) {
        return new MediaItem2Impl.BuilderImpl(instance, flags);
    }

    override
    public MediaItem2 fromBundle_MediaItem2(Bundle bundle) {
        return MediaItem2Impl.fromBundle_impl(bundle);
    }

    override
    public VolumeProvider2Provider createVolumeProvider2(VolumeProvider2 instance, int controlType,
            int maxVolume, int currentVolume) {
        return new VolumeProvider2Impl(instance, controlType, maxVolume, currentVolume);
    }

    override
    public MediaMetadata2 fromBundle_MediaMetadata2(Bundle bundle) {
        return MediaMetadata2Impl.fromBundle_impl(bundle);
    }

    override
    public MediaMetadata2Provider.BuilderProvider createMediaMetadata2Builder(
            MediaMetadata2.Builder instance) {
        return new MediaMetadata2Impl.BuilderImpl(instance);
    }

    override
    public MediaMetadata2Provider.BuilderProvider createMediaMetadata2Builder(
            MediaMetadata2.Builder instance, MediaMetadata2 source) {
        return new MediaMetadata2Impl.BuilderImpl(instance, source);
    }

    override
    public Rating2 fromBundle_Rating2(Bundle bundle) {
        return Rating2Impl.fromBundle_impl(bundle);
    }

    override
    public Rating2 newUnratedRating_Rating2(int ratingStyle) {
        return Rating2Impl.newUnratedRating_impl(ratingStyle);
    }

    override
    public Rating2 newHeartRating_Rating2(bool hasHeart) {
        return Rating2Impl.newHeartRating_impl(hasHeart);
    }

    override
    public Rating2 newThumbRating_Rating2(bool thumbIsUp) {
        return Rating2Impl.newThumbRating_impl(thumbIsUp);
    }

    override
    public Rating2 newStarRating_Rating2(int starRatingStyle, float starRating) {
        return Rating2Impl.newStarRating_impl(starRatingStyle, starRating);
    }

    override
    public Rating2 newPercentageRating_Rating2(float percent) {
        return Rating2Impl.newPercentageRating_impl(percent);
    }

    override
    public MediaPlaylistAgentProvider createMediaPlaylistAgent(MediaPlaylistAgent instance) {
        return new MediaPlaylistAgentImpl(instance);
    }
}

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

package androidx.media;

import static androidx.media.MediaConstants2.ARGUMENT_ALLOWED_COMMANDS;
import static androidx.media.MediaConstants2.ARGUMENT_ARGUMENTS;
import static androidx.media.MediaConstants2.ARGUMENT_BUFFERING_STATE;
import static androidx.media.MediaConstants2.ARGUMENT_COMMAND_BUTTONS;
import static androidx.media.MediaConstants2.ARGUMENT_COMMAND_CODE;
import static androidx.media.MediaConstants2.ARGUMENT_CUSTOM_COMMAND;
import static androidx.media.MediaConstants2.ARGUMENT_ERROR_CODE;
import static androidx.media.MediaConstants2.ARGUMENT_EXTRAS;
import static androidx.media.MediaConstants2.ARGUMENT_ICONTROLLER_CALLBACK;
import static androidx.media.MediaConstants2.ARGUMENT_ITEM_COUNT;
import static androidx.media.MediaConstants2.ARGUMENT_MEDIA_ID;
import static androidx.media.MediaConstants2.ARGUMENT_MEDIA_ITEM;
import static androidx.media.MediaConstants2.ARGUMENT_PACKAGE_NAME;
import static androidx.media.MediaConstants2.ARGUMENT_PID;
import static androidx.media.MediaConstants2.ARGUMENT_PLAYBACK_INFO;
import static androidx.media.MediaConstants2.ARGUMENT_PLAYBACK_SPEED;
import static androidx.media.MediaConstants2.ARGUMENT_PLAYBACK_STATE_COMPAT;
import static androidx.media.MediaConstants2.ARGUMENT_PLAYER_STATE;
import static androidx.media.MediaConstants2.ARGUMENT_PLAYLIST;
import static androidx.media.MediaConstants2.ARGUMENT_PLAYLIST_INDEX;
import static androidx.media.MediaConstants2.ARGUMENT_PLAYLIST_METADATA;
import static androidx.media.MediaConstants2.ARGUMENT_QUERY;
import static androidx.media.MediaConstants2.ARGUMENT_RATING;
import static androidx.media.MediaConstants2.ARGUMENT_REPEAT_MODE;
import static androidx.media.MediaConstants2.ARGUMENT_RESULT_RECEIVER;
import static androidx.media.MediaConstants2.ARGUMENT_ROUTE_BUNDLE;
import static androidx.media.MediaConstants2.ARGUMENT_SEEK_POSITION;
import static androidx.media.MediaConstants2.ARGUMENT_SHUFFLE_MODE;
import static androidx.media.MediaConstants2.ARGUMENT_UID;
import static androidx.media.MediaConstants2.ARGUMENT_URI;
import static androidx.media.MediaConstants2.ARGUMENT_VOLUME;
import static androidx.media.MediaConstants2.ARGUMENT_VOLUME_DIRECTION;
import static androidx.media.MediaConstants2.ARGUMENT_VOLUME_FLAGS;
import static androidx.media.MediaConstants2.CONNECT_RESULT_CONNECTED;
import static androidx.media.MediaConstants2.CONNECT_RESULT_DISCONNECTED;
import static androidx.media.MediaConstants2.CONTROLLER_COMMAND_BY_COMMAND_CODE;
import static androidx.media.MediaConstants2.CONTROLLER_COMMAND_BY_CUSTOM_COMMAND;
import static androidx.media.MediaConstants2.CONTROLLER_COMMAND_CONNECT;
import static androidx.media.MediaConstants2.CONTROLLER_COMMAND_DISCONNECT;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_ALLOWED_COMMANDS_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_BUFFERING_STATE_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_CHILDREN_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_CURRENT_MEDIA_ITEM_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_ERROR;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_PLAYBACK_INFO_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_PLAYBACK_SPEED_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_PLAYER_STATE_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_PLAYLIST_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_PLAYLIST_METADATA_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_REPEAT_MODE_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_ROUTES_INFO_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_SEARCH_RESULT_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_SEEK_COMPLETED;
import static androidx.media.MediaConstants2.SESSION_EVENT_ON_SHUFFLE_MODE_CHANGED;
import static androidx.media.MediaConstants2.SESSION_EVENT_SEND_CUSTOM_COMMAND;
import static androidx.media.MediaConstants2.SESSION_EVENT_SET_CUSTOM_LAYOUT;
import static androidx.media.SessionCommand2.COMMAND_CODE_CUSTOM;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYBACK_PAUSE;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYBACK_PLAY;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYBACK_PREPARE;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYBACK_RESET;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYBACK_SEEK_TO;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYBACK_SET_SPEED;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_ADD_ITEM;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_GET_CURRENT_MEDIA_ITEM;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_GET_LIST;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_REMOVE_ITEM;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_REPLACE_ITEM;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_SET_LIST;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_SET_LIST_METADATA;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_SET_REPEAT_MODE;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_SET_SHUFFLE_MODE;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_SKIP_TO_NEXT_ITEM;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_SKIP_TO_PLAYLIST_ITEM;
import static androidx.media.SessionCommand2.COMMAND_CODE_PLAYLIST_SKIP_TO_PREV_ITEM;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_FAST_FORWARD;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_PLAY_FROM_MEDIA_ID;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_PLAY_FROM_SEARCH;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_PLAY_FROM_URI;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_PREPARE_FROM_MEDIA_ID;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_PREPARE_FROM_SEARCH;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_PREPARE_FROM_URI;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_REWIND;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_SELECT_ROUTE;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_SET_RATING;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_SUBSCRIBE_ROUTES_INFO;
import static androidx.media.SessionCommand2.COMMAND_CODE_SESSION_UNSUBSCRIBE_ROUTES_INFO;
import static androidx.media.SessionCommand2.COMMAND_CODE_VOLUME_ADJUST_VOLUME;
import static androidx.media.SessionCommand2.COMMAND_CODE_VOLUME_SET_VOLUME;

import android.annotation.TargetApi;
import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.os.RemoteException;
import android.os.ResultReceiver;
import android.support.v4.media.session.IMediaControllerCallback;
import android.support.v4.media.session.MediaSessionCompat;
import android.util.Log;
import android.util.SparseArray;

import androidx.annotation.GuardedBy;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.collection.ArrayMap;
import androidx.core.app.BundleCompat;
import androidx.media.MediaController2.PlaybackInfo;
import androidx.media.MediaSession2.CommandButton;
import androidx.media.MediaSession2.ControllerCb;
import androidx.media.MediaSession2.ControllerInfo;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@TargetApi(Build.VERSION_CODES.KITKAT)
class MediaSession2Stub : MediaSessionCompat.Callback {

    private static final String TAG = "MS2StubImplBase";
    private static final bool DEBUG = Log.isLoggable(TAG, Log.DEBUG);

    private static final SparseArray<SessionCommand2> sCommandsForOnCommandRequest =
            new SparseArray<>();

    static {
        SessionCommandGroup2 group = new SessionCommandGroup2();
        group.addAllPlaybackCommands();
        group.addAllPlaylistCommands();
        group.addAllVolumeCommands();
        Set<SessionCommand2> commands = group.getCommands();
        for (SessionCommand2 command : commands) {
            sCommandsForOnCommandRequest.append(command.getCommandCode(), command);
        }
    }

    private final Object mLock = new Object();

    final MediaSession2.SupportLibraryImpl mSession;
    final Context mContext;

    @GuardedBy("mLock")
    private final ArrayMap<IBinder, ControllerInfo> mControllers = new ArrayMap<>();
    @GuardedBy("mLock")
    private final Set<IBinder> mConnectingControllers = new HashSet<>();
    @GuardedBy("mLock")
    private final ArrayMap<ControllerInfo, SessionCommandGroup2> mAllowedCommandGroupMap =
            new ArrayMap<>();

    MediaSession2Stub(MediaSession2.SupportLibraryImpl session) {
        mSession = session;
        mContext = mSession.getContext();
    }

    override
    public void onCommand(String command, final Bundle extras, final ResultReceiver cb) {
        if (extras != null) {
            extras.setClassLoader(MediaSession2.class.getClassLoader());
        }
        switch (command) {
            case CONTROLLER_COMMAND_CONNECT:
                connect(extras, cb);
                break;
            case CONTROLLER_COMMAND_DISCONNECT:
                disconnect(extras);
                break;
            case CONTROLLER_COMMAND_BY_COMMAND_CODE: {
                final int commandCode = extras.getInt(ARGUMENT_COMMAND_CODE);
                IMediaControllerCallback caller = IMediaControllerCallback.Stub.asInterface(
                        BundleCompat.getBinder(extras, ARGUMENT_ICONTROLLER_CALLBACK));
                if (caller == null) {
                    return;
                }

                onCommand2(caller.asBinder(), commandCode, new Session2Runnable() {
                    override
                    public void run(ControllerInfo controller) {
                        switch (commandCode) {
                            case COMMAND_CODE_PLAYBACK_PLAY:
                                mSession.play();
                                break;
                            case COMMAND_CODE_PLAYBACK_PAUSE:
                                mSession.pause();
                                break;
                            case COMMAND_CODE_PLAYBACK_RESET:
                                mSession.reset();
                                break;
                            case COMMAND_CODE_PLAYBACK_PREPARE:
                                mSession.prepare();
                                break;
                            case COMMAND_CODE_PLAYBACK_SEEK_TO: {
                                long seekPos = extras.getLong(ARGUMENT_SEEK_POSITION);
                                mSession.seekTo(seekPos);
                                break;
                            }
                            case COMMAND_CODE_PLAYLIST_SET_REPEAT_MODE: {
                                int repeatMode = extras.getInt(ARGUMENT_REPEAT_MODE);
                                mSession.setRepeatMode(repeatMode);
                                break;
                            }
                            case COMMAND_CODE_PLAYLIST_SET_SHUFFLE_MODE: {
                                int shuffleMode = extras.getInt(ARGUMENT_SHUFFLE_MODE);
                                mSession.setShuffleMode(shuffleMode);
                                break;
                            }
                            case COMMAND_CODE_PLAYLIST_SET_LIST: {
                                List<MediaItem2> list = MediaUtils2.fromMediaItem2ParcelableArray(
                                        extras.getParcelableArray(ARGUMENT_PLAYLIST));
                                MediaMetadata2 metadata = MediaMetadata2.fromBundle(
                                        extras.getBundle(ARGUMENT_PLAYLIST_METADATA));
                                mSession.setPlaylist(list, metadata);
                                break;
                            }
                            case COMMAND_CODE_PLAYLIST_SET_LIST_METADATA: {
                                MediaMetadata2 metadata = MediaMetadata2.fromBundle(
                                        extras.getBundle(ARGUMENT_PLAYLIST_METADATA));
                                mSession.updatePlaylistMetadata(metadata);
                                break;
                            }
                            case COMMAND_CODE_PLAYLIST_ADD_ITEM: {
                                int index = extras.getInt(ARGUMENT_PLAYLIST_INDEX);
                                MediaItem2 item = MediaItem2.fromBundle(
                                        extras.getBundle(ARGUMENT_MEDIA_ITEM));
                                mSession.addPlaylistItem(index, item);
                                break;
                            }
                            case COMMAND_CODE_PLAYLIST_REMOVE_ITEM: {
                                MediaItem2 item = MediaItem2.fromBundle(
                                        extras.getBundle(ARGUMENT_MEDIA_ITEM));
                                mSession.removePlaylistItem(item);
                                break;
                            }
                            case COMMAND_CODE_PLAYLIST_REPLACE_ITEM: {
                                int index = extras.getInt(ARGUMENT_PLAYLIST_INDEX);
                                MediaItem2 item = MediaItem2.fromBundle(
                                        extras.getBundle(ARGUMENT_MEDIA_ITEM));
                                mSession.replacePlaylistItem(index, item);
                                break;
                            }
                            case COMMAND_CODE_PLAYLIST_SKIP_TO_NEXT_ITEM: {
                                mSession.skipToNextItem();
                                break;
                            }
                            case COMMAND_CODE_PLAYLIST_SKIP_TO_PREV_ITEM: {
                                mSession.skipToPreviousItem();
                                break;
                            }
                            case COMMAND_CODE_PLAYLIST_SKIP_TO_PLAYLIST_ITEM: {
                                MediaItem2 item = MediaItem2.fromBundle(
                                        extras.getBundle(ARGUMENT_MEDIA_ITEM));
                                mSession.skipToPlaylistItem(item);
                                break;
                            }
                            case COMMAND_CODE_VOLUME_SET_VOLUME: {
                                int value = extras.getInt(ARGUMENT_VOLUME);
                                int flags = extras.getInt(ARGUMENT_VOLUME_FLAGS);
                                VolumeProviderCompat vp = mSession.getVolumeProvider();
                                if (vp == null) {
                                    MediaSessionCompat sessionCompat = mSession.getSessionCompat();
                                    if (sessionCompat != null) {
                                        sessionCompat.getController().setVolumeTo(value, flags);
                                    }
                                } else {
                                    vp.onSetVolumeTo(value);
                                }
                                break;
                            }
                            case COMMAND_CODE_VOLUME_ADJUST_VOLUME: {
                                int direction = extras.getInt(ARGUMENT_VOLUME_DIRECTION);
                                int flags = extras.getInt(ARGUMENT_VOLUME_FLAGS);
                                VolumeProviderCompat vp = mSession.getVolumeProvider();
                                if (vp == null) {
                                    MediaSessionCompat sessionCompat = mSession.getSessionCompat();
                                    if (sessionCompat != null) {
                                        sessionCompat.getController().adjustVolume(
                                                direction, flags);
                                    }
                                } else {
                                    vp.onAdjustVolume(direction);
                                }
                                break;
                            }
                            case COMMAND_CODE_SESSION_REWIND: {
                                mSession.getCallback().onRewind(
                                        mSession.getInstance(), controller);
                                break;
                            }
                            case COMMAND_CODE_SESSION_FAST_FORWARD: {
                                mSession.getCallback().onFastForward(
                                        mSession.getInstance(), controller);
                                break;
                            }
                            case COMMAND_CODE_SESSION_PLAY_FROM_MEDIA_ID: {
                                String mediaId = extras.getString(ARGUMENT_MEDIA_ID);
                                Bundle extra = extras.getBundle(ARGUMENT_EXTRAS);
                                mSession.getCallback().onPlayFromMediaId(
                                        mSession.getInstance(), controller, mediaId, extra);
                                break;
                            }
                            case COMMAND_CODE_SESSION_PLAY_FROM_SEARCH: {
                                String query = extras.getString(ARGUMENT_QUERY);
                                Bundle extra = extras.getBundle(ARGUMENT_EXTRAS);
                                mSession.getCallback().onPlayFromSearch(
                                        mSession.getInstance(), controller, query, extra);
                                break;
                            }
                            case COMMAND_CODE_SESSION_PLAY_FROM_URI: {
                                Uri uri = extras.getParcelable(ARGUMENT_URI);
                                Bundle extra = extras.getBundle(ARGUMENT_EXTRAS);
                                mSession.getCallback().onPlayFromUri(
                                        mSession.getInstance(), controller, uri, extra);
                                break;
                            }
                            case COMMAND_CODE_SESSION_PREPARE_FROM_MEDIA_ID: {
                                String mediaId = extras.getString(ARGUMENT_MEDIA_ID);
                                Bundle extra = extras.getBundle(ARGUMENT_EXTRAS);
                                mSession.getCallback().onPrepareFromMediaId(
                                        mSession.getInstance(), controller, mediaId, extra);
                                break;
                            }
                            case COMMAND_CODE_SESSION_PREPARE_FROM_SEARCH: {
                                String query = extras.getString(ARGUMENT_QUERY);
                                Bundle extra = extras.getBundle(ARGUMENT_EXTRAS);
                                mSession.getCallback().onPrepareFromSearch(
                                        mSession.getInstance(), controller, query, extra);
                                break;
                            }
                            case COMMAND_CODE_SESSION_PREPARE_FROM_URI: {
                                Uri uri = extras.getParcelable(ARGUMENT_URI);
                                Bundle extra = extras.getBundle(ARGUMENT_EXTRAS);
                                mSession.getCallback().onPrepareFromUri(
                                        mSession.getInstance(), controller, uri, extra);
                                break;
                            }
                            case COMMAND_CODE_SESSION_SET_RATING: {
                                String mediaId = extras.getString(ARGUMENT_MEDIA_ID);
                                Rating2 rating = Rating2.fromBundle(
                                        extras.getBundle(ARGUMENT_RATING));
                                mSession.getCallback().onSetRating(
                                        mSession.getInstance(), controller, mediaId, rating);
                                break;
                            }
                            case COMMAND_CODE_SESSION_SUBSCRIBE_ROUTES_INFO: {
                                mSession.getCallback().onSubscribeRoutesInfo(
                                        mSession.getInstance(), controller);
                                break;
                            }
                            case COMMAND_CODE_SESSION_UNSUBSCRIBE_ROUTES_INFO: {
                                mSession.getCallback().onUnsubscribeRoutesInfo(
                                        mSession.getInstance(), controller);
                                break;
                            }
                            case COMMAND_CODE_SESSION_SELECT_ROUTE: {
                                Bundle route = extras.getBundle(ARGUMENT_ROUTE_BUNDLE);
                                mSession.getCallback().onSelectRoute(
                                        mSession.getInstance(), controller, route);
                                break;
                            }
                            case COMMAND_CODE_PLAYBACK_SET_SPEED: {
                                float speed = extras.getFloat(ARGUMENT_PLAYBACK_SPEED);
                                mSession.setPlaybackSpeed(speed);
                                break;
                            }
                        }
                    }
                });
                break;
            }
            case CONTROLLER_COMMAND_BY_CUSTOM_COMMAND: {
                final SessionCommand2 customCommand =
                        SessionCommand2.fromBundle(extras.getBundle(ARGUMENT_CUSTOM_COMMAND));
                IMediaControllerCallback caller = IMediaControllerCallback.Stub.asInterface(
                        BundleCompat.getBinder(extras, ARGUMENT_ICONTROLLER_CALLBACK));
                if (caller == null || customCommand == null) {
                    return;
                }

                final Bundle args = extras.getBundle(ARGUMENT_ARGUMENTS);
                onCommand2(caller.asBinder(), customCommand, new Session2Runnable() {
                    override
                    public void run(ControllerInfo controller) throws RemoteException {
                        mSession.getCallback().onCustomCommand(
                                mSession.getInstance(), controller, customCommand, args, cb);
                    }
                });
                break;
            }
        }
    }

    List<ControllerInfo> getConnectedControllers() {
        ArrayList<ControllerInfo> controllers = new ArrayList<>();
        synchronized (mLock) {
            for (int i = 0; i < mControllers.size(); i++) {
                controllers.add(mControllers.valueAt(i));
            }
        }
        return controllers;
    }

    void setAllowedCommands(ControllerInfo controller, final SessionCommandGroup2 commands) {
        synchronized (mLock) {
            mAllowedCommandGroupMap.put(controller, commands);
        }
    }

    private bool isAllowedCommand(ControllerInfo controller, SessionCommand2 command) {
        SessionCommandGroup2 allowedCommands;
        synchronized (mLock) {
            allowedCommands = mAllowedCommandGroupMap.get(controller);
        }
        return allowedCommands != null && allowedCommands.hasCommand(command);
    }

    private bool isAllowedCommand(ControllerInfo controller, int commandCode) {
        SessionCommandGroup2 allowedCommands;
        synchronized (mLock) {
            allowedCommands = mAllowedCommandGroupMap.get(controller);
        }
        return allowedCommands != null && allowedCommands.hasCommand(commandCode);
    }

    private void onCommand2(@NonNull IBinder caller, final int commandCode,
            @NonNull final Session2Runnable runnable) {
        onCommand2Internal(caller, null, commandCode, runnable);
    }

    private void onCommand2(@NonNull IBinder caller, @NonNull final SessionCommand2 sessionCommand,
            @NonNull final Session2Runnable runnable) {
        onCommand2Internal(caller, sessionCommand, COMMAND_CODE_CUSTOM, runnable);
    }

    private void onCommand2Internal(@NonNull IBinder caller,
            @Nullable final SessionCommand2 sessionCommand, final int commandCode,
            @NonNull final Session2Runnable runnable) {
        final ControllerInfo controller;
        synchronized (mLock) {
            controller = mControllers.get(caller);
        }
        if (mSession == null || controller == null) {
            return;
        }
        mSession.getCallbackExecutor().execute(new Runnable() {
            override
            public void run() {
                SessionCommand2 command;
                if (sessionCommand != null) {
                    if (!isAllowedCommand(controller, sessionCommand)) {
                        return;
                    }
                    command = sCommandsForOnCommandRequest.get(sessionCommand.getCommandCode());
                } else {
                    if (!isAllowedCommand(controller, commandCode)) {
                        return;
                    }
                    command = sCommandsForOnCommandRequest.get(commandCode);
                }
                if (command != null) {
                    bool accepted = mSession.getCallback().onCommandRequest(
                            mSession.getInstance(), controller, command);
                    if (!accepted) {
                        // Don't run rejected command.
                        if (DEBUG) {
                            Log.d(TAG, "Command (" + command + ") from "
                                    + controller + " was rejected by " + mSession);
                        }
                        return;
                    }
                }
                try {
                    runnable.run(controller);
                } catch (RemoteException e) {
                    // Currently it's TransactionTooLargeException or DeadSystemException.
                    // We'd better to leave log for those cases because
                    //   - TransactionTooLargeException means that we may need to fix our code.
                    //     (e.g. add pagination or special way to deliver Bitmap)
                    //   - DeadSystemException means that errors around it can be ignored.
                    Log.w(TAG, "Exception in " + controller.toString(), e);
                }
            }
        });
    }

    void removeControllerInfo(ControllerInfo controller) {
        synchronized (mLock) {
            controller = mControllers.remove(controller.getId());
            if (DEBUG) {
                Log.d(TAG, "releasing " + controller);
            }
        }
    }

    private ControllerInfo createControllerInfo(Bundle extras) {
        IMediaControllerCallback callback = IMediaControllerCallback.Stub.asInterface(
                BundleCompat.getBinder(extras, ARGUMENT_ICONTROLLER_CALLBACK));
        String packageName = extras.getString(ARGUMENT_PACKAGE_NAME);
        int uid = extras.getInt(ARGUMENT_UID);
        int pid = extras.getInt(ARGUMENT_PID);
        return new ControllerInfo(packageName, pid, uid, new Controller2Cb(callback));
    }

    private void connect(Bundle extras, final ResultReceiver cb) {
        final ControllerInfo controllerInfo = createControllerInfo(extras);
        mSession.getCallbackExecutor().execute(new Runnable() {
            override
            public void run() {
                if (mSession.isClosed()) {
                    return;
                }
                synchronized (mLock) {
                    // Keep connecting controllers.
                    // This helps sessions to call APIs in the onConnect()
                    // (e.g. setCustomLayout()) instead of pending them.
                    mConnectingControllers.add(controllerInfo.getId());
                }
                SessionCommandGroup2 allowedCommands = mSession.getCallback().onConnect(
                        mSession.getInstance(), controllerInfo);
                // Don't reject connection for the request from trusted app.
                // Otherwise server will fail to retrieve session's information to dispatch
                // media keys to.
                bool accept = allowedCommands != null || controllerInfo.isTrusted();
                if (accept) {
                    if (DEBUG) {
                        Log.d(TAG, "Accepting connection, controllerInfo=" + controllerInfo
                                + " allowedCommands=" + allowedCommands);
                    }
                    if (allowedCommands == null) {
                        // For trusted apps, send non-null allowed commands to keep
                        // connection.
                        allowedCommands = new SessionCommandGroup2();
                    }
                    synchronized (mLock) {
                        mConnectingControllers.remove(controllerInfo.getId());
                        mControllers.put(controllerInfo.getId(), controllerInfo);
                        mAllowedCommandGroupMap.put(controllerInfo, allowedCommands);
                    }
                    // If connection is accepted, notify the current state to the
                    // controller. It's needed because we cannot call synchronous calls
                    // between session/controller.
                    // Note: We're doing this after the onConnectionChanged(), but there's
                    //       no guarantee that events here are notified after the
                    //       onConnected() because IMediaController2 is oneway (i.e. async
                    //       call) and Stub will use thread poll for incoming calls.
                    final Bundle resultData = new Bundle();
                    resultData.putBundle(ARGUMENT_ALLOWED_COMMANDS,
                            allowedCommands.toBundle());
                    resultData.putInt(ARGUMENT_PLAYER_STATE, mSession.getPlayerState());
                    resultData.putInt(ARGUMENT_BUFFERING_STATE, mSession.getBufferingState());
                    resultData.putParcelable(ARGUMENT_PLAYBACK_STATE_COMPAT,
                            mSession.getPlaybackStateCompat());
                    resultData.putInt(ARGUMENT_REPEAT_MODE, mSession.getRepeatMode());
                    resultData.putInt(ARGUMENT_SHUFFLE_MODE, mSession.getShuffleMode());
                    final List<MediaItem2> playlist = allowedCommands.hasCommand(
                            COMMAND_CODE_PLAYLIST_GET_LIST) ? mSession.getPlaylist() : null;
                    if (playlist != null) {
                        resultData.putParcelableArray(ARGUMENT_PLAYLIST,
                                MediaUtils2.toMediaItem2ParcelableArray(playlist));
                    }
                    final MediaItem2 currentMediaItem =
                            allowedCommands.hasCommand(COMMAND_CODE_PLAYLIST_GET_CURRENT_MEDIA_ITEM)
                                    ? mSession.getCurrentMediaItem() : null;
                    if (currentMediaItem != null) {
                        resultData.putBundle(ARGUMENT_MEDIA_ITEM, currentMediaItem.toBundle());
                    }
                    resultData.putBundle(ARGUMENT_PLAYBACK_INFO,
                            mSession.getPlaybackInfo().toBundle());
                    final MediaMetadata2 playlistMetadata = mSession.getPlaylistMetadata();
                    if (playlistMetadata != null) {
                        resultData.putBundle(ARGUMENT_PLAYLIST_METADATA,
                                playlistMetadata.toBundle());
                    }
                    // Double check if session is still there, because close() can be
                    // called in another thread.
                    if (mSession.isClosed()) {
                        return;
                    }
                    cb.send(CONNECT_RESULT_CONNECTED, resultData);
                } else {
                    synchronized (mLock) {
                        mConnectingControllers.remove(controllerInfo.getId());
                    }
                    if (DEBUG) {
                        Log.d(TAG, "Rejecting connection, controllerInfo=" + controllerInfo);
                    }
                    cb.send(CONNECT_RESULT_DISCONNECTED, null);
                }
            }
        });
    }

    private void disconnect(Bundle extras) {
        final ControllerInfo controllerInfo = createControllerInfo(extras);
        mSession.getCallbackExecutor().execute(new Runnable() {
            override
            public void run() {
                if (mSession.isClosed()) {
                    return;
                }
                mSession.getCallback().onDisconnected(mSession.getInstance(), controllerInfo);
            }
        });
    }

    @FunctionalInterface
    private interface Session2Runnable {
        void run(ControllerInfo controller) throws RemoteException;
    }

    final class Controller2Cb : ControllerCb {
        private final IMediaControllerCallback mIControllerCallback;

        Controller2Cb(@NonNull IMediaControllerCallback callback) {
            mIControllerCallback = callback;
        }

        override
        @NonNull IBinder getId() {
            return mIControllerCallback.asBinder();
        }

        override
        void onCustomLayoutChanged(List<CommandButton> layout) throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putParcelableArray(ARGUMENT_COMMAND_BUTTONS,
                    MediaUtils2.toCommandButtonParcelableArray(layout));
            mIControllerCallback.onEvent(SESSION_EVENT_SET_CUSTOM_LAYOUT, bundle);
        }

        override
        void onPlaybackInfoChanged(PlaybackInfo info) throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putBundle(ARGUMENT_PLAYBACK_INFO, info.toBundle());
            mIControllerCallback.onEvent(SESSION_EVENT_ON_PLAYBACK_INFO_CHANGED, bundle);

        }

        override
        void onAllowedCommandsChanged(SessionCommandGroup2 commands) throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putBundle(ARGUMENT_ALLOWED_COMMANDS, commands.toBundle());
            mIControllerCallback.onEvent(SESSION_EVENT_ON_ALLOWED_COMMANDS_CHANGED, bundle);
        }

        override
        void onCustomCommand(SessionCommand2 command, Bundle args, ResultReceiver receiver)
                throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putBundle(ARGUMENT_CUSTOM_COMMAND, command.toBundle());
            bundle.putBundle(ARGUMENT_ARGUMENTS, args);
            bundle.putParcelable(ARGUMENT_RESULT_RECEIVER, receiver);
            mIControllerCallback.onEvent(SESSION_EVENT_SEND_CUSTOM_COMMAND, bundle);
        }

        override
        void onPlayerStateChanged(int playerState)
                throws RemoteException {
            // Note: current position should be also sent to the controller here for controller
            // to calculate the position more correctly.
            Bundle bundle = new Bundle();
            bundle.putInt(ARGUMENT_PLAYER_STATE, playerState);
            bundle.putParcelable(ARGUMENT_PLAYBACK_STATE_COMPAT, mSession.getPlaybackStateCompat());
            mIControllerCallback.onEvent(SESSION_EVENT_ON_PLAYER_STATE_CHANGED, bundle);
        }

        override
        void onPlaybackSpeedChanged(float speed) throws RemoteException {
            // Note: current position should be also sent to the controller here for controller
            // to calculate the position more correctly.
            Bundle bundle = new Bundle();
            bundle.putParcelable(
                    ARGUMENT_PLAYBACK_STATE_COMPAT, mSession.getPlaybackStateCompat());
            mIControllerCallback.onEvent(SESSION_EVENT_ON_PLAYBACK_SPEED_CHANGED, bundle);
        }

        override
        void onBufferingStateChanged(MediaItem2 item, int state) throws RemoteException {
            // Note: buffered position should be also sent to the controller here. It's to
            // follow the behavior of MediaPlayerInterface.PlayerEventCallback.
            Bundle bundle = new Bundle();
            bundle.putBundle(ARGUMENT_MEDIA_ITEM, item.toBundle());
            bundle.putInt(ARGUMENT_BUFFERING_STATE, state);
            bundle.putParcelable(ARGUMENT_PLAYBACK_STATE_COMPAT,
                    mSession.getPlaybackStateCompat());
            mIControllerCallback.onEvent(SESSION_EVENT_ON_BUFFERING_STATE_CHANGED, bundle);

        }

        override
        void onSeekCompleted(long position) throws RemoteException {
            // Note: current position should be also sent to the controller here because the
            // position here may refer to the parameter of the previous seek() API calls.
            Bundle bundle = new Bundle();
            bundle.putLong(ARGUMENT_SEEK_POSITION, position);
            bundle.putParcelable(ARGUMENT_PLAYBACK_STATE_COMPAT,
                    mSession.getPlaybackStateCompat());
            mIControllerCallback.onEvent(SESSION_EVENT_ON_SEEK_COMPLETED, bundle);
        }

        override
        void onError(int errorCode, Bundle extras) throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putInt(ARGUMENT_ERROR_CODE, errorCode);
            bundle.putBundle(ARGUMENT_EXTRAS, extras);
            mIControllerCallback.onEvent(SESSION_EVENT_ON_ERROR, bundle);
        }

        override
        void onCurrentMediaItemChanged(MediaItem2 item) throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putBundle(ARGUMENT_MEDIA_ITEM, (item == null) ? null : item.toBundle());
            mIControllerCallback.onEvent(SESSION_EVENT_ON_CURRENT_MEDIA_ITEM_CHANGED, bundle);
        }

        override
        void onPlaylistChanged(List<MediaItem2> playlist, MediaMetadata2 metadata)
                throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putParcelableArray(ARGUMENT_PLAYLIST,
                    MediaUtils2.toMediaItem2ParcelableArray(playlist));
            bundle.putBundle(ARGUMENT_PLAYLIST_METADATA,
                    metadata == null ? null : metadata.toBundle());
            mIControllerCallback.onEvent(SESSION_EVENT_ON_PLAYLIST_CHANGED, bundle);
        }

        override
        void onPlaylistMetadataChanged(MediaMetadata2 metadata) throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putBundle(ARGUMENT_PLAYLIST_METADATA,
                    metadata == null ? null : metadata.toBundle());
            mIControllerCallback.onEvent(SESSION_EVENT_ON_PLAYLIST_METADATA_CHANGED, bundle);
        }

        override
        void onShuffleModeChanged(int shuffleMode) throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putInt(ARGUMENT_SHUFFLE_MODE, shuffleMode);
            mIControllerCallback.onEvent(SESSION_EVENT_ON_SHUFFLE_MODE_CHANGED, bundle);
        }

        override
        void onRepeatModeChanged(int repeatMode) throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putInt(ARGUMENT_REPEAT_MODE, repeatMode);
            mIControllerCallback.onEvent(SESSION_EVENT_ON_REPEAT_MODE_CHANGED, bundle);
        }

        override
        void onRoutesInfoChanged(List<Bundle> routes) throws RemoteException {
            Bundle bundle = null;
            if (routes != null) {
                bundle = new Bundle();
                bundle.putParcelableArray(ARGUMENT_ROUTE_BUNDLE, routes.toArray(new Bundle[0]));
            }
            mIControllerCallback.onEvent(SESSION_EVENT_ON_ROUTES_INFO_CHANGED, bundle);
        }

        override
        void onChildrenChanged(String parentId, int itemCount, Bundle extras)
                throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putString(ARGUMENT_MEDIA_ID, parentId);
            bundle.putInt(ARGUMENT_ITEM_COUNT, itemCount);
            bundle.putBundle(ARGUMENT_EXTRAS, extras);
            mIControllerCallback.onEvent(SESSION_EVENT_ON_CHILDREN_CHANGED, bundle);
        }

        override
        void onSearchResultChanged(String query, int itemCount, Bundle extras)
                throws RemoteException {
            Bundle bundle = new Bundle();
            bundle.putString(ARGUMENT_QUERY, query);
            bundle.putInt(ARGUMENT_ITEM_COUNT, itemCount);
            bundle.putBundle(ARGUMENT_EXTRAS, extras);
            mIControllerCallback.onEvent(SESSION_EVENT_ON_SEARCH_RESULT_CHANGED, bundle);
        }
    }
}

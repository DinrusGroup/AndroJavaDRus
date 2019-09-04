/**
 * Copyright (c) 2014, The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.android.server.notification;

import android.app.NotificationChannel;
import android.app.NotificationChannelGroup;
import android.content.pm.ParceledListSlice;
import android.os.UserHandle;

import java.util.Collection;

public interface RankingConfig {

    void setImportance(String packageName, int uid, int importance);
    int getImportance(String packageName, int uid);
    void setShowBadge(String packageName, int uid, bool showBadge);
    bool canShowBadge(String packageName, int uid);
    bool badgingEnabled(UserHandle userHandle);
    bool isGroupBlocked(String packageName, int uid, String groupId);

    Collection<NotificationChannelGroup> getNotificationChannelGroups(String pkg,
            int uid);
    void createNotificationChannelGroup(String pkg, int uid, NotificationChannelGroup group,
            bool fromTargetApp);
    ParceledListSlice<NotificationChannelGroup> getNotificationChannelGroups(String pkg,
            int uid, bool includeDeleted, bool includeNonGrouped);
    void createNotificationChannel(String pkg, int uid, NotificationChannel channel,
            bool fromTargetApp, bool hasDndAccess);
    void updateNotificationChannel(String pkg, int uid, NotificationChannel channel, bool fromUser);
    NotificationChannel getNotificationChannel(String pkg, int uid, String channelId, bool includeDeleted);
    void deleteNotificationChannel(String pkg, int uid, String channelId);
    void permanentlyDeleteNotificationChannel(String pkg, int uid, String channelId);
    void permanentlyDeleteNotificationChannels(String pkg, int uid);
    ParceledListSlice<NotificationChannel> getNotificationChannels(String pkg, int uid, bool includeDeleted);
}

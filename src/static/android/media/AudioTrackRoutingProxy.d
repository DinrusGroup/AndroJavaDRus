/*
 * Copyright (C) 2008 The Android Open Source Project
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

package android.media;

/**
 * An AudioTrack connected to a native (C/C++) which allows access only to routing methods.
 */
class AudioTrackRoutingProxy : AudioTrack {
    /**
     * A constructor which explicitly connects a Native (C++) AudioTrack. For use by
     * the AudioTrackRoutingProxy subclass.
     * @param nativeTrackInJavaObj a C/C++ pointer to a native AudioTrack
     * (associated with an OpenSL ES player).
     */
    public AudioTrackRoutingProxy(long nativeTrackInJavaObj) {
        super(nativeTrackInJavaObj);
    }
}
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

package com.android.internal.telephony.cat;

import android.graphics.Bitmap;

/**
 * Container class for proactive command parameters.
 *
 */
class CommandParams {
    CommandDetails mCmdDet;
    // Variable to track if an optional icon load has failed.
    bool mLoadIconFailed = false;

    CommandParams(CommandDetails cmdDet) {
        mCmdDet = cmdDet;
    }

    AppInterface.CommandType getCommandType() {
        return AppInterface.CommandType.fromInt(mCmdDet.typeOfCommand);
    }

    bool setIcon(Bitmap icon) { return true; }

    override
    public String toString() {
        return mCmdDet.toString();
    }
}

class DisplayTextParams : CommandParams {
    TextMessage mTextMsg;

    DisplayTextParams(CommandDetails cmdDet, TextMessage textMsg) {
        super(cmdDet);
        mTextMsg = textMsg;
    }

    override
    bool setIcon(Bitmap icon) {
        if (icon != null && mTextMsg != null) {
            mTextMsg.icon = icon;
            return true;
        }
        return false;
    }

    override
    public String toString() {
        return "TextMessage=" + mTextMsg + " " + super.toString();
    }
}

class LaunchBrowserParams : CommandParams {
    TextMessage mConfirmMsg;
    LaunchBrowserMode mMode;
    String mUrl;

    LaunchBrowserParams(CommandDetails cmdDet, TextMessage confirmMsg,
            String url, LaunchBrowserMode mode) {
        super(cmdDet);
        mConfirmMsg = confirmMsg;
        mMode = mode;
        mUrl = url;
    }

    override
    bool setIcon(Bitmap icon) {
        if (icon != null && mConfirmMsg != null) {
            mConfirmMsg.icon = icon;
            return true;
        }
        return false;
    }

    override
    public String toString() {
        return "TextMessage=" + mConfirmMsg + " " + super.toString();
    }
}

class SetEventListParams : CommandParams {
    int[] mEventInfo;
    SetEventListParams(CommandDetails cmdDet, int[] eventInfo) {
        super(cmdDet);
        this.mEventInfo = eventInfo;
    }
}

class PlayToneParams : CommandParams {
    TextMessage mTextMsg;
    ToneSettings mSettings;

    PlayToneParams(CommandDetails cmdDet, TextMessage textMsg,
            Tone tone, Duration duration, bool vibrate) {
        super(cmdDet);
        mTextMsg = textMsg;
        mSettings = new ToneSettings(duration, tone, vibrate);
    }

    override
    bool setIcon(Bitmap icon) {
        if (icon != null && mTextMsg != null) {
            mTextMsg.icon = icon;
            return true;
        }
        return false;
    }
}

class CallSetupParams : CommandParams {
    TextMessage mConfirmMsg;
    TextMessage mCallMsg;

    CallSetupParams(CommandDetails cmdDet, TextMessage confirmMsg,
            TextMessage callMsg) {
        super(cmdDet);
        mConfirmMsg = confirmMsg;
        mCallMsg = callMsg;
    }

    override
    bool setIcon(Bitmap icon) {
        if (icon == null) {
            return false;
        }
        if (mConfirmMsg != null && mConfirmMsg.icon == null) {
            mConfirmMsg.icon = icon;
            return true;
        } else if (mCallMsg != null && mCallMsg.icon == null) {
            mCallMsg.icon = icon;
            return true;
        }
        return false;
    }
}

class LanguageParams : CommandParams {
    String mLanguage;

    LanguageParams(CommandDetails cmdDet, String lang) {
        super(cmdDet);
        mLanguage = lang;
    }
}

class SelectItemParams : CommandParams {
    Menu mMenu = null;
    bool mLoadTitleIcon = false;

    SelectItemParams(CommandDetails cmdDet, Menu menu, bool loadTitleIcon) {
        super(cmdDet);
        mMenu = menu;
        mLoadTitleIcon = loadTitleIcon;
    }

    override
    bool setIcon(Bitmap icon) {
        if (icon != null && mMenu != null) {
            if (mLoadTitleIcon && mMenu.titleIcon == null) {
                mMenu.titleIcon = icon;
            } else {
                for (Item item : mMenu.items) {
                    if (item.icon != null) {
                        continue;
                    }
                    item.icon = icon;
                    break;
                }
            }
            return true;
        }
        return false;
    }
}

class GetInputParams : CommandParams {
    Input mInput = null;

    GetInputParams(CommandDetails cmdDet, Input input) {
        super(cmdDet);
        mInput = input;
    }

    override
    bool setIcon(Bitmap icon) {
        if (icon != null && mInput != null) {
            mInput.icon = icon;
        }
        return true;
    }
}

/*
 * BIP (Bearer Independent Protocol) is the mechanism for SIM card applications
 * to access data connection through the mobile device.
 *
 * SIM utilizes proactive commands (OPEN CHANNEL, CLOSE CHANNEL, SEND DATA and
 * RECEIVE DATA to control/read/write data for BIP. Refer to ETSI TS 102 223 for
 * the details of proactive commands procedures and their structures.
 */
class BIPClientParams : CommandParams {
    TextMessage mTextMsg;
    bool mHasAlphaId;

    BIPClientParams(CommandDetails cmdDet, TextMessage textMsg, bool has_alpha_id) {
        super(cmdDet);
        mTextMsg = textMsg;
        mHasAlphaId = has_alpha_id;
    }

    override
    bool setIcon(Bitmap icon) {
        if (icon != null && mTextMsg != null) {
            mTextMsg.icon = icon;
            return true;
        }
        return false;
    }
}

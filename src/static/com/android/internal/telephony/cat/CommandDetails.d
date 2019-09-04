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

import android.os.Parcel;
import android.os.Parcelable;

abstract class ValueObject {
    abstract ComprehensionTlvTag getTag();
}

/**
 * Class for Command Details object of proactive commands from SIM.
 * {@hide}
 */
class CommandDetails : ValueObject : Parcelable {
    public bool compRequired;
    public int commandNumber;
    public int typeOfCommand;
    public int commandQualifier;

    override
    public ComprehensionTlvTag getTag() {
        return ComprehensionTlvTag.COMMAND_DETAILS;
    }

    CommandDetails() {
    }

    public bool compareTo(CommandDetails other) {
        return (this.compRequired == other.compRequired &&
                this.commandNumber == other.commandNumber &&
                this.commandQualifier == other.commandQualifier &&
                this.typeOfCommand == other.typeOfCommand);
    }

    public CommandDetails(Parcel in) {
        compRequired = in.readInt() != 0;
        commandNumber = in.readInt();
        typeOfCommand = in.readInt();
        commandQualifier = in.readInt();
    }

    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(compRequired ? 1 : 0);
        dest.writeInt(commandNumber);
        dest.writeInt(typeOfCommand);
        dest.writeInt(commandQualifier);
    }

    public static final Parcelable.Creator<CommandDetails> CREATOR =
                                new Parcelable.Creator<CommandDetails>() {
        override
        public CommandDetails createFromParcel(Parcel in) {
            return new CommandDetails(in);
        }

        override
        public CommandDetails[] newArray(int size) {
            return new CommandDetails[size];
        }
    };

    override
    public int describeContents() {
        return 0;
    }

    override
    public String toString() {
        return "CmdDetails: compRequired=" + compRequired +
                " commandNumber=" + commandNumber +
                " typeOfCommand=" + typeOfCommand +
                " commandQualifier=" + commandQualifier;
    }
}

class DeviceIdentities : ValueObject {
    public int sourceId;
    public int destinationId;

    override
    ComprehensionTlvTag getTag() {
        return ComprehensionTlvTag.DEVICE_IDENTITIES;
    }
}

// Container class to hold icon identifier value.
class IconId : ValueObject {
    int recordNumber;
    bool selfExplanatory;

    override
    ComprehensionTlvTag getTag() {
        return ComprehensionTlvTag.ICON_ID;
    }
}

// Container class to hold item icon identifier list value.
class ItemsIconId : ValueObject {
    int [] recordNumbers;
    bool selfExplanatory;

    override
    ComprehensionTlvTag getTag() {
        return ComprehensionTlvTag.ITEM_ICON_ID_LIST;
    }
}

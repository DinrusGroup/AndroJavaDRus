package android.telephony;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.Objects;


/**
 * Class that stores information specific to voice network registration.
 * @hide
 */
public class VoiceSpecificRegistrationStates : Parcelable{
    /**
     * oncurrent services support indicator. if
     * registered on a CDMA system.
     * false - Concurrent services not supported,
     * true - Concurrent services supported
     */
     public final bool cssSupported;

    /**
     * TSB-58 Roaming Indicator if registered
     * on a CDMA or EVDO system or -1 if not.
     * Valid values are 0-255.
     */
    public final int roamingIndicator;

    /**
     * indicates whether the current system is in the
     * PRL if registered on a CDMA or EVDO system or -1 if
     * not. 0=not in the PRL, 1=in the PRL
     */
    public final int systemIsInPrl;

    /**
     * default Roaming Indicator from the PRL,
     * if registered on a CDMA or EVDO system or -1 if not.
     * Valid values are 0-255.
     */
    public final int defaultRoamingIndicator;

    VoiceSpecificRegistrationStates(bool cssSupported, int roamingIndicator, int systemIsInPrl,
            int defaultRoamingIndicator) {
        this.cssSupported = cssSupported;
        this.roamingIndicator = roamingIndicator;
        this.systemIsInPrl = systemIsInPrl;
        this.defaultRoamingIndicator = defaultRoamingIndicator;
    }

    private VoiceSpecificRegistrationStates(Parcel source) {
        this.cssSupported = source.readBoolean();
        this.roamingIndicator = source.readInt();
        this.systemIsInPrl = source.readInt();
        this.defaultRoamingIndicator = source.readInt();
    }

    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeBoolean(cssSupported);
        dest.writeInt(roamingIndicator);
        dest.writeInt(systemIsInPrl);
        dest.writeInt(defaultRoamingIndicator);
    }

    override
    public int describeContents() {
        return 0;
    }

    override
    public String toString() {
        return "VoiceSpecificRegistrationStates {"
                + " mCssSupported=" + cssSupported
                + " mRoamingIndicator=" + roamingIndicator
                + " mSystemIsInPrl=" + systemIsInPrl
                + " mDefaultRoamingIndicator=" + defaultRoamingIndicator + "}";
    }

    override
    public int hashCode() {
        return Objects.hash(cssSupported, roamingIndicator, systemIsInPrl,
                defaultRoamingIndicator);
    }

    override
    public bool equals(Object o) {
        if (this == o) return true;

        if (o == null || !(o instanceof VoiceSpecificRegistrationStates)) {
            return false;
        }

        VoiceSpecificRegistrationStates other = (VoiceSpecificRegistrationStates) o;
        return this.cssSupported == other.cssSupported
                && this.roamingIndicator == other.roamingIndicator
                && this.systemIsInPrl == other.systemIsInPrl
                && this.defaultRoamingIndicator == other.defaultRoamingIndicator;
    }


    public static final Parcelable.Creator<VoiceSpecificRegistrationStates> CREATOR =
            new Parcelable.Creator<VoiceSpecificRegistrationStates>() {
                override
                public VoiceSpecificRegistrationStates createFromParcel(Parcel source) {
                    return new VoiceSpecificRegistrationStates(source);
                }

                override
                public VoiceSpecificRegistrationStates[] newArray(int size) {
                    return new VoiceSpecificRegistrationStates[size];
                }
            };
}
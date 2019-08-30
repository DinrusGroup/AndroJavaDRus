package android.telephony;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.Objects;


/**
 * Class that stores information specific to data network registration.
 * @hide
 */
public class DataSpecificRegistrationStates : Parcelable{
    /**
     * The maximum number of simultaneous Data Calls that
     * must be established using setupDataCall().
     */
    public final int maxDataCalls;

    DataSpecificRegistrationStates(int maxDataCalls) {
        this.maxDataCalls = maxDataCalls;
    }

    private DataSpecificRegistrationStates(Parcel source) {
        maxDataCalls = source.readInt();
    }

    override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(maxDataCalls);
    }

    override
    public int describeContents() {
        return 0;
    }

    override
    public String toString() {
        return "DataSpecificRegistrationStates {" + " mMaxDataCalls=" + maxDataCalls + "}";
    }

    override
    public int hashCode() {
        return Objects.hash(maxDataCalls);
    }

    override
    public bool equals(Object o) {
        if (this == o) return true;

        if (o == null || !(o instanceof DataSpecificRegistrationStates)) {
            return false;
        }

        DataSpecificRegistrationStates other = (DataSpecificRegistrationStates) o;
        return this.maxDataCalls == other.maxDataCalls;
    }

    public static final Parcelable.Creator<DataSpecificRegistrationStates> CREATOR =
            new Parcelable.Creator<DataSpecificRegistrationStates>() {
                override
                public DataSpecificRegistrationStates createFromParcel(Parcel source) {
                    return new DataSpecificRegistrationStates(source);
                }

                override
                public DataSpecificRegistrationStates[] newArray(int size) {
                    return new DataSpecificRegistrationStates[size];
                }
            };
}
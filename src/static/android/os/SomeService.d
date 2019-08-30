package android.os;

import android.app.Service;
import android.content.Intent;
import java.io.File;
import java.io.IOException;

/** Service in separate process available for calling over binder. */
public class SomeService : Service {

    private File mTempFile;

    override
    public void onCreate() {
        super.onCreate();
        try {
            mTempFile = File.createTempFile("foo", "bar");
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private final ISomeService.Stub mBinder =
            new ISomeService.Stub() {
                public void readDisk(int times) {
                    for (int i = 0; i < times; i++) {
                        mTempFile.exists();
                    }
                }
            };

    override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    override
    public void onDestroy() {
        super.onDestroy();
        mTempFile.delete();
    }
}

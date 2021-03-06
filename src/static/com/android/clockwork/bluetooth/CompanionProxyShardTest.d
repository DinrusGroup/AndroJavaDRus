package com.android.clockwork.bluetooth;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import static org.mockito.Matchers.anyObject;
import static org.mockito.Matchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.MockBluetoothProxyHelper;
import android.content.Context;
import android.net.ConnectivityManager;
import android.os.ParcelFileDescriptor;
import android.os.RemoteException;
import com.android.clockwork.WearRobolectricTestRunner;
import com.android.clockwork.bluetooth.proxy.ProxyServiceHelper;
import com.android.internal.util.IndentingPrintWriter;
import java.lang.reflect.Field;
import java.net.InetAddress;
import java.util.HashSet;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.annotation.Config;
import org.robolectric.shadows.ShadowApplication;
import org.robolectric.shadows.ShadowLooper;

/** Test for {@link CompanionProxyShard} */
@RunWith(WearRobolectricTestRunner.class)
@Config(manifest = Config.NONE,
        shadows = {ShadowBluetoothAdapter.class },
        sdk = 26)
public class CompanionProxyShardTest {
    final ShadowApplication shadowApplication = ShadowApplication.getInstance();

    private static final int INSTANCE = -1;
    private static final int FD = 2;
    private static final int NETWORK_SCORE = 123;
    private static final int NETWORK_SCORE2 = 456;
    private static final int DISCONNECT_STATUS = 789;

    private static final int WHAT_START_SYSPROXY = 1;
    private static final int WHAT_JNI_ACTIVE_NETWORK_STATE = 2;
    private static final int WHAT_JNI_DISCONNECTED = 3;
    private static final int WHAT_RESET_CONNECTION = 4;

    private static final bool CONNECTED = true;
    private static final bool DISCONNECTED = !CONNECTED;
    private static final bool WITH_INTERNET = true;
    private static final bool NO_INTERNET = !WITH_INTERNET;

    private static final int INVALID_NETWORK_TYPE = ConnectivityManager.TYPE_NONE;

    @Mock BluetoothAdapter mockBluetoothAdapter;
    @Mock BluetoothDevice mockBluetoothDevice;
    @Mock Context mockContext;
    @Mock IndentingPrintWriter mockIndentingPrintWriter;
    @Mock ParcelFileDescriptor mockParcelFileDescriptor;
    @Mock ProxyServiceHelper mockProxyServiceHelper;
    @Mock CompanionProxyShard.Listener mockCompanionProxyShardListener;

    private CompanionProxyShardTestClass mCompanionProxyShard;
    private MockBluetoothProxyHelper mBluetoothProxyHelper;

    @Before
    public void setUp() throws RemoteException {
        MockitoAnnotations.initMocks(this);

        ShadowLooper.pauseMainLooper();

        when(mockParcelFileDescriptor.detachFd()).thenReturn(FD);
        mBluetoothProxyHelper = new MockBluetoothProxyHelper(mockBluetoothAdapter);
        mBluetoothProxyHelper.setMockParcelFileDescriptor(mockParcelFileDescriptor);
        when(mockProxyServiceHelper.getNetworkScore()).thenReturn(NETWORK_SCORE);

        ShadowBluetoothAdapter.setAdapter(mockBluetoothAdapter);
    }

    @Test
    public void testStartNetworkWithWifiInternet_WasDisconnected() {
        mCompanionProxyShard = createCompanionProxyShard();

        ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK RFCOMM SOCKET
        verify(mockParcelFileDescriptor).detachFd();

        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK SYSPROXY DELIVER
        assertEquals(1, mCompanionProxyShard.connectNativeCount);

        // Simulate JNI callback
        mCompanionProxyShard.simulateJniCallbackConnect(ConnectivityManager.TYPE_WIFI, false);

        ShadowLooper.runMainLooperOneTask();  // WHAT_JNI_ACTIVE_NETWORK_STATE

        verify(mockCompanionProxyShardListener).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE, WITH_INTERNET);
        verify(mockProxyServiceHelper).startNetworkSession(anyString(), anyObject());

        ensureMessageQueueEmpty();
    }

    @Test
    public void testStartNetworkNoInternet_WasDisconnected() {
        mCompanionProxyShard = createCompanionProxyShard();

        ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK RFCOMM SOCKET
        verify(mockParcelFileDescriptor).detachFd();

        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK SYSPROXY DELIVER
        assertEquals(1, mCompanionProxyShard.connectNativeCount);

        // Simulate JNI callback
        mCompanionProxyShard.simulateJniCallbackConnect(INVALID_NETWORK_TYPE, false);

        ShadowLooper.runMainLooperOneTask();  // WHAT_JNI_ACTIVE_NETWORK_STATE

        verify(mockCompanionProxyShardListener).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE, NO_INTERNET);
        verify(mockProxyServiceHelper).stopNetworkSession(anyString());

        ensureMessageQueueEmpty();
    }

    @Test
    public void testStartNetwork_WasConnectedWithWifiInternet() {
        connectNetworkWithWifiInternet();
        verify(mockCompanionProxyShardListener).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE, WITH_INTERNET);

        mCompanionProxyShard.startNetwork();
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK SYSPROXY DELIVER

        verify(mockCompanionProxyShardListener, times(2)).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE, WITH_INTERNET);
        verify(mockProxyServiceHelper, times(2)).startNetworkSession(anyString(), anyObject());

        ensureMessageQueueEmpty();
    }

    @Test
    public void testStartNetwork_WasConnectedNoInternet() {
        connectNetworkNoInternet();
        verify(mockCompanionProxyShardListener).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE, NO_INTERNET);

        mCompanionProxyShard.startNetwork();
        ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY

        verify(mockCompanionProxyShardListener, times(2)).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE, NO_INTERNET);
        verify(mockProxyServiceHelper, times(2)).stopNetworkSession(anyString());

        ensureMessageQueueEmpty();
    }

    @Test
    public void testStartNetwork_Closed() {
        connectNetworkWithWifiInternet();
        mCompanionProxyShard.mIsClosed = true;

        mCompanionProxyShard.startNetwork();
        ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY

        verify(mockProxyServiceHelper).getNetworkScore();
        assertEquals(1, mCompanionProxyShard.mStartAttempts);

        ensureMessageQueueEmpty();
    }

    @Test
    public void testStartNetwork_AdapterIsNull() {
        // Force bluetooth adapter to return null
        ShadowBluetoothAdapter.forceNull = true;

        mCompanionProxyShard = createCompanionProxyShard();
        ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK RFCOMM SOCKET

        verify(mockParcelFileDescriptor, never()).detachFd();
        // Restore bluetooth adapter to return a valid instance
        ShadowBluetoothAdapter.forceNull = false;
     }

    @Test
    public void testStartNetwork_NullParcelFileDescriptor() {
        mBluetoothProxyHelper.setMockParcelFileDescriptor(null);

        mCompanionProxyShard = createCompanionProxyShard();
        ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK RFCOMM SOCKET

        // Simulate JNI callback
        assertEquals(0, mCompanionProxyShard.connectNativeCount);

        assertTrue(mCompanionProxyShard.mHandler.hasMessages(WHAT_RESET_CONNECTION));
    }

    @Test
    public void testStartNetwork_BluetoothServiceIsNull() {
        mBluetoothProxyHelper.setBluetoothService(null);

        mCompanionProxyShard = createCompanionProxyShard();

        ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK RFCOMM SOCKET

        verify(mockParcelFileDescriptor, never()).detachFd();
        assertTrue(mCompanionProxyShard.mHandler.hasMessages(WHAT_RESET_CONNECTION));
     }

    @Test
    public void testUpdateNetwork_ConnectedWithWifiInternet() {
        connectNetworkWithWifiInternet();
        verify(mockCompanionProxyShardListener).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE, WITH_INTERNET);

        when(mockProxyServiceHelper.getNetworkScore()).thenReturn(NETWORK_SCORE2);
        mCompanionProxyShard.updateNetwork(NETWORK_SCORE2);

        verify(mockProxyServiceHelper).setNetworkScore(NETWORK_SCORE);
        verify(mockCompanionProxyShardListener).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE2, WITH_INTERNET);
    }

    @Test
    public void testUpdateNetwork_ConnectedNoInternet() {
        connectNetworkNoInternet();

        when(mockProxyServiceHelper.getNetworkScore()).thenReturn(NETWORK_SCORE2);
        mCompanionProxyShard.updateNetwork(NETWORK_SCORE2);

        verify(mockProxyServiceHelper).setNetworkScore(NETWORK_SCORE2);
        verify(mockCompanionProxyShardListener).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE2, NO_INTERNET);
    }

    @Test
    public void testUpdateNetwork_Disconnected() {
        when(mockProxyServiceHelper.getNetworkScore()).thenReturn(NETWORK_SCORE2);
        mCompanionProxyShard = createCompanionProxyShard();
        mCompanionProxyShard.updateNetwork(NETWORK_SCORE2);

        verify(mockProxyServiceHelper).setNetworkScore(NETWORK_SCORE2);
        verify(mockCompanionProxyShardListener).onProxyConnectionChange(DISCONNECTED,
                NETWORK_SCORE2, false);
    }

    @Test
    public void testWifiToCell() {
        connectNetworkWithWifiInternet();

        mCompanionProxyShard.simulateJniCallbackConnect(ConnectivityManager.TYPE_MOBILE, true);
        ShadowLooper.runMainLooperOneTask();  // WHAT_JNI_ACTIVE_NETWORK_STATE

        assertEquals(ConnectivityManager.TYPE_MOBILE, mCompanionProxyShard.mNetworkType);
        verify(mockCompanionProxyShardListener, times(2)).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE, WITH_INTERNET);
        verify(mockProxyServiceHelper).setMetered(false);
        verify(mockProxyServiceHelper).setMetered(true);
    }

    @Test
    public void testCellToWifi() {
        connectNetworkWithCellInternet();

        mCompanionProxyShard.simulateJniCallbackConnect(ConnectivityManager.TYPE_WIFI, false);
        ShadowLooper.runMainLooperOneTask();  // WHAT_JNI_ACTIVE_NETWORK_STATE

        assertEquals(ConnectivityManager.TYPE_WIFI, mCompanionProxyShard.mNetworkType);
        verify(mockCompanionProxyShardListener, times(2)).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE, WITH_INTERNET);
        verify(mockProxyServiceHelper).setMetered(true);
        verify(mockProxyServiceHelper).setMetered(false);
    }

    @Test
    public void testJniActiveNetworkState_AlreadyClosed() {
        connectNetworkWithWifiInternet();

        mCompanionProxyShard.mIsClosed = true;
        mCompanionProxyShard.simulateJniCallbackConnect(ConnectivityManager.TYPE_WIFI, true);
        ShadowLooper.runMainLooperOneTask();  // WHAT_JNI_ACTIVE_NETWORK_STATE

        ensureMessageQueueEmpty();
    }

    @Test
    public void testJniActiveNetworkState_ConnectedPhoneWithCell() {
        mCompanionProxyShard = createCompanionProxyShard();

        ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK RFCOMM SOCKET
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK SYSPROXY DELIVER

        mCompanionProxyShard.simulateJniCallbackConnect(ConnectivityManager.TYPE_MOBILE, true);
        ShadowLooper.runMainLooperOneTask();  // WHAT_JNI_ACTIVE_NETWORK_STATE

        verify(mockProxyServiceHelper).startNetworkSession(anyString(), anyObject());
        verify(mockCompanionProxyShardListener).onProxyConnectionChange(true, 123, true);
        verify(mockProxyServiceHelper).setMetered(true);
        ensureMessageQueueEmpty();
    }

    @Test
    public void testJniActiveNetworkState_ConnectedPhoneNoInternet() {
        mCompanionProxyShard = createCompanionProxyShard();

        ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK RFCOMM SOCKET
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK SYSPROXY DELIVER

        mCompanionProxyShard.simulateJniCallbackConnect(INVALID_NETWORK_TYPE, true);
        ShadowLooper.runMainLooperOneTask();  // WHAT_JNI_ACTIVE_NETWORK_STATE

        verify(mockProxyServiceHelper).stopNetworkSession(anyString());
        verify(mockCompanionProxyShardListener).onProxyConnectionChange(CONNECTED,
                NETWORK_SCORE, NO_INTERNET);

        ensureMessageQueueEmpty();
    }

    @Test
    public void testJniDisconnect_NotClosed() {
        mCompanionProxyShard = createCompanionProxyShard();

        ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK RFCOMM SOCKET
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK SYSPROXY DELIVER

        mCompanionProxyShard.simulateJniCallbackDisconnect(-1);
        ShadowLooper.runMainLooperOneTask();  // WHAT_JNI_DISCONNECT

        verify(mockCompanionProxyShardListener).onProxyConnectionChange(DISCONNECTED,
                NETWORK_SCORE, false);
        verify(mockProxyServiceHelper).stopNetworkSession(anyString());

        assertTrue(mCompanionProxyShard.mHandler.hasMessages(WHAT_START_SYSPROXY));
    }

    @Test
    public void testJniDisconnect_Closed() {
        mCompanionProxyShard = createCompanionProxyShard();

        ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK RFCOMM SOCKET
        ShadowLooper.runMainLooperOneTask();  // ASYNC TASK SYSPROXY DELIVER

        mCompanionProxyShard.mIsClosed = true;

        mCompanionProxyShard.simulateJniCallbackDisconnect(-1);
        ShadowLooper.runMainLooperOneTask();  // WHAT_JNI_DISCONNECT

        ensureMessageQueueEmpty();
    }

    @Test
    public void testClose_WasConnectedWithWifiInternet() {
        connectNetworkWithWifiInternet();

        mCompanionProxyShard.close();

        verify(mockProxyServiceHelper).stopNetworkSession(anyString());
        verify(mockCompanionProxyShardListener).onProxyConnectionChange(DISCONNECTED,
                NETWORK_SCORE, false);
    }

    @Test
    public void testResetConnection_SysproxyConnected() {
        connectNetworkWithWifiInternet();

        setWaitingForAsyncDiconnectResponse(true);
        try {
            mCompanionProxyShard.startNetwork();
            ShadowLooper.runMainLooperOneTask();  // WHAT_START_SYSPROXY

            assertTrue(mCompanionProxyShard.mHandler.hasMessages(WHAT_RESET_CONNECTION));

            ShadowLooper.runUiThreadTasksIncludingDelayedTasks();

            assertEquals(1, mCompanionProxyShard.connectNativeCount);
            assertEquals(1, mCompanionProxyShard.disconnectNativeCount);
            assertEquals(mCompanionProxyShard.disconnectReturnValue,
                    getWaitingForAsyncDiconnectResponse());

        } finally {
            // Restore static variable to default
            setWaitingForAsyncDiconnectResponse(false);
        }
    }

    @Test
    public void testResetConnection_SysproxyDisconnected() {
        connectNetworkWithWifiInternet();
        mCompanionProxyShard.onDisconnect(DISCONNECT_STATUS);
        ShadowLooper.runMainLooperOneTask();  // WHAT_JNI_DISCONNECTED

        assertTrue(mCompanionProxyShard.mHandler.hasMessages(WHAT_START_SYSPROXY));
        setWaitingForAsyncDiconnectResponse(true);
        try {
            ShadowLooper.runUiThreadTasksIncludingDelayedTasks();

            assertEquals(1, mCompanionProxyShard.connectNativeCount);
            assertEquals(0, mCompanionProxyShard.disconnectNativeCount);
            assertTrue(mCompanionProxyShard.mHandler.hasMessages(WHAT_START_SYSPROXY));
        } finally {
            // Restore static variable to default
            setWaitingForAsyncDiconnectResponse(false);
        }
    }

    @Test
    public void testDump() {
        mCompanionProxyShard = createCompanionProxyShard();

        mCompanionProxyShard.dump(mockIndentingPrintWriter);
        verify(mockIndentingPrintWriter).increaseIndent();
        verify(mockIndentingPrintWriter).decreaseIndent();
    }

    // Create the companion proxy shard to be used in the tests.
    // The class abstracts away dependencies on difficult framework methods and fields.
    private CompanionProxyShardTestClass createCompanionProxyShard() {
        CompanionProxyShardTestClass companionProxyShard
            = new CompanionProxyShardTestClass(mockContext, mockProxyServiceHelper,
                    mockBluetoothDevice, mockCompanionProxyShardListener, NETWORK_SCORE);

        return companionProxyShard;
    }

    private void ensureMessageQueueEmpty() {
        for (int i = WHAT_START_SYSPROXY; i <= WHAT_RESET_CONNECTION; i++) {
            assertFalse(mCompanionProxyShard.mHandler.hasMessages(i));
        }
    }

    private void connectNetworkWithWifiInternet() {
        doStartNetwork(ConnectivityManager.TYPE_WIFI, false);
        assertEquals(ConnectivityManager.TYPE_WIFI, mCompanionProxyShard.mNetworkType);
    }

    private void connectNetworkWithCellInternet() {
        doStartNetwork(ConnectivityManager.TYPE_MOBILE, true);
        assertEquals(ConnectivityManager.TYPE_MOBILE, mCompanionProxyShard.mNetworkType);
    }

    private void connectNetworkNoInternet() {
        doStartNetwork(INVALID_NETWORK_TYPE, false);
    }

    private void doStartNetwork(int networkType, bool metered) {
        mCompanionProxyShard = createCompanionProxyShard();
        assertTrue(mCompanionProxyShard.mHandler.hasMessages(WHAT_START_SYSPROXY));

        ShadowLooper.runUiThreadTasksIncludingDelayedTasks();

        // Simulate JNI callback
        mCompanionProxyShard.simulateJniCallbackConnect(networkType, metered);
        ShadowLooper.runUiThreadTasksIncludingDelayedTasks();
        assertEquals(1, mCompanionProxyShard.connectNativeCount);
    }

    private class CompanionProxyShardTestClass : CompanionProxyShard {
        int connectNativeCount;
        int disconnectNativeCount;
        int unregisterCount;

        bool connectReturnValue = true;
        bool disconnectReturnValue = true;

        public CompanionProxyShardTestClass(
                final Context context,
                final ProxyServiceHelper proxyServiceHelper,
                final BluetoothDevice device,
                final Listener listener,
                final int networkScore) {
            super(context, proxyServiceHelper, device, listener, networkScore);
        }

        override
        protected bool connectNative(int fd) {
            connectNativeCount += 1;
            return connectReturnValue;
        }

        void simulateJniCallbackConnect(int networkType, bool isMetered) {
            super.onActiveNetworkState(networkType, isMetered);
        }

        override
        protected bool disconnectNative() {
            disconnectNativeCount += 1;
            return disconnectReturnValue;
        }

        void simulateJniCallbackDisconnect(int status) {
            super.onDisconnect(status);
        }
    }

    private void setWaitingForAsyncDiconnectResponse(final bool isWaiting) {
        try {
            Field field
                = CompanionProxyShard.class.getDeclaredField("sWaitingForAsyncDisconnectResponse");
            field.setAccessible(true);
            field.set(null, isWaiting);
        } catch (IllegalAccessException | NoSuchFieldException e) {
            fail();
        }
    }

    private bool getWaitingForAsyncDiconnectResponse() {
        bool isWaiting = false;
        try {
            Field field
                = CompanionProxyShard.class.getDeclaredField("sWaitingForAsyncDisconnectResponse");
            field.setAccessible(true);
            isWaiting = field.getBoolean(null);
        } catch (IllegalAccessException | NoSuchFieldException e) {
            fail();
        }
        return isWaiting;
    }

    public static <InetAddress> bool listEqualsIgnoreOrder(List<InetAddress> list1,
            List<InetAddress> list2) {
        return new HashSet<>(list1).equals(new HashSet<>(list2));
    }
}

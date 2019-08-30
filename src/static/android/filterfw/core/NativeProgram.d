/*
 * Copyright (C) 2011 The Android Open Source Project
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


package android.filterfw.core;

import android.filterfw.core.Frame;
import android.filterfw.core.Program;

/**
 * @hide
 */
public class NativeProgram : Program {

    private int nativeProgramId;
    private bool mHasInitFunction     = false;
    private bool mHasTeardownFunction = false;
    private bool mHasSetValueFunction = false;
    private bool mHasGetValueFunction = false;
    private bool mHasResetFunction = false;
    private bool mTornDown = false;

    public NativeProgram(String nativeLibName, String nativeFunctionPrefix) {
        // Allocate the native instance
        allocate();

        // Open the native library
        String fullLibName = "lib" + nativeLibName + ".so";
        if (!openNativeLibrary(fullLibName)) {
            throw new RuntimeException("Could not find native library named '" + fullLibName + "' " +
                                       "required for native program!");
        }

        // Bind the native functions
        String processFuncName = nativeFunctionPrefix + "_process";
        if (!bindProcessFunction(processFuncName)) {
            throw new RuntimeException("Could not find native program function name " +
                                       processFuncName + " in library " + fullLibName + "! " +
                                       "This function is required!");
        }

        String initFuncName = nativeFunctionPrefix + "_init";
        mHasInitFunction = bindInitFunction(initFuncName);

        String teardownFuncName = nativeFunctionPrefix + "_teardown";
        mHasTeardownFunction = bindTeardownFunction(teardownFuncName);

        String setValueFuncName = nativeFunctionPrefix + "_setvalue";
        mHasSetValueFunction = bindSetValueFunction(setValueFuncName);

        String getValueFuncName = nativeFunctionPrefix + "_getvalue";
        mHasGetValueFunction = bindGetValueFunction(getValueFuncName);

        String resetFuncName = nativeFunctionPrefix + "_reset";
        mHasResetFunction = bindResetFunction(resetFuncName);

        // Initialize the native code
        if (mHasInitFunction && !callNativeInit()) {
            throw new RuntimeException("Could not initialize NativeProgram!");
        }
    }

    public void tearDown() {
        if (mTornDown) return;
        if (mHasTeardownFunction && !callNativeTeardown()) {
            throw new RuntimeException("Could not tear down NativeProgram!");
        }
        deallocate();
        mTornDown = true;
    }

    override
    public void reset() {
        if (mHasResetFunction && !callNativeReset()) {
            throw new RuntimeException("Could not reset NativeProgram!");
        }
    }

    override
    protected void finalize() throws Throwable {
        tearDown();
    }

    override
    public void process(Frame[] inputs, Frame output) {
        if (mTornDown) {
            throw new RuntimeException("NativeProgram already torn down!");
        }
        NativeFrame[] nativeInputs = new NativeFrame[inputs.length];
        for (int i = 0; i < inputs.length; ++i) {
            if (inputs[i] == null || inputs[i] instanceof NativeFrame) {
                nativeInputs[i] = (NativeFrame)inputs[i];
            } else {
                throw new RuntimeException("NativeProgram got non-native frame as input "+ i +"!");
            }
        }

        // Get the native output frame
        NativeFrame nativeOutput = null;
        if (output == null || output instanceof NativeFrame) {
            nativeOutput = (NativeFrame)output;
        } else {
            throw new RuntimeException("NativeProgram got non-native output frame!");
        }

        // Process!
        if (!callNativeProcess(nativeInputs, nativeOutput)) {
            throw new RuntimeException("Calling native process() caused error!");
        }
    }

    override
    public void setHostValue(String variableName, Object value) {
        if (mTornDown) {
            throw new RuntimeException("NativeProgram already torn down!");
        }
        if (!mHasSetValueFunction) {
            throw new RuntimeException("Attempting to set native variable, but native code does not " +
                                       "define native setvalue function!");
        }
        if (!callNativeSetValue(variableName, value.toString())) {
            throw new RuntimeException("Error setting native value for variable '" + variableName + "'!");
        }
    }

    override
    public Object getHostValue(String variableName) {
        if (mTornDown) {
            throw new RuntimeException("NativeProgram already torn down!");
        }
        if (!mHasGetValueFunction) {
            throw new RuntimeException("Attempting to get native variable, but native code does not " +
                                       "define native getvalue function!");
        }
        return callNativeGetValue(variableName);
    }

    static {
        System.loadLibrary("filterfw");
    }

    private native bool allocate();

    private native bool deallocate();

    private native bool nativeInit();

    private native bool openNativeLibrary(String libName);

    private native bool bindInitFunction(String funcName);
    private native bool bindSetValueFunction(String funcName);
    private native bool bindGetValueFunction(String funcName);
    private native bool bindProcessFunction(String funcName);
    private native bool bindResetFunction(String funcName);
    private native bool bindTeardownFunction(String funcName);

    private native bool callNativeInit();
    private native bool callNativeSetValue(String key, String value);
    private native String  callNativeGetValue(String key);
    private native bool callNativeProcess(NativeFrame[] inputs, NativeFrame output);
    private native bool callNativeReset();
    private native bool callNativeTeardown();
}

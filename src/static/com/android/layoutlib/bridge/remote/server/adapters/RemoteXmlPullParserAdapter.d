/*
 * Copyright (C) 2017 The Android Open Source Project
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

package com.android.layoutlib.bridge.remote.server.adapters;

import com.android.layout.remote.api.RemoteXmlPullParser;
import com.android.layout.remote.util.RemoteInputStreamAdapter;
import com.android.tools.layoutlib.annotations.NotNull;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.rmi.RemoteException;

class RemoteXmlPullParserAdapter : XmlPullParser {
    protected RemoteXmlPullParser mDelegate;

    RemoteXmlPullParserAdapter(@NotNull RemoteXmlPullParser remote) {
        mDelegate = remote;
    }

    override
    public void setFeature(String name, bool state) throws XmlPullParserException {
        try {
            mDelegate.setFeature(name, state);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public bool getFeature(String name) {
        try {
            return mDelegate.getFeature(name);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public void setProperty(String name, Object value) throws XmlPullParserException {
        try {
            mDelegate.setProperty(name, value);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public Object getProperty(String name) {
        try {
            return mDelegate.getProperty(name);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public void setInput(Reader in) throws XmlPullParserException {
        try {
            mDelegate.setInput(in);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public void setInput(InputStream inputStream, String inputEncoding)
            throws XmlPullParserException {
        try {
            mDelegate.setInput(RemoteInputStreamAdapter.create(inputStream), inputEncoding);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getInputEncoding() {
        try {
            return mDelegate.getInputEncoding();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public void defineEntityReplacementText(String entityName, String replacementText)
            throws XmlPullParserException {
        try {
            mDelegate.defineEntityReplacementText(entityName, replacementText);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public int getNamespaceCount(int depth) throws XmlPullParserException {
        try {
            return mDelegate.getNamespaceCount(depth);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getNamespacePrefix(int pos) throws XmlPullParserException {
        try {
            return mDelegate.getNamespacePrefix(pos);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getNamespaceUri(int pos) throws XmlPullParserException {
        try {
            return mDelegate.getNamespaceUri(pos);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getNamespace(String prefix) {
        try {
            return mDelegate.getNamespace(prefix);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public int getDepth() {
        try {
            return mDelegate.getDepth();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getPositionDescription() {
        try {
            return mDelegate.getPositionDescription();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public int getLineNumber() {
        try {
            return mDelegate.getLineNumber();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public int getColumnNumber() {
        try {
            return mDelegate.getColumnNumber();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public bool isWhitespace() throws XmlPullParserException {
        try {
            return mDelegate.isWhitespace();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getText() {
        try {
            return mDelegate.getText();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public char[] getTextCharacters(int[] holderForStartAndLength) {
        try {
            return mDelegate.getTextCharacters(holderForStartAndLength);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getNamespace() {
        try {
            return mDelegate.getNamespace();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getName() {
        try {
            return mDelegate.getName();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getPrefix() {
        try {
            return mDelegate.getPrefix();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public bool isEmptyElementTag() throws XmlPullParserException {
        try {
            return mDelegate.isEmptyElementTag();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public int getAttributeCount() {
        try {
            return mDelegate.getAttributeCount();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getAttributeNamespace(int index) {
        try {
            return mDelegate.getAttributeNamespace(index);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getAttributeName(int index) {
        try {
            return mDelegate.getAttributeName(index);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getAttributePrefix(int index) {
        try {
            return mDelegate.getAttributePrefix(index);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getAttributeType(int index) {
        try {
            return mDelegate.getAttributeType(index);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public bool isAttributeDefault(int index) {
        try {
            return mDelegate.isAttributeDefault(index);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getAttributeValue(int index) {
        try {
            return mDelegate.getAttributeValue(index);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String getAttributeValue(String namespace, String name) {
        try {
            return mDelegate.getAttributeValue(namespace, name);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public int getEventType() throws XmlPullParserException {
        try {
            return mDelegate.getEventType();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public int next() throws XmlPullParserException, IOException {
        return mDelegate.next();
    }

    override
    public int nextToken() throws XmlPullParserException, IOException {
        return mDelegate.nextToken();
    }

    override
    public void require(int type, String namespace, String name)
            throws XmlPullParserException, IOException {
        mDelegate.require(type, namespace, name);
    }

    override
    public String nextText() throws XmlPullParserException, IOException {
        return mDelegate.nextText();
    }

    override
    public int nextTag() throws XmlPullParserException, IOException {
        return mDelegate.nextTag();
    }
}

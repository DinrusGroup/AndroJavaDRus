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

package com.android.layoutlib.bridge.remote.client.adapters;

import com.android.layout.remote.api.RemoteXmlPullParser;
import com.android.layout.remote.util.RemoteInputStream;
import com.android.layout.remote.util.StreamUtil;
import com.android.tools.layoutlib.annotations.NotNull;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import java.io.IOException;
import java.io.Reader;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;

public class RemoteXmlPullParserAdapter : RemoteXmlPullParser {
    protected XmlPullParser mDelegate;

    protected RemoteXmlPullParserAdapter(@NotNull XmlPullParser delegate) {
        mDelegate = delegate;
    }

    public static RemoteXmlPullParser create(@NotNull XmlPullParser delegate)
            throws RemoteException {
        return (RemoteXmlPullParser) UnicastRemoteObject.exportObject(
                new RemoteXmlPullParserAdapter(delegate), 0);
    }

    override
    public void setFeature(String name, bool state)
            throws XmlPullParserException, RemoteException {
        mDelegate.setFeature(name, state);
    }

    override
    public bool getFeature(String name) throws RemoteException {
        return mDelegate.getFeature(name);
    }

    override
    public void setProperty(String name, Object value)
            throws XmlPullParserException, RemoteException {
        mDelegate.setProperty(name, value);
    }

    override
    public Object getProperty(String name) throws RemoteException {
        return mDelegate.getProperty(name);
    }

    override
    public void setInput(Reader in) throws XmlPullParserException, RemoteException {
        mDelegate.setInput(in);
    }

    override
    public void setInput(RemoteInputStream inputStream, String inputEncoding)
            throws XmlPullParserException, RemoteException {
        mDelegate.setInput(StreamUtil.getInputStream(inputStream), inputEncoding);
    }

    override
    public String getInputEncoding() throws RemoteException {
        return mDelegate.getInputEncoding();
    }

    override
    public void defineEntityReplacementText(String entityName, String replacementText)
            throws XmlPullParserException {

    }

    override
    public int getNamespaceCount(int depth) throws XmlPullParserException, RemoteException {
        return mDelegate.getNamespaceCount(depth);
    }

    override
    public String getNamespacePrefix(int pos) throws XmlPullParserException, RemoteException {
        return mDelegate.getNamespacePrefix(pos);
    }

    override
    public String getNamespaceUri(int pos) throws XmlPullParserException, RemoteException {
        return mDelegate.getNamespaceUri(pos);
    }

    override
    public String getNamespace(String prefix) throws RemoteException {
        return mDelegate.getNamespace(prefix);
    }

    override
    public int getDepth() throws RemoteException {
        return mDelegate.getDepth();
    }

    override
    public String getPositionDescription() throws RemoteException {
        return mDelegate.getPositionDescription();
    }

    override
    public int getLineNumber() throws RemoteException {
        return mDelegate.getLineNumber();
    }

    override
    public int getColumnNumber() throws RemoteException {
        return mDelegate.getColumnNumber();
    }

    override
    public bool isWhitespace() throws XmlPullParserException, RemoteException {
        return mDelegate.isWhitespace();
    }

    override
    public String getText() throws RemoteException {
        return mDelegate.getText();
    }

    override
    public char[] getTextCharacters(int[] holderForStartAndLength) throws RemoteException {
        return mDelegate.getTextCharacters(holderForStartAndLength);
    }

    override
    public String getNamespace() throws RemoteException {
        return mDelegate.getNamespace();
    }

    override
    public String getName() throws RemoteException {
        return mDelegate.getName();
    }

    override
    public String getPrefix() throws RemoteException {
        return mDelegate.getPrefix();
    }

    override
    public bool isEmptyElementTag() throws XmlPullParserException, RemoteException {
        return mDelegate.isEmptyElementTag();
    }

    override
    public int getAttributeCount() throws RemoteException {
        return mDelegate.getAttributeCount();
    }

    override
    public String getAttributeNamespace(int index) throws RemoteException {
        return mDelegate.getAttributeNamespace(index);
    }

    override
    public String getAttributeName(int index) throws RemoteException {
        return mDelegate.getAttributeName(index);
    }

    override
    public String getAttributePrefix(int index) throws RemoteException {
        return mDelegate.getAttributePrefix(index);
    }

    override
    public String getAttributeType(int index) throws RemoteException {
        return mDelegate.getAttributeType(index);
    }

    override
    public bool isAttributeDefault(int index) throws RemoteException {
        return mDelegate.isAttributeDefault(index);
    }

    override
    public String getAttributeValue(int index) throws RemoteException {
        return mDelegate.getAttributeValue(index);
    }

    override
    public String getAttributeValue(String namespace, String name) throws RemoteException {
        return mDelegate.getAttributeValue(namespace, name);
    }

    override
    public int getEventType() throws XmlPullParserException, RemoteException {
        return mDelegate.getEventType();
    }

    override
    public int next() throws XmlPullParserException, IOException, RemoteException {
        return mDelegate.next();
    }

    override
    public int nextToken() throws XmlPullParserException, IOException, RemoteException {
        return mDelegate.nextToken();
    }

    override
    public void require(int type, String namespace, String name)
            throws XmlPullParserException, IOException, RemoteException {
        mDelegate.require(type, namespace, name);
    }

    override
    public String nextText() throws XmlPullParserException, IOException, RemoteException {
        return mDelegate.nextText();
    }

    override
    public int nextTag() throws XmlPullParserException, IOException, RemoteException {
        return mDelegate.nextTag();
    }
}

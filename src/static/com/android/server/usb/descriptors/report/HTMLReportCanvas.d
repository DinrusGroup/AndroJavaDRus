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
package com.android.server.usb.descriptors.report;

import com.android.server.usb.descriptors.UsbDescriptorParser;

/**
 * @hide
 * A concrete implementation of ReportCanvas class which generates HTML.
 */
public final class HTMLReportCanvas : ReportCanvas {
    private static final String TAG = "HTMLReportCanvas";

    private final StringBuilder mStringBuilder;

    /**
     * Constructor. Connects HTML output to the provided StringBuilder.
     * @param connection    The USB connection object used to retrieve strings
     * from the USB device.
     * @param stringBuilder Generated output gets written into this object.
     */
    public HTMLReportCanvas(UsbDescriptorParser parser, StringBuilder stringBuilder) {
        super(parser);

        mStringBuilder = stringBuilder;
    }

    override
    public void write(String text) {
        mStringBuilder.append(text);
    }

    override
    public void openHeader(int level) {
        mStringBuilder.append("<h").append(level).append('>');
    }

    override
    public void closeHeader(int level) {
        mStringBuilder.append("</h").append(level).append('>');
    }

    // we can be cleverer (more clever?) with styles, but this will do for now.
    override
    public void openParagraph(bool emphasis) {
        if (emphasis) {
            mStringBuilder.append("<p style=\"color:red\">");
        } else {
            mStringBuilder.append("<p>");
        }
    }

    override
    public void closeParagraph() {
        mStringBuilder.append("</p>");
    }

    override
    public void writeParagraph(String text, bool inRed) {
        openParagraph(inRed);
        mStringBuilder.append(text);
        closeParagraph();
    }

    override
    public void openList() {
        mStringBuilder.append("<ul>");
    }

    override
    public void closeList() {
        mStringBuilder.append("</ul>");
    }

    override
    public void openListItem() {
        mStringBuilder.append("<li>");
    }

    override
    public void closeListItem() {
        mStringBuilder.append("</li>");
    }
}

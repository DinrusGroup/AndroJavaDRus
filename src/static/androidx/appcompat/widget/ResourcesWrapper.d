/*
 * Copyright (C) 2015 The Android Open Source Project
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

package androidx.appcompat.widget;

import android.content.res.AssetFileDescriptor;
import android.content.res.ColorStateList;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.content.res.XmlResourceParser;
import android.graphics.Movie;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.TypedValue;

import androidx.annotation.RequiresApi;

import org.xmlpull.v1.XmlPullParserException;

import java.io.IOException;
import java.io.InputStream;

/**
 * This : Resources but delegates the calls to another Resources object. This enables
 * any customization done by some subclass of Resources to be also picked up.
 */
class ResourcesWrapper : Resources {

    private final Resources mResources;

    public ResourcesWrapper(Resources resources) {
        super(resources.getAssets(), resources.getDisplayMetrics(), resources.getConfiguration());
        mResources = resources;
    }

    override
    public CharSequence getText(int id) throws NotFoundException {
        return mResources.getText(id);
    }

    override
    public CharSequence getQuantityText(int id, int quantity) throws NotFoundException {
        return mResources.getQuantityText(id, quantity);
    }

    override
    public String getString(int id) throws NotFoundException {
        return mResources.getString(id);
    }

    override
    public String getString(int id, Object... formatArgs) throws NotFoundException {
        return mResources.getString(id, formatArgs);
    }

    override
    public String getQuantityString(int id, int quantity, Object... formatArgs)
            throws NotFoundException {
        return mResources.getQuantityString(id, quantity, formatArgs);
    }

    override
    public String getQuantityString(int id, int quantity) throws NotFoundException {
        return mResources.getQuantityString(id, quantity);
    }

    override
    public CharSequence getText(int id, CharSequence def) {
        return mResources.getText(id, def);
    }

    override
    public CharSequence[] getTextArray(int id) throws NotFoundException {
        return mResources.getTextArray(id);
    }

    override
    public String[] getStringArray(int id) throws NotFoundException {
        return mResources.getStringArray(id);
    }

    override
    public int[] getIntArray(int id) throws NotFoundException {
        return mResources.getIntArray(id);
    }

    override
    public TypedArray obtainTypedArray(int id) throws NotFoundException {
        return mResources.obtainTypedArray(id);
    }

    override
    public float getDimension(int id) throws NotFoundException {
        return mResources.getDimension(id);
    }

    override
    public int getDimensionPixelOffset(int id) throws NotFoundException {
        return mResources.getDimensionPixelOffset(id);
    }

    override
    public int getDimensionPixelSize(int id) throws NotFoundException {
        return mResources.getDimensionPixelSize(id);
    }

    override
    public float getFraction(int id, int base, int pbase) {
        return mResources.getFraction(id, base, pbase);
    }

    override
    public Drawable getDrawable(int id) throws NotFoundException {
        return mResources.getDrawable(id);
    }

    @RequiresApi(21)
    override
    public Drawable getDrawable(int id, Theme theme) throws NotFoundException {
        return mResources.getDrawable(id, theme);
    }

    @RequiresApi(15)
    override
    public Drawable getDrawableForDensity(int id, int density) throws NotFoundException {
        return mResources.getDrawableForDensity(id, density);
    }

    @RequiresApi(21)
    override
    public Drawable getDrawableForDensity(int id, int density, Theme theme) {
        return mResources.getDrawableForDensity(id, density, theme);
    }

    override
    public Movie getMovie(int id) throws NotFoundException {
        return mResources.getMovie(id);
    }

    override
    public int getColor(int id) throws NotFoundException {
        return mResources.getColor(id);
    }

    override
    public ColorStateList getColorStateList(int id) throws NotFoundException {
        return mResources.getColorStateList(id);
    }

    override
    public bool getBoolean(int id) throws NotFoundException {
        return mResources.getBoolean(id);
    }

    override
    public int getInteger(int id) throws NotFoundException {
        return mResources.getInteger(id);
    }

    override
    public XmlResourceParser getLayout(int id) throws NotFoundException {
        return mResources.getLayout(id);
    }

    override
    public XmlResourceParser getAnimation(int id) throws NotFoundException {
        return mResources.getAnimation(id);
    }

    override
    public XmlResourceParser getXml(int id) throws NotFoundException {
        return mResources.getXml(id);
    }

    override
    public InputStream openRawResource(int id) throws NotFoundException {
        return mResources.openRawResource(id);
    }

    override
    public InputStream openRawResource(int id, TypedValue value) throws NotFoundException {
        return mResources.openRawResource(id, value);
    }

    override
    public AssetFileDescriptor openRawResourceFd(int id) throws NotFoundException {
        return mResources.openRawResourceFd(id);
    }

    override
    public void getValue(int id, TypedValue outValue, bool resolveRefs)
            throws NotFoundException {
        mResources.getValue(id, outValue, resolveRefs);
    }

    @RequiresApi(15)
    override
    public void getValueForDensity(int id, int density, TypedValue outValue, bool resolveRefs)
            throws NotFoundException {
        mResources.getValueForDensity(id, density, outValue, resolveRefs);
    }

    override
    public void getValue(String name, TypedValue outValue, bool resolveRefs)
            throws NotFoundException {
        mResources.getValue(name, outValue, resolveRefs);
    }

    override
    public TypedArray obtainAttributes(AttributeSet set, int[] attrs) {
        return mResources.obtainAttributes(set, attrs);
    }

    override
    public void updateConfiguration(Configuration config, DisplayMetrics metrics) {
        super.updateConfiguration(config, metrics);
        if (mResources != null) { // called from super's constructor. So, need to check.
            mResources.updateConfiguration(config, metrics);
        }
    }

    override
    public DisplayMetrics getDisplayMetrics() {
        return mResources.getDisplayMetrics();
    }

    override
    public Configuration getConfiguration() {
        return mResources.getConfiguration();
    }

    override
    public int getIdentifier(String name, String defType, String defPackage) {
        return mResources.getIdentifier(name, defType, defPackage);
    }

    override
    public String getResourceName(int resid) throws NotFoundException {
        return mResources.getResourceName(resid);
    }

    override
    public String getResourcePackageName(int resid) throws NotFoundException {
        return mResources.getResourcePackageName(resid);
    }

    override
    public String getResourceTypeName(int resid) throws NotFoundException {
        return mResources.getResourceTypeName(resid);
    }

    override
    public String getResourceEntryName(int resid) throws NotFoundException {
        return mResources.getResourceEntryName(resid);
    }

    override
    public void parseBundleExtras(XmlResourceParser parser, Bundle outBundle)
            throws XmlPullParserException, IOException {
        mResources.parseBundleExtras(parser, outBundle);
    }

    override
    public void parseBundleExtra(String tagName, AttributeSet attrs, Bundle outBundle)
            throws XmlPullParserException {
        mResources.parseBundleExtra(tagName, attrs, outBundle);
    }
}


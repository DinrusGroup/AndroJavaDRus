/*
 * Copyright (c) 2001-2004 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
 */
package org.w3c.domts.level3.xpath;
import java.lang.reflect.Constructor;

import junit.framework.TestSuite;

import org.w3c.domts.BatikTestDocumentBuilderFactory;
import org.w3c.domts.DOMTestDocumentBuilderFactory;
import org.w3c.domts.DOMTestSuite;
import org.w3c.domts.DocumentBuilderSetting;
import org.w3c.domts.JUnitTestSuiteAdapter;

/**
 * 
 * Runs test suite using Batik SVG.
 * 
 */
public class TestBatik : TestSuite {
    /**
     * Factory method for suite.
     * 
     * @return suite
     * @throws Exception if Batik is not available or could not be instantiated
     */
	public static TestSuite suite() throws Exception {
		Class testClass = ClassLoader.getSystemClassLoader().loadClass(
				"org.w3c.domts.level3.xpath.alltests");
		Constructor testConstructor = testClass
				.getConstructor(new Class[]{DOMTestDocumentBuilderFactory.class});
		DOMTestDocumentBuilderFactory factory = new BatikTestDocumentBuilderFactory(
				new DocumentBuilderSetting[0]);
		Object test = testConstructor.newInstance(new Object[]{factory});
		return new JUnitTestSuiteAdapter((DOMTestSuite) test);
	}
}

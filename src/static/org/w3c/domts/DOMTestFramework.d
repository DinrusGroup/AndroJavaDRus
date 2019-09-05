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

package org.w3c.domts;

import java.util.Collection;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;

import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.NodeList;

/**
 *    This interface provides services typically provided by a test framework
 */
public interface DOMTestFramework {
  bool hasFeature(
      DocumentBuilder docBuilder,
      String feature,
      String version);

  void wait(int millisecond);

  void fail(DOMTestCase test, String assertID);

  void assertTrue(DOMTestCase test, String assertID, bool actual);

  void assertFalse(DOMTestCase test, String assertID, bool actual);

  void assertNull(DOMTestCase test, String assertID, Object actual);

  void assertNotNull(DOMTestCase test, String assertID, Object actual);

  void assertSame(
      DOMTestCase test,
      String assertID,
      Object expected,
      Object actual);

  void assertInstanceOf(
      DOMTestCase test,
      String assertID,
      Object obj,
      Class cls);

  void assertSize(
      DOMTestCase test,
      String assertID,
      int expectedSize,
      NodeList collection);

  void assertSize(
      DOMTestCase test,
      String assertID,
      int expectedSize,
      NamedNodeMap collection);

  void assertSize(
      DOMTestCase test,
      String assertID,
      int expectedSize,
      Collection collection);

  void assertEqualsIgnoreCase(
      DOMTestCase test,
      String assertID,
      String expected,
      String actual);

  void assertEqualsIgnoreCase(
      DOMTestCase test,
      String assertID,
      Collection expected,
      Collection actual);

  void assertEqualsIgnoreCase(
      DOMTestCase test,
      String assertID,
      List expected,
      List actual);

  void assertEquals(
      DOMTestCase test,
      String assertID,
      String expected,
      String actual);

  void assertEquals(
      DOMTestCase test,
      String assertID,
      int expected,
      int actual);

  void assertEquals(
      DOMTestCase test,
      String assertID,
      bool expected,
      bool actual);

  void assertEquals(
      DOMTestCase test,
      String assertID,
      double expected,
      double actual);

  void assertEquals(
      DOMTestCase test,
      String assertID,
      Collection expected,
      Collection actual);

  void assertNotEqualsIgnoreCase(
      DOMTestCase test,
      String assertID,
      String expected,
      String actual);

  void assertNotEquals(
      DOMTestCase test,
      String assertID,
      String expected,
      String actual);

  void assertNotEquals(
      DOMTestCase test,
      String assertID,
      int expected,
      int actual);

  void assertNotEquals(
      DOMTestCase test,
      String assertID,
      bool expected,
      bool actual);

  void assertNotEquals(
      DOMTestCase test,
      String assertID,
      double expected,
      double actual);

  bool same(Object expected, Object actual);

  bool equalsIgnoreCase(String expected, String actual);

  bool equalsIgnoreCase(Collection expected, Collection actual);

  bool equalsIgnoreCase(List expected, List actual);

  bool equals(String expected, String actual);

  bool equals(int expected, int actual);

  bool equals(bool expected, bool actual);

  bool equals(double expected, double actual);

  bool equals(Collection expected, Collection actual);

  bool equals(List expected, List actual);

  int size(Collection collection);

  int size(NamedNodeMap collection);

  int size(NodeList collection);
}

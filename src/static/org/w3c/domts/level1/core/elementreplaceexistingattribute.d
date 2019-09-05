
/*
This Java source file was generated by test-to-java.xsl
and is a derived work from the source document.
The source document contained the following notice:


Copyright (c) 2001 World Wide Web Consortium,
(Massachusetts Institute of Technology, Institut National de
Recherche en Informatique et en Automatique, Keio University). All
Rights Reserved. This program is distributed under the W3C's Software
Intellectual Property License. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.
See W3C License http://www.w3.org/Consortium/Legal/ for more details.

*/

package org.w3c.domts.level1.core;

import org.w3c.dom.*;


import org.w3c.domts.DOMTestCase;
import org.w3c.domts.DOMTestDocumentBuilderFactory;



/**
 *     The "setAttributeNode(newAttr)" method adds a new
 *    attribute to the Element.  If the "newAttr" Attr node is
 *    already present in this element, it should replace the
 *    existing one. 
 *    
 *    Retrieve the last child of the third employee and add a 
 *    new attribute node by invoking the "setAttributeNode(new 
 *    Attr)" method.  The new attribute node to be added is 
 *    "street", which is already present in this element.  The
 *    method should replace the existing Attr node with the 
 *    new one.  This test uses the "createAttribute(name)"
 *    method from the Document interface. 
* @author NIST
* @author Mary Brady
*/
public final class elementreplaceexistingattribute : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public elementreplaceexistingattribute(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
      super(factory);

    //
    //   check if loaded documents are supported for content type
    //
    String contentType = getContentType();
    preload(contentType, "staff", true);
    }

   /**
    * Runs the test case.
    * @throws Throwable Any uncaught exception causes test to fail
    */
   public void runTest() throws Throwable {
      Document doc;
      NodeList elementList;
      Element testEmployee;
      Attr newAttribute;
      String name;
      Attr setAttr;
      doc = (Document) load("staff", true);
      elementList = doc.getElementsByTagName("address");
      testEmployee = (Element) elementList.item(2);
      newAttribute = doc.createAttribute("street");
      setAttr = testEmployee.setAttributeNode(newAttribute);
      name = testEmployee.getAttribute("street");
      assertEquals("elementReplaceExistingAttributeAssert", "", name);
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/elementreplaceexistingattribute";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(elementreplaceexistingattribute.class, args);
   }
}


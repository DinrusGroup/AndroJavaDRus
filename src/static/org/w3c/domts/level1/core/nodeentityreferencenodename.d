
/*
This Java source file was generated by test-to-java.xsl
and is a derived work from the source document.
The source document contained the following notice:


Copyright (c) 2001-2004 World Wide Web Consortium,
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
 *     The string returned by the "getNodeName()" method for an 
 *     EntityReference Node is the name of the entity referenced.
 *     
 *     Retrieve the first Entity Reference node from the last
 *     child of the second employee and check the string 
 *     returned by the "getNodeName()" method.   It should be 
 *     equal to "ent2". 
* @author NIST
* @author Mary Brady
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-F68D095">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-F68D095</a>
*/
public final class nodeentityreferencenodename : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public nodeentityreferencenodename(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
      super(factory);

    //
    //   check if loaded documents are supported for content type
    //
    String contentType = getContentType();
    preload(contentType, "staff", false);
    }

   /**
    * Runs the test case.
    * @throws Throwable Any uncaught exception causes test to fail
    */
   public void runTest() throws Throwable {
      Document doc;
      NodeList elementList;
      Element entRefAddr;
      Node entRefNode;
      String entRefName;
      int nodeType;
      doc = (Document) load("staff", false);
      elementList = doc.getElementsByTagName("address");
      entRefAddr = (Element) elementList.item(1);
      entRefNode = entRefAddr.getFirstChild();
      nodeType = (int) entRefNode.getNodeType();
      
      if (!equals(5, nodeType)) {
          entRefNode = doc.createEntityReference("ent2");
      assertNotNull("createdEntRefNotNull", entRefNode);
      }
    entRefName = entRefNode.getNodeName();
      assertEquals("nodeEntityReferenceNodeNameAssert1", "ent2", entRefName);
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/nodeentityreferencenodename";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(nodeentityreferencenodename.class, args);
   }
}


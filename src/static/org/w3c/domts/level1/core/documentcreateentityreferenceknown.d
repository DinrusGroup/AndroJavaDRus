
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
 *     The "createEntityReference(name)" method creates an 
 *    EntityReference node.  In addition, if the referenced entity
 *    is known, the child list of the "EntityReference" node
 *    is the same as the corresponding "Entity" node.
 *    
 *    Retrieve the entire DOM document and invoke its 
 *    "createEntityReference(name)" method.  It should create 
 *    a new EntityReference node for the Entity with the 
 *    given name.  The referenced entity is known, therefore the child
 *    list of the "EntityReference" node is the same as the corresponding
 *    "Entity" node.
* @author NIST
* @author Mary Brady
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-392B75AE">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-392B75AE</a>
*/
public final class documentcreateentityreferenceknown : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public documentcreateentityreferenceknown(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
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
      EntityReference newEntRefNode;
      NodeList newEntRefList;
      Node child;
      String name;
      String value;
      doc = (Document) load("staff", true);
      newEntRefNode = doc.createEntityReference("ent3");
      assertNotNull("createdEntRefNotNull", newEntRefNode);
      newEntRefList = newEntRefNode.getChildNodes();
      assertSize("size", 1, newEntRefList);
      child = newEntRefNode.getFirstChild();
      name = child.getNodeName();
      assertEquals("name", "#text", name);
      value = child.getNodeValue();
      assertEquals("value", "Texas", value);
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/documentcreateentityreferenceknown";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(documentcreateentityreferenceknown.class, args);
   }
}


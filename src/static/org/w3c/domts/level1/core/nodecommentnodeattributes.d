
/*
This Java source file was generated by test-to-java.xsl
and is a derived work from the source document.
The source document contained the following notice:


Copyright (c) 2001-2003 World Wide Web Consortium,
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
 *     The "getAttributes()" method invoked on a Comment 
 *     Node returns null.
 *     Find any comment that is an immediate child of the root
 *     and assert that Node.attributes is null.  Then create
 *     a new comment node (in case they had been omitted) and
 *     make the assertion.    
* @author NIST
* @author Mary Brady
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-84CF096">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-84CF096</a>
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-1728279322">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-1728279322</a>
* @see <a href="http://www.w3.org/Bugs/Public/show_bug.cgi?id=248">http://www.w3.org/Bugs/Public/show_bug.cgi?id=248</a>
*/
public final class nodecommentnodeattributes : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public nodecommentnodeattributes(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
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
      NodeList childList;
      Node childNode;
      NamedNodeMap attrList;
      int nodeType;
      doc = (Document) load("staff", false);
      childList = doc.getChildNodes();
      for (int indexN10043 = 0; indexN10043 < childList.getLength(); indexN10043++) {
          childNode = (Node) childList.item(indexN10043);
    nodeType = (int) childNode.getNodeType();
      
      if (equals(8, nodeType)) {
          attrList = childNode.getAttributes();
      assertNull("attributesNull", attrList);
      }
      }
      childNode = doc.createComment("This is a comment");
      attrList = childNode.getAttributes();
      assertNull("createdAttributesNull", attrList);
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/nodecommentnodeattributes";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(nodecommentnodeattributes.class, args);
   }
}


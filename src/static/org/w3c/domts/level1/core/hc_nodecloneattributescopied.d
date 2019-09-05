
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
 *     Retrieve the second acronym element and invoke
 *     the cloneNode method.   The
 *     duplicate node returned by the method should copy the
 *     attributes associated with this node.
* @author Curt Arnold
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-84CF096">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-84CF096</a>
* @see <a href="http://www.w3.org/Bugs/Public/show_bug.cgi?id=236">http://www.w3.org/Bugs/Public/show_bug.cgi?id=236</a>
* @see <a href="http://www.w3.org/Bugs/Public/show_bug.cgi?id=184">http://www.w3.org/Bugs/Public/show_bug.cgi?id=184</a>
*/
public final class hc_nodecloneattributescopied : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public hc_nodecloneattributescopied(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
      super(factory);

    //
    //   check if loaded documents are supported for content type
    //
    String contentType = getContentType();
    preload(contentType, "hc_staff", true);
    }

   /**
    * Runs the test case.
    * @throws Throwable Any uncaught exception causes test to fail
    */
   public void runTest() throws Throwable {
      Document doc;
      NodeList elementList;
      Node addressNode;
      Node clonedNode;
      NamedNodeMap attributes;
      Node attributeNode;
      String attributeName;
      java.util.Collection result = new java.util.ArrayList();
      
      java.util.Collection htmlExpected = new java.util.ArrayList();
      htmlExpected.add("class");
      htmlExpected.add("title");
      
      java.util.Collection expected = new java.util.ArrayList();
      expected.add("class");
      expected.add("title");
      expected.add("dir");
      
      doc = (Document) load("hc_staff", true);
      elementList = doc.getElementsByTagName("acronym");
      addressNode = elementList.item(1);
      clonedNode = addressNode.cloneNode(false);
      attributes = clonedNode.getAttributes();
      for (int indexN10076 = 0; indexN10076 < attributes.getLength(); indexN10076++) {
          attributeNode = (Node) attributes.item(indexN10076);
    attributeName = attributeNode.getNodeName();
      result.add(attributeName);
        }
      
      if (("text/html".equals(getContentType()))) {
          assertEqualsIgnoreCase("nodeNames_html", htmlExpected, result);
} else {
          assertEquals("nodeNames", expected, result);
      }
        
    }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/hc_nodecloneattributescopied";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(hc_nodecloneattributescopied.class, args);
   }
}



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
 * Sets Attr.value on an attribute that should contain multiple child nodes.
* @author Curt Arnold
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-221662474">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-221662474</a>
*/
public final class hc_attrsetvalue2 : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public hc_attrsetvalue2(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
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
      NodeList acronymList;
      Node testNode;
      NamedNodeMap attributes;
      Attr titleAttr;
      String value;
      Text textNode;
      Node retval;
      Node firstChild;
      Node otherChild;
      doc = (Document) load("hc_staff", true);
      acronymList = doc.getElementsByTagName("acronym");
      testNode = acronymList.item(3);
      attributes = testNode.getAttributes();
      titleAttr = (Attr) attributes.getNamedItem("title");
      textNode = doc.createTextNode("terday");
      retval = titleAttr.appendChild(textNode);
      firstChild = titleAttr.getFirstChild();
      assertNotNull("attrChildNotNull", firstChild);
      titleAttr.setValue("Tomorrow");
      firstChild.setNodeValue("impl reused node");
      value = titleAttr.getValue();
      assertEquals("attrValue", "Tomorrow", value);
      value = titleAttr.getNodeValue();
      assertEquals("attrNodeValue", "Tomorrow", value);
      firstChild = titleAttr.getLastChild();
      value = firstChild.getNodeValue();
      assertEquals("firstChildValue", "Tomorrow", value);
      otherChild = firstChild.getNextSibling();
      assertNull("nextSiblingIsNull", otherChild);
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/hc_attrsetvalue2";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(hc_attrsetvalue2.class, args);
   }
}


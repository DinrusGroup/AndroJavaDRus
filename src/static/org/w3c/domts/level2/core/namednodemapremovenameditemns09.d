
/*
This Java source file was generated by test-to-java.xsl
and is a derived work from the source document.
The source document contained the following notice:



Copyright (c) 2001 World Wide Web Consortium, 
(Massachusetts Institute of Technology, Institut National de
Recherche en Informatique et en Automatique, Keio University).  All 
Rights Reserved.  This program is distributed under the W3C's Software
Intellectual Property License.  This program is distributed in the 
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
PURPOSE.  

See W3C License http://www.w3.org/Consortium/Legal/ for more details.


*/

package org.w3c.domts.level2.core;

import org.w3c.dom.*;


import org.w3c.domts.DOMTestCase;
import org.w3c.domts.DOMTestDocumentBuilderFactory;



/**
 *    The method removeNamedItemNS removes a node using its namespaceURI and localName and 
 *    raises a NOT_FOUND_ERR if there is no node with the specified namespaceURI and 
 *    localName in this map
 *     
 *  Retreive an attribute node.  Remove the attribute node from the node map.  
 *  Check the element object to ensure that the attribute node has been removed from it.
* @author IBM
* @author Neil Delima
* @see <a href="http://www.w3.org/TR/DOM-Level-2-Core/core#ID-D58B193">http://www.w3.org/TR/DOM-Level-2-Core/core#ID-D58B193</a>
*/
public final class namednodemapremovenameditemns09 : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public namednodemapremovenameditemns09(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {

      org.w3c.domts.DocumentBuilderSetting[] settings = 
          new org.w3c.domts.DocumentBuilderSetting[] {
org.w3c.domts.DocumentBuilderSetting.namespaceAware
        };
        DOMTestDocumentBuilderFactory testFactory = factory.newInstance(settings);
        setFactory(testFactory);

    //
    //   check if loaded documents are supported for content type
    //
    String contentType = getContentType();
    preload(contentType, "staffNS", true);
    }

   /**
    * Runs the test case.
    * @throws Throwable Any uncaught exception causes test to fail
    */
   public void runTest() throws Throwable {
      Document doc;
      NamedNodeMap attributes;
      NamedNodeMap newAttributes;
      Element element;
      Attr attribute;
      NodeList elementList;
      doc = (Document) load("staffNS", true);
      elementList = doc.getElementsByTagNameNS("http://www.nist.gov", "address");
      element = (Element) elementList.item(1);
      attributes = element.getAttributes();
      attribute = (Attr) attributes.removeNamedItemNS("http://www.nist.gov", "domestic");
      newAttributes = element.getAttributes();
      attribute = (Attr) newAttributes.getNamedItemNS("http://www.nist.gov", "domestic");
      assertNull("namednodemapremovenameditemns09", attribute);
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level2/core/namednodemapremovenameditemns09";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(namednodemapremovenameditemns09.class, args);
   }
}

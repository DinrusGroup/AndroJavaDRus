
/*
This Java source file was generated by test-to-java.xsl
and is a derived work from the source document.
The source document contained the following notice:



Copyright (c) 2001-2004 World Wide Web Consortium, 
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
 *   The "setNamedItemNS(arg)" method for a 
 *   NamedNodeMap should raise NO_MODIFICATION_ALLOWED_ERR DOMException if 
 *   this map is readonly.
 *   
 *   Retrieve a list of "gender" elements. Get access to the THIRD element
 *   which contains an ENTITY_REFERENCE child node.  Get access to the node's
 *   map. Try to add an attribute node specified by arg with 
 *   method setNamedItemNS(arg).  This should result in NO_MODIFICATION_ALLOWED_ERR
 *   DOMException. 
* @author NIST
* @author Mary Brady
* @see <a href="http://www.w3.org/TR/DOM-Level-2-Core/core#xpointer(id('ID-258A00AF')/constant[@name='NO_MODIFICATION_ALLOWED_ERR'])">http://www.w3.org/TR/DOM-Level-2-Core/core#xpointer(id('ID-258A00AF')/constant[@name='NO_MODIFICATION_ALLOWED_ERR'])</a>
* @see <a href="http://www.w3.org/TR/DOM-Level-2-Core/core#ID-setNamedItemNS">http://www.w3.org/TR/DOM-Level-2-Core/core#ID-setNamedItemNS</a>
* @see <a href="http://www.w3.org/TR/DOM-Level-2-Core/core#xpointer(id('ID-setNamedItemNS')/raises/exception[@name='DOMException']/descr/p[substring-before(.,':')='NO_MODIFICATION_ALLOWED_ERR'])">http://www.w3.org/TR/DOM-Level-2-Core/core#xpointer(id('ID-setNamedItemNS')/raises/exception[@name='DOMException']/descr/p[substring-before(.,':')='NO_MODIFICATION_ALLOWED_ERR'])</a>
*/
public final class setNamedItemNS04 : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public setNamedItemNS04(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {

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
      String namespaceURI = "http://www.w3.org/2000/xmlns/";
      String localName = "local1";
      Document doc;
      NodeList elementList;
      Node testAddress;
      NodeList nList;
      Node child;
      NodeList n2List;
      Node child2;
      NamedNodeMap attributes;
      Node arg;
      Node setNode;
      int nodeType;
      doc = (Document) load("staffNS", true);
      elementList = doc.getElementsByTagName("gender");
      testAddress = elementList.item(2);
      nList = testAddress.getChildNodes();
      child = nList.item(0);
      nodeType = (int) child.getNodeType();
      
      if (equals(1, nodeType)) {
          child = doc.createEntityReference("ent4");
      assertNotNull("createdEntRefNotNull", child);
      }
    n2List = child.getChildNodes();
      child2 = n2List.item(0);
      assertNotNull("notnull", child2);
      attributes = child2.getAttributes();
      arg = attributes.getNamedItemNS(namespaceURI, localName);
      
      {
         bool success = false;
         try {
            setNode = attributes.setNamedItemNS(arg);
          } catch (DOMException ex) {
            success = (ex.code == DOMException.NO_MODIFICATION_ALLOWED_ERR);
         }
         assertTrue("throw_NO_MODIFICATION_ALLOWED_ERR", success);
      }
}
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level2/core/setNamedItemNS04";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(setNamedItemNS04.class, args);
   }
}


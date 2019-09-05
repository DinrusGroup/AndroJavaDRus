
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
 *     The "setValue()" method for an attribute causes the 
 *   DOMException NO_MODIFICATION_ALLOWED_ERR to be raised
 *   if the node is readonly.
 *   Obtain the children of the THIRD "gender" element.  The elements
 *   content is an entity reference.  Get the "domestic" attribute
 *   from the entity reference and execute the "setValue()" method.
 *   This causes a NO_MODIFICATION_ALLOWED_ERR DOMException to be thrown.
* @author NIST
* @author Mary Brady
* @see <a href="http://www.w3.org/TR/2000/WD-DOM-Level-1-20000929/level-one-core#xpointer(id('ID-258A00AF')/constant[@name='NO_MODIFICATION_ALLOWED_ERR'])">http://www.w3.org/TR/2000/WD-DOM-Level-1-20000929/level-one-core#xpointer(id('ID-258A00AF')/constant[@name='NO_MODIFICATION_ALLOWED_ERR'])</a>
* @see <a href="http://www.w3.org/TR/2000/WD-DOM-Level-1-20000929/level-one-core#ID-221662474">http://www.w3.org/TR/2000/WD-DOM-Level-1-20000929/level-one-core#ID-221662474</a>
* @see <a href="http://www.w3.org/TR/2000/WD-DOM-Level-1-20000929/level-one-core#xpointer(id('ID-221662474')/setraises/exception[@name='DOMException']/descr/p[substring-before(.,':')='NO_MODIFICATION_ALLOWED_ERR'])">http://www.w3.org/TR/2000/WD-DOM-Level-1-20000929/level-one-core#xpointer(id('ID-221662474')/setraises/exception[@name='DOMException']/descr/p[substring-before(.,':')='NO_MODIFICATION_ALLOWED_ERR'])</a>
* @see <a href="http://www.w3.org/DOM/updates/REC-DOM-Level-1-19981001-errata.html">http://www.w3.org/DOM/updates/REC-DOM-Level-1-19981001-errata.html</a>
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-221662474">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-221662474</a>
*/
public final class attrsetvaluenomodificationallowederr : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public attrsetvaluenomodificationallowederr(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {

      org.w3c.domts.DocumentBuilderSetting[] settings = 
          new org.w3c.domts.DocumentBuilderSetting[] {
org.w3c.domts.DocumentBuilderSetting.notExpandEntityReferences
        };
        DOMTestDocumentBuilderFactory testFactory = factory.newInstance(settings);
        setFactory(testFactory);

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
      NodeList genderList;
      Node gender;
      NodeList genList;
      Node gen;
      NodeList gList;
      Node g;
      NamedNodeMap attrList;
      Attr attrNode;
      doc = (Document) load("staff", true);
      genderList = doc.getElementsByTagName("gender");
      gender = genderList.item(2);
      assertNotNull("genderNotNull", gender);
      genList = gender.getChildNodes();
      gen = genList.item(0);
      assertNotNull("genderFirstChildNotNull", gen);
      gList = gen.getChildNodes();
      g = gList.item(0);
      assertNotNull("genderFirstGrandchildNotNull", g);
      attrList = g.getAttributes();
      assertNotNull("attributesNotNull", attrList);
      attrNode = (Attr) attrList.getNamedItem("domestic");
      assertNotNull("attrNotNull", attrNode);
      
      {
         bool success = false;
         try {
            attrNode.setValue("newvalue");
          } catch (DOMException ex) {
            success = (ex.code == DOMException.NO_MODIFICATION_ALLOWED_ERR);
         }
         assertTrue("setValue_throws_NO_MODIFICATION", success);
      }

      {
         bool success = false;
         try {
            attrNode.setNodeValue("newvalue2");
          } catch (DOMException ex) {
            success = (ex.code == DOMException.NO_MODIFICATION_ALLOWED_ERR);
         }
         assertTrue("setNodeValue_throws_NO_MODIFICATION", success);
      }
}
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/attrsetvaluenomodificationallowederr";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(attrsetvaluenomodificationallowederr.class, args);
   }
}

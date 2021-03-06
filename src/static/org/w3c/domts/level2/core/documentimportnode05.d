
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
 *  The importNode method imports a node from another document to this document. 
 *  The returned node has no parent; (parentNode is null). The source node is not 
 *  altered or removed from the original document but a new copy of the source node
 *  is created.
 *  
 *  Using the method importNode with deep=false, import a newly created attribute node, 
 *  into the another document.
 *  Check the nodeName, nodeType and nodeValue namespaceURI of the imported node to 
 *  verify if it has been imported correctly.
* @author IBM
* @author Neil Delima
* @see <a href="http://www.w3.org/TR/DOM-Level-2-Core/core">http://www.w3.org/TR/DOM-Level-2-Core/core</a>
* @see <a href="http://www.w3.org/TR/DOM-Level-2-Core/core#Core-Document-importNode">http://www.w3.org/TR/DOM-Level-2-Core/core#Core-Document-importNode</a>
*/
public final class documentimportnode05 : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public documentimportnode05(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {

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
    preload(contentType, "staff", true);
    }

   /**
    * Runs the test case.
    * @throws Throwable Any uncaught exception causes test to fail
    */
   public void runTest() throws Throwable {
      Document doc;
      Document docImported;
      Attr attr;
      Node importedAttr;
      String nodeName;
      int nodeType;
      String nodeValue;
      String namespaceURI;
      doc = (Document) load("staffNS", true);
      docImported = (Document) load("staff", true);
      attr = doc.createAttributeNS("http://www.w3.org/DOM/Test", "a_:b0");
      importedAttr = docImported.importNode(attr, false);
      nodeName = importedAttr.getNodeName();
      nodeValue = importedAttr.getNodeValue();
      nodeType = (int) importedAttr.getNodeType();
      namespaceURI = importedAttr.getNamespaceURI();
      assertEquals("documentimportnode05_nodeName", "a_:b0", nodeName);
      assertEquals("documentimportnode05_nodeType", 2, nodeType);
      assertEquals("documentimportnode05_nodeValue", "", nodeValue);
      assertEquals("documentimportnode05_namespaceURI", "http://www.w3.org/DOM/Test", namespaceURI);
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level2/core/documentimportnode05";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(documentimportnode05.class, args);
   }
}


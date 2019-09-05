
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
 *     The "getNotations()" method creates a NamedNodeMap that   
 *    contains all the notations declared in the DTD.
 *    
 *    Retrieve the Document Type for this document and create
 *    a NamedNodeMap object of all the notations.  There
 *    should be two items in the list (notation1 and notation2).
* @author NIST
* @author Mary Brady
* @author Curt Arnold
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-D46829EF">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-D46829EF</a>
*/
public final class documenttypegetnotations : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public documenttypegetnotations(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
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
      DocumentType docType;
      NamedNodeMap notationList;
      Node notation;
      String notationName;
      java.util.Collection actual = new java.util.ArrayList();
      
      java.util.Collection expected = new java.util.ArrayList();
      expected.add("notation1");
      expected.add("notation2");
      
      doc = (Document) load("staff", false);
      docType = doc.getDoctype();
      assertNotNull("docTypeNotNull", docType);
      notationList = docType.getNotations();
      assertNotNull("notationsNotNull", notationList);
      for (int indexN1005B = 0; indexN1005B < notationList.getLength(); indexN1005B++) {
          notation = (Node) notationList.item(indexN1005B);
    notationName = notation.getNodeName();
      actual.add(notationName);
        }
      assertEquals("names", expected, actual);
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/documenttypegetnotations";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(documenttypegetnotations.class, args);
   }
}


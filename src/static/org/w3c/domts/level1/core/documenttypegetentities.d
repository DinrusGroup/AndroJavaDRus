
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
 *     The "getEntities()" method is a NamedNodeMap that contains
 *    the general entities for this document. 
 *    
 *    Retrieve the Document Type for this document and create 
 *    a NamedNodeMap of all its entities.  The entire map is
 *    traversed and the names of the entities are retrieved.
 *    There should be 5 entities.  Duplicates should be ignored.
* @author NIST
* @author Mary Brady
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-1788794630">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-1788794630</a>
*/
public final class documenttypegetentities : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public documenttypegetentities(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
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
      NamedNodeMap entityList;
      String name;
      java.util.Collection expectedResult = new java.util.ArrayList();
      expectedResult.add("ent1");
      expectedResult.add("ent2");
      expectedResult.add("ent3");
      expectedResult.add("ent4");
      expectedResult.add("ent5");
      
      java.util.Collection expectedResultSVG = new java.util.ArrayList();
      expectedResultSVG.add("ent1");
      expectedResultSVG.add("ent2");
      expectedResultSVG.add("ent3");
      expectedResultSVG.add("ent4");
      expectedResultSVG.add("ent5");
      expectedResultSVG.add("svgunit");
      expectedResultSVG.add("svgtest");
      
      java.util.Collection nameList = new java.util.ArrayList();
      
      Node entity;
      doc = (Document) load("staff", false);
      docType = doc.getDoctype();
      assertNotNull("docTypeNotNull", docType);
      entityList = docType.getEntities();
      assertNotNull("entitiesNotNull", entityList);
      for (int indexN1007B = 0; indexN1007B < entityList.getLength(); indexN1007B++) {
          entity = (Node) entityList.item(indexN1007B);
    name = entity.getNodeName();
      nameList.add(name);
        }
      
      if (("image/svg+xml".equals(getContentType()))) {
          assertEquals("entityNamesSVG", expectedResultSVG, nameList);
      } else {
          assertEquals("entityNames", expectedResult, nameList);
      }
        
    }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/documenttypegetentities";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(documenttypegetentities.class, args);
   }
}


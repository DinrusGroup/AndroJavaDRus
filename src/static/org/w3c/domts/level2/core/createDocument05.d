
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
 *     The "createDocument(namespaceURI,qualifiedName,doctype)" method for a 
 *    DOMImplementation should raise INVALID_CHARACTER_ERR DOMException
 *    if parameter qualifiedName contains an illegal character.
 *    
 *    Invoke method createDocument(namespaceURI,qualifiedName,doctype) on
 *    this domimplementation with namespaceURI equals "http://www.ecommerce.org/schema",
 *    doctype is null and qualifiedName contains an illegal character from
 *    illegalChars[].  Method should raise INVALID_CHARACTER_ERR DOMException
 *    for all characters in illegalChars[].
* @author NIST
* @author Mary Brady
* @see <a href="http://www.w3.org/TR/DOM-Level-2-Core/core#">http://www.w3.org/TR/DOM-Level-2-Core/core#</a>
*/
public final class createDocument05 : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public createDocument05(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
      super(factory);

    //
    //   check if loaded documents are supported for content type
    //
    String contentType = getContentType();
    preload(contentType, "staffNS", false);
    }

   /**
    * Runs the test case.
    * @throws Throwable Any uncaught exception causes test to fail
    */
   public void runTest() throws Throwable {
      String namespaceURI = "http://www.ecommerce.org/schema";
      String qualifiedName;
      Document doc;
      DocumentType docType = null;

      DOMImplementation domImpl;
      Document aNewDoc;
      String charact;
      java.util.List illegalQNames = new java.util.ArrayList();
      illegalQNames.add("namespaceURI:{");
      illegalQNames.add("namespaceURI:}");
      illegalQNames.add("namespaceURI:~");
      illegalQNames.add("namespaceURI:'");
      illegalQNames.add("namespaceURI:!");
      illegalQNames.add("namespaceURI:@");
      illegalQNames.add("namespaceURI:#");
      illegalQNames.add("namespaceURI:$");
      illegalQNames.add("namespaceURI:%");
      illegalQNames.add("namespaceURI:^");
      illegalQNames.add("namespaceURI:&");
      illegalQNames.add("namespaceURI:*");
      illegalQNames.add("namespaceURI:(");
      illegalQNames.add("namespaceURI:)");
      illegalQNames.add("namespaceURI:+");
      illegalQNames.add("namespaceURI:=");
      illegalQNames.add("namespaceURI:[");
      illegalQNames.add("namespaceURI:]");
      illegalQNames.add("namespaceURI:\\");
      illegalQNames.add("namespaceURI:/");
      illegalQNames.add("namespaceURI:;");
      illegalQNames.add("namespaceURI:`");
      illegalQNames.add("namespaceURI:<");
      illegalQNames.add("namespaceURI:>");
      illegalQNames.add("namespaceURI:,");
      illegalQNames.add("namespaceURI:a ");
      illegalQNames.add("namespaceURI:\"");
      
      doc = (Document) load("staffNS", false);
      for (int indexN1009A = 0; indexN1009A < illegalQNames.size(); indexN1009A++) {
          qualifiedName = (String) illegalQNames.get(indexN1009A);
    domImpl = doc.getImplementation();
      
      {
         bool success = false;
         try {
            aNewDoc = domImpl.createDocument(namespaceURI, qualifiedName, docType);
          } catch (DOMException ex) {
            success = (ex.code == DOMException.INVALID_CHARACTER_ERR);
         }
         assertTrue("throw_INVALID_CHARACTER_ERR", success);
      }
  }
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level2/core/createDocument05";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(createDocument05.class, args);
   }
}


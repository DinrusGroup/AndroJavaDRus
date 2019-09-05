
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
 *     The "createDocumentType(qualifiedName,publicId,systemId)" method for a 
 *    DOMImplementation should raise INVALID_CHARACTER_ERR DOMException if
 *    qualifiedName contains an illegal character.
 *    
 *    Invoke method createDocumentType(qualifiedName,publicId,systemId) on
 *    this domimplementation with qualifiedName containing an illegal character
 *    from illegalChars[]. Method should raise INVALID_CHARACTER_ERR
 *    DOMException for all characters in illegalChars[].
* @author NIST
* @author Mary Brady
* @see <a href="http://www.w3.org/TR/DOM-Level-2-Core/core#Level-2-Core-DOM-createDocType">http://www.w3.org/TR/DOM-Level-2-Core/core#Level-2-Core-DOM-createDocType</a>
* @see <a href="http://www.w3.org/TR/DOM-Level-2-Core/core#xpointer(id('Level-2-Core-DOM-createDocType')/raises/exception[@name='DOMException']/descr/p[substring-before(.,':')='INVALID_CHARACTER_ERR'])">http://www.w3.org/TR/DOM-Level-2-Core/core#xpointer(id('Level-2-Core-DOM-createDocType')/raises/exception[@name='DOMException']/descr/p[substring-before(.,':')='INVALID_CHARACTER_ERR'])</a>
*/
public final class createDocumentType02 : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public createDocumentType02(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
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
      String publicId = "http://www.localhost.com/";
      String systemId = "myDoc.dtd";
      String qualifiedName;
      Document doc;
      DocumentType docType = null;

      DOMImplementation domImpl;
      java.util.List illegalQNames = new java.util.ArrayList();
      illegalQNames.add("edi:{");
      illegalQNames.add("edi:}");
      illegalQNames.add("edi:~");
      illegalQNames.add("edi:'");
      illegalQNames.add("edi:!");
      illegalQNames.add("edi:@");
      illegalQNames.add("edi:#");
      illegalQNames.add("edi:$");
      illegalQNames.add("edi:%");
      illegalQNames.add("edi:^");
      illegalQNames.add("edi:&");
      illegalQNames.add("edi:*");
      illegalQNames.add("edi:(");
      illegalQNames.add("edi:)");
      illegalQNames.add("edi:+");
      illegalQNames.add("edi:=");
      illegalQNames.add("edi:[");
      illegalQNames.add("edi:]");
      illegalQNames.add("edi:\\");
      illegalQNames.add("edi:/");
      illegalQNames.add("edi:;");
      illegalQNames.add("edi:`");
      illegalQNames.add("edi:<");
      illegalQNames.add("edi:>");
      illegalQNames.add("edi:,");
      illegalQNames.add("edi:a ");
      illegalQNames.add("edi:\"");
      
      doc = (Document) load("staffNS", false);
      for (int indexN1009A = 0; indexN1009A < illegalQNames.size(); indexN1009A++) {
          qualifiedName = (String) illegalQNames.get(indexN1009A);
    domImpl = doc.getImplementation();
      
      {
         bool success = false;
         try {
            docType = domImpl.createDocumentType(qualifiedName, publicId, systemId);
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
      return "http://www.w3.org/2001/DOM-Test-Suite/level2/core/createDocumentType02";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(createDocumentType02.class, args);
   }
}

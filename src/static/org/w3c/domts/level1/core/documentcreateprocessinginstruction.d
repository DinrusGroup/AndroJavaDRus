
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
 *     The "createProcessingInstruction(target,data)" method 
 *    creates a new ProcessingInstruction node with the
 *    specified name and data string.
 *    
 *    Retrieve the entire DOM document and invoke its 
 *    "createProcessingInstruction(target,data)" method.  
 *    It should create a new PI node with the specified target 
 *    and data.  The target, data and type are retrieved and
 *    output.
* @author NIST
* @author Mary Brady
* @author Curt Arnold
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#</a>
* @see <a href="http://lists.w3.org/Archives/Public/www-dom-ts/2001Apr/0020.html">http://lists.w3.org/Archives/Public/www-dom-ts/2001Apr/0020.html</a>
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-135944439">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-135944439</a>
* @see <a href="http://www.w3.org/Bugs/Public/show_bug.cgi?id=249">http://www.w3.org/Bugs/Public/show_bug.cgi?id=249</a>
*/
public final class documentcreateprocessinginstruction : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public documentcreateprocessinginstruction(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
      super(factory);

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
      ProcessingInstruction newPINode;
      String piValue;
      String piName;
      int piType;
      doc = (Document) load("staff", true);
      newPINode = doc.createProcessingInstruction("TESTPI", "This is a new PI node");
      assertNotNull("createdPINotNull", newPINode);
      piName = newPINode.getNodeName();
      assertEquals("name", "TESTPI", piName);
      piValue = newPINode.getNodeValue();
      assertEquals("value", "This is a new PI node", piValue);
      piType = (int) newPINode.getNodeType();
      assertEquals("type", 7, piType);
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/documentcreateprocessinginstruction";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(documentcreateprocessinginstruction.class, args);
   }
}

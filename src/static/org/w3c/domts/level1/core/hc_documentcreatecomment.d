
/*
This Java source file was generated by test-to-java.xsl
and is a derived work from the source document.
The source document contained the following notice:


Copyright (c) 2001 World Wide Web Consortium,
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
 *     The "createComment(data)" method creates a new Comment
 *    node given the specified string. 
 *    Retrieve the entire DOM document and invoke its 
 *    "createComment(data)" method.  It should create a new
 *    Comment node whose "data" is the specified string.
 *    The content, name and type are retrieved and output.
* @author Curt Arnold
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-1334481328">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-1334481328</a>
*/
public final class hc_documentcreatecomment : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public hc_documentcreatecomment(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
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
      Comment newCommentNode;
      String newCommentValue;
      String newCommentName;
      int newCommentType;
      doc = (Document) load("hc_staff", true);
      newCommentNode = doc.createComment("This is a new Comment node");
      newCommentValue = newCommentNode.getNodeValue();
      assertEquals("value", "This is a new Comment node", newCommentValue);
      newCommentName = newCommentNode.getNodeName();
      assertEquals("strong", "#comment", newCommentName);
      newCommentType = (int) newCommentNode.getNodeType();
      assertEquals("type", 8, newCommentType);
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/hc_documentcreatecomment";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(hc_documentcreatecomment.class, args);
   }
}


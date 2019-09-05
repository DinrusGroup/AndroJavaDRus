
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
 *     If the "newChild" is already in the tree, it is first
 *     removed before the new one is appended.
 *     
 *     Retrieve the first child of the second employee and   
 *     append the first child to the end of the list.   After
 *     the "appendChild(newChild)" method is invoked the first 
 *     child should be the one that was second and the last
 *     child should be the one that was first.
* @author NIST
* @author Mary Brady
* @see <a href="http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-184E7107">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-184E7107</a>
*/
public final class nodeappendchildchildexists : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public nodeappendchildchildexists(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
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
      NodeList elementList;
      Node childNode;
      Node newChild;
      Node lchild;
      Node fchild;
      String lchildName;
      String fchildName;
      Node appendedChild;
      String initialName;
      doc = (Document) load("staff", true);
      elementList = doc.getElementsByTagName("employee");
      childNode = elementList.item(1);
      newChild = childNode.getFirstChild();
      initialName = newChild.getNodeName();
      appendedChild = childNode.appendChild(newChild);
      fchild = childNode.getFirstChild();
      fchildName = fchild.getNodeName();
      lchild = childNode.getLastChild();
      lchildName = lchild.getNodeName();
      
      if (equals("employeeId", initialName)) {
          assertEquals("assert1_nowhitespace", "name", fchildName);
      assertEquals("assert2_nowhitespace", "employeeId", lchildName);
      } else {
          assertEquals("assert1", "employeeId", fchildName);
      assertEquals("assert2", "#text", lchildName);
      }
        
    }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level1/core/nodeappendchildchildexists";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(nodeappendchildchildexists.class, args);
   }
}


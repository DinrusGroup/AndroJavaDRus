
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
 *     The "feature" parameter in the
 *    "hasFeature(feature,version)" method is the package name
 *    of the feature.  Legal values are XML and HTML and CORE.
 *    (Test for feature core, lower case)
 *    
 *    Retrieve the entire DOM document and invoke its 
 *    "getImplementation()" method.  This should create a
 *    DOMImplementation object whose "hasFeature(feature,
 *    version)" method is invoked with feature equal to "core".
 *    The method should return a bool "true".
* @author NIST
* @author Mary Brady
* @see <a href="http://www.w3.org/TR/DOM-Level-2-Core/core#ID-5CED94D7">http://www.w3.org/TR/DOM-Level-2-Core/core#ID-5CED94D7</a>
*/
public final class domimplementationfeaturecore : DOMTestCase {

   /**
    * Constructor.
    * @param factory document factory, may not be null
    * @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
    */
   public domimplementationfeaturecore(final DOMTestDocumentBuilderFactory factory)  throws org.w3c.domts.DOMTestIncompatibleException {
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
      DOMImplementation domImpl;
      bool state;
      doc = (Document) load("staff", false);
      domImpl = doc.getImplementation();
      state = domImpl.hasFeature("core", "2.0");
assertTrue("domimplementationFeaturecoreAssert", state);
      }
   /**
    *  Gets URI that identifies the test.
    *  @return uri identifier of test
    */
   public String getTargetURI() {
      return "http://www.w3.org/2001/DOM-Test-Suite/level2/core/domimplementationfeaturecore";
   }
   /**
    * Runs this test from the command line.
    * @param args command line arguments
    */
   public static void main(final String[] args) {
        DOMTestCase.doMain(domimplementationfeaturecore.class, args);
   }
}


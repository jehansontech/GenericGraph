import XCTest

import GraphLibTests

var tests = [XCTestCaseEntry]()
tests += CoderTests.allTests()
tests += GraphTests.allTests()
tests += NeighborhoodTests.allTests()
XCTMain(tests)

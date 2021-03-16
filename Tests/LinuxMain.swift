import XCTest

import GenericGraphTests

var tests = [XCTestCaseEntry]()
tests += BaseGraphTests.allTests()
tests += SubGraphTests.allTests()
tests += TraversalTests.allTests()
tests += CoderTests.allTests()
XCTMain(tests)

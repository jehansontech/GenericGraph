//
//  File.swift
//  
//
//  Created by Jim Hanson on 3/9/21.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BaseGraphTests.allTests),
        testCase(SubGraphTests.allTests),
        testCase(TraversalTests.allTests),
        testCase(CoderTests.allTests)
    ]
}
#endif

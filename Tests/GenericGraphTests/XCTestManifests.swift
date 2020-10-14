import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CoderTests.allTests),
        testCase(GraphTests.allTests),
        testCase(NeighborhoodTests.allTests),
    ]
}
#endif

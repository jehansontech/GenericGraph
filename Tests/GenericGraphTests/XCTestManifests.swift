import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GraphTests.allTests),
        testCase(GraphSpecTests.allTests),
    ]
}
#endif

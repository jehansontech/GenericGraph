import XCTest
@testable import GenericGraph

final class GraphTests: XCTestCase {

    func testGraphCreation() {
        let g = Graph<Any, Any>()
        XCTAssertEqual(g.nodes.count, 0)
        XCTAssertEqual(g.edges.count, 0)
    }

    func testNodeCreation() {
        var g = Graph<Any, Any>()
        let n = g.addNode()
        XCTAssertEqual(g.nodes.count, 1)
        XCTAssertEqual(n.inEdges.count, 0)
        XCTAssertEqual(n.outEdges.count, 0)
    }

    func testSelfEdgeCreation() {
        var g = Graph<Any, Any>()
        let n = g.addNode()
        _ = g.addEdge(n, n)
        XCTAssertEqual(g.nodes.count, 1)
        XCTAssertEqual(g.edges.count, 1)
        XCTAssertEqual(n.inEdges.count, 1)
        XCTAssertEqual(n.outEdges.count, 1)
    }
    
    static var allTests = [
        ("testGraphCreation", testGraphCreation),
        ("testNodeCreation", testNodeCreation),
        ("testSelfEdgeCreation", testSelfEdgeCreation),
    ]
}

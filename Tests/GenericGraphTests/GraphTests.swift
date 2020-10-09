import XCTest
@testable import GenericGraph

final class BaseGraphTests: XCTestCase {

    func testGraphCreation() {
        let g = Graph<Any, Any>()
        XCTAssertEqual(g.nodeCount, 0)
        XCTAssertEqual(g.edgeCount, 0)
    }
    
    func testNodeCreation() {
        let g = Graph<Any, Any>()
        let n = g.addNode()
        XCTAssertEqual(g.nodeCount, 1)
        XCTAssertEqual(n.inDegree, 0)
        XCTAssertEqual(n.outDegree, 0)
    }

    func testSelfEdgeCreation() {
        let g = Graph<Any, Any>()
        let n = g.addNode()
        _ = g.addEdge(n, n)
        XCTAssertEqual(g.nodeCount, 1)
        XCTAssertEqual(g.edgeCount, 1)
        XCTAssertEqual(n.inDegree, 1)
        XCTAssertEqual(n.outDegree, 1)
    }

    func testGraphAssignment() {
        
        let g = Graph<Any, Any>()
        addNode(g)
        XCTAssertEqual(g.nodeCount, 1)
        
        let g2 = g
        addNode(g2)
        XCTAssertEqual(g.nodeCount, 2)
    }
    
    private func addNode(_ graph: Graph<Any, Any>) {
        graph.addNode()
    }
    
    static var allTests = [
        ("testGraphCreation", testGraphCreation),
        ("testNodeCreation", testNodeCreation),
        ("testSelfEdgeCreation", testSelfEdgeCreation),
        ("testGraphAssignment", testGraphAssignment),
    ]
}

import XCTest
@testable import GenericGraph

final class BaseGraphTests: XCTestCase {

    func testGraphCreation() {
        let g = Graph<Any, Any>()
        XCTAssertEqual(g.nodes.count, 0)
        XCTAssertEqual(g.edges.count, 0)
    }
    
    func testNodeCreation() {
        let g = Graph<Any, Any>()
        let n = g.addNode()
        XCTAssertEqual(g.nodes.count, 1)
        XCTAssertEqual(n.inEdges.count, 0)
        XCTAssertEqual(n.outEdges.count, 0)
    }

    func testSelfEdgeCreation() {
        let g = Graph<Any, Any>()
        let n = g.addNode()
        _ = g.addEdge(n, n)
        XCTAssertEqual(g.nodes.count, 1)
        XCTAssertEqual(g.edges.count, 1)
        XCTAssertEqual(n.inEdges.count, 1)
        XCTAssertEqual(n.outEdges.count, 1)
    }

    func testGraphAssignment() {
        
        let g = Graph<Any, Any>()
        addNode(g)
        XCTAssertEqual(g.nodes.count, 1)
        
        let g2 = g
        addNode(g2)
        XCTAssertEqual(g.nodes.count, 2)
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

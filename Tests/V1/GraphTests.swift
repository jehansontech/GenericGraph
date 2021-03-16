//
//  GraphTests.swift
//
//
//  Created by Jim Hanson on 10/8/20.
//

import XCTest
@testable import GenericGraph

final class GraphTests: XCTestCase {

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

    func testSelfEdgeCreation() throws {
        let g = Graph<Any, Any>()
        let n = g.addNode()
        try g.addEdge(n.id, n.id)
        XCTAssertEqual(g.nodeCount, 1)
        XCTAssertEqual(g.edgeCount, 1)
        XCTAssertEqual(n.inDegree, 1)
        XCTAssertEqual(n.outDegree, 1)
    }

    static var allTests = [
        ("testGraphCreation", testGraphCreation),
        ("testNodeCreation", testNodeCreation),
        ("testSelfEdgeCreation", testSelfEdgeCreation),
    ]
}

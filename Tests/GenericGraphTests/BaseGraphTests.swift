//
//  BaseGraphTests.swift
//  
//
//  Created by Jim Hanson on 3/7/21.
//

import XCTest
@testable import GenericGraph

final class BaseGraphTests: XCTestCase {

    func test_nodeCreation() throws {
        let node0 = BaseGraphNode<String, String>(0, "nodeValue0")
        
        XCTAssertEqual(node0.id, 0)
        XCTAssertEqual(node0.value, "nodeValue0")
        XCTAssertEqual(node0.inEdges.count, 0)
        XCTAssertEqual(node0.outEdges.count, 0)
    }

    func test_edgeCreation() throws {
        let node0 = BaseGraphNode<String, String>(0, "nodeValue0")
        let node1 = BaseGraphNode<String, String>(1, "nodeValue1")
        let edge0 = BaseGraphEdge<String, String>(0, "edgeValue0", node0, node1)
        
        XCTAssertEqual(edge0.id, 0)
        XCTAssertEqual(edge0.value, "edgeValue0")
        XCTAssertEqual(node0.id, edge0.source.id)
        XCTAssertEqual(node1.id, edge0.target.id)
    }
    
    func test_graphCreation() throws {
        let graph = BaseGraph<String, String>();
        let node0 = graph.addNode("nodeValue0");
        let node1 = graph.addNode("nodeValue1");
        let edge0 = try graph.addEdge(node0.id, node1.id, "edgeValue0")
        let edge1 = try graph.addEdge(node1.id, node0.id, "edgeValue1")

        XCTAssertNotEqual(node0.id, node1.id)
        XCTAssertEqual(node0.outDegree, 1)
        XCTAssertEqual(node0.inDegree, 1)
        XCTAssertEqual(node0.outEdges[edge0.id]?.id, edge0.id)
        XCTAssertEqual(node0.inEdges[edge1.id]?.id, edge1.id)
        XCTAssertNotNil(node0.outEdges.randomElement())
        XCTAssertNotNil(node0.inEdges.randomElement())
        XCTAssertEqual(node1.outDegree, 1)
        XCTAssertEqual(node1.inDegree, 1)
        XCTAssertEqual(node1.outEdges[edge1.id]?.id, edge1.id)
        XCTAssertEqual(node1.inEdges[edge0.id]?.id, edge0.id)

        XCTAssertNotEqual(edge0.id, edge1.id)
        XCTAssertEqual(edge0.source.id, node0.id)
        XCTAssertEqual(edge0.target.id, node1.id)
        XCTAssertEqual(edge1.source.id, node1.id)
        XCTAssertEqual(edge1.target.id, node0.id)

        XCTAssertEqual(graph.nodes.count, 2)
        XCTAssertEqual(graph.nodes[node0.id]?.id, node0.id)
        XCTAssertEqual(graph.nodes[node1.id]?.id, node1.id)
        XCTAssertNotNil(graph.nodes.randomElement())

        XCTAssertEqual(graph.edges.count, 2)
        XCTAssertEqual(graph.edges[edge0.id]?.id, edge0.id)
        XCTAssertEqual(graph.edges[edge1.id]?.id, edge1.id)
        XCTAssertNotNil(graph.edges.randomElement())
        
    }
    
    static var allTests = [
        ("test_nodeCreation", test_nodeCreation),
        ("test_edgeCreation", test_edgeCreation),
        ("test_graphCreation", test_graphCreation)
    ]
}

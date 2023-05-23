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
        let node0 = BaseGraphNode<String, String>(0, "node0")
        
        XCTAssertEqual(node0.nodeNumber, 0)
        XCTAssertEqual(node0.value, "node0")
        XCTAssertEqual(node0.inEdges.count, 0)
        XCTAssertEqual(node0.outEdges.count, 0)
    }

    func test_edgeCreation() throws {
        let node0 = BaseGraphNode<String, String>(0, "node0")
        let node1 = BaseGraphNode<String, String>(1, "node1")
        let edge0 = BaseGraphEdge<String, String>(0, "edge0", node0, node1)
        
        XCTAssertEqual(edge0.edgeNumber, 0)
        XCTAssertEqual(edge0.value, "edge0")
        XCTAssertEqual(node0.nodeNumber, edge0.source.nodeNumber)
        XCTAssertEqual(node1.nodeNumber, edge0.target.nodeNumber)
    }
    
    func test_graphCreation() throws {
        let graph = BaseGraph<String, String>();
        let node0 = graph.addNode("node0");
        let node1 = graph.addNode("node1");
        let edge0 = try graph.addEdge(node0.nodeNumber, node1.nodeNumber, "edge0")
        let edge1 = try graph.addEdge(node1.nodeNumber, node0.nodeNumber, "edge1")

        XCTAssertNotEqual(node0.nodeNumber, node1.nodeNumber)
        XCTAssertEqual(node0.outDegree, 1)
        XCTAssertEqual(node0.inDegree, 1)
        XCTAssertEqual(node0.outEdges[edge0.edgeNumber]?.edgeNumber, edge0.edgeNumber)
        XCTAssertEqual(node0.inEdges[edge1.edgeNumber]?.edgeNumber, edge1.edgeNumber)
        XCTAssertNotNil(node0.outEdges.randomElement())
        XCTAssertNotNil(node0.inEdges.randomElement())
        XCTAssertEqual(node1.outDegree, 1)
        XCTAssertEqual(node1.inDegree, 1)
        XCTAssertEqual(node1.outEdges[edge1.edgeNumber]?.edgeNumber, edge1.edgeNumber)
        XCTAssertEqual(node1.inEdges[edge0.edgeNumber]?.edgeNumber, edge0.edgeNumber)

        XCTAssertNotEqual(edge0.edgeNumber, edge1.edgeNumber)
        XCTAssertEqual(edge0.source.nodeNumber, node0.nodeNumber)
        XCTAssertEqual(edge0.target.nodeNumber, node1.nodeNumber)
        XCTAssertEqual(edge1.source.nodeNumber, node1.nodeNumber)
        XCTAssertEqual(edge1.target.nodeNumber, node0.nodeNumber)

        XCTAssertEqual(graph.nodes.count, 2)
        XCTAssertEqual(graph.nodes[node0.nodeNumber]?.nodeNumber, node0.nodeNumber)
        XCTAssertEqual(graph.nodes[node1.nodeNumber]?.nodeNumber, node1.nodeNumber)
        XCTAssertNotNil(graph.nodes.randomElement())

        XCTAssertEqual(graph.edges.count, 2)
        XCTAssertEqual(graph.edges[edge0.edgeNumber]?.edgeNumber, edge0.edgeNumber)
        XCTAssertEqual(graph.edges[edge1.edgeNumber]?.edgeNumber, edge1.edgeNumber)
        XCTAssertNotNil(graph.edges.randomElement())
    }

    func test_nodeDeletion() throws {
        let graph = BaseGraph<String, String>();
        let node0 = graph.addNode("node0");
        let node1 = graph.addNode("node1");
        try graph.addEdge(node0.nodeNumber, node1.nodeNumber, "edge0")
        try graph.addEdge(node1.nodeNumber, node0.nodeNumber, "edge1")

        graph.removeNode(node0.nodeNumber)

        XCTAssertEqual(graph.nodes.count, 1)
        XCTAssertEqual(graph.nodes[node1.nodeNumber]?.nodeNumber, node1.nodeNumber)
        XCTAssertEqual(graph.edges.count, 0)
    }

    func test_edgeDeletion() throws {
        let graph = BaseGraph<String, String>();
        let node0 = graph.addNode("node0");
        let node1 = graph.addNode("node1");
        let edge0 = try graph.addEdge(node0.nodeNumber, node1.nodeNumber, "edge0")
        let edge1 = try graph.addEdge(node1.nodeNumber, node0.nodeNumber, "edge1")

        graph.removeEdge(edge0.edgeNumber)

        XCTAssertEqual(graph.edges.count, 1)
        XCTAssertEqual(graph.edges[edge1.edgeNumber]?.edgeNumber, edge1.edgeNumber)

        XCTAssertEqual(node0.outDegree, 0)
        XCTAssertEqual(node0.inDegree, 1)
        XCTAssertEqual(node0.inEdges[edge1.edgeNumber]?.edgeNumber, edge1.edgeNumber)
        XCTAssertEqual(node1.outDegree, 1)
        XCTAssertEqual(node1.inDegree, 0)
        XCTAssertEqual(node1.outEdges[edge1.edgeNumber]?.edgeNumber, edge1.edgeNumber)
    }

    static var allTests = [
        ("test_nodeCreation", test_nodeCreation),
        ("test_edgeCreation", test_edgeCreation),
        ("test_graphCreation", test_graphCreation)
    ]
}

//
//  SubGraphTests.swift
//
//
//  Created by Jim Hanson on 3/7/21.
//

import XCTest
@testable import GenericGraph

final class SubGraphTests: XCTestCase {
    
    func test_subgraphCreation() throws {

        let graph = BaseGraph<String, String>()
        let node0 = graph.addNode("node0")
        let node1 = graph.addNode("node1")
        let node2 = graph.addNode("node2")
        try graph.addEdge(node0.id, node1.id, "edge01")
        try graph.addEdge(node0.id, node2.id, "edge02")
        try graph.addEdge(node1.id, node0.id, "edge10")
        try graph.addEdge(node1.id, node2.id, "edge12")
        try graph.addEdge(node2.id, node0.id, "edge20")
        try graph.addEdge(node2.id, node1.id, "edge21")

        var nodeIDs = Set<NodeID>()
        nodeIDs.insert(node0.id)
        nodeIDs.insert(node1.id)
        let subgraph = graph.subgraph(nodeIDs)

        XCTAssertEqual(2, subgraph.nodes.count)
        XCTAssertEqual(2, subgraph.edges.count)
    }

    func test_subgraphNodeDeletion() throws {

        let graph = BaseGraph<String, String>()
        let node0 = graph.addNode("node0")
        let node1 = graph.addNode("node1")
        let node2 = graph.addNode("node2")
        try graph.addEdge(node0.id, node1.id, "edge01")
        try graph.addEdge(node0.id, node2.id, "edge02")
        try graph.addEdge(node1.id, node0.id, "edge10")
        try graph.addEdge(node1.id, node2.id, "edge12")
        try graph.addEdge(node2.id, node0.id, "edge20")
        try graph.addEdge(node2.id, node1.id, "edge21")

        var nodeIDs = Set<NodeID>()
        nodeIDs.insert(node0.id)
        nodeIDs.insert(node1.id)
        nodeIDs.insert(node2.id)
        let subgraph = graph.subgraph(nodeIDs)

        XCTAssertEqual(graph.nodes.count, subgraph.nodes.count)
        XCTAssertEqual(graph.edges.count, subgraph.edges.count)

        subgraph.removeNode(id: node2.id)

        XCTAssertEqual(3, graph.nodes.count)
        XCTAssertEqual(6, graph.edges.count)
        XCTAssertEqual(2, subgraph.edges.count)
        XCTAssertEqual(2, subgraph.edges.count)
    }

    func test_subgraphInheritsBaseEdgeDeletion() throws {

        let graph = BaseGraph<String, String>()
        let node0 = graph.addNode("node0")
        let node1 = graph.addNode("node1")
        let node2 = graph.addNode("node2")
        let edge01 = try graph.addEdge(node0.id, node1.id, "edge01")
        try graph.addEdge(node0.id, node2.id, "edge02")
        try graph.addEdge(node1.id, node0.id, "edge10")
        try graph.addEdge(node1.id, node2.id, "edge12")
        try graph.addEdge(node2.id, node0.id, "edge20")
        try graph.addEdge(node2.id, node1.id, "edge21")

        var nodeIDs = Set<NodeID>()
        nodeIDs.insert(node0.id)
        nodeIDs.insert(node1.id)
        nodeIDs.insert(node2.id)
        let subgraph = graph.subgraph(nodeIDs)

        graph.removeEdge(edge01.id)

        XCTAssertEqual(5, subgraph.edges.count)
    }


    static var allTests = [
        ("test_subgraphCreation", test_subgraphCreation),
        ("test_subgraphNodeDeletion", test_subgraphNodeDeletion)
    ]
}

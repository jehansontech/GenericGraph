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
        try graph.addEdge(node0.nodeNumber, node1.nodeNumber, "edge01")
        try graph.addEdge(node0.nodeNumber, node2.nodeNumber, "edge02")
        try graph.addEdge(node1.nodeNumber, node0.nodeNumber, "edge10")
        try graph.addEdge(node1.nodeNumber, node2.nodeNumber, "edge12")
        try graph.addEdge(node2.nodeNumber, node0.nodeNumber, "edge20")
        try graph.addEdge(node2.nodeNumber, node1.nodeNumber, "edge21")

        var nodeNumbers = Set<Int>()
        nodeNumbers.insert(node0.nodeNumber)
        nodeNumbers.insert(node1.nodeNumber)
        let subgraph = graph.subgraph(nodeNumbers)

        XCTAssertEqual(2, subgraph.nodes.count)
        XCTAssertEqual(2, subgraph.edges.count)
    }

    func test_subgraphNodeDeletion() throws {

        let graph = BaseGraph<String, String>()
        let node0 = graph.addNode("node0")
        let node1 = graph.addNode("node1")
        let node2 = graph.addNode("node2")
        try graph.addEdge(node0.nodeNumber, node1.nodeNumber, "edge01")
        try graph.addEdge(node0.nodeNumber, node2.nodeNumber, "edge02")
        try graph.addEdge(node1.nodeNumber, node0.nodeNumber, "edge10")
        try graph.addEdge(node1.nodeNumber, node2.nodeNumber, "edge12")
        try graph.addEdge(node2.nodeNumber, node0.nodeNumber, "edge20")
        try graph.addEdge(node2.nodeNumber, node1.nodeNumber, "edge21")

        var nodeNumbers = Set<Int>()
        nodeNumbers.insert(node0.nodeNumber)
        nodeNumbers.insert(node1.nodeNumber)
        nodeNumbers.insert(node2.nodeNumber)
        let subgraph = graph.subgraph(nodeNumbers)

        XCTAssertEqual(graph.nodes.count, subgraph.nodes.count)
        XCTAssertEqual(graph.edges.count, subgraph.edges.count)

        subgraph.removeNode(nodeNumber: node2.nodeNumber)

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
        let edge01 = try graph.addEdge(node0.nodeNumber, node1.nodeNumber, "edge01")
        try graph.addEdge(node0.nodeNumber, node2.nodeNumber, "edge02")
        try graph.addEdge(node1.nodeNumber, node0.nodeNumber, "edge10")
        try graph.addEdge(node1.nodeNumber, node2.nodeNumber, "edge12")
        try graph.addEdge(node2.nodeNumber, node0.nodeNumber, "edge20")
        try graph.addEdge(node2.nodeNumber, node1.nodeNumber, "edge21")

        var nodeNumbers = Set<Int>()
        nodeNumbers.insert(node0.nodeNumber)
        nodeNumbers.insert(node1.nodeNumber)
        nodeNumbers.insert(node2.nodeNumber)
        let subgraph = graph.subgraph(nodeNumbers)

        graph.removeEdge(edge01.edgeNumber)

        XCTAssertEqual(5, subgraph.edges.count)
    }


    static var allTests = [
        ("test_subgraphCreation", test_subgraphCreation),
        ("test_subgraphNodeDeletion", test_subgraphNodeDeletion)
    ]
}

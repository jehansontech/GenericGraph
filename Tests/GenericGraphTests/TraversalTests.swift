//
//  File.swift
//  
//
//  Created by Jim Hanson on 3/9/21.
//

import Foundation

import XCTest
@testable import GenericGraph

final class TraversalTests: XCTestCase {

    func test_neighborhood() throws {
        let graph = BaseGraph<String, String>()
        let node1 = graph.addNode("n1")
        let node2 = graph.addNode("n2")
        let node3 = graph.addNode("n3")
        let node4 = graph.addNode("n4")
        try graph.addEdge(node1.id, node2.id, "e12")
        try graph.addEdge(node1.id, node3.id, "e13")
        try graph.addEdge(node1.id, node4.id, "e14")
        try graph.addEdge(node2.id, node3.id, "e23")
        try graph.addEdge(node2.id, node4.id, "e24")
        try graph.addEdge(node3.id, node4.id, "e34")

        var nodeIds = [NodeID]()
        for path in node1.neighborhood(.max, .forward) {
            XCTAssertTrue(path.length <= 1)
            nodeIds.append(path.destination.id)
        }
        XCTAssertEqual(4, nodeIds.count)
        XCTAssertEqual(nodeIds[0], node1.id)
        XCTAssertTrue(nodeIds.contains(node2.id))
        XCTAssertTrue(nodeIds.contains(node3.id))
        XCTAssertTrue(nodeIds.contains(node4.id))
    }


    func test_components() throws {
        let graph = BaseGraph<String, String>()
        
        let A0 = graph.addNode("A0")
        let A1 = graph.addNode("A1")
        let A2 = graph.addNode("A2")
        try graph.addEdge(A0.id, A1.id, "a01")
        try graph.addEdge(A1.id, A2.id, "a12")
        try graph.addEdge(A2.id, A0.id, "a20")
        
        let B0 = graph.addNode("B0")
        let B1 = graph.addNode("B1")
        try graph.addEdge(B0.id, B1.id, "b01")

        graph.addNode("C0")

        let components = graph.components()
        XCTAssertEqual(3, components.count)
    }
    
    static var allTests = [
        ("test_neighborhood", test_neighborhood),
        ("test_componenets", test_components)
    ]

}

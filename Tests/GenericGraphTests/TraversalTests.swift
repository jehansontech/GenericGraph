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
        try graph.addEdge(node1.nodeNumber, node2.nodeNumber, "e12")
        try graph.addEdge(node1.nodeNumber, node3.nodeNumber, "e13")
        try graph.addEdge(node1.nodeNumber, node4.nodeNumber, "e14")
        try graph.addEdge(node2.nodeNumber, node3.nodeNumber, "e23")
        try graph.addEdge(node2.nodeNumber, node4.nodeNumber, "e24")
        try graph.addEdge(node3.nodeNumber, node4.nodeNumber, "e34")

        var nodeNumbers = [Int]()
        for path in node1.neighborhood(.max, .forward) {
            XCTAssertTrue(path.length <= 1)
            nodeNumbers.append(path.destination.nodeNumber)
        }
        XCTAssertEqual(4, nodeNumbers.count)
        XCTAssertEqual(nodeNumbers[0], node1.nodeNumber)
        XCTAssertTrue(nodeNumbers.contains(node2.nodeNumber))
        XCTAssertTrue(nodeNumbers.contains(node3.nodeNumber))
        XCTAssertTrue(nodeNumbers.contains(node4.nodeNumber))
    }


    func test_components() throws {
        let graph = BaseGraph<String, String>()
        
        let A0 = graph.addNode("A0")
        let A1 = graph.addNode("A1")
        let A2 = graph.addNode("A2")
        try graph.addEdge(A0.nodeNumber, A1.nodeNumber, "a01")
        try graph.addEdge(A1.nodeNumber, A2.nodeNumber, "a12")
        try graph.addEdge(A2.nodeNumber, A0.nodeNumber, "a20")
        
        let B0 = graph.addNode("B0")
        let B1 = graph.addNode("B1")
        try graph.addEdge(B0.nodeNumber, B1.nodeNumber, "b01")

        graph.addNode("C0")

        let components = graph.components()
        XCTAssertEqual(3, components.count)
    }
    
    static var allTests = [
        ("test_neighborhood", test_neighborhood),
        ("test_componenets", test_components)
    ]

}

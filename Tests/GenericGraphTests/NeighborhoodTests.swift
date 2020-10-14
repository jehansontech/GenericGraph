//
//  NeighborhoodTests.swift
//  
//
//  Created by Jim Hanson on 10/14/20.
//

import Foundation

import XCTest
@testable import GenericGraph

final class NeighborhoodTests: XCTestCase {

    func testNeighborhood0() throws {
        let g = Graph<Any, Any>()
        let n0 = g.addNode()
        let n1 = g.addNode()
        try g.addEdge(n0.id, n1.id)
        try g.addEdge(n1.id, n0.id)
        
        let nbhd = n0.neighborhood(radius: 0)
        var nodeCount: Int = 0
        for walk in nbhd {
            nodeCount += 1
            XCTAssertEqual(walk.destination.id, n0.id)
        }
        XCTAssertEqual(nodeCount, 1)
    }
    
    func testNeighborhood1() throws {
        let g = Graph<Any, Any>()
        let n0 = g.addNode()
        let n1 = g.addNode()
        let n2 = g.addNode()
        let n10 = g.addNode()
        
        try g.addEdge(n0.id, n1.id)
        try g.addEdge(n1.id, n2.id)
        try g.addEdge(n2.id, n0.id)
        try g.addEdge(n1.id, n10.id)
        
        let nbhd = n0.neighborhood(radius: 1)
        var destinationIDs = Set<NodeID>()
        for walk in nbhd {
            destinationIDs.insert(walk.destination.id)
        }
        XCTAssertEqual(destinationIDs.count, 3)
        XCTAssert(destinationIDs.contains(n0.id))
        XCTAssert(destinationIDs.contains(n1.id))
        XCTAssert(destinationIDs.contains(n2.id))
    }
    
    static var allTests = [
        ("testNeighborhood0", testNeighborhood0),
        ("testNeighborhood1", testNeighborhood1),
    ]
}

//
//  SubGraphTests.swift
//
//
//  Created by Jim Hanson on 3/7/21.
//

import XCTest
@testable import GenericGraph

final class SubGraphTests: XCTestCase {
    
    private var nodeNumber: Int = 1
    
    private var edgeNumber: Int = 1
    
    func nodeValueFactory() -> String {
        let value = "node\(nodeNumber)"
        nodeNumber += 1
        return value
    }
    
    func edgeValueFactory() -> String {
        let value = "edge\(edgeNumber)"
        edgeNumber += 1
        return value
    }
    
    func test0() throws {
        
        let baseNodeCount = 4
        let baseGraph = try BaseGraphFactory.completeGraph(baseNodeCount, nodeValueFactory, edgeValueFactory, allowSelfLoops: false)
        let subgraph = SubGraph<String, String>(baseGraph)
        
        var baseNodeIter = baseGraph.nodes.makeIterator()
        for _ in 0..<(baseNodeCount/2) {
            if let subNodeId = baseNodeIter.next()?.id {
                try subgraph.addNode(id: subNodeId)
            }
            
        }

        let printer = GraphPrinter()
        printer.printString("subgraph", 0)
        printer.printGraph(subgraph, 1)
    }
    
    func test1() throws {
        let printer = GraphPrinter()
        let baseGraph = try BaseGraphFactory.makeBaseGraph0()
        
        var nodeIDs = Set<NodeID>()
        var lastNodeID: NodeID = 0
        for baseNode in baseGraph.nodes {
            nodeIDs.insert(baseNode.id)
            lastNodeID = baseNode.id
        }
        nodeIDs.remove(lastNodeID)

        let graph = baseGraph.subgraph(nodeIDs)
        printer.printString("subgraph", 0)
        printer.printGraph(graph, 1)
    }
        

    static var allTests = [
        ("test0", test0),
        ("test1", test1)
    ]
}

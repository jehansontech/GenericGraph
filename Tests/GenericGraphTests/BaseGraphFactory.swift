//
//  File.swift
//  
//
//  Created by Jim Hanson on 3/9/21.
//

import Foundation
@testable import GenericGraph

public struct BaseGraphFactory {
    
    public static func completeGraph<N, E>(_ nodeCount: Int,
                                    _ nodeValueFactory: () -> N?,
                                    _ edgeValueFactory: () -> E?,
                                    allowSelfLoops: Bool) throws -> BaseGraph<N, E> {
        let graph = BaseGraph<N, E>()
        for _ in 0..<nodeCount {
            graph.addNode(nodeValueFactory())
        }
        for sourceNode in graph.nodes {
            for targetNode in graph.nodes {
                if allowSelfLoops || sourceNode.id != targetNode.id {
                    try graph.addEdge(sourceNode.id, targetNode.id, edgeValueFactory())
                }
            }
        }
        return graph
    }

    public static func makeBaseGraph0() throws -> BaseGraph<String, String> {
        let graph = BaseGraph<String, String>()
        let node0 = graph.addNode("node0")
        let node1 = graph.addNode("node1")
        let node2 = graph.addNode("node2")
        try graph.addEdge(node0.id, node0.id, "edge00")
        try graph.addEdge(node0.id, node1.id, "edge01")
        try graph.addEdge(node0.id, node2.id, "edge02")
        try graph.addEdge(node1.id, node0.id, "edge10")
        try graph.addEdge(node1.id, node1.id, "edge11")
        try graph.addEdge(node1.id, node2.id, "edge12")
        try graph.addEdge(node2.id, node0.id, "edge20")
        try graph.addEdge(node2.id, node1.id, "edge21")
        try graph.addEdge(node2.id, node2.id, "edge22")
        return graph
    }
}

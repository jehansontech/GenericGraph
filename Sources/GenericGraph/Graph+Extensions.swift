//
//  Graph+Extensions.swift
//  
//
//  Created by Jim Hanson on 10/9/20.
//

import Foundation

extension Edge: CustomStringConvertible {
  
    public var description: String {
        return "Edge \(id)"
    }
}

extension Node: CustomStringConvertible {
    
    public var description: String {
        return "Node \(id)"
    }
    
    public var degree: Int {
        return inDegree + outDegree
    }
    
    public func neighborhood(radius: Int = 1) -> Neighborhood<N, E> {
        return Neighborhood<N, E>(self, radius: radius)
    }
}

extension Graph {
    
    public func randomNode() -> Node<N, E>? {
        return _nodes.randomElement()?.value
    }
    
    public func randomEdge() -> Edge<N, E>? {
        return _edges.randomElement()?.value
    }
    
    public func calculateDiameter() -> Int {
        var visited = Set<NodeID>()
        var diameter: Int = 0
        for node in nodes {
            if (visited.contains(node.id)) {
                continue
            }
            for walk in node.neighborhood(radius: nodeCount) {
                visited.insert(walk.destination.id)
                if walk.length > diameter {
                    diameter = walk.length
                }
            }
        }
        return diameter
    }
}

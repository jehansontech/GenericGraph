//
//  File.swift
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

    public func neighbors<N, E>(ofNode node: Node<N, E>) -> [Node<N, E>] {
        var nbrs = [Node<N, E>]()
        for edge in node.inEdges {
            nbrs.append(edge.origin)
        }
        for edge in node.outEdges {
            nbrs.append(edge.destination)
        }
        return nbrs;
    }
    
}

extension Graph {
    
    // TODO
    // diameter
    
    // TODO
    // stronglyConnectedComponents
}

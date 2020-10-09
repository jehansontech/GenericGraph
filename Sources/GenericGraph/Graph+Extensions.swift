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

    public func neighborhood(radius: Int) -> [NodeID: Node<N, E>] {
        var nbhd = [NodeID: Node<N, E>]()
    
        if (radius >= 0) {
            nbhd[self.id] = self
        }
        
        if (radius >= 1) {
            nbhd.merge(neighbors(), uniquingKeysWith: { x, y in return x })
        }
        
        // TODO
        
        return nbhd
    }
    
    public func neighbors() -> [NodeID: Node<N, E>] {
        var nbrs = [NodeID: Node<N, E>]()
        for edge in self.inEdges {
            nbrs[edge.origin.id] = edge.origin
        }
        for edge in self.outEdges {
            nbrs[edge.destination.id] = edge.destination
        }
        return nbrs
    }
}

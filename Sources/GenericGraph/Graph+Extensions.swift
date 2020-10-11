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
}

extension Graph {
    
    public func randomNode() -> Node<N, E>? {
        return _nodes.randomElement()?.value
    }
    
    public func randomEdge() -> Edge<N, E>? {
        return _edges.randomElement()?.value
    }
    

}

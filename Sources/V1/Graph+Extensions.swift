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

extension EdgeSequence {
    
    public func randomElement() -> Edge<N,E>? {
        return _edges.randomElement()?.value
    }
}

extension Node: CustomStringConvertible {
    
    public var description: String {
        return "Node \(id)"
    }
    
    public var degree: Int {
        return inDegree + outDegree
    }
    
    public func randomStep(inDirection dir: StepDirection) -> Step<N, E>? {
        switch dir {
        case .downstream:
            if let edge = _outEdges.randomElement()?.value {
                return Step<N, E>(edge, dir)
            }
        case .upstream:
            if let edge = _inEdges.randomElement()?.value {
                return Step<N, E>(edge, dir)
            }
        }
        return nil
    }
    
    public func randomStep() -> Step<N, E>? {
        if inDegree <= 0 {
            if let edge = _outEdges.randomElement()?.value {
                return Step<N, E>(edge, .downstream)
            }
            else {
                return nil
            }
        }
        
        if outDegree <= 0 {
            let edge = _inEdges.randomElement()!.value
            return Step<N, E>(edge, .upstream)
        }
        
        let outEdgeBias: Float = Float(outDegree)/Float(degree)
        if (Float.random(in: 0..<1) < outEdgeBias) {
            return Step<N, E>(_outEdges.randomElement()!.value, .downstream)
        }
        else {
            return Step<N, E>(_inEdges.randomElement()!.value, .upstream)
        }
    }
    
    public func steps(inDirection dir: StepDirection? = nil) -> StepSequence<N, E> {
        return StepSequence(self, dir)
    }
    
    public func neighborhood(radius: Int = 1) -> Neighborhood<N, E> {
        return Neighborhood<N, E>(self, radius: radius)
    }
}

extension NodeSequence {
    
    public func randomElement() -> Node<N,E>? {
        return _nodes.randomElement()?.value
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

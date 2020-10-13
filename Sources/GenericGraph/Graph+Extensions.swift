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
}

public enum StepDirection {
    case downstream
    case upstream
}

public struct Step<N, E> {
    
    public var origin: Node<N, E> {
        switch direction {
            case .downstream:
                return edge.origin
            case .upstream:
                return edge.destination
        }
    }
    
    public var destination: Node<N, E> {
        switch direction {
            case .downstream:
                return edge.destination
            case .upstream:
                return edge.origin
        }
    }
    
    public let edge: Edge<N, E>
    
    public let direction: StepDirection
    
    internal init(_ edge: Edge<N, E>, _ direction: StepDirection) {
        self.edge = edge
        self.direction = direction
    }
}

public struct Walk<N, E> {
    
    public let origin: Node<N, E>
    public let path: [Step<N, E>]
    
    public var length: Int {
        return path.count
    }
    
    public var destination: Node<N, E> {
        if let lastStep = path.last {
            return lastStep.destination
        }
        else {
            return origin
        }
    }
    
    internal init(node: Node<N,E>) {
        self.origin = node
        self.path = [Step<N, E>]()
    }
    
    internal init(origin: Node<N, E>, step: Step<N, E>) {
        self.origin = origin
        self.path = [step]
    }

    internal init(walk: Walk<N, E>, step: Step<N, E>) {
        self.origin = walk.origin
        var newPath = walk.path
        newPath.append(step)
        self.path = newPath
    }
}


public struct Neighborhood<N, E>: Sequence, IteratorProtocol {
    public typealias Element = Walk<N, E>
    
    class WalkQueueElem {
        
        let value: Walk<N, E>
        
        var next: WalkQueueElem?
        
        init(_ value: Walk<N, E>) {
            self.value = value
            self.next = nil
        }
    }

    struct WalkQueue {
        
        var first: WalkQueueElem? = nil
        
        var last: WalkQueueElem? = nil
        
        var isEmpty: Bool {
            return last == nil
        }
        
        init(_ walk: Walk<N, E>) {
            first = WalkQueueElem(walk)
            last = first
        }
        
        mutating func removeFirst() -> Walk<N, E>? {
            if let oldFirst = first {
                self.first = oldFirst.next
                if self.first == nil {
                    self.last = nil
                }
                return oldFirst.value
            }
            else {
                return nil
            }
        }
        
        mutating func addLast(_ walk: Walk<N, E>) {
            if let oldLast = last {
                oldLast.next = WalkQueueElem(walk)
                last = oldLast.next
            }
            else {
                last = WalkQueueElem(walk)
                first = last
            }
        }
    }
    
    public let origin: Node<N, E>
    
    public let radius: Int
    
    /// Queue of walks whose we know about but that have not yet been returned by next()
    private var unvisited: WalkQueue
    
    /// Set of destination IDs for the walks we have returned
    private var visited = Set<NodeID>()
    
   public init(_ origin: Node<N, E>, radius: Int = 1) {
        self.origin = origin
        self.radius = radius
        self.unvisited = WalkQueue(Walk<N, E>(node: origin))
    }
    
    public mutating func next() -> Element? {
        let nextElement = unvisited.removeFirst()
        if let walk = nextElement {
            visited.insert(walk.destination.id)
            if walk.length < radius {
                for inEdge in walk.destination.inEdges {
                    if !visited.contains(inEdge.origin.id) {
                        unvisited.addLast(Walk<N, E>(walk: walk, step: Step<N, E>(inEdge, .upstream)))
                    }
                }
                for outEdge in walk.destination.outEdges {
                    if !visited.contains(outEdge.destination.id) {
                        unvisited.addLast(Walk<N, E>(walk: walk, step: Step<N, E>(outEdge, .downstream)))
                    }
                }
            }
        }
        return nextElement
    }
    
}


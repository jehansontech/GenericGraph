//
//  Neighborhood.swift
//  
//
//  Created by Jim Hanson on 10/14/20.
//

import Foundation


public enum StepDirection: CaseIterable {
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

public struct StepSequence<N, E>: Sequence, IteratorProtocol {
    
    public typealias Element = Step<N, E>
    
    var inEdgeIterator: EdgeSequence<N,E>?
    var outEdgeIterator: EdgeSequence<N, E>?
    
    init(_ node: Node<N, E>, _ stepDirection: StepDirection? = nil) {
        if let dir =  stepDirection {
            switch dir {
            case .upstream:
                inEdgeIterator = node.inEdges
                outEdgeIterator = nil
            case .downstream:
                inEdgeIterator = nil
                outEdgeIterator = node.outEdges
            }
        }
        else {
            inEdgeIterator = node.inEdges
            outEdgeIterator = node.outEdges
        }
    }
    
    public mutating func next() -> Element? {
        if var inIter = inEdgeIterator,
           let inEdge = inIter.next() {
            return Step<N, E>(inEdge, .upstream)
        }
        else if var outIter = outEdgeIterator,
                let outEdge = outIter.next() {
            return Step<N, E>(outEdge, .downstream)
        }
        else {
            return nil
        }
    }
}


/// a sequence of walks all starting at a given node, all having length less than a given value, each ending on a different node,
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
    
    /// Set of destination IDs for the walks that have been returned by next()
    public var visited = Set<NodeID>()
    
    /// Queue of walks we have constructed but that have not yet been returned by next()
    private var _unvisited: WalkQueue
    
    public init(_ origin: Node<N, E>, radius: Int = 1) {
        self.origin = origin
        self.radius = radius
        self._unvisited = WalkQueue(Walk<N, E>(node: origin))
    }
    
    public mutating func next() -> Element? {
        let nextElement = _unvisited.removeFirst()
        if let walk = nextElement {
            visited.insert(walk.destination.id)
            if walk.length < radius {
                for inEdge in walk.destination.inEdges {
                    if !visited.contains(inEdge.origin.id) {
                        _unvisited.addLast(Walk<N, E>(walk: walk, step: Step<N, E>(inEdge, .upstream)))
                    }
                }
                for outEdge in walk.destination.outEdges {
                    if !visited.contains(outEdge.destination.id) {
                        _unvisited.addLast(Walk<N, E>(walk: walk, step: Step<N, E>(outEdge, .downstream)))
                    }
                }
            }
        }
        return nextElement
    }
}


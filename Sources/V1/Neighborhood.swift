//
//  Neighborhood.swift
//  
//
//  Created by Jim Hanson on 10/14/20.
//

import Foundation


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


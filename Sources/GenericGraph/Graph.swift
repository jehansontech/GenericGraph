//
//  Graph.swift
//  
//
//  Created by Jim Hanson on 10/8/20.
//

import Foundation

public typealias NodeID = Int

public typealias EdgeID = Int

public enum GraphError: Error {
    case noSuchNode(id: NodeID)
    case noSuchEdge(id: EdgeID)
}

public class Node<N, E> {
    
    /// Graph-assigned identifier. Unique within any one graph.
    public let id: NodeID
    
    /// number of inbound edges
    public var inDegree: Int {
        return _inEdges.count
    }
    
    /// number of outbound edges
    public var outDegree: Int {
        return _outEdges.count
    }
    
    /// inbound edges, i.e., edges whose destination is this node
    public var inEdges: EdgeSequence<N, E> {
        return EdgeSequence<N, E>(_inEdges)
    }
    
    /// outbound edges, i.e., edges whose origin is this node
    public var outEdges: EdgeSequence<N, E> {
        return EdgeSequence(_outEdges)
    }
    
    internal var _inEdges = [EdgeID: Edge<N, E>]()
    
    internal var _outEdges = [EdgeID: Edge<N, E>]()
    
    public var value: N?
    
    public init(_ id: NodeID, _ value: N?) {
        self.id = id
        self.value = value
    }
    
    public func inEdge(withID id: EdgeID) -> Edge<N, E>? {
        return _inEdges[id]
    }
    
    public func outEdge(withID id: EdgeID) -> Edge<N, E>? {
        return _outEdges[id]
    }
    
}

public struct NodeSequence<N, E>: Sequence, IteratorProtocol {
    public typealias Element = Node<N,E>
    
    var iterator: Dictionary<NodeID, Node<N, E>>.Iterator
    
    init(_ nodes: [NodeID : Node<N, E>]) {
        self.iterator = nodes.makeIterator()
    }
    
    public mutating func next() -> Node<N, E>? {
        return iterator.next()?.value
    }
}

public class Edge<N, E>  {
    
    /// Graph-assigned identifier. Unique within any one graph.
    public let id: EdgeID
    
    public weak var origin: Node<N, E>!
    
    public weak var destination: Node<N, E>!
    
    public var value: E? = nil
    
    public init(_ id: EdgeID, _ origin: Node<N, E>, _ destination: Node<N, E>, _ value: E?) {
        self.id = id
        self.origin = origin
        self.destination = destination
        self.value = value
    }
}

public struct EdgeSequence<N, E>: Sequence, IteratorProtocol {
    public typealias Element = Edge<N, E>
    
    var iterator: Dictionary<EdgeID, Edge<N, E>>.Iterator
    
    init(_ edges: Dictionary<EdgeID, Edge<N, E>>) {
        self.iterator = edges.makeIterator()
    }
    
    public mutating func next() -> Edge<N, E>? {
        return iterator.next()?.value
    }
}


public class Graph<N, E> {
    
    public var nodeCount: Int {
        return _nodes.count
    }
    
    public var nodes: NodeSequence<N, E> {
        return NodeSequence<N, E>(_nodes)
    }
    
    private var _nodes = [NodeID: Node<N, E>]()
    
    private var _nextNodeID = 0
    
    public var edgeCount: Int {
        return _edges.count
    }
    
    public var edges: EdgeSequence<N, E> {
        return EdgeSequence<N, E>(_edges)
    }
    
    private var _edges = [EdgeID: Edge<N, E>]()
    
    private var _nextEdgeID = 0
    
    public init() {}
    
    public func node(_ id: NodeID) -> Node<N, E>? {
        return _nodes[id]
    }
    
    @discardableResult public func addNode(value: N? = nil) -> Node<N, E> {
        let id = _nextNodeID
        _nextNodeID += 1
        
        let newNode = Node<N, E>(id, value)
        _nodes[id] = newNode
        return newNode
    }
    
    /// remove the given node and all its edges. node and edge values are discarded
    public func removeNode(_ id: NodeID) {
        if let node = _nodes.removeValue(forKey: id) {
            for edge in node.inEdges {
                removeEdge(edge.id)
            }
            for edge in node.outEdges {
                removeEdge(edge.id)
            }
        }
    }
    
    public func edge(_ id: EdgeID) -> Edge<N, E>? {
        return _edges[id]
    }
    
    @discardableResult public func addEdge(_ originID: NodeID, _ destinationID: NodeID, value: E? = nil) throws -> Edge<N, E> {
        guard
            let origin = _nodes[originID]
        else {
            throw GraphError.noSuchNode(id: originID)
        }
        
        guard
            let destination = _nodes[destinationID]
        else {
            throw GraphError.noSuchNode(id: destinationID)
        }
        
        return addEdge(origin: origin, destination: destination, value: value)
    }
    
    private func addEdge(origin: Node<N, E>, destination: Node<N, E>, value: E? = nil) -> Edge<N, E> {
        let id = _nextEdgeID
        _nextEdgeID += 1
        
        let newEdge = Edge<N, E>(id, origin, destination, value)
        _edges[id] = newEdge
        origin._outEdges[id] = newEdge
        destination._inEdges[id] = newEdge
        return newEdge
    }
    
    /// removes the given edge. edge value is discarded
    public func removeEdge(_ id: EdgeID) {
        if let edge = _edges.removeValue(forKey: id) {
            edge.origin._outEdges.removeValue(forKey: id)
            edge.destination._inEdges.removeValue(forKey: id)
        }
    }
}

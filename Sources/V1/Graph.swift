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


public protocol GraphElement {
    associatedtype Identifier
    associatedtype ValueType
    
    /// Does not change. Unique within the set of elements of the same type (i.e., edge or node) in any one graph
    var id: Identifier { get }
    
    var value: ValueType? { get set }
}


public class Edge<N, E>: GraphElement {
    public typealias Identifier = EdgeID
    public typealias ValueType = E

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
    
    internal var _edges: Dictionary<EdgeID, Edge<N, E>>
    
    internal var _iterator: Dictionary<EdgeID, Edge<N, E>>.Iterator
    
    var count: Int {
        return self._edges.count
    }
    
    init(_ edges: Dictionary<EdgeID, Edge<N, E>>) {
        self._edges = edges
        self._iterator = edges.makeIterator()
    }
    
    public mutating func next() -> Edge<N, E>? {
        return _iterator.next()?.value
    }
}


public class Node<N, E>: GraphElement {
    public typealias Identifier = NodeID
    public typealias ValueType = N
    
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
}


public struct NodeSequence<N, E>: Sequence, IteratorProtocol {
    public typealias Element = Node<N,E>
    
    internal var _nodes: Dictionary<NodeID, Node<N, E>>
    
    private var _iterator: Dictionary<NodeID, Node<N, E>>.Iterator
    
    var count: Int {
        return self._nodes.count
    }
    
    init(_ nodes: [NodeID : Node<N, E>]) {
        self._nodes = nodes
        self._iterator = nodes.makeIterator()
    }
    
    public mutating func next() -> Node<N, E>? {
        return _iterator.next()?.value
    }
}


public class Graph<N, E> {
    public var nodeCount: Int {
        return _nodes.count
    }
    
    public var nodes: NodeSequence<N, E> {
        return NodeSequence<N, E>(_nodes)
    }
    
    internal var _nodes = [NodeID: Node<N, E>]()
    
    private var _nextNodeID = 0
    
    public var edgeCount: Int {
        return _edges.count
    }
    
    public var edges: EdgeSequence<N, E> {
        return EdgeSequence<N, E>(_edges)
    }
    
    internal var _edges = [EdgeID: Edge<N, E>]()
    
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
        
        return addAndInstallEdge(origin, destination, value)
    }
    
    private func addAndInstallEdge(_ origin: Node<N, E>, _ destination: Node<N, E>, _ value: E?) -> Edge<N, E> {
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

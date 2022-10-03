//
//  BaseGraph.swift
//  GenericGraph
//
//  Created by Jim Hanson on 3/8/21.
//

import Foundation

// ====================================================
// MARK:- BaseGraph node
// ====================================================

///
///
///
public class BaseGraphNode<N, E>: Node {
    public typealias ValueType = N
    public typealias EdgeType = BaseGraphEdge<N, E>
    public typealias InEdgeCollectionType = BaseGraphEdgeCollection<N, E>
    public typealias OutEdgeCollectionType = BaseGraphEdgeCollection<N, E>

    public let id: NodeID
    
    public var value: N?
    
    public var inEdges: BaseGraphEdgeCollection<N, E> {
        return _inEdges
    }
    
    public var outEdges: BaseGraphEdgeCollection<N, E> {
        return _outEdges
    }
    
    internal lazy var _inEdges = BaseGraphEdgeCollection<N, E>()
    
    internal lazy var _outEdges = BaseGraphEdgeCollection<N, E>()
    
    public init(_ id: NodeID, _ value: N?) {
        self.id = id
        self.value = value
    }
    
    deinit {
        _inEdges._dict.removeAll()
        _outEdges._dict.removeAll()
    }
}


///
///
///
public struct BaseGraphNodeCollection<N, E>: NodeCollection {
    public typealias NodeType = BaseGraphNode<N, E>
    public typealias Iterator = BaseGraphNodeIterator<N, E>
    
    public var count: Int {
        return _dict.count
    }
    
    internal var _dict = Dictionary<NodeID, BaseGraphNode<N, E>>()
    
    public func contains(_ id: NodeID) -> Bool {
        return _dict[id] != nil
    }
    
    public func randomElement() -> BaseGraphNode<N, E>? {
        return _dict.randomElement()?.value
    }
    
    public subscript(id: NodeID) -> BaseGraphNode<N, E>? {
        return _dict[id]
    }

    public func makeIterator() -> BaseGraphNodeIterator<N, E> {
        return BaseGraphNodeIterator(self)
    }
}


///
///
///
public struct BaseGraphNodeIterator<N, E>: IteratorProtocol {
    public typealias Element = BaseGraphNode<N, E>

    internal var _innerIterator: Dictionary<NodeID, BaseGraphNode<N, E>>.Iterator
    
    public init(_ nodes: BaseGraphNodeCollection<N, E>) {
        self._innerIterator = nodes._dict.makeIterator()
    }

    public mutating func next() -> BaseGraphNode<N, E>? {
        return _innerIterator.next()?.value
    }
}


// ====================================================
// MARK:- BaseGraph edge
// ====================================================


///
///
///
public class BaseGraphEdge<N, E>: Edge {
    public typealias ValueType = E
    public typealias NodeType = BaseGraphNode<N, E>
    
    public var id: EdgeID
    
    public var value: E?
    
    public var source: BaseGraphNode<N, E> {
        return _source
    }
    
    public var target: BaseGraphNode<N, E> {
        return _target
    }
    
    internal weak var _source: BaseGraphNode<N, E>!
    
    internal weak var _target: BaseGraphNode<N, E>!
    
    public init(_ id: EdgeID, _ value: E?, _ source: BaseGraphNode<N, E>, _ target: BaseGraphNode<N, E>) {
        self.id = id
        self.value = value
        self._source = source
        self._target = target
    }
}


///
///
///
public struct BaseGraphEdgeCollection<N, E>: EdgeCollection {
    public typealias EdgeType = BaseGraphEdge<N, E>
    public typealias Iterator = BaseGraphEdgeIterator<N, E>
    
    public var count: Int {
        return _dict.count
    }
    
    internal var _dict =  Dictionary<EdgeID, BaseGraphEdge<N, E>>()
    
    public func contains(_ id: EdgeID) -> Bool {
        return _dict[id] != nil
    }
    
    public func randomElement() -> BaseGraphEdge<N, E>? {
        return _dict.randomElement()?.value
    }
    
    public subscript(id: EdgeID) -> BaseGraphEdge<N, E>? {
        return _dict[id]
    }

    public func makeIterator() -> BaseGraphEdgeIterator<N, E> {
        return BaseGraphEdgeIterator<N, E>(self)
    }
}


///
///
///
public struct BaseGraphEdgeIterator<N, E>: IteratorProtocol {
    public typealias Element = BaseGraphEdge<N, E>
    
    internal var _innerIterator: Dictionary<EdgeID, BaseGraphEdge<N, E>>.Iterator
    
    public init(_ edges: BaseGraphEdgeCollection<N,E>) {
        self._innerIterator = edges._dict.makeIterator()
    }
    
    public mutating func next() -> BaseGraphEdge<N, E>? {
        return _innerIterator.next()?.value
    }
}

// ====================================================
// MARK:- BaseGraph
// ====================================================


///
///
///
public class BaseGraph<N, E>: Graph {
    public typealias NodeType = BaseGraphNode<N, E>
    public typealias EdgeType = BaseGraphEdge<N, E>
    public typealias NodeCollectionType = BaseGraphNodeCollection<N, E>
    public typealias EdgeCollectionType = BaseGraphEdgeCollection<N, E>
    public typealias SubGraphType = SubGraph<N, E>

    public lazy var id = GraphID(self)

    public var nodes: BaseGraphNodeCollection<N, E> {
        return _nodes
    }
    
    public var edges: BaseGraphEdgeCollection<N, E> {
        return _edges
    }
    
    internal var _nodes = BaseGraphNodeCollection<N,E>()
    
    internal var _nextNodeID: NodeID = 0
    
    internal var _edges = BaseGraphEdgeCollection<N, E>()
    
    internal var _nextEdgeID: EdgeID = 0
            
    public init() {}
        
    public func subgraph<S: Sequence>(_ nodeIDs: S) -> SubGraph<N, E> where S.Element == NodeID {
        return SubGraph<N, E>(self, nodeIDs)
    }

    // TODO: determine whether this is safe
    //    @discardableResult public func addNode(_ id: NodeID, _ value: N? = nil) throws -> BaseGraphNode<N, E> {
    //        if _nodes._dict[id] != nil {
    //            throw GraphError.nodeExists(id: id)
    //        }
    //
    //        _nextNodeID = max(id, _nextNodeID) + 1
    //
    //        let newNode = BaseGraphNode<N, E>(id, value)
    //        _nodes._dict[id] = newNode
    //        return newNode
    //    }

    @discardableResult public func addNode(_ value: N? = nil) -> BaseGraphNode<N, E> {
        let id = _nextNodeID
        _nextNodeID += 1
        
        let newNode = BaseGraphNode<N, E>(id, value)
        _nodes._dict[id] = newNode
        return newNode
    }
    
    public func removeNode(_ id: NodeID) {
        if let node = _nodes._dict.removeValue(forKey: id) {
            for edge in node._inEdges {
                removeEdge(edge.id)
            }
            for edge in node._outEdges {
                removeEdge(edge.id)
            }
        }
    }

    public func removeNodes<S: Sequence>(_ ids: S) where S.Element == NodeID {
        ids.forEach({ removeNode($0) })
    }


    @discardableResult public func addEdge(_ from: NodeID, _ to: NodeID, _ value: E? = nil) throws -> BaseGraphEdge<N, E> {
        guard
            let source = _nodes[from]
        else {
            throw GraphError.noSuchNode(id: from)
        }
        
        guard
            let target = _nodes[to]
        else {
            throw GraphError.noSuchNode(id: to)
        }
        
        return addAndInstallEdge(source, target, value)
    }
    
    public func removeEdge(_ id: EdgeID) {
        if let edge = _edges._dict.removeValue(forKey: id) {
            edge._source._outEdges._dict.removeValue(forKey: id)
            edge._target._inEdges._dict.removeValue(forKey: id)
        }
    }

    public func removeEdges<S: Sequence>(_ ids: S) where S.Element == EdgeID {
        ids.forEach({ removeEdge($0) })
    }

    public func clearAll() {
        _edges._dict.removeAll()
        _nodes._dict.removeAll()
    }

    private func addAndInstallEdge(_ source: BaseGraphNode<N, E>, _ target: BaseGraphNode<N, E>, _ value: E?) -> BaseGraphEdge<N, E> {
        let id = _nextEdgeID
        _nextEdgeID += 1
        
        let newEdge = BaseGraphEdge<N, E>(id, value, source, target)
        _edges._dict[id] = newEdge
        source._outEdges._dict[id] = newEdge
        target._inEdges._dict[id] = newEdge
        return newEdge
    }
}


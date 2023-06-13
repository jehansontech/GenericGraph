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

    public let nodeNumber: Int
    
    public var value: N?
    
    public var inEdges: BaseGraphEdgeCollection<N, E> {
        return _inEdges
    }
    
    public var outEdges: BaseGraphEdgeCollection<N, E> {
        return _outEdges
    }
    
    internal lazy var _inEdges = BaseGraphEdgeCollection<N, E>()
    
    internal lazy var _outEdges = BaseGraphEdgeCollection<N, E>()
    
    public init(_ nodeNumber: Int, _ value: N?) {
        self.nodeNumber = nodeNumber
        self.value = value
    }
    
    deinit {
        _inEdges.edgesByEdgeNumber.removeAll()
        _outEdges.edgesByEdgeNumber.removeAll()
    }
}


///
///
///
public struct BaseGraphNodeCollection<N, E>: NodeCollection {

    public typealias NodeType = BaseGraphNode<N, E>
    public typealias Iterator = BaseGraphNodeIterator<N, E>
    
    public var isEmpty: Bool {
        return nodesByNodeNumber.isEmpty
    }

    public var count: Int {
        return nodesByNodeNumber.count
    }
    
    internal var nodesByNodeNumber = Dictionary<Int, BaseGraphNode<N, E>>()
    
    public func contains(_ nodeNumber: Int) -> Bool {
        return nodesByNodeNumber[nodeNumber] != nil
    }
    
    public func randomElement() -> BaseGraphNode<N, E>? {
        return nodesByNodeNumber.randomElement()?.value
    }
    
    public subscript(nodeNumber: Int) -> BaseGraphNode<N, E>? {
        return nodesByNodeNumber[nodeNumber]
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

    internal var _innerIterator: Dictionary<Int, BaseGraphNode<N, E>>.Iterator
    
    public init(_ nodes: BaseGraphNodeCollection<N, E>) {
        self._innerIterator = nodes.nodesByNodeNumber.makeIterator()
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
    
    public var edgeNumber: Int
    
    public var value: E?
    
    public var source: BaseGraphNode<N, E> {
        return _source
    }
    
    public var target: BaseGraphNode<N, E> {
        return _target
    }
    
    internal weak var _source: BaseGraphNode<N, E>!
    
    internal weak var _target: BaseGraphNode<N, E>!
    
    public init(_ edgeNumber: Int, _ value: E?, _ source: BaseGraphNode<N, E>, _ target: BaseGraphNode<N, E>) {
        self.edgeNumber = edgeNumber
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

    public var isEmpty: Bool {
        return edgesByEdgeNumber.isEmpty
    }

    public var count: Int {
        return edgesByEdgeNumber.count
    }
    
    internal var edgesByEdgeNumber =  Dictionary<Int, BaseGraphEdge<N, E>>()
    
    public func contains(_ edgeNumber: Int) -> Bool {
        return edgesByEdgeNumber[edgeNumber] != nil
    }
    
    public func randomElement() -> BaseGraphEdge<N, E>? {
        return edgesByEdgeNumber.randomElement()?.value
    }
    
    public subscript(edgeNumber: Int) -> BaseGraphEdge<N, E>? {
        return edgesByEdgeNumber[edgeNumber]
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
    
    internal var _innerIterator: Dictionary<Int, BaseGraphEdge<N, E>>.Iterator
    
    public init(_ edges: BaseGraphEdgeCollection<N,E>) {
        self._innerIterator = edges.edgesByEdgeNumber.makeIterator()
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

    public private(set) lazy var id = GraphID(self)

    public var nodes: BaseGraphNodeCollection<N, E> {
        return _nodes
    }
    
    public var edges: BaseGraphEdgeCollection<N, E> {
        return _edges
    }
    
    internal var _nodes = BaseGraphNodeCollection<N,E>()
    
    internal var _nextNodeNumber: Int = 0
    
    internal var _edges = BaseGraphEdgeCollection<N, E>()
    
    internal var _nextEdgeNumber: Int = 0
            
    public init() {}

    public func subgraph() -> SubGraph<N, E> {
        return SubGraph<N, E>(self)
    }

    public func subgraph<S: Sequence>(_ nodeNumbers: S) -> SubGraph<N, E> where S.Element == Int {
        return SubGraph<N, E>(self, nodeNumbers)
    }

    // TODO: determine whether this is safe
    //    @discardableResult public func addNode(_ nodeNumber: Int, _ value: N? = nil) throws -> BaseGraphNode<N, E> {
    //        if _nodes._dict[nodeNumber] != nil {
    //            throw GraphError.nodeExists(nodeNumber: nodeNumber)
    //        }
    //
    //        _nextNodeNumber = max(nodeNumber, _nextNodeNumber) + 1
    //
    //        let newNode = BaseGraphNode<N, E>(nodeNumber, value)
    //        _nodes._dict[nodeNumber] = newNode
    //        return newNode
    //    }

    @discardableResult public func addNode(_ value: N? = nil) -> BaseGraphNode<N, E> {
        let newNodeNumber = _nextNodeNumber
        _nextNodeNumber += 1
        
        let newNode = BaseGraphNode<N, E>(newNodeNumber, value)
        _nodes.nodesByNodeNumber[newNodeNumber] = newNode
        return newNode
    }
    
    public func removeNode(_ nodeNumber: Int) {
        if let node = _nodes.nodesByNodeNumber.removeValue(forKey: nodeNumber) {
            for edge in node._inEdges {
                removeEdge(edge.edgeNumber)
            }
            for edge in node._outEdges {
                removeEdge(edge.edgeNumber)
            }
        }
    }

    public func removeNodes<S: Sequence>(_ nodeNumbers: S) where S.Element == Int {
        nodeNumbers.forEach({ removeNode($0) })
    }

    @discardableResult public func addEdge(_ from: Int, _ to: Int, _ value: E? = nil) throws -> BaseGraphEdge<N, E> {
        guard
            let source = _nodes[from]
        else {
            throw GraphError.noSuchNode(nodeNumber: from)
        }
        
        guard
            let target = _nodes[to]
        else {
            throw GraphError.noSuchNode(nodeNumber: to)
        }
        
        return uncheckedAddEdge(source, target, value)
    }

    @discardableResult public func uncheckedAddEdge(_ source: BaseGraphNode<N, E>, _ target: BaseGraphNode<N, E>, _ value: E? = nil) -> BaseGraphEdge<N, E> {
        let newEdgeNumber = _nextEdgeNumber
        _nextEdgeNumber += 1

        let newEdge = BaseGraphEdge<N, E>(newEdgeNumber, value, source, target)
        _edges.edgesByEdgeNumber[newEdgeNumber] = newEdge
        source._outEdges.edgesByEdgeNumber[newEdgeNumber] = newEdge
        target._inEdges.edgesByEdgeNumber[newEdgeNumber] = newEdge
        return newEdge
    }

    public func removeEdge(_ edgeNumber: Int) {
        if let edge = _edges.edgesByEdgeNumber.removeValue(forKey: edgeNumber) {
            edge._source._outEdges.edgesByEdgeNumber.removeValue(forKey: edgeNumber)
            edge._target._inEdges.edgesByEdgeNumber.removeValue(forKey: edgeNumber)
        }
    }

    public func removeEdges<S: Sequence>(_ edgeNumbers: S) where S.Element == Int {
        edgeNumbers.forEach({ removeEdge($0) })
    }

    public func clearAll() {
        _edges.edgesByEdgeNumber.removeAll()
        _nodes.nodesByNodeNumber.removeAll()
    }

}


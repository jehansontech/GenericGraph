//
//  SubGraph.swift
//  GenericGraph
//
//  Created by Jim Hanson on 3/8/21.
//

import Foundation

// ====================================================
// MARK:- SubrGraph node
// ====================================================


///
///
///
public class SubGraphNode<N, E>: Node {
    public typealias ValueType = N
    public typealias EdgeType = SubGraphEdge<N, E>
    public typealias InEdgeCollectionType = SubGraphInEdgeCollection<N, E>
    public typealias OutEdgeCollectionType = SubGraphOutEdgeCollection<N, E>
    
    public var id: NodeID {
        return _baseNode.id
    }
    
    public var value: N? {
        get {
            return _baseNode.value
        }
        set(newValue) {
            _baseNode.value = newValue
        }
    }
    
    public var inEdges: SubGraphInEdgeCollection<N, E> {
        return _inEdges
    }
    
    public var outEdges: SubGraphOutEdgeCollection<N,E> {
        return _outEdges
    }
    
    public var graph: SubGraph<N,E> {
        return _graph!
    }
    
    internal weak var _graph: SubGraph<N,E>!
    
    internal let _baseNode: BaseGraphNode<N,E>
    
    internal lazy var _inEdges = SubGraphInEdgeCollection<N, E>(_graph, _baseNode)
    
    internal lazy var _outEdges = SubGraphOutEdgeCollection<N, E>(_graph, _baseNode)
    
    public init(_ graph: SubGraph<N,E>, _ baseNode: BaseGraphNode<N,E>) {
        self._graph = graph
        self._baseNode = baseNode
    }
}


///
///
///
public struct SubGraphNodeCollection<N, E>: NodeCollection {
    public typealias NodeType = SubGraphNode<N, E>
    public typealias Iterator = SubGraphNodeIterator<N,E>
    
    public var count: Int {
        return _graph._nodeIDs.count
    }
        
    internal weak var _graph: SubGraph<N, E>!
    
    public init(_ graph: SubGraph<N, E>) {
        self._graph = graph
    }
    
    public func contains(_ id: NodeID) -> Bool {
        return _graph._nodeIDs.contains(id)
    }
    
    public func makeIterator() -> SubGraphNodeIterator<N,E> {
        return SubGraphNodeIterator<N,E>(_graph)
    }
    
    public func randomElement() -> NodeType? {
        if let randomId = _graph._nodeIDs.randomElement(),
           let baseNode = _graph.baseGraph.nodes[randomId] {
            return SubGraphNode<N, E>(_graph, baseNode)
        }
        else {
            return nil
        }
    }
    
    public subscript(id: NodeID) -> NodeType? {
        if _graph._nodeIDs.contains(id),
           let baseNode = _graph.baseGraph._nodes[id] {
            return SubGraphNode<N, E>(_graph, baseNode)
        }
        else {
            return nil
        }
    }
}



///
///
///
public struct SubGraphNodeIterator<N,E>: IteratorProtocol {
    public typealias Element = SubGraphNode<N, E>
    
    private weak var _graph: SubGraph<N,E>!
    
    private lazy var _filteredBaseNodeIterator = makeInnerIterator()
    
    public mutating func next() -> SubGraphNode<N, E>? {
        if let baseNode = _filteredBaseNodeIterator.next()?.value {
                return SubGraphNode<N,E>(_graph, baseNode)
        }
        else {
            return nil
        }
    }
    
    public init(_ graph: SubGraph<N, E>) {
        self._graph = graph
    }
    
    private func makeInnerIterator() -> Dictionary<NodeID, BaseGraphNode<N, E>>.Iterator {
        return _graph.baseGraph._nodes._dict.filter({ _graph._nodeIDs.contains($0.value.id) }).makeIterator()
    }
}



// ====================================================
// MARK:- SubGraph edge
// ====================================================


///
///
///
public class SubGraphEdge<N, E>: Edge {
    public typealias ValueType = E
    public typealias NodeType = SubGraphNode<N, E>
    
    public var id: EdgeID {
        return _baseEdge.id
    }
    
    public var value: E? {
        get {
            return _baseEdge.value
        }
        set(newValue) {
            _baseEdge.value = newValue
        }
    }
    
    public var source: NodeType {
        return SubGraphNode<N,E>(_graph, _baseEdge.source)
    }
    
    public var target: NodeType {
        return SubGraphNode<N,E>(_graph, _baseEdge.target)
    }
    
    public var graph: SubGraph<N,E> {
        return _graph
    }
    
    internal weak var _graph: SubGraph<N,E>!
    
    internal let _baseEdge: BaseGraphEdge<N,E>
    
    public init(_ graph: SubGraph<N,E>, _ baseEdge: BaseGraphEdge<N,E>) {
        self._graph = graph
        self._baseEdge = baseEdge
    }
}


///
/// In-edges of a subgraph node
///
public struct SubGraphInEdgeCollection<N, E>: EdgeCollection {
    public typealias EdgeType = SubGraphEdge<N, E>
    public typealias Iterator = SubGraphInEdgeIterator<N,E>
    
    /// INEFFICIENT
    public var count: Int {
        return _baseNode._inEdges._dict.filter({ _graph.nodes.contains($0.value._source.id) }).count
    }
            
    internal weak var _graph: SubGraph<N, E>!
    
    internal let _baseNode: BaseGraphNode<N, E>
    
    public init(_ graph: SubGraph<N, E>, _ baseNode: BaseGraphNode<N, E>) {
        self._baseNode = baseNode
        self._graph = graph
    }
    
    public func contains(_ id: EdgeID) -> Bool {
        if let sourceID = _baseNode.inEdges[id]?._source.id {
            return _graph.nodes.contains(sourceID)
        }
        else {
            return false
        }
    }
    
    /// INEFFICIENT
    public func randomElement() -> SubGraphEdge<N, E>? {
        if let baseEdge =  _graph.baseGraph._edges._dict.filter({ _graph._nodeIDs.contains($0.value._source.id) }).randomElement()?.value {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public subscript(id: EdgeID) -> SubGraphEdge<N, E>? {
        if let baseEdge = _baseNode._inEdges[id], _graph._nodeIDs.contains(baseEdge._source.id) {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public func makeIterator() -> SubGraphInEdgeIterator<N, E> {
        return SubGraphInEdgeIterator<N, E>(self)
    }
}


///
///
///
public struct SubGraphInEdgeIterator<N, E>: IteratorProtocol {
    public typealias Element = SubGraphEdge<N, E>
    
    internal weak var _graph: SubGraph<N, E>!

    internal let _baseNode: BaseGraphNode<N, E>
    
    internal lazy var _filteredBaseEdgeIterator = makeInnerIterator()

    public mutating func next() -> SubGraphEdge<N, E>? {
        if let baseEdge = _filteredBaseEdgeIterator.next()?.value {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public init(_ sequence: SubGraphInEdgeCollection<N, E>) {
        self._graph = sequence._graph
        self._baseNode = sequence._baseNode
    }
    
    private func makeInnerIterator() -> Dictionary<EdgeID, BaseGraphEdge<N, E>>.Iterator {
        return _baseNode._inEdges._dict.filter({ _graph._nodeIDs.contains($0.value._source.id) }).makeIterator()
    }
}


///
///
///
public struct SubGraphOutEdgeCollection<N, E>: EdgeCollection {
    public typealias EdgeType = SubGraphEdge<N, E>
    public typealias Iterator = SubGraphOutEdgeIterator<N,E>
    
    /// INEFFICIENT
    public var count: Int {
        return _baseNode._outEdges._dict.filter({ _graph._nodeIDs.contains($0.value._target.id) }).count
    }
            
    internal weak var _graph: SubGraph<N, E>!
    
    internal let _baseNode: BaseGraphNode<N, E>
    
    public init(_ graph: SubGraph<N, E>, _ baseNode: BaseGraphNode<N, E>) {
        self._baseNode = baseNode
        self._graph = graph
    }
    
    public func contains(_ id: EdgeID) -> Bool {
        if let destinationId = _baseNode._outEdges[id]?._target.id {
            return _graph._nodeIDs.contains(destinationId)
        }
        else {
            return false
        }
    }
    
    /// INEFFICIENT
    public func randomElement() -> SubGraphEdge<N, E>? {
        if let baseEdge =  _graph.baseGraph._edges._dict.filter({ _graph._nodeIDs.contains($0.value._target.id) }).randomElement()?.value {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public subscript(id: EdgeID) -> EdgeType? {
        if let baseEdge = _baseNode._outEdges[id], _graph._nodeIDs.contains(baseEdge._target.id) {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public func makeIterator() -> SubGraphOutEdgeIterator<N, E> {
        return SubGraphOutEdgeIterator<N, E>(self)
    }
}


///
///
///
public struct SubGraphOutEdgeIterator<N, E>: IteratorProtocol {
    public typealias Element = SubGraphEdge<N, E>
    
    internal weak var _graph: SubGraph<N, E>!

    internal let _baseNode: BaseGraphNode<N, E>
    
    internal lazy var _filteredBaseEdgeIterator = makeInnerIterator()
        
    public mutating func next() -> SubGraphEdge<N, E>? {
        if let baseEdge = _filteredBaseEdgeIterator.next()?.value {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public init(_ sequence: SubGraphOutEdgeCollection<N, E>) {
        self._graph = sequence._graph
        self._baseNode = sequence._baseNode
    }
    
    private func makeInnerIterator() -> Dictionary<EdgeID, BaseGraphEdge<N, E>>.Iterator {
        return _baseNode._outEdges._dict.filter({ _graph._nodeIDs.contains($0.value._target.id) }).makeIterator()
    }
}


///
///
///
public struct SubGraphEdgeCollection<N, E>: EdgeCollection {
    public typealias EdgeType = SubGraphEdge<N, E>
    public typealias Iterator = SubGraphEdgeIterator<N,E>
            
    /// INEFFICIENT
    public var count: Int {
        return _graph.baseGraph._edges._dict.filter({
            _graph._nodeIDs.contains($0.value._source.id) && _graph._nodeIDs.contains($0.value._target.id)
        }).count
    }
            
    internal weak var _graph: SubGraph<N, E>!
        
    public init(_ graph: SubGraph<N, E>) {
        self._graph = graph
    }
    
    public func contains(_ id: EdgeID) -> Bool {
        if let baseEdge = _graph.baseGraph.edges[id] {
            return _graph._nodeIDs.contains(baseEdge._source.id) && _graph._nodeIDs.contains(baseEdge._target.id)
        }
        else {
            return false
        }
    }
    
    /// INEFFICIENT
    public func randomElement() -> SubGraphEdge<N, E>? {
        if let baseEdge =  _graph.baseGraph._edges._dict.filter({
            _graph._nodeIDs.contains($0.value._source.id) && _graph._nodeIDs.contains($0.value._target.id)
        }).randomElement()?.value {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public subscript(id: EdgeID) -> EdgeType? {
        if let baseEdge = _graph.baseGraph._edges[id],
           _graph._nodeIDs.contains(baseEdge._source.id),
           _graph._nodeIDs.contains(baseEdge._target.id) {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public func makeIterator() -> SubGraphEdgeIterator<N, E> {
        return SubGraphEdgeIterator<N, E>(self)
    }
}


///
///
///
public struct SubGraphEdgeIterator<N, E>: IteratorProtocol {
    public typealias Element = SubGraphEdge<N, E>
    
    internal weak var _graph: SubGraph<N, E>!
    
    internal lazy var _filteredBaseEdgeIterator = makeInnerIterator()
        
    public mutating func next() -> SubGraphEdge<N, E>? {
        if let baseEdge = _filteredBaseEdgeIterator.next()?.value {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public init(_ edges: SubGraphEdgeCollection<N, E>) {
        self._graph = edges._graph
    }
    
    private func makeInnerIterator() -> Dictionary<EdgeID, BaseGraphEdge<N, E>>.Iterator {
        return _graph.baseGraph._edges._dict.filter({
            _graph._nodeIDs.contains($0.value.source.id) && _graph._nodeIDs.contains($0.value.target.id)
        }).makeIterator()
    }
}


// ====================================================
// MARK:- SubGraph
// ====================================================


///
///
///
public class SubGraph<N, E>: Graph {
    public typealias NodeType = SubGraphNode<N, E>
    public typealias EdgeType = SubGraphEdge<N, E>
    public typealias NodeCollectionType = SubGraphNodeCollection<N, E>
    public typealias EdgeCollectionType = SubGraphEdgeCollection<N, E>
    public typealias SubGraphType = SubGraph<N, E>

    public var nodes: SubGraphNodeCollection<N, E> {
        return _nodes
    }
    
    public var edges: SubGraphEdgeCollection<N, E> {
        return _edges
    }
    
    public let baseGraph: BaseGraph<N, E>
    
    internal var _nodeIDs: Set<NodeID>
    
    lazy internal var _nodes = SubGraphNodeCollection<N,E>(self)
    
    lazy internal var _edges = SubGraphEdgeCollection<N,E>(self)
    
    public init<S: Sequence>(_ baseGraph: BaseGraph<N, E>, _ nodeIDs: S) where S.Element == NodeID {
        self.baseGraph = baseGraph

        let validNodeIDs = Set<NodeID>(baseGraph._nodes.map({$0.id}))
        let givenNodeIDs = Set<NodeID>(nodeIDs)
        self._nodeIDs = validNodeIDs.intersection(givenNodeIDs)
    }

    public convenience init(_ baseGraph: BaseGraph<N, E>) {
        self.init(baseGraph, Set<NodeID>())
    }

    public convenience init(_ subgraph: SubGraph<N, E>) {
        self.init(subgraph.baseGraph, subgraph._nodeIDs)
    }

    public convenience init(_ subgraph: SubGraph<N, E>, _ nodeIDs: Set<NodeID>) {
        self.init(subgraph.baseGraph, nodeIDs.intersection(subgraph._nodeIDs))
    }

    public func subgraph(_ nodeIDs: Set<NodeID>) -> SubGraph<N, E> {
        return SubGraph<N, E>(self, nodeIDs)
    }
    
    @discardableResult public func addNode(id: NodeID) throws -> SubGraphNode<N, E> {
        if let baseNode = baseGraph.nodes[id] {
            _nodeIDs.insert(id)
            return SubGraphNode<N, E>(self, baseNode)
        }
        else {
            throw GraphError.noSuchNode(id: id)
        }
    }
    
    public func removeNode(id: NodeID) {
        _nodeIDs.remove(id)
    }
}

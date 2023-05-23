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
    
    public var nodeNumber: Int {
        return _baseNode.nodeNumber
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
        return _graph._nodeNumbers.count
    }
        
    internal weak var _graph: SubGraph<N, E>!
    
    public init(_ graph: SubGraph<N, E>) {
        self._graph = graph
    }
    
    public func contains(_ nodeNumber: Int) -> Bool {
        return _graph._nodeNumbers.contains(nodeNumber)
    }
    
    public func makeIterator() -> SubGraphNodeIterator<N,E> {
        return SubGraphNodeIterator<N,E>(_graph)
    }
    
    public func randomElement() -> NodeType? {
        if let randomNodeNumber = _graph._nodeNumbers.randomElement(),
           let baseNode = _graph.baseGraph.nodes[randomNodeNumber] {
            return SubGraphNode<N, E>(_graph, baseNode)
        }
        else {
            return nil
        }
    }
    
    public subscript(nodeNumber: Int) -> NodeType? {
        if _graph._nodeNumbers.contains(nodeNumber),
           let baseNode = _graph.baseGraph._nodes[nodeNumber] {
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
    
    private func makeInnerIterator() -> Dictionary<Int, BaseGraphNode<N, E>>.Iterator {
        return _graph.baseGraph._nodes.nodesByNodeNumber.filter({ _graph._nodeNumbers.contains($0.value.nodeNumber) }).makeIterator()
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
    
    public var edgeNumber: Int {
        return _baseEdge.edgeNumber
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
        return _baseNode._inEdges.edgesByEdgeNumber.filter({ _graph.nodes.contains($0.value._source.nodeNumber) }).count
    }
            
    internal weak var _graph: SubGraph<N, E>!
    
    internal let _baseNode: BaseGraphNode<N, E>
    
    public init(_ graph: SubGraph<N, E>, _ baseNode: BaseGraphNode<N, E>) {
        self._baseNode = baseNode
        self._graph = graph
    }
    
    public func contains(_ edgeNumber: Int) -> Bool {
        if let sourceNodeNumber = _baseNode.inEdges[edgeNumber]?._source.nodeNumber {
            return _graph.nodes.contains(sourceNodeNumber)
        }
        else {
            return false
        }
    }
    
    /// INEFFICIENT
    public func randomElement() -> SubGraphEdge<N, E>? {
        if let baseEdge =  _graph.baseGraph._edges.edgesByEdgeNumber.filter({ _graph._nodeNumbers.contains($0.value._source.nodeNumber) }).randomElement()?.value {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public subscript(edgeNumber: Int) -> SubGraphEdge<N, E>? {
        if let baseEdge = _baseNode._inEdges[edgeNumber], _graph._nodeNumbers.contains(baseEdge._source.nodeNumber) {
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
    
    private func makeInnerIterator() -> Dictionary<Int, BaseGraphEdge<N, E>>.Iterator {
        return _baseNode._inEdges.edgesByEdgeNumber.filter({ _graph._nodeNumbers.contains($0.value._source.nodeNumber) }).makeIterator()
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
        return _baseNode._outEdges.edgesByEdgeNumber.filter({ _graph._nodeNumbers.contains($0.value._target.nodeNumber) }).count
    }
            
    internal weak var _graph: SubGraph<N, E>!
    
    internal let _baseNode: BaseGraphNode<N, E>
    
    public init(_ graph: SubGraph<N, E>, _ baseNode: BaseGraphNode<N, E>) {
        self._baseNode = baseNode
        self._graph = graph
    }
    
    public func contains(_ edgeNumber: Int) -> Bool {
        if let destinationNodeNumber = _baseNode._outEdges[edgeNumber]?._target.nodeNumber {
            return _graph._nodeNumbers.contains(destinationNodeNumber)
        }
        else {
            return false
        }
    }
    
    /// INEFFICIENT
    public func randomElement() -> SubGraphEdge<N, E>? {
        if let baseEdge =  _graph.baseGraph._edges.edgesByEdgeNumber.filter({ _graph._nodeNumbers.contains($0.value._target.nodeNumber) }).randomElement()?.value {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public subscript(edgeNumber: Int) -> EdgeType? {
        if let baseEdge = _baseNode._outEdges[edgeNumber], _graph._nodeNumbers.contains(baseEdge._target.nodeNumber) {
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
    
    private func makeInnerIterator() -> Dictionary<Int, BaseGraphEdge<N, E>>.Iterator {
        return _baseNode._outEdges.edgesByEdgeNumber.filter({ _graph._nodeNumbers.contains($0.value._target.nodeNumber) }).makeIterator()
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
        return _graph.baseGraph._edges.edgesByEdgeNumber.filter({
            _graph._nodeNumbers.contains($0.value._source.nodeNumber) && _graph._nodeNumbers.contains($0.value._target.nodeNumber)
        }).count
    }
            
    internal weak var _graph: SubGraph<N, E>!
        
    public init(_ graph: SubGraph<N, E>) {
        self._graph = graph
    }
    
    public func contains(_ edgeNumber: Int) -> Bool {
        if let baseEdge = _graph.baseGraph.edges[edgeNumber] {
            return _graph._nodeNumbers.contains(baseEdge._source.nodeNumber) && _graph._nodeNumbers.contains(baseEdge._target.nodeNumber)
        }
        else {
            return false
        }
    }
    
    /// INEFFICIENT
    public func randomElement() -> SubGraphEdge<N, E>? {
        if let baseEdge =  _graph.baseGraph._edges.edgesByEdgeNumber.filter({
            _graph._nodeNumbers.contains($0.value._source.nodeNumber) && _graph._nodeNumbers.contains($0.value._target.nodeNumber)
        }).randomElement()?.value {
            return SubGraphEdge<N,E>(_graph, baseEdge)
        }
        else {
            return nil
        }
    }
    
    public subscript(edgeNumber: Int) -> EdgeType? {
        if let baseEdge = _graph.baseGraph._edges[edgeNumber],
           _graph._nodeNumbers.contains(baseEdge._source.nodeNumber),
           _graph._nodeNumbers.contains(baseEdge._target.nodeNumber) {
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
    
    private func makeInnerIterator() -> Dictionary<Int, BaseGraphEdge<N, E>>.Iterator {
        return _graph.baseGraph._edges.edgesByEdgeNumber.filter({
            _graph._nodeNumbers.contains($0.value.source.nodeNumber) && _graph._nodeNumbers.contains($0.value.target.nodeNumber)
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

    public private(set) lazy var id = GraphID(self)

    public var nodes: SubGraphNodeCollection<N, E> {
        return _nodes
    }
    
    public var edges: SubGraphEdgeCollection<N, E> {
        return _edges
    }
    
    public let baseGraph: BaseGraph<N, E>
    
    internal var _nodeNumbers: Set<Int>
    
    lazy internal var _nodes = SubGraphNodeCollection<N,E>(self)
    
    lazy internal var _edges = SubGraphEdgeCollection<N,E>(self)
    
    public init<S: Sequence>(_ baseGraph: BaseGraph<N, E>, _ nodeNumbers: S) where S.Element == Int {
        self.baseGraph = baseGraph

        let validNodeNumbers = Set<Int>(baseGraph._nodes.map({$0.nodeNumber}))
        let givenNodeNumbers = Set<Int>(nodeNumbers)
        self._nodeNumbers = validNodeNumbers.intersection(givenNodeNumbers)
    }

    public convenience init(_ baseGraph: BaseGraph<N, E>) {
        self.init(baseGraph, Set<Int>())
    }

    public convenience init(_ subgraph: SubGraph<N, E>) {
        self.init(subgraph.baseGraph, subgraph._nodeNumbers)
    }

    public convenience init(_ subgraph: SubGraph<N, E>, _ nodeNumbers: Set<Int>) {
        self.init(subgraph.baseGraph, nodeNumbers.intersection(subgraph._nodeNumbers))
    }

    public func subgraph(_ nodeNumbers: Set<Int>) -> SubGraph<N, E> {
        return SubGraph<N, E>(self, nodeNumbers)
    }
    
    @discardableResult public func addNode(nodeNumber: Int) throws -> SubGraphNode<N, E> {
        if let baseNode = baseGraph.nodes[nodeNumber] {
            _nodeNumbers.insert(nodeNumber)
            return SubGraphNode<N, E>(self, baseNode)
        }
        else {
            throw GraphError.noSuchNode(nodeNumber: nodeNumber)
        }
    }
    
    public func removeNode(nodeNumber: Int) {
        _nodeNumbers.remove(nodeNumber)
    }
}

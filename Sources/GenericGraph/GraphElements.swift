//
//  GraphElements.swift
//  GenericGraph
//
//  Created by Jim Hanson on 3/8/21.
//

import Foundation

// ====================================================
// MARK:- Node
// ====================================================

///
///
///
public protocol Node: AnyObject, Hashable
where InEdgeCollectionType.EdgeType == EdgeType,
      OutEdgeCollectionType.EdgeType == EdgeType {
    
    associatedtype ValueType
    associatedtype EdgeType
    associatedtype InEdgeCollectionType: EdgeCollection
    associatedtype OutEdgeCollectionType: EdgeCollection

    /// Non-negative
    /// Unique within the graph
    /// Does not change
    var nodeNumber: Int { get }
    
    var value: ValueType? { get set }

    var outEdges: OutEdgeCollectionType { get }
    
    var inEdges: InEdgeCollectionType { get }
}

extension Node {
    
    public var outDegree: Int {
        return outEdges.count
    }

    public var inDegree: Int {
        return inEdges.count
    }

    public var degree: Int {
        return inEdges.count + outEdges.count
    }

    /// equality is testable only within a given graph
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.nodeNumber == rhs.nodeNumber
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(nodeNumber)
    }
}


///
/// Despite the name, this does not inherit from *Collection*
///
public protocol NodeCollection: Sequence where Element == NodeType {
    associatedtype NodeType: Node
    
    var count: Int { get }
    
    func contains(_ nodeNumber: Int) -> Bool

    func randomElement() -> NodeType?

    subscript(nodeNumber: Int) -> NodeType? { get }
}


// ====================================================
// MARK:- Edge
// ====================================================

///
///
///
public protocol Edge: AnyObject, Hashable {
    associatedtype ValueType
    associatedtype NodeType: Node

    /// Non-negative
    /// Unique within the graph
    /// Does not change
    var edgeNumber: Int { get }
    
    var value: ValueType? { get set }
    
    var source: NodeType { get }
    
    var target: NodeType { get }
}

extension Edge {

    /// equality is testable only within a given graph
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.edgeNumber == rhs.edgeNumber
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(edgeNumber)
    }

    public var isSelfEdge: Bool {
        return source == target
    }
}

///
/// Despite the name, this does not inherit from *Collection*
///
public protocol EdgeCollection: Sequence where Element == EdgeType {
    associatedtype EdgeType: Edge
    
    var count: Int { get }
    
    func contains(_ edgeNumber: Int) -> Bool
    
    func randomElement() -> EdgeType?

    subscript(_ edgeNumber: Int) -> EdgeType? { get }
}


// ====================================================
// MARK:- Graph
// ====================================================


public typealias GraphID = ObjectIdentifier

public enum GraphError: Error {
    case nodeExists(nodeNumber: Int)
    case noSuchNode(nodeNumber: Int)
    case edgeExists(edgeNumber: Int)
    case noSuchEdge(edgeNumber: Int)
}


///
///
///
public protocol Graph: AnyObject
where EdgeType.NodeType == NodeType,
      NodeType.EdgeType == EdgeType,
      NodeCollectionType.NodeType == NodeType,
      EdgeCollectionType.EdgeType == EdgeType,
      SubGraphType.NodeType.ValueType == NodeType.ValueType,
      SubGraphType.EdgeType.ValueType == EdgeType.ValueType
{
    
    associatedtype NodeType
    associatedtype EdgeType
    associatedtype NodeCollectionType: NodeCollection
    associatedtype EdgeCollectionType: EdgeCollection
    associatedtype SubGraphType: Graph

    var id: GraphID { get }

    var nodes: NodeCollectionType { get }

    var edges: EdgeCollectionType { get }
    
    func subgraph(_ nodeNumbers: Set<Int>) -> SubGraphType
}

//
//  GraphElements.swift
//  
//
//  Created by Jim Hanson on 3/8/21.
//

import Foundation

// ====================================================
// MARK:- Node
// ====================================================


public typealias NodeID = Int


///
///
///
public protocol Node: AnyObject where
    InEdgeCollectionType.EdgeType == EdgeType,
    OutEdgeCollectionType.EdgeType == EdgeType {
    
    associatedtype ValueType
    associatedtype EdgeType
    associatedtype InEdgeCollectionType: EdgeCollection
    associatedtype OutEdgeCollectionType: EdgeCollection

    var id: NodeID { get }
    
    var value: ValueType? { get set }
        
    var outEdges: OutEdgeCollectionType { get }
    
    var inEdges: InEdgeCollectionType { get }
}

extension Node {
    
    var outDegree: Int {
        return outEdges.count
    }

    var inDegree: Int {
        return inEdges.count
    }
}


///
/// Despite the name, this does not inherit from *Collection*
///
public protocol NodeCollection: Sequence where Element == NodeType {
    associatedtype NodeType: Node
    
    var count: Int { get }
    
    func contains(_ id: NodeID) -> Bool
 
    func randomElement() -> NodeType?
    
    subscript(_ id: NodeID) -> NodeType? { get }
}


// ====================================================
// MARK:- Edge
// ====================================================


public typealias EdgeID = Int


///
///
///
public protocol Edge: AnyObject {
    associatedtype ValueType
    associatedtype NodeType: Node
    
    var id: EdgeID { get }
    
    var value: ValueType? { get set }
    
    var source: NodeType { get }
    
    var target: NodeType { get }
}

///
/// Despite the name, this does not inherit from *Collection*
///
public protocol EdgeCollection: Sequence where Element == EdgeType {
    associatedtype EdgeType: Edge
    
    var count: Int { get }
    
    func contains(_ id: EdgeID) -> Bool
    
    func randomElement() -> EdgeType?

    subscript(_ id: EdgeID) -> EdgeType? { get }
}


// ====================================================
// MARK:- Graph
// ====================================================


public enum GraphError: Error {
    case noSuchNode(id: NodeID)
    case noSuchEdge(id: EdgeID)
}


///
///
///
public protocol Graph: AnyObject where
    EdgeType.NodeType == NodeType,
    NodeType.EdgeType == EdgeType,
    NodeCollectionType.NodeType == NodeType,
    EdgeCollectionType.EdgeType == EdgeType,
    SubGraphType.NodeType.ValueType == NodeType.ValueType,
    SubGraphType.EdgeType.ValueType == EdgeType.ValueType {
    
    associatedtype NodeType
    associatedtype EdgeType
    associatedtype NodeCollectionType: NodeCollection
    associatedtype EdgeCollectionType: EdgeCollection
    associatedtype SubGraphType: Graph
    
    var nodes: NodeCollectionType { get }

    var edges: EdgeCollectionType { get }
    
    func subgraph(_ nodeIDs: Set<NodeID>) -> SubGraphType
}

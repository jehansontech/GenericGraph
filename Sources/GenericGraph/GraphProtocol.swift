//
//  GraphProtocol.swift
//  GenericGraph
//
//  Created by James Hanson on 10/4/20.
//

import Foundation

public typealias NodeID = Int

public typealias EdgeID = Int

public enum GraphError: Error {
    case noSuchNode(id: NodeID)
}

protocol GraphNode: CustomStringConvertible {
    associatedtype NodeValueType
    
    var id: NodeID { get }
    var inDegree: Int { get }
    // MAYBE inEdgeIDs: [EdgeID]
    // MAYBE outEdgeIDs: [EdgeID]
    var outDegree: Int { get }
    var value: NodeValueType? { get }
}

extension GraphNode {
    
    public var description: String {
        return "Node \(id)"
    }
    
    public var degree: Int {
        return inDegree + outDegree
    }
}

protocol GraphEdge: CustomStringConvertible {
    associatedtype EdgeValueType
    
    var id: EdgeID { get }
    var value: EdgeValueType? { get }
    
    // MAYBE sourceID: NodeID
    // MAYBE destinationID: NodeID
    
}

extension GraphEdge {
    
    public var description: String {
        return "Node \(id)"
    }
    
}

protocol GraphProtocol {
    
}


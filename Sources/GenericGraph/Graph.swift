//
//  Graph.swift
//  GenericGraph
//
//  Created by James Hanson on 10/4/20.
//

import Foundation

typealias NodeID = Int

typealias EdgeID = Int

struct Graph<N, E> {
    
    class Node: CustomStringConvertible {

        /// Graph-assigned identifier. Unique within any one graph.
        let id: NodeID
        
        /// User-assignable identifier
        var name: String?
        
        var description: String {
            if let name = name {
                return name
            }
            else {
                return "Node \(id)"
            }
        }
        
        var inDegree: Int {
            return _inEdges.count
        }
        
        var outDegree: Int {
            return _outEdges.count
        }
        
        var inEdges: Dictionary<EdgeID, Edge>.Values {
            return _inEdges.values
        }
        
        var outEdges: Dictionary<EdgeID, Edge>.Values {
            return _outEdges.values
        }
        
        internal var _inEdges = [EdgeID: Edge]()
        
        internal var _outEdges = [EdgeID: Edge]()
        
        var value: N?

        init(_ id: NodeID, _ name: String?, _ value: N?) {
            self.id = id
            self.name = name
            self.value = value
        }
    }
        
    class Edge: CustomStringConvertible {
        
        /// Graph-assigned identifier. Unique within any one graph.
        let id: EdgeID
        
        weak var source: Node!
        
        weak var destination: Node!
        
        /// User-assignable identifier
        var name: String?
        
        var description: String {
            if let name = name {
                return name
            }
            else {
                return "Edge \(id)"
            }
        }
        
        var value: E? = nil
        
        init(_ id: EdgeID, _ source: Node, _ destination: Node, _ name: String?, _ value: E?) {
            self.id = id
            self.source = source
            self.destination = destination
            self.name = name
            self.value = value
        }
    }
        
    var nodes: Dictionary<NodeID, Node>.Values {
        return _nodes.values
    }
    
    var edges: Dictionary<EdgeID, Edge>.Values {
        return _edges.values
    }
    
    private var _nodes = [NodeID: Node]()
    
    private var _nextNodeID = 0
    
    private var _edges = [EdgeID: Edge]()
    
    private var _nextEdgeID = 0
        
    mutating func addNode(name: String? = nil, value: N? = nil) -> Node {
        let id = _nextNodeID
        _nextNodeID += 1
        
        let newNode = Node(id, name, value)
        _nodes[id] = newNode
        return newNode
    }
    
    mutating func removeNode(_ id: NodeID) {
        if let Node = _nodes.removeValue(forKey: id) {
            for edge in Node.inEdges {
                removeEdge(edge.id)
            }
            for edge in Node.outEdges {
                removeEdge(edge.id)
            }
        }
    }
    
    /// source and destination MUST be nodes in this graph
    mutating func addEdge(_ source: Node, _ destination: Node, name: String? = nil, value: E? = nil) -> Edge {
        let id = _nextEdgeID
        _nextEdgeID += 1
        
        let newEdge = Edge(id, source, destination, name, value)
        _edges[id] = newEdge
        source._outEdges[id] = newEdge
        destination._inEdges[id] = newEdge
        return newEdge
    }
    
    mutating func removeEdge(_ id: EdgeID) {
        if let edge = _edges.removeValue(forKey: id) {
            edge.source._outEdges.removeValue(forKey: id)
            edge.destination._inEdges.removeValue(forKey: id)
        }
    }
}

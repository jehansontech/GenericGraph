//
//  Graph.swift
//  GenericGraph
//
//  Created by James Hanson on 10/4/20.
//

import Foundation

public typealias NodeID = Int

public typealias EdgeID = Int

public struct Graph<N, E> {
    
    public class Node: CustomStringConvertible {

        /// Graph-assigned identifier. Unique within any one graph.
        public let id: NodeID
        
        public var description: String {
            return "Node \(id)"
        }
        
        /// number of in-edges
        public var inDegree: Int {
            return _inEdges.count
        }
        
        /// number of out-edges
        public var outDegree: Int {
            return _outEdges.count
        }
        
        /// total number of edges
        public var degree: Int {
            return _inEdges.count + _outEdges.count
        }
        
        public var inEdges: Dictionary<EdgeID, Edge>.Values {
            return _inEdges.values
        }
        
        public var outEdges: Dictionary<EdgeID, Edge>.Values {
            return _outEdges.values
        }
        
        internal var _inEdges = [EdgeID: Edge]()
        
        internal var _outEdges = [EdgeID: Edge]()
        
        public var value: N?

        public init(_ id: NodeID, _ value: N?) {
            self.id = id
            self.value = value
        }
        
        /// returns array containing sources of all in-edges and destinations of all out-edges
        public func neighbors() -> [Node] {
            var nbrs = [Node]()
            for (_, edge) in _inEdges {
                nbrs.append(edge.source)
            }
            for (_, edge) in _outEdges {
                nbrs.append(edge.destination)
            }
            return nbrs;
        }
    }
        
    public class Edge: CustomStringConvertible {
        
        /// Graph-assigned identifier. Unique within any one graph.
        public let id: EdgeID
        
        public weak var source: Node!
        
        public weak var destination: Node!
        
        public var description: String {
            return "Edge \(id)"
        }
        
        public var value: E? = nil
        
        public init(_ id: EdgeID, _ source: Node, _ destination: Node, _ value: E?) {
            self.id = id
            self.source = source
            self.destination = destination
            self.value = value
        }
    }
        
    public var nodes: Dictionary<NodeID, Node>.Values {
        return _nodes.values
    }
    
    public var edges: Dictionary<EdgeID, Edge>.Values {
        return _edges.values
    }
    
    private var _nodes = [NodeID: Node]()
    
    private var _nextNodeID = 0
    
    private var _edges = [EdgeID: Edge]()
    
    private var _nextEdgeID = 0
        
    public init() {}
    
    public mutating func addNode(value: N? = nil) -> Node {
        let id = _nextNodeID
        _nextNodeID += 1
        
        let newNode = Node(id, value)
        _nodes[id] = newNode
        return newNode
    }
    
    public mutating func removeNode(_ id: NodeID) {
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
    public mutating func addEdge(_ source: Node, _ destination: Node, value: E? = nil) -> Edge {
        let id = _nextEdgeID
        _nextEdgeID += 1
        
        let newEdge = Edge(id, source, destination, value)
        _edges[id] = newEdge
        source._outEdges[id] = newEdge
        destination._inEdges[id] = newEdge
        return newEdge
    }
    
    public mutating func removeEdge(_ id: EdgeID) {
        if let edge = _edges.removeValue(forKey: id) {
            edge.source._outEdges.removeValue(forKey: id)
            edge.destination._inEdges.removeValue(forKey: id)
        }
    }
}

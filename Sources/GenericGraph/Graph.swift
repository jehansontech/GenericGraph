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
}

public class Graph<N, E> {
    
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
        
        public var degree: Int {
            return inDegree + outDegree
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
        
        public func inEdge(withID id: EdgeID) -> Edge? {
            return _inEdges[id]
        }
        
        public func outEdge(withID id: EdgeID) -> Edge? {
            return _outEdges[id]
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
    
    public class Edge: CustomStringConvertible  {
        
        /// Graph-assigned identifier. Unique within any one graph.
        public let id: EdgeID
        
        public var description: String {
            return "Edge \(id)"
        }
        
        public weak var source: Node!
        
        public weak var destination: Node!
        
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
    
    public func node(withID id: NodeID) -> Node? {
        return _nodes[id]
    }
    
    @discardableResult public func addNode(value: N? = nil) -> Node {
        let id = _nextNodeID
        _nextNodeID += 1
        
        let newNode = Node(id, value)
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
    
    public func edge(withID id: EdgeID) -> Edge? {
        return _edges[id]
    }
    
    /// source and destination MUST be nodes in this graph
    @discardableResult public func addEdge(_ source: Node, _ destination: Node, value: E? = nil) -> Edge {
        let id = _nextEdgeID
        _nextEdgeID += 1
        
        let newEdge = Edge(id, source, destination, value)
        _edges[id] = newEdge
        source._outEdges[id] = newEdge
        destination._inEdges[id] = newEdge
        return newEdge
    }
    
    @discardableResult public func addEdge(sourceID: NodeID, destinationID: NodeID, value: E? = nil) throws -> Edge {
        guard
            let source = _nodes[sourceID]
        else {
            throw GraphError.noSuchNode(id: sourceID)
        }
        
        guard
            let destination = _nodes[destinationID]
        else {
            throw GraphError.noSuchNode(id: destinationID)
        }
        
        return addEdge(source, destination, value: value)
    }
    
    /// removes the given edge. edge value is discarded
    public func removeEdge(_ id: EdgeID) {
        if let edge = _edges.removeValue(forKey: id) {
            edge.source._outEdges.removeValue(forKey: id)
            edge.destination._inEdges.removeValue(forKey: id)
        }
    }
}

//
//  Coders.swift
//  
//
//  Created by Jim Hanson on 10/5/20.
//

import Foundation

struct NodeCoder<N: Codable, E: Codable>: Codable {
            
    var value: N?
    
    var outEdges: [EdgeID]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(N.self, forKey: .value)
        self.outEdges = try container.decode([EdgeID].self, forKey: .outEdges)
    }
    
    init(_ node: Node<N, E>) {
        self.value = node.value
        self.outEdges = [EdgeID]()
        for outEdge in node.outEdges {
            self.outEdges.append(outEdge.id)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case value
        case outEdges
    }
}

struct EdgeCoder<N: Codable, E: Codable>: Codable {
            
    let value: E?
    
    let destination: NodeID
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(E.self, forKey: .value)
        self.destination = try container.decode(NodeID.self, forKey: .destination)
    }
    
   init(_ edge: Edge<N, E>) {
        self.value = edge.value
        self.destination = edge.destination.id
    }
    
    enum CodingKeys: String, CodingKey {
        case value
        case destination
    }
}

public struct GraphCoder<N: Codable, E: Codable>: Codable {
    
    var nodes = [NodeID: NodeCoder<N, E>]()
    
    var edges = [EdgeID: EdgeCoder<N, E>]()
    
    public init() {}
    
    public init(_ graph: Graph<N, E>) {
        for node in graph.nodes {
            self.nodes[node.id] = NodeCoder(node)
        }
        for edge in graph.edges {
            self.edges[edge.id] = EdgeCoder(edge)
        }
    }

    public init(_ graph: Graph<N, E>, _ nodeIDs: Set<NodeID>) {
        for node in graph.nodes.filter({ nodeIDs.contains($0.id) }) {
            self.nodes[node.id] = NodeCoder(node)
        }
        for edge in graph.edges.filter({ nodeIDs.contains($0.origin.id) && nodeIDs.contains($0.destination.id)}) {
            self.edges[edge.id] = EdgeCoder(edge)
        }
    }

    public init(_ graph: Graph<N, E>, _ nodeID: NodeID, _ radius: Int) {
        if let neighborhood = graph.node(nodeID)?.neighborhood(radius: radius) {
            // to build up visited
            for _ in neighborhood {}
            self.init(graph, neighborhood.visited)
        }
        else {
            self.init()
        }
    }

    public func makeGraph() throws -> Graph<N, E> {
        let graph = Graph<N, E>()
        
        /// maps (node ID in coder) -> (node ID in graph)
        var coderNodeIDToGraphNodeID = [NodeID: NodeID]()
        
        // Add all the nodes.
        for (coderNodeID, nodeCoder) in self.nodes {
            let graphNode = graph.addNode(value: nodeCoder.value)
            coderNodeIDToGraphNodeID[coderNodeID] = graphNode.id
        }
        
        // Add all the edges
        for (coderNodeID, nodeCoder) in self.nodes {
            let graphOriginNodeID = coderNodeIDToGraphNodeID[coderNodeID]!
            for coderOutEdgeID in nodeCoder.outEdges {
                
                guard
                    let outEdgeCoder = self.edges[coderOutEdgeID]
                else {
                    throw GraphError.noSuchEdge(id: coderOutEdgeID)
                }

                guard
                    let graphDestinationNodeID = coderNodeIDToGraphNodeID[outEdgeCoder.destination]
                else {
                    throw GraphError.noSuchNode(id: outEdgeCoder.destination)
                }
                    
                try graph.addEdge(graphOriginNodeID,
                                  graphDestinationNodeID,
                                  value: outEdgeCoder.value)
            }
        }
        
        return graph
    }
}

//
//  GraphSpec.swift
//  
//
//  Created by James Hanson on 10/5/20.
//

import Foundation

enum GraphSpecError: Error {
    case noSuchEdge(id: EdgeID)
    case noSuchNode(id: NodeID)
}


public struct GraphSpec<N: Codable, E: Codable>: Codable {
    
    struct NodeSpec: Codable {
                
        var value: N?
        
        var outEdges: [EdgeID]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.value = try container.decode(N.self, forKey: .value)
            self.outEdges = try container.decode([EdgeID].self, forKey: .outEdges)
        }
        
        init(_ node: Graph<N,E>.Node) {
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
    
    struct EdgeSpec: Codable {
                
        let value: E?
        
        let destination: NodeID
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.value = try container.decode(E.self, forKey: .value)
            self.destination = try container.decode(NodeID.self, forKey: .destination)
        }
        
        init(_ edge: Graph<N,E>.Edge) {
            self.value = edge.value
            self.destination = edge.destination.id
        }
        
        enum CodingKeys: String, CodingKey {
            case value
            case destination
        }
    }
    
    var nodes = [NodeID: NodeSpec]()
    
    var edges = [EdgeID: EdgeSpec]()
    
    public init() {}
    
    public init(_ graph: Graph<N, E>) {
        for node in graph.nodes {
            self.nodes[node.id] = NodeSpec(node)
        }
        for edge in graph.edges {
            self.edges[edge.id] = EdgeSpec(edge)
        }
    }
    
    public func buildGraph() throws -> Graph<N, E> {
        let graph = Graph<N, E>()
        
        /// maps (node ID in spec) -> (node ID in graph)
        var nodeSpecIDToGraphNodeID = [NodeID: NodeID]()
        
        // Add all the nodes.
        for (nodeSpecID, nodeSpec) in self.nodes {
            let graphNode = graph.addNode(value: nodeSpec.value)
            nodeSpecIDToGraphNodeID[nodeSpecID] = graphNode.id
        }
        
        // Add all the edges
        for (nodeSpecID, nodeSpec) in self.nodes {
            let graphSourceNodeID = nodeSpecIDToGraphNodeID[nodeSpecID]!
            for outEdgeSpecID in nodeSpec.outEdges {
                
                guard
                    let outEdgeSpec = self.edges[outEdgeSpecID]
                else {
                    throw GraphSpecError.noSuchEdge(id: outEdgeSpecID)
                }

                guard
                    let graphDestinationNodeID = nodeSpecIDToGraphNodeID[outEdgeSpec.destination]
                else {
                    throw GraphSpecError.noSuchNode(id: outEdgeSpec.destination)
                }
                    
                try graph.addEdge(sourceID: graphSourceNodeID,
                                  destinationID: graphDestinationNodeID,
                                  value: outEdgeSpec.value)
            }
        }
        
        return graph
    }
}

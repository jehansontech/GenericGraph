//
//  Coders.swift
//  GenericGraph
//
//  Created by Jim Hanson on 3/15/21.
//

import Foundation


public enum GraphCodingKeys: String, CodingKey {
    case nodeNumber
    case edgeNumber
    case value
    case target
    case nodes
    case outEdges
}

// ===================================================
// MARK:- Encoding delegates
// ===================================================

///
///
///
public protocol EncodingDelegate: Encodable {
    associatedtype GraphType: Graph
    
    var graph: GraphType { get }
    
    func encode(to encoder: Encoder) throws
    
    func encodeNodeValue(_ value: GraphType.NodeType.ValueType?,
                         _ container: inout KeyedEncodingContainer<GraphCodingKeys>) throws

    
    func encodeEdgeValue(_ value: GraphType.EdgeType.ValueType?,
                         _ container: inout KeyedEncodingContainer<GraphCodingKeys>) throws

}

extension EncodingDelegate {
    
    func encode(to encoder: Encoder) throws {
        var graphContainer = encoder.container(keyedBy: GraphCodingKeys.self)
        var nodesContainer = graphContainer.nestedUnkeyedContainer(forKey: .nodes)
        
        for node in graph.nodes {
            var nodeContainer = nodesContainer.nestedContainer(keyedBy: GraphCodingKeys.self)
            try nodeContainer.encode(node.nodeNumber, forKey: .nodeNumber)
            try encodeNodeValue(node.value, &nodeContainer)
            
            var outEdgesContainer = nodeContainer.nestedUnkeyedContainer(forKey: .outEdges)
            for edge in node.outEdges {
                var edgeContainer = outEdgesContainer.nestedContainer(keyedBy: GraphCodingKeys.self)
                try edgeContainer.encode(edge.edgeNumber, forKey: .edgeNumber)
                try edgeContainer.encode(edge.target.nodeNumber, forKey: .target)
                try encodeEdgeValue(edge.value, &edgeContainer)
            }
        }
    }
}


///
///
///
struct EncodingDelegate_NoValues<G: Graph> : EncodingDelegate {
   
    typealias G = GraphType
    
    let graph: G
    
    init(_ graph: G) {
        self.graph = graph
    }
    
    func encodeNodeValue(_ value: GraphType.NodeType.ValueType?,
                         _ container: inout KeyedEncodingContainer<GraphCodingKeys>) throws {
    }
    
    func encodeEdgeValue(_ value: GraphType.EdgeType.ValueType?,
                         _ container: inout KeyedEncodingContainer<GraphCodingKeys>) throws {
    }
}

///
///
///
struct EncodingDelegate_NodeValues<G: Graph>: EncodingDelegate where G.NodeType.ValueType: Encodable {
 
    typealias G = GraphType

    let graph: G

    init(_ graph: G) {
        self.graph = graph
    }
    
    func encodeNodeValue(_ value: GraphType.NodeType.ValueType?,
                         _ container: inout KeyedEncodingContainer<GraphCodingKeys>) throws {
        try container.encodeIfPresent(value, forKey: .value)
    }
    
    func encodeEdgeValue(_ value: GraphType.EdgeType.ValueType?,
                         _ container: inout KeyedEncodingContainer<GraphCodingKeys>) throws {
    }
}


///
///
///
struct EncodingDelegate_EdgeValues<G: Graph>: EncodingDelegate where G.EdgeType.ValueType: Encodable {
  
    typealias G = GraphType

    let graph: G

    init(_ graph: G) {
        self.graph = graph
    }
    
    func encodeNodeValue(_ value: GraphType.NodeType.ValueType?,
                         _ container: inout KeyedEncodingContainer<GraphCodingKeys>) throws {
    }
    
    func encodeEdgeValue(_ value: GraphType.EdgeType.ValueType?,
                         _ container: inout KeyedEncodingContainer<GraphCodingKeys>) throws {
        try container.encodeIfPresent(value, forKey: .value)
    }
}

///
///
///
struct EncodingDelegate_BothValues<G: Graph>: EncodingDelegate where
    G.NodeType.ValueType: Encodable, G.EdgeType.ValueType: Encodable {

    typealias G = GraphType

    let graph: G

    init(_ graph: G) {
        self.graph = graph
    }
    
    func encodeNodeValue(_ value: GraphType.NodeType.ValueType?,
                         _ container: inout KeyedEncodingContainer<GraphCodingKeys>) throws {
        try container.encodeIfPresent(value, forKey: .value)
    }
    
    func encodeEdgeValue(_ value: GraphType.EdgeType.ValueType?,
                         _ container: inout KeyedEncodingContainer<GraphCodingKeys>) throws {
        try container.encodeIfPresent(value, forKey: .value)
    }
}


// ===================================================
// MARK: - Graph extensions for encoding
// ===================================================

extension Graph {
    
    public func makeEncodingDelegate() -> some EncodingDelegate {
        return EncodingDelegate_NoValues<Self>(self)
    }
}

extension Graph where NodeType.ValueType: Encodable {

    public func makeEncodingDelegate() -> some EncodingDelegate {
        return EncodingDelegate_NodeValues<Self>(self)
    }
}

extension Graph where EdgeType.ValueType: Encodable {

    public func makeEncodingDelegate() -> some EncodingDelegate {
        return EncodingDelegate_EdgeValues<Self>(self)
    }
}

extension Graph where NodeType.ValueType: Encodable, EdgeType.ValueType: Encodable {

    public func makeEncodingDelegate() -> some EncodingDelegate {
        return EncodingDelegate_BothValues<Self>(self)
    }
}


// ===================================================
// MARK:- Decoding helpers & delegates
// ===================================================

public struct GraphElementMapper {

    /// key = old node number (e.g., decoded from file); value = new node number (e.g., added to graph)
    public var newNodeNumbers = [Int: Int]()

    /// key = old edge number (e.g., decoded from file); value = new edge number (e.g., added to graph)
    public var newEdgeNumbers = [Int: Int]()

    public init() {}
}


///
///
///
public protocol GraphDecodingDelegate: Decodable {
    associatedtype NodeValueType
    associatedtype EdgeValueType
    typealias NodeType = BaseGraphNode<NodeValueType, EdgeValueType>
    typealias EdgeType = BaseGraphEdge<NodeValueType, EdgeValueType>

    var graph: BaseGraph<NodeValueType, EdgeValueType> { get }

    var elementMapper: GraphElementMapper { get set }

    mutating func buildGraph(from decoder: Decoder) throws

    mutating func buildGraph(_ graphContainer: KeyedDecodingContainer<GraphCodingKeys>) throws

    /// node is the node into which the decoded value will be passed
    mutating func decodeNodeValue(_ container: inout KeyedDecodingContainer<GraphCodingKeys>, _ node: NodeType) throws -> NodeValueType?

    /// edge is the edge into which the decoded value will be passed
    mutating func decodeEdgeValue(_ container: inout KeyedDecodingContainer<GraphCodingKeys>, _ edge: EdgeType) throws -> EdgeValueType?
}


///
///
///
extension GraphDecodingDelegate {
    
    public mutating func buildGraph(from decoder: Decoder) throws {
        try buildGraph(try decoder.container(keyedBy: GraphCodingKeys.self))
    }

    public mutating func buildGraph(_ graphContainer: KeyedDecodingContainer<GraphCodingKeys>) throws {
        var nodesContainer = try graphContainer.nestedUnkeyedContainer(forKey: .nodes)
        while !nodesContainer.isAtEnd {
            var nodeContainer = try nodesContainer.nestedContainer(keyedBy: GraphCodingKeys.self)
            
            let decodedNodeNumber = try nodeContainer.decode(Int.self, forKey: .nodeNumber)
            let createdNode = findOrCreateNode(decodedNodeNumber)
            createdNode.value = try decodeNodeValue(&nodeContainer, createdNode)

            var outEdgesContainer = try nodeContainer.nestedUnkeyedContainer(forKey: .outEdges)
            while !outEdgesContainer.isAtEnd {
                var edgeContainer = try outEdgesContainer.nestedContainer(keyedBy: GraphCodingKeys.self)
                let decodedEdgeNumber = try edgeContainer.decode(Int.self, forKey: .edgeNumber)
                let decodedTargetNodeNumber = try edgeContainer.decode(Int.self, forKey: .target)
                let targetNode = findOrCreateNode(decodedTargetNodeNumber)
                let createdEdge = try graph.addEdge(createdNode.nodeNumber, targetNode.nodeNumber)
                elementMapper.newEdgeNumbers[decodedEdgeNumber] = createdEdge.edgeNumber
                createdEdge.value = try decodeEdgeValue(&edgeContainer, createdEdge)
            }
        }
    }
    
    public mutating func findOrCreateNode(_ decodedNodeNumber: Int) -> BaseGraph<NodeValueType, EdgeValueType>.NodeType {
        if let createdNodeNumber = elementMapper.newNodeNumbers[decodedNodeNumber] {
            return graph.nodes[createdNodeNumber]!
        }
        else {
            let createdNode = graph.addNode()
            elementMapper.newNodeNumbers[decodedNodeNumber] = createdNode.nodeNumber
            return createdNode
        }
    }
    
}


///
///
///
public struct GraphDecoding_NoValues<N, E>: GraphDecodingDelegate {
    public typealias NodeValueType = N
    public typealias EdgeValueType = E
    
    public var graph = BaseGraph<N, E>()

    public var elementMapper = GraphElementMapper()

    public init(from decoder: Decoder) throws {
        try buildGraph(from: decoder)
    }
    
    public func decodeNodeValue(_ container: inout KeyedDecodingContainer<GraphCodingKeys>, _ node: NodeType) throws -> N? {
        return nil
    }
    
    public func decodeEdgeValue(_ container: inout KeyedDecodingContainer<GraphCodingKeys>, _ edge: EdgeType) throws -> E? {
        return nil
    }
}


///
///
///
public struct GraphDecoding_NodeValues<N, E>: GraphDecodingDelegate where N: Decodable {
    public typealias NodeValueType = N
    public typealias EdgeValueType = E
    
    public var graph = BaseGraph<N, E>()
    
    public var elementMapper = GraphElementMapper()

    public init(from decoder: Decoder) throws {
        try buildGraph(from: decoder)
    }
    
    public func decodeNodeValue(_ container: inout KeyedDecodingContainer<GraphCodingKeys>, _ node: NodeType) throws -> N? {
        return try container.decodeIfPresent(N.self, forKey: .value)
    }
    
    public func decodeEdgeValue(_ container: inout KeyedDecodingContainer<GraphCodingKeys>, _ edge: EdgeType) throws -> E? {
        return nil
    }
}


///
///
///
public struct GraphDecoding_EdgeValues<N, E>: GraphDecodingDelegate where E: Decodable {
    public typealias NodeValueType = N
    public typealias EdgeValueType = E
    
    public var graph = BaseGraph<N, E>()
    
    public var elementMapper = GraphElementMapper()

    public init(from decoder: Decoder) throws {
        try buildGraph(from: decoder)
    }
    
    public func decodeNodeValue(_ container: inout KeyedDecodingContainer<GraphCodingKeys>, _ node: NodeType) throws -> N? {
        return nil
    }
    
    public func decodeEdgeValue(_ container: inout KeyedDecodingContainer<GraphCodingKeys>, _ edge: EdgeType) throws -> E? {
        return try container.decodeIfPresent(E.self, forKey: .value)
    }
}


///
///
///
public struct GraphDecoding_AllValues<N, E>: GraphDecodingDelegate where N: Decodable, E: Decodable {
    public typealias NodeValueType = N
    public typealias EdgeValueType = E
    
    public var graph = BaseGraph<N, E>()

    public var elementMapper = GraphElementMapper()

    public init(from decoder: Decoder) throws {
        try buildGraph(from: decoder)
    }
    
    public func decodeNodeValue(_ container: inout KeyedDecodingContainer<GraphCodingKeys>, _ node: NodeType) throws -> N? {
        return try container.decodeIfPresent(N.self, forKey: .value)
    }
    
    public func decodeEdgeValue(_ container: inout KeyedDecodingContainer<GraphCodingKeys>, _ edge: EdgeType) throws -> E? {
        return try container.decodeIfPresent(E.self, forKey: .value)
    }
}


// ===================================================
// MARK: - BaseGraph extensions for decoding
// ===================================================

extension BaseGraph {


    public class func decodingDelegateType(_ nType: N.Type, _ eType: E.Type) -> GraphDecoding_NoValues<N, E>.Type {
        return GraphDecoding_NoValues<N, E>.self
    }
}


extension BaseGraph where N: Decodable {
    
    public class func decodingDelegateType(_ nType: N.Type, _ eType: E.Type) -> GraphDecoding_NodeValues<N, E>.Type {
        return GraphDecoding_NodeValues<N, E>.self
    }
}


extension BaseGraph where E: Decodable {
    
    public class func decodingDelegateType(_ nType: N.Type, _ eType: E.Type) -> GraphDecoding_EdgeValues<N, E>.Type {
        return GraphDecoding_EdgeValues<N, E>.self
    }
}


extension BaseGraph where N: Decodable, E: Decodable {
    
    public class func decodingDelegateType(_ nType: N.Type, _ eType: E.Type) -> GraphDecoding_AllValues<N, E>.Type {
        return GraphDecoding_AllValues<N, E>.self
    }
}

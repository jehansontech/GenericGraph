//
//  File.swift
//  
//
//  Created by Jim Hanson on 3/15/21.
//

import XCTest
@testable import GenericGraph

fileprivate class Foo: CustomStringConvertible {
    
    let label: String
    
    init(_ label: String) {
        self.label = label
    }
    
    public var description: String {
        return "Foo \(label)"
    }
}

final class CoderTests: XCTestCase {

    func test_encodeWithNoValues() throws {
        let graph = BaseGraph<Foo, Foo>()
        let n0 = graph.addNode(Foo("n0"))
        let n1 = graph.addNode(Foo("n1"))
        let n2 = graph.addNode(Foo("n2"))
        try graph.addEdge(n0.nodeNumber, n1.nodeNumber, Foo("e01"))
        try graph.addEdge(n1.nodeNumber, n2.nodeNumber, Foo("e12"))
        try graph.addEdge(n2.nodeNumber, n0.nodeNumber, Foo("e20"))

        let encoder = JSONEncoder()
        let data = try encoder.encode(graph.makeEncodingDelegate())
        let json = String(data: data, encoding: .utf8)!

        // TODO verify json
    }

    func test_encodeWithNodeValues() throws {
        let graph = BaseGraph<String, Foo>()
        let n0 = graph.addNode("n0")
        let n1 = graph.addNode("n1")
        let n2 = graph.addNode("n2")
        try graph.addEdge(n0.nodeNumber, n1.nodeNumber, Foo("e01"))
        try graph.addEdge(n1.nodeNumber, n2.nodeNumber, Foo("e12"))
        try graph.addEdge(n2.nodeNumber, n0.nodeNumber, Foo("e20"))
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(graph.makeEncodingDelegate())
        let json = String(data: data, encoding: .utf8)!

        // TODO verify json
    }
    
    func test_encodeWithEdgeValues() throws {
        let graph = BaseGraph<Foo, String>()
        let n0 = graph.addNode(Foo("n0"))
        let n1 = graph.addNode(Foo("n1"))
        let n2 = graph.addNode(Foo("n2"))
        try graph.addEdge(n0.nodeNumber, n1.nodeNumber, "e01")
        try graph.addEdge(n1.nodeNumber, n2.nodeNumber, "e12")
        try graph.addEdge(n2.nodeNumber, n0.nodeNumber, "e20")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(graph.makeEncodingDelegate())
        let json = String(data: data, encoding: .utf8)!

        // TODO verify json
    }
    
    func test_encodeWithBothValues() throws {
        let graph = BaseGraph<String, String>()
        let n0 = graph.addNode("n0")
        let n1 = graph.addNode("n1")
        let n2 = graph.addNode("n2")
        try graph.addEdge(n0.nodeNumber, n1.nodeNumber, "e01")
        try graph.addEdge(n1.nodeNumber, n2.nodeNumber, "e12")
        try graph.addEdge(n2.nodeNumber, n0.nodeNumber, "e20")

        let encoder = JSONEncoder()
        let data = try encoder.encode(graph.makeEncodingDelegate())
        let json = String(data: data, encoding: .utf8)!

        // TODO verify json
    }

    func test_decodeWithNoValues() throws {
        let json =
            """
            {
                "nodes": [
                    {
                        "nodeNumber":0,
                        "outEdges": [
                            { "edgeNumber": 0, "target": 1 }
                        ]
                    },
                    {
                        "nodeNumber": 1,
                        "outEdges": [
                            { "edgeNumber": 1, "target": 2 }
                        ]
                    },
                    {
                        "nodeNumber": 2,
                        "outEdges": [
                            { "edgeNumber": 2, "target": 0 }
                        ]
                    }
                ]
            }
            """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let graph = try decoder.decode(BaseGraph.decodingDelegateType(Foo.self, Foo.self), from: data).graph

        XCTAssertEqual(graph.nodes.count, 3)
        for node in graph.nodes {
            XCTAssertEqual(node.inDegree, 1)
            XCTAssertEqual(node.outDegree, 1)
            XCTAssertNil(node.value)
        }

        XCTAssertEqual(graph.edges.count, 3)
        for edge in graph.edges {
            XCTAssertNil(edge.value)
        }
    }
    
    func test_decodeWithNodeValues() throws {
        let json =
            """
            {
                "nodes": [
                    {
                        "nodeNumber":0,
                        "value": "n0",
                        "outEdges": [
                            { "edgeNumber": 0, "target": 1 }
                        ]
                    },
                    {
                        "nodeNumber": 1,
                        "value": "n1",
                        "outEdges": [
                            { "edgeNumber": 1, "target": 2 }
                        ]
                    },
                    {
                        "nodeNumber": 2,
                        "value": "n2",
                        "outEdges": [
                            { "edgeNumber": 2, "target": 0 }
                        ]
                    }
                ]
            }
            """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let graph = try decoder.decode(BaseGraph.decodingDelegateType(String.self, Foo.self), from: data).graph

        XCTAssertEqual(graph.nodes.count, 3)
        for node in graph.nodes {
            XCTAssertEqual(node.inDegree, 1)
            XCTAssertEqual(node.outDegree, 1)
            XCTAssertNotNil(node.value)
        }

        XCTAssertEqual(graph.edges.count, 3)
        for edge in graph.edges {
            XCTAssertNil(edge.value)
        }
    }
    
    func test_decodeWithEdgeValues() throws {
        let json =
            """
            {
                "nodes": [
                    {
                        "nodeNumber":0,
                        "outEdges": [
                            { "edgeNumber": 0, "value": "e01", "target": 1 }
                        ]
                    },
                    {
                        "nodeNumber": 1,
                        "outEdges": [
                            { "edgeNumber": 1, "value": "e12", "target": 2 }
                        ]
                    },
                    {
                        "nodeNumber": 2,
                        "outEdges": [
                            { "edgeNumber": 2, "value": "e20", "target": 0 }
                        ]
                    }
                ]
            }
            """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let graph = try decoder.decode(BaseGraph.decodingDelegateType(Foo.self, String.self), from: data).graph

        XCTAssertEqual(graph.nodes.count, 3)
        for node in graph.nodes {
            XCTAssertEqual(node.inDegree, 1)
            XCTAssertEqual(node.outDegree, 1)
            XCTAssertNil(node.value)
        }

        XCTAssertEqual(graph.edges.count, 3)
        for edge in graph.edges {
            XCTAssertNotNil(edge.value)
        }
    }

    func test_decodeWithBothValues() throws {
        let json =
            """
            {
                "nodes": [
                    {
                        "nodeNumber":0,
                        "value": "n0",
                        "outEdges": [
                            { "edgeNumber": 0, "value": "e01", "target": 1 }
                        ]
                    },
                    {
                        "nodeNumber": 1,
                        "value": "n1",
                        "outEdges": [
                            { "edgeNumber": 1, "value": "e12", "target": 2 }
                        ]
                    },
                    {
                        "nodeNumber": 2,
                        "value": "n2",
                        "outEdges": [
                            { "edgeNumber": 2, "value": "e20", "target": 0 }
                        ]
                    }
                ]
            }
            """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let graph = try decoder.decode(BaseGraph.decodingDelegateType(String.self, String.self), from: data).graph

        XCTAssertEqual(graph.nodes.count, 3)
        for node in graph.nodes {
            XCTAssertEqual(node.inDegree, 1)
            XCTAssertEqual(node.outDegree, 1)
            XCTAssertNotNil(node.value)
        }

        XCTAssertEqual(graph.edges.count, 3)
        for edge in graph.edges {
            XCTAssertNotNil(edge.value)
        }
    }

    func test_roundTripWithNoValues() throws {
        let graph1 = BaseGraph<Foo, Foo>()
        let n0 = graph1.addNode(Foo("n0"))
        let n1 = graph1.addNode(Foo("n1"))
        let n2 = graph1.addNode(Foo("n2"))
        try graph1.addEdge(n0.nodeNumber, n1.nodeNumber, Foo("e01"))
        try graph1.addEdge(n1.nodeNumber, n2.nodeNumber, Foo("e12"))
        try graph1.addEdge(n2.nodeNumber, n0.nodeNumber, Foo("e20"))

        let encoder = JSONEncoder()
        let data = try encoder.encode(graph1.makeEncodingDelegate())
        let json = String(data: data, encoding: .utf8)!

        // TODO verify json

        let decoder = JSONDecoder()
        let graph2 = try decoder.decode(BaseGraph.decodingDelegateType(Foo.self, Foo.self), from: data).graph

        XCTAssertEqual(graph2.nodes.count, 3)
        for node in graph2.nodes {
            XCTAssertEqual(node.inDegree, 1)
            XCTAssertEqual(node.outDegree, 1)
            XCTAssertNil(node.value)
        }

        XCTAssertEqual(graph2.edges.count, 3)
        for edge in graph2.edges {
            XCTAssertNil(edge.value)
        }
    }

    func test_roundTripWithNodeValues() throws {
        let graph1 = BaseGraph<String, Foo>()
        let n0 = graph1.addNode("n0")
        let n1 = graph1.addNode("n1")
        let n2 = graph1.addNode("n2")
        try graph1.addEdge(n0.nodeNumber, n1.nodeNumber, Foo("e01"))
        try graph1.addEdge(n1.nodeNumber, n2.nodeNumber, Foo("e12"))
        try graph1.addEdge(n2.nodeNumber, n0.nodeNumber, Foo("e20"))

        let encoder = JSONEncoder()
        let data = try encoder.encode(graph1.makeEncodingDelegate())
        let json = String(data: data, encoding: .utf8)!

        // TODO verify json

        let decoder = JSONDecoder()
        let graph2 = try decoder.decode(BaseGraph.decodingDelegateType(String.self, Foo.self), from: data).graph

        XCTAssertEqual(graph2.nodes.count, 3)
        for node in graph2.nodes {
            XCTAssertEqual(node.inDegree, 1)
            XCTAssertEqual(node.outDegree, 1)
            XCTAssertNotNil(node.value)
        }

        XCTAssertEqual(graph2.edges.count, 3)
        for edge in graph2.edges {
            XCTAssertNil(edge.value)
        }
    }

    func test_roundTripWithEdgeValues() throws {
        let graph1 = BaseGraph<Foo, String>()
        let n0 = graph1.addNode(Foo("n0"))
        let n1 = graph1.addNode(Foo("n1"))
        let n2 = graph1.addNode(Foo("n2"))
        try graph1.addEdge(n0.nodeNumber, n1.nodeNumber, "e01")
        try graph1.addEdge(n1.nodeNumber, n2.nodeNumber, "e12")
        try graph1.addEdge(n2.nodeNumber, n0.nodeNumber, "e20")

        let encoder = JSONEncoder()
        let data = try encoder.encode(graph1.makeEncodingDelegate())
        let json = String(data: data, encoding: .utf8)!

        // TODO verify json

        let decoder = JSONDecoder()
        let graph2 = try decoder.decode(BaseGraph.decodingDelegateType(Foo.self, String.self), from: data).graph

        XCTAssertEqual(graph2.nodes.count, 3)
        for node in graph2.nodes {
            XCTAssertEqual(node.inDegree, 1)
            XCTAssertEqual(node.outDegree, 1)
            XCTAssertNil(node.value)
        }

        XCTAssertEqual(graph2.edges.count, 3)
        for edge in graph2.edges {
            XCTAssertNotNil(edge.value)
        }
    }

    func test_roundTripWithBothValues() throws {
        let graph1 = BaseGraph<String, String>()
        let n0 = graph1.addNode("n0")
        let n1 = graph1.addNode("n1")
        let n2 = graph1.addNode("n2")
        try graph1.addEdge(n0.nodeNumber, n1.nodeNumber, "e01")
        try graph1.addEdge(n1.nodeNumber, n2.nodeNumber, "e12")
        try graph1.addEdge(n2.nodeNumber, n0.nodeNumber, "e20")

        let encoder = JSONEncoder()
        let data = try encoder.encode(graph1.makeEncodingDelegate())
        let json = String(data: data, encoding: .utf8)!

        // TODO verify json

        let decoder = JSONDecoder()
        let graph2 = try decoder.decode(BaseGraph.decodingDelegateType(String.self, String.self), from: data).graph

        XCTAssertEqual(graph2.nodes.count, 3)
        for node in graph2.nodes {
            XCTAssertEqual(node.inDegree, 1)
            XCTAssertEqual(node.outDegree, 1)
            XCTAssertNotNil(node.value)
        }

        XCTAssertEqual(graph2.edges.count, 3)
        for edge in graph2.edges {
            XCTAssertNotNil(edge.value)
        }
    }

    static var allTests = [
        ("test_encodeWithNoValues", test_encodeWithNoValues),
        ("test_encodeWithNodeValues", test_encodeWithNodeValues),
        ("test_encodeWithEdgeValues", test_encodeWithEdgeValues),
        ("test_encodeWithBothValues", test_encodeWithBothValues),
        ("test_decodeWithNoValues", test_decodeWithNoValues),
        ("test_decodeWithNodeValues", test_decodeWithNodeValues),
        ("test_decodeWithEdgeValues", test_decodeWithEdgeValues),
        ("test_roundTripWithBothValues", test_roundTripWithBothValues),
        ("test_roundTripWithNoValues", test_roundTripWithNoValues),
        ("test_roundTripWithNodeValues", test_roundTripWithNodeValues),
        ("test_roundTripWithEdgeValues", test_roundTripWithEdgeValues),
        ("test_roundTripWithBothValues", test_roundTripWithBothValues)
    ]
}

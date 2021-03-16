//
//  CoderTests.swift
//  
//
//  Created by Jim Hanson on 10/5/20.
//

import XCTest
@testable import GenericGraph

final class CoderTests1: XCTestCase {

    func testCoderCreation() throws {
        let graph = Graph<String, Int>()
        let graphNode = graph.addNode(value: "graphNode")
        let graphEdge = try graph.addEdge(graphNode.id, graphNode.id, value: 99)

        let spec = GraphCoder<String, Int>(graph)
        XCTAssertEqual(spec.nodes.count, 1)
        XCTAssertEqual(spec.nodes.first!.value.value, graphNode.value)
        XCTAssertEqual(spec.nodes.first!.value.outEdges.count, 1)
        XCTAssertEqual(spec.nodes.first!.value.outEdges.first!, spec.edges.first!.key)
        XCTAssertEqual(spec.edges.count, 1)
        XCTAssertEqual(spec.edges.first!.value.value, graphEdge.value)
        XCTAssertEqual(spec.edges.first!.value.destination, spec.nodes.first!.key)
    }
    
    func testEncoding() throws {
        let graph = Graph<String, String>()
        let n1 = graph.addNode(value: "n1")
        let n2 = graph.addNode(value: "n2")
        try graph.addEdge(n1.id, n2.id, value: "e1")
        try graph.addEdge(n2.id, n1.id, value: "e2")

        let spec = GraphCoder<String, String>(graph)
        let encoder = JSONEncoder()
        let data = try encoder.encode(spec)
        let jsonString = String(data: data, encoding: .utf8)!
        print("jsonString=\(jsonString)")
        
        // Not bothering with assertions on the string
    }
    
    func testDecoding() throws {
        let json = """
{
    "nodes": {
        "0": {
            "value": "n1",
            "outEdges": [0]
        },
        "1": {
            "value": "n2",
            "outEdges": [1]
        }
    },
    "edges": {
        "0": {
            "value":"e1",
            "destination": 1
        },
        "1": {
            "value": "e2",
            "destination": 0
        }
    }
}
""".data(using: .utf8)!
     
        let decoder = JSONDecoder()
        let spec = try decoder.decode(GraphCoder<String, String>.self, from: json)
        _ = try spec.makeGraph()
    }
    
    func testRoundTrip() throws {
        let graph1 = Graph<String, String>()
        let n1 = graph1.addNode(value: "n1")
        let n2 = graph1.addNode(value: "n2")
        try graph1.addEdge(n1.id, n2.id, value: "e1")
        try graph1.addEdge(n2.id, n1.id, value: "e2")
        
        let encoder = JSONEncoder()
        let specToEncode = GraphCoder<String, String>(graph1)
        let encodedData = try encoder.encode(specToEncode)
        let jsonString = String(data: encodedData, encoding: .utf8)!

        let decoder = JSONDecoder()
        let decodedData = jsonString.data(using: .utf8)!
        let spec = try decoder.decode(GraphCoder<String, String>.self, from: decodedData)
        let graph2 = try spec.makeGraph()

        XCTAssertEqual(graph2.nodeCount, 2)
        XCTAssertEqual(graph2.edgeCount, 2)
    }
    
    static var allTests = [
        ("testCoderCreation", testCoderCreation),
        ("testEncoding", testEncoding),
        ("testDecoding", testDecoding),
        ("testRoundTrip", testRoundTrip),
    ]
}

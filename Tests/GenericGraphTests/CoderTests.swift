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
    
    let printer = GraphPrinter()
    
    func test_encodeWithBothValues() throws {
        let g0 = BaseGraph<String, String>()
        let n0 = g0.addNode("n0")
        let n1 = g0.addNode("n1")
        let n2 = g0.addNode("n2")
        try g0.addEdge(n0.id, n1.id, "e01")
        try g0.addEdge(n1.id, n2.id, "e12")
        try g0.addEdge(n2.id, n0.id, "e20")
        
        let delegate0 = g0.makeEncodingDelegate()
        printString("delegate0", "\(delegate0)")
        printString("delegate0.graph", "\(delegate0.graph)")
        
        let encoder = JSONEncoder()
        let data0 = try encoder.encode(delegate0)
        let json0 = String(data: data0, encoding: .utf8)!
        printString("json0", json0)
    }
    
    func test_encodeWithNodeValues() throws {
        let g0 = BaseGraph<String, Foo>()
        let n0 = g0.addNode("n0")
        let n1 = g0.addNode("n1")
        let n2 = g0.addNode("n2")
        try g0.addEdge(n0.id, n1.id, Foo("e01"))
        try g0.addEdge(n1.id, n2.id, Foo("e12"))
        try g0.addEdge(n2.id, n0.id, Foo("e20"))
        
        let delegate0 = g0.makeEncodingDelegate()
        printString("delegate0", "\(delegate0)")
        printString("delegate0.graph", "\(delegate0.graph)")
        
        let encoder = JSONEncoder()
        let data0 = try encoder.encode(delegate0)
        let json0 = String(data: data0, encoding: .utf8)!
        printString("json0", json0)
    }
    
    func test_encodeWithEdgeValues() throws {
        let g0 = BaseGraph<Foo, String>()
        let n0 = g0.addNode(Foo("n0"))
        let n1 = g0.addNode(Foo("n1"))
        let n2 = g0.addNode(Foo("n2"))
        try g0.addEdge(n0.id, n1.id, "e01")
        try g0.addEdge(n1.id, n2.id, "e12")
        try g0.addEdge(n2.id, n0.id, "e20")
        
        let delegate0 = g0.makeEncodingDelegate()
        printString("delegate0", "\(delegate0)")
        printString("delegate0.graph", "\(delegate0.graph)")
        
        let encoder = JSONEncoder()
        let data0 = try encoder.encode(delegate0)
        let json0 = String(data: data0, encoding: .utf8)!
        printString("json0", json0)
    }
    
    func test_encodeWithNoValues() throws {
        let g0 = BaseGraph<Foo, Foo>()
        let n0 = g0.addNode(Foo("n0"))
        let n1 = g0.addNode(Foo("n1"))
        let n2 = g0.addNode(Foo("n2"))
        try g0.addEdge(n0.id, n1.id, Foo("e01"))
        try g0.addEdge(n1.id, n2.id, Foo("e12"))
        try g0.addEdge(n2.id, n0.id, Foo("e20"))
        
        let delegate0 = g0.makeEncodingDelegate()
        printString("delegate0", "\(delegate0)")
        printString("delegate0.graph", "\(delegate0.graph)")
        
        let encoder = JSONEncoder()
        let data0 = try encoder.encode(delegate0)
        let json0 = String(data: data0, encoding: .utf8)!
        printString("json0", json0)
    }
    
    func test_decodeWithNoValues() throws {
        let json =
            """
            {
                "nodes": [
                    {
                        "id":0,
                        "outEdges": [
                            { "target": 1 }
                        ]
                    },
                    {
                        "id": 1,
                        "outEdges": [
                            { "target": 2 }
                        ]
                    },
                    {
                        "id": 2,
                        "outEdges": [
                            { "target": 0 }
                        ]
                    }
                ]
            }
            """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let delegate = try decoder.decode(BaseGraph<Foo, Foo>.decodingDelegateType(), from: data)
        let graph = delegate.graph
        printGraph("graph", graph)
    }
    
    func test_decodeWithNodeValues() throws {
        let json =
            """
            {
                "nodes": [
                    {
                        "id":0,
                        "value": "n0",
                        "outEdges": [
                            { "target": 1 }
                        ]
                    },
                    {
                        "id": 1,
                        "value": "n1",
                        "outEdges": [
                            { "target": 2 }
                        ]
                    },
                    {
                        "id": 2,
                        "value": "n2",
                        "outEdges": [
                            { "target": 0 }
                        ]
                    }
                ]
            }
            """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let delegate = try decoder.decode(BaseGraph<String, Foo>.decodingDelegateType(), from: data)
        let graph = delegate.graph
        printGraph("graph", graph)
    }
    
    func test_decodeWithEdgeValues() throws {
        let json =
            """
            {
                "nodes": [
                    {
                        "id":0,
                        "outEdges": [
                            { "value": "e01", "target": 1 }
                        ]
                    },
                    {
                        "id": 1,
                        "outEdges": [
                            { "value": "e12", "target": 2 }
                        ]
                    },
                    {
                        "id": 2,
                        "outEdges": [
                            { "value": "e20", "target": 0 }
                        ]
                    }
                ]
            }
            """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let delegate = try decoder.decode(BaseGraph<Foo, String>.decodingDelegateType(), from: data)
        let graph = delegate.graph
        printGraph("graph", graph)
    }

    func test_decodeWithBothValues() throws {
        let json =
            """
            {
                "nodes": [
                    {
                        "id":0,
                        "value": "n0",
                        "outEdges": [
                            { "value": "e01", "target": 1 }
                        ]
                    },
                    {
                        "id": 1,
                        "value": "n1",
                        "outEdges": [
                            { "value": "e12", "target": 2 }
                        ]
                    },
                    {
                        "id": 2,
                        "value": "n2",
                        "outEdges": [
                            { "value": "e20", "target": 0 }
                        ]
                    }
                ]
            }
            """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let delegate = try decoder.decode(BaseGraph<String, String>.decodingDelegateType(), from: data)
        let graph = delegate.graph
        printGraph("graph", graph)
    }

    func printString(_ label: String, _ s: String) {
        printer.printString("---- \(label) ----", 0)
        printer.printString(s, 1)
    }
    
    func printGraph<GraphType: Graph>(_ label: String, _ graph: GraphType) {
        printer.printString("---- \(label) ----", 0)
        printer.printGraph(graph, 1)
        
    }
    
    static var allTests = [
        ("test_encodeWithNoValues", test_encodeWithNoValues),
        ("test_encodeWithNodeValues", test_encodeWithNodeValues),
        ("test_encodeWithEdgeValues", test_encodeWithEdgeValues),
        ("test_encodeWithBothValues", test_encodeWithBothValues),
        ("test_decodeWithNoValues", test_decodeWithNoValues),
        ("test_decodeWithNodeValues", test_decodeWithNodeValues),
        ("test_decodeWithEdgeValues", test_decodeWithEdgeValues),
        ("test_decodeWithBothValues", test_decodeWithBothValues)
    ]

}

//
//  File.swift
//  
//
//  Created by Jim Hanson on 3/9/21.
//

import Foundation

import XCTest
@testable import GenericGraph

final class TraversalTests: XCTestCase {
    
    func test_components() throws {
        let printer = GraphPrinter()
        let graph = BaseGraph<String, String>()
        
        let A0 = graph.addNode("A0")
        let A1 = graph.addNode("A1")
        let A2 = graph.addNode("A2")
        try graph.addEdge(A0.id, A1.id, "a01")
        try graph.addEdge(A1.id, A2.id, "a12")
        try graph.addEdge(A2.id, A0.id, "a20")
        
        let B0 = graph.addNode("B0")
        let B1 = graph.addNode("B1")
        try graph.addEdge(B0.id, B1.id, "b01")

        graph.addNode("C0")
        
        printer.printString("graph", 0)
        printer.printGraph(graph, 1)
        
        printer.printString("components", 0)
        var needsSep = false
        for component in graph.components() {
            if needsSep {
                printer.printSeparator(1)
            }
            printer.printGraph(component, 1)
            needsSep = true
        }
    }
    
    static var allTests = [
        ("test_componenets", test_components)
    ]

}

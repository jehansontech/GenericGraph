//
//  GraphPrinter.swift
//  
//
//  Created by Jim Hanson on 3/8/21.
//

import XCTest
@testable import GenericGraph

struct GraphPrinter {

    func printString(_ s: String, _ level: Int) {
        let indent = String(repeating: "    ", count: level)
        print("\(indent)\(s)")
    }
    
    func printSeparator(_ level: Int) {
        printString("----", level)
    }
    
    func printNode<NType: Node>(_ node: NType?, _ level: Int) {
        printNode(node, level, level+1)
    }
    
    func printNode<NType: Node>(_ node: NType?, _ level: Int, _ depth: Int) {
        if level > depth {
            return
        }
        
        if let node = node {
            printString("id = \(node.id)", level)
            if let nodeValue = node.value {
                printString("value = \(nodeValue)", level)
            }
            else {
                printString("value = nil", level)
            }
            
            printString("inDegree: \(node.inEdges.count)", level)
            if (level < depth && node.inEdges.count > 0) {
                printString("inEdges:", level)
                var needsSep = false
                for edge in node.inEdges {
                    if needsSep {
                        printSeparator(level+1)
                    }
                    printEdge(edge, level+1, depth)
                    needsSep = true
                }
            }
            
            printString("outDegree: \(node.outEdges.count)", level)
            if (level < depth && node.outEdges.count > 0) {
                printString("outEdges:", level)
                var needsSep = false
                for edge in node.outEdges {
                    if needsSep {
                        printSeparator(level+1)
                    }
                    printEdge(edge, level+1, depth)
                    needsSep = true
                }
            }
        }
        else {
            printString("nil", level)
        }
    }

    func printEdge<EType: Edge>(_ edge: EType?, _ level: Int) {
        printEdge(edge, level, level+1)
    }
    
    func printEdge<EType: Edge>(_ edge: EType?, _ level: Int, _ depth: Int) {
        if level > depth {
            return
        }
        
        if let edge = edge {
            printString("id = \(edge.id)", level)
            if let edgeValue = edge.value {
                printString("value = \(edgeValue)", level)
            }
            else {
                printString("value = nil", level)
            }
            if (level < depth) {
                printString("source:", level)
                printNode(edge.source, level+1, depth)
                printString("target:", level)
                printNode(edge.target, level+1, depth)
            }
        }
        else {
            printString("nil", level)
        }
    }
    
    func printGraph<GType: Graph>(_ graph: GType?, _ level: Int = 0) {
        printGraph(graph, level, level+2)
    }
    
    func printGraph<GType: Graph>(_ graph: GType?, _ level: Int = 0, _ depth: Int) {
        if (level > depth) {
            return
        }
        
        if let graph = graph {
            printString("nodeCount = \(graph.nodes.count)", level)
            printString("edgeCount = \(graph.edges.count)", level)
            if (level < depth && graph.nodes.count > 0) {
                printString("nodes:" , level)
                var needsSep = false
                for node in graph.nodes {
                    if needsSep {
                        printSeparator(level+1)
                    }
                    printNode(node, level+1, depth)
                    needsSep = true
                }
            }
            if (level < depth && graph.edges.count > 0) {
                printString("edges:", level)
                var needsSep = false
                for edge in graph.edges {
                    if needsSep {
                        printSeparator(level+1)
                    }
                    printEdge(edge, level+1, depth)
                    needsSep = true
                }
            }
        }
        else {
            printString("nil", level)
        }
    }
    
    func printStep<EdgeType: Edge>(_ step: Step<EdgeType>?, _ level: Int, _ depth: Int) {
        if (level > depth) {
            return
        }
        
        if let step = step {
            printString("edgeID = \(step.edgeID)", level)
            if let edgeValue = step.edgeValue {
                printString("edgeValue = \(edgeValue)", level)
            }
            else {
                printString("edgeValue = nil", level)
            }
            printString("heading = \(step.heading)", level)
            if (level < depth) {
                printString("origin:", level)
                printNode(step.origin, level+1, depth)
                printString("destination:", level)
                printNode(step.destination, level+1, depth)
            }
        }
        else {
            printString("nil", level)
        }
    }
}

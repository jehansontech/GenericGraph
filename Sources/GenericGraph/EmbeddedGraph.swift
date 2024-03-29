//
//  EmbeddedGraph.swift
//  GenericGraph
//
//  Created by Jim Hanson on 5/5/21.
//

import Foundation
import simd
import Wacoma

public protocol EmbeddedNodeValue {

    var location: SIMD3<Float> { get set }
}

extension Node where ValueType: EmbeddedNodeValue {

    var location: SIMD3<Float> {
        value?.location ?? .zero
    }
}

extension Step where EdgeType.NodeType.ValueType: EmbeddedNodeValue {

    var displacement: SIMD3<Float> {
        destination.location - origin.location
    }
}

extension Graph where NodeType.ValueType: EmbeddedNodeValue {

    public func makeBoundingBox() -> BoundingBox {
        var bbox: BoundingBox? = nil
        nodes.forEach {
            if let p = $0.value?.location {
                if bbox == nil {
                    bbox = BoundingBox(p)
                }
                else {
                    bbox!.cover(p)
                }
            }
        }
        return bbox ?? BoundingBox(SIMD3<Float>(0,0,0))
    }
}

public enum EmbeddedGraphError: Error {
    case noNodeAtLocation(location: SIMD3<Float>)
}

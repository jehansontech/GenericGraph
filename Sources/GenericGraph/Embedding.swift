//
//  Embedding.swift
//  
//
//  Created by Jim Hanson on 5/5/21.
//

import Foundation

protocol EmbeddableNodeValue {

    var location: SIMD3<Float> { get set }
}

extension Graph where
    NodeType.ValueType: EmbeddableNodeValue {

    func makeBoundingBox() -> BoundingBox {
        var bbox: BoundingBox? = nil
        for node in nodes {
            if let p = node.value?.location {
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

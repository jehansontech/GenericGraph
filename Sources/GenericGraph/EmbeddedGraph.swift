//
//  EmbeddedGraph.swift
//  GenericGraph
//
//  Created by Jim Hanson on 5/5/21.
//

import Foundation
import simd

public protocol EmbeddedNodeValue {

    var location: SIMD3<Float> { get set }
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

    public func findNearbyNodes(point: SIMD3<Float>,
                                radius: Float,
                                excluding filter: (NodeType) -> Bool) -> [NodeType] {
        var hits = [NodeType]()
        nodes.forEach {
            if let nodeLocation = $0.value?.location,
            simd_distance(nodeLocation, point) <= radius,
            !filter($0) {
                hits.append($0)
            }
        }
        return hits
    }

    public func findNearestNode(rayOrigin: SIMD3<Float>,
                                rayDirection: SIMD3<Float>,
                                zRange: ClosedRange<Float>)  -> NodeType? {
        var nearestNode: NodeType? = nil
        var bestD2 = Float.greatestFiniteMagnitude
        var bestRayZ = Float.greatestFiniteMagnitude
        nodes.forEach {
            if let nodeLocation = $0.value?.location {

                let nodeDisplacement = nodeLocation - rayOrigin

                // rayZ is the z-distance from rayOrigin to the point on the ray
                // that is closest to the node
                let rayZ = simd_dot(nodeDisplacement, rayDirection)
                // print("\(node) rayZ: \(rayZ)")

                // STET: nodeLocation.z does not work
                if zRange.contains(rayZ) {
                    // nodeD2 is the square of the distance from the node to the ray
                    // (i.e., to the point on the ray that is closest to the node)
                    let nodeD2 = simd_dot(nodeDisplacement, nodeDisplacement) - rayZ * rayZ
                    // print("\(node) distance to ray: \(sqrt(nodeD2))")

                    // smaller is better
                    if (nodeD2 < bestD2 || (nodeD2 == bestD2 && rayZ < bestRayZ)) {
                        bestD2 = nodeD2
                        bestRayZ = rayZ
                        nearestNode = $0
                    }
                }
            }
        }
        return nearestNode
    }

}

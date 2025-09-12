//
//  EmbeddedGraph.swift
//  GenericGraph
//
//  Created by Jim Hanson on 5/5/21.
//

import Foundation
import simd
import Wacoma

public protocol EmbeddedValue {

    var location: SIMD3<Float> { get set }
}

extension Node where ValueType: EmbeddedValue {

    public var location: SIMD3<Float> {
        value?.location ?? .zero
    }
}

extension Edge where NodeType.ValueType: EmbeddedValue {

    public var length: Float {
        distance(source.location, target.location)
    }

    public var displacement: SIMD3<Float> {
        target.location - source.location
    }
}

extension Step where EdgeType.NodeType.ValueType: EmbeddedValue {

    public var displacement: SIMD3<Float> {
        destination.location - origin.location
    }
}

extension Graph where NodeType.ValueType: EmbeddedValue {

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
        return bbox ?? BoundingBox(.zero)
    }
}

public enum EmbeddedGraphError: Error {
    case noNodeAtLocation(location: SIMD3<Float>)
}

public struct BoundingBox: Codable, Sendable, Equatable {

    public var xMin: Float
    public var yMin: Float
    public var zMin: Float

    public var xMax: Float
    public var yMax: Float
    public var zMax: Float

    public init(x0: Float, y0: Float, z0: Float, x1: Float, y1: Float, z1: Float) {
        xMin = Float.minimum(x0, x1)
        yMin = Float.minimum(y0, y1)
        zMin = Float.minimum(z0, z1)

        xMax = Float.maximum(x0, x1)
        yMax = Float.maximum(y0, y1)
        zMax = Float.maximum(z0, z1)
    }

    public init(_ point: SIMD3<Float>) {
        xMin = point.x
        yMin = point.y
        zMin = point.z

        xMax = point.x
        yMax = point.y
        zMax = point.z
    }

    public init(center: SIMD3<Float>, halfSize: Float) {
        xMin = center.x - halfSize
        yMin = center.y - halfSize
        zMin = center.z - halfSize

        xMax = center.x + halfSize
        yMax = center.y + halfSize
        zMax = center.z + halfSize
    }

    public init(_ p0: SIMD3<Float>, _ p1: SIMD3<Float>) {
        xMin = Swift.min(p0.x, p1.x)
        yMin = Swift.min(p0.y, p1.y)
        zMin = Swift.min(p0.z, p1.z)

        xMax = Swift.max(p0.x, p1.x)
        yMax = Swift.max(p0.y, p1.y)
        zMax = Swift.max(p0.z, p1.z)
    }

    public mutating func cover(_ point: SIMD3<Float>) {
        if point.x < xMin {
            xMin = point.x
        }
        if point.y < yMin {
            yMin = point.y
        }
        if point.z < zMin {
            zMin = point.z
        }

        if point.x > xMax {
            xMax = point.x
        }
        if point.y > yMax {
            yMax = point.y
        }
        if point.z > zMax {
            zMax = point.z
        }
    }

    public mutating func cover(_ bbox: BoundingBox) {
        self.cover(bbox.min)
        self.cover(bbox.max)
    }
}

extension BoundingBox: CustomStringConvertible {

    public var description: String {
        "min: \(self.min.prettyString) max:\(self.max.prettyString)"
    }
}

extension BoundingBox {

    public static func unitCube() -> BoundingBox {
        return BoundingBox(x0: 0, y0: 0, z0: 0, x1: 1, y1: 1, z1: 1)
    }

    public static func centeredCube(_ size: Float = 1) -> BoundingBox {
        let w = (size > 0) ? size/2 : 0.5
        return BoundingBox(x0: -w, y0: -w, z0: -w, x1: w, y1: w, z1: w)
    }
}

extension BoundingBox {

    public var xCenter: Float {
        xMin + xSize/2
    }

    public var yCenter: Float {
        yMin + ySize/2
    }

    public var zCenter: Float {
        zMin + zSize/2
    }

    public var xSize: Float {
        xMax - xMin
    }

    public var ySize: Float {
        yMax - yMin
    }

    public var zSize: Float {
        zMax - zMin
    }

    public var min: SIMD3<Float> {
        return SIMD3<Float>(xMin, yMin, zMin)
    }

    public var max: SIMD3<Float> {
        return SIMD3<Float>(xMax, yMax, zMax)
    }

    public var center: SIMD3<Float> {
        return SIMD3<Float>(xCenter, yCenter, zCenter)
    }

    public var size: SIMD3<Float>  {
        return SIMD3<Float>(xSize, ySize, zSize)
    }

    public var xBounds: ClosedRange<Float> {
        return xMin...xMax
    }

    public var yBounds: ClosedRange<Float> {
        return yMin...yMax
    }

    public var zBounds: ClosedRange<Float> {
        return zMin...zMax
    }

    public var corners: [SIMD3<Float>] {
        [
            SIMD3<Float>(xMin, yMin, zMin),
            SIMD3<Float>(xMin, yMin, zMax),
            SIMD3<Float>(xMin, yMax, zMin),
            SIMD3<Float>(xMin, yMax, zMax),
            SIMD3<Float>(xMax, yMin, zMin),
            SIMD3<Float>(xMax, yMin, zMax),
            SIMD3<Float>(xMax, yMax, zMin),
            SIMD3<Float>(xMax, yMax, zMax)
        ]
    }

    /// Radius of a sphere that contains the bbox, i.e., max distance from center to any corner
    public var radius: Float {
        var rx: Float = 0
        let cx = self.center
        for corner in corners {
            let d = simd_distance(corner, cx)
            if d > rx {
                rx = d
            }
        }
        return rx
    }
}

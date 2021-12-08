//
//  BoundingBox.swift
//  ArcWorld iOS
//
//  Created by James Hanson on 9/29/20.
//  Copyright © 2020 J.E. Hanson Technologies LLC. All rights reserved.
//

import Foundation

public struct BoundingBox {

    public var xMin: Float
    public var yMin: Float
    public var zMin: Float

    public var xMax: Float
    public var yMax: Float
    public var zMax: Float

    public var xCenter: Float {
        (xMin + xMax) / 2
    }

    public var yCenter: Float {
        (yMin + yMax) / 2
    }

    public var zCenter: Float {
        (zMin + zMax) / 2
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

    public var xBounds: ClosedRange<Float> {
        return xMin...xMax
    }

    public var yBounds: ClosedRange<Float> {
        return yMin...yMax
    }

    public var zBounds: ClosedRange<Float> {
        return zMin...zMax
    }

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
}

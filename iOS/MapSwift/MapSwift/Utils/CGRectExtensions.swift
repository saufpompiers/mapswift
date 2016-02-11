//
//  CGRectExtensions.swift
//  MapSwift
//
//  Created by David de Florinier on 09/02/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

extension MapSwift {
    struct Position  {
        enum Horizontal {
            case Left, Right
        }
        enum Vertical {
            case Top, Bottom
        }
        enum Measurement {
            case Absolute, Proportional
        }
        typealias Origin  = (horizontal: Horizontal, vertical:Vertical)
        typealias Point = (type:Measurement, origin:Origin, point:CGPoint)
    }
    public enum RelativeNodePosition:String {
        case Above = "above", Below = "below", Horizontal = "horizontal"
        static var allValues:[RelativeNodePosition] {
            return [.Above, .Below, .Horizontal]
        }
    }
}
extension CGRect {
    func mapswift_CGPointForPositionPoint(point:MapSwift.Position.Point) -> CGPoint {
        var dx:CGFloat = point.point.x
        var dy:CGFloat = point.point.y
        if point.type == MapSwift.Position.Measurement.Proportional {
            dx = self.width * dx
            dy = self.height * dy
        }
        if point.origin.horizontal == MapSwift.Position.Horizontal.Right {
            dx = self.width - dx
        }
        if point.origin.vertical == MapSwift.Position.Vertical.Bottom {
            dy = self.height - dy
        }
        return CGPointMake(self.origin.x + dx, self.origin.y + dy)
    }
    func mapswift_relativePositionOfPoint(to:CGPoint, tolerance:CGFloat = 10) -> MapSwift.RelativeNodePosition {
        if to.y > self.maxY + tolerance {
            return MapSwift.RelativeNodePosition.Below
        }
        if to.y < self.minY - tolerance {
            return MapSwift.RelativeNodePosition.Above
        }
        return MapSwift.RelativeNodePosition.Horizontal
    }
    func mapswift_pointsforFromAndToCGPoints(from:CGPoint, to:CGPoint) -> (from:MapSwift.Position.Point, to:MapSwift.Position.Point) {
        let type = MapSwift.Position.Measurement.Absolute
        func pointFromCGPointWithOrigin(point:CGPoint, origin:MapSwift.Position.Origin) -> MapSwift.Position.Point {
            var x = point.x - self.origin.x
            var y = point.y - self.origin.y
            if origin.horizontal == MapSwift.Position.Horizontal.Right {
                x = self.width - x
            }
            if origin.vertical == MapSwift.Position.Vertical.Bottom {
                y = self.height - y
            }
            return MapSwift.Position.Point(type:type, origin:origin, point:CGPointMake(x,y))
        }
        var p1h = MapSwift.Position.Horizontal.Left
        var p1v = MapSwift.Position.Vertical.Top
        var p2h = MapSwift.Position.Horizontal.Right
        var p2v = MapSwift.Position.Vertical.Bottom
        if (from.y > to.y) {
            p1v = MapSwift.Position.Vertical.Bottom
            p2v = MapSwift.Position.Vertical.Top
        }
        if (from.x > to.x) {
            p1h = MapSwift.Position.Horizontal.Right
            p2h = MapSwift.Position.Horizontal.Left
        }
        let fromOrigin = MapSwift.Position.Origin(horizontal:p1h, vertical:p1v)
        let toOrigin = MapSwift.Position.Origin(horizontal:p2h, vertical:p2v)
        let fromPoint = pointFromCGPointWithOrigin(from, origin:fromOrigin)
        let toPoint = pointFromCGPointWithOrigin(to, origin:toOrigin)

        return (from:fromPoint, to:toPoint)
    }
    static func mapswift_rectContainingPoints(from:CGPoint, to:CGPoint, minSize:CGFloat) -> CGRect {
        let minX = min(from.x, to.x)
        let maxX = max(from.x, to.x)
        let minY = min(from.y, to.y)
        let maxY = max(from.y, to.y)
        let height = max(maxY - minY, minSize)
        let width = max(maxX - minX, minSize)
        return CGRectMake(minX, minY, width, height)
    }
}

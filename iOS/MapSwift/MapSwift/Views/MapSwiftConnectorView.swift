//
//  MapSwiftConnectorView.swift
//  MapSwift
//
//  Created by David de Florinier on 10/02/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

class MapSwiftConnectorView: UIView {
    typealias Connector = (nodes:MapSwiftNodeConnector, from:MapSwift.Position.Point, to: MapSwift.Position.Point, controlPoint:MapSwift.Position.Point, curveType:String)
    private var connectorInfo:(connector:Connector, line:MapSwift.LineStyle, inset:CGFloat)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
    }
    func showConnector(connector:Connector, line:MapSwift.LineStyle, inset:CGFloat) {
        self.connectorInfo = (connector:connector, line:line, inset:inset)
        self.setNeedsDisplay()
    }
    var connector:MapSwiftNodeConnector? {
        get {
            if let connectorInfo = self.connectorInfo {
                return connectorInfo.connector.nodes
            }
            return nil
        }
    }
    private var connectorBounds:CGRect {
        get {
            if let connectorInfo = self.connectorInfo {
                let inset = connectorInfo.inset
                return CGRectInset(self.bounds, inset, inset)
            }
            return self.bounds
        }
    }
    private func containedPoint(point:CGPoint) -> CGPoint {
        return CGPointMake(min(max(point.x, 0), self.bounds.width), min(max(point.y, 0), self.bounds.height))
    }

    private func drawStaightConnector(ctx:CGContext, fromPoint:CGPoint, toPoint:CGPoint) {
        CGContextMoveToPoint(ctx, fromPoint.x , fromPoint.y )
        CGContextAddLineToPoint(ctx, toPoint.x, toPoint.y)
        CGContextStrokePath(ctx)
    }

    private func drawQuadraticConnector(ctx:CGContext, fromPoint:CGPoint, toPoint:CGPoint, connector:Connector) {
        CGContextMoveToPoint(ctx, fromPoint.x , fromPoint.y )
        let controlPoint = containedPoint(connectorBounds.mapswift_CGPointForPositionPoint(connector.controlPoint))
        CGContextAddQuadCurveToPoint(ctx, controlPoint.x , controlPoint.y , toPoint.x , toPoint.y )
        CGContextStrokePath(ctx)
    }

    private func drawSCurveConnector(ctx:CGContext, fromPoint:CGPoint, toPoint:CGPoint) {
        let initialRadius:CGFloat = 10
        let minDiff:CGFloat = initialRadius * 2
        let dx:CGFloat = toPoint.x - fromPoint.x
        let dy:CGFloat = toPoint.y - fromPoint.y
        CGContextMoveToPoint(ctx, fromPoint.x , fromPoint.y )
        if abs(dx) < minDiff || abs(dy) < minDiff {
            CGContextAddQuadCurveToPoint(ctx, toPoint.x , fromPoint.y , toPoint.x , toPoint.y )
        } else {
            let signX = dx/abs(dx)
            let signY = dy/abs(dy)
            let incrementX = initialRadius * signX
            let incrementY = initialRadius * signY

            let cp1 = CGPointMake(incrementX + fromPoint.x, fromPoint.y)
            let p1 = CGPointMake(cp1.x, incrementY + fromPoint.y)
            CGContextAddQuadCurveToPoint(ctx, cp1.x , cp1.y , p1.x , p1.y)

            let rdx = toPoint.x - p1.x
            let cp2 = CGPointMake(toPoint.x - rdx, toPoint.y - incrementY)
            let cp3 = CGPointMake(toPoint.x - rdx, toPoint.y)
            CGContextAddCurveToPoint(ctx, cp2.x, cp2.y, cp3.x, cp3.y, toPoint.x, toPoint.y)
        }


        CGContextStrokePath(ctx)
    }
    override func drawRect(rect: CGRect) {
        if let connectorInfo = self.connectorInfo, ctx = UIGraphicsGetCurrentContext() {
            func containedPoint(point:CGPoint) -> CGPoint {
                return CGPointMake(min(max(point.x, 0), self.bounds.width), min(max(point.y, 0), self.bounds.height))
            }
            let inset = connectorInfo.inset
            let connectorBounds = CGRectInset(self.bounds, inset, inset)
            CGContextSetStrokeColorWithColor(ctx, connectorInfo.line.color.CGColor)
            CGContextSetLineWidth(ctx, connectorInfo.line.width)
            CGContextSetLineCap(ctx, CGLineCap.Round)
            let fromPoint = connectorBounds.mapswift_CGPointForPositionPoint(connectorInfo.connector.from)
            let toPoint = connectorBounds.mapswift_CGPointForPositionPoint(connectorInfo.connector.to)

            switch connectorInfo.connector.curveType {
                case "straight":
                    self.drawStaightConnector(ctx, fromPoint: fromPoint, toPoint: toPoint)
                case "s-curve":
                    self.drawSCurveConnector(ctx, fromPoint: fromPoint, toPoint: toPoint)
                default:
                    self.drawQuadraticConnector(ctx, fromPoint: fromPoint, toPoint: toPoint, connector: connectorInfo.connector)

            }
        }
    }

}

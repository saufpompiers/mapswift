//
//  MapSwiftConnectorView.swift
//  MapSwift
//
//  Created by David de Florinier on 10/02/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

class MapSwiftConnectorView: UIView {
    typealias Connector = (nodes:MapSwiftNodeConnector, from:MapSwift.Position.Point, to: MapSwift.Position.Point, controlPoints:[MapSwift.Position.Point])
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
    override func drawRect(rect: CGRect) {
        if let connectorInfo = self.connectorInfo {
            var controlPoints = connectorInfo.connector.controlPoints
            func containedPoint(point:CGPoint) -> CGPoint {
                return CGPointMake(min(max(point.x, 0), self.bounds.width), min(max(point.y, 0), self.bounds.height))
            }
            let inset = connectorInfo.inset
            let connectorBounds = CGRectInset(self.bounds, inset, inset)
            let ctx = UIGraphicsGetCurrentContext()
            CGContextSetStrokeColorWithColor(ctx, connectorInfo.line.color.CGColor)
            CGContextSetLineWidth(ctx, connectorInfo.line.width)
            CGContextSetLineCap(ctx, CGLineCap.Round)
            let startPoint = connectorBounds.mapswift_CGPointForPositionPoint(connectorInfo.connector.from)

            CGContextMoveToPoint(ctx, startPoint.x , startPoint.y )
            while controlPoints.count > 2 {
                let cp1 = containedPoint(connectorBounds.mapswift_CGPointForPositionPoint(controlPoints.removeFirst()))
                let cp2 = containedPoint(connectorBounds.mapswift_CGPointForPositionPoint(controlPoints.removeFirst()))
                let toPoint = containedPoint(connectorBounds.mapswift_CGPointForPositionPoint(controlPoints.removeFirst()))
                CGContextAddCurveToPoint(ctx, cp1.x , cp1.y , cp2.x , cp2.y , toPoint.x , toPoint.y )
            }
            let toPoint = connectorBounds.mapswift_CGPointForPositionPoint(connectorInfo.connector.to)
            if controlPoints.count > 1 {
                let cp1 = containedPoint(connectorBounds.mapswift_CGPointForPositionPoint(controlPoints.removeFirst()))
                let cp2 = containedPoint(connectorBounds.mapswift_CGPointForPositionPoint(controlPoints.removeFirst()))
                CGContextAddCurveToPoint(ctx, cp1.x , cp1.y , cp2.x , cp2.y , toPoint.x , toPoint.y )
            } else {
                let controlPoint = controlPoints.count > 0 ? containedPoint(connectorBounds.mapswift_CGPointForPositionPoint(controlPoints.removeFirst())) : toPoint
                CGContextAddQuadCurveToPoint(ctx, controlPoint.x , controlPoint.y , toPoint.x , toPoint.y )
            }
            CGContextStrokePath(ctx)

        }
    }

}

//
//  MapSwiftConnectorsView.swift
//  MapSwift
//
//  Created by David de Florinier on 05/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation
class MapSwiftConnectorsView : UIView {
    typealias ConnectorPath = (from:CGPoint, to:CGPoint, controlPoint:CGPoint)
    private var connectors:[String: MapSwiftNodeConnector] = [:]
    private var nodeRects:[String:CGRect] = [:]

    private func keyForConnector(connector:MapSwiftNodeConnector) -> String {
        return "\(connector.from)->\(connector.to)"
    }

    private func drawPathForConnector(from:MapSwiftNode, to:MapSwiftNode)  {
    }

    private func horizontalConnector(from:CGRect, to: CGRect) -> ConnectorPath {
        let inset = MapSwiftNodeView.BackgroundInset + MapSwiftNodeView.LabelInset
        var pointFrom = CGPointMake(from.maxX - inset, from.midY)
        var pointTo = CGPointMake(to.minX + inset, to.midY)
        if pointFrom.x > pointTo.x {
            pointFrom.x = from.minX + inset
            pointTo.x = to.maxX - inset
        }
        return ConnectorPath(from: pointFrom, to:pointTo, controlPoint:CGPointMake(pointFrom.x, pointTo.y))
    }
    private func calculateConnector(from:CGRect, to: CGRect) -> ConnectorPath {
        let tolerance:CGFloat = 10
        if abs(from.midY - to.midY) + tolerance < max(to.height, from.height * 0.75) {
            return horizontalConnector(from, to: to)
        }
        let inset = MapSwiftNodeView.BackgroundInset + MapSwiftNodeView.LabelInset
        let pointFrom = CGPointMake(from.midX, from.midY)
        var pointTo = CGPointMake(to.minX + inset, to.midY)
        if from.minX > to.minX {
            pointTo.x = to.maxX - inset
        }
        let initialOffset = 0.75 * (pointFrom.y - pointTo.y)
        let maxOffset = min(from.height, to.height) * 1.5
        let offset = max(-1 * maxOffset, min(maxOffset, initialOffset))

        return ConnectorPath(from: pointFrom, to:pointTo, controlPoint:CGPointMake(pointFrom.x, pointTo.y - offset))
    }
    func nodeRect(nodeId:String, nodeRect:CGRect?) {
        if let nodeRect = nodeRect {
            nodeRects[nodeId] = nodeRect
        } else {
            nodeRects.removeValueForKey(nodeId)
        }
        self.setNeedsDisplay()
    }
    func animateNodeRectWithDuration(duration:NSTimeInterval, nodeId:String, nodeRect:CGRect) {
        self.nodeRect(nodeId, nodeRect: nodeRect)
    }
    func addConnector(connector:MapSwiftNodeConnector) {
        self.connectors[keyForConnector(connector)] = connector
        self.setNeedsDisplay()
    }

    func removeConnector(connector:MapSwiftNodeConnector) {
        self.connectors.removeValueForKey(keyForConnector(connector))
        self.setNeedsDisplay()
    }
    override func drawRect(rect: CGRect) {
        self.clipsToBounds = false
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx,UIColor(hexString: "#4F4F4F").CGColor)
        CGContextSetLineWidth(ctx, 1.0)
        for (_, connector) in self.connectors {
                if let fromRect = nodeRects[connector.from], toRect = nodeRects[connector.to] {
                    let connectorPath = calculateConnector(fromRect, to: toRect)

//                    print("from:\(connector.from) rect:\(fromRect) to:\(connector.to) rect:\(toRect)")
                    CGContextMoveToPoint(ctx, connectorPath.from.x, connectorPath.from.y)
                    CGContextAddQuadCurveToPoint(ctx, connectorPath.controlPoint.x, connectorPath.controlPoint.y, connectorPath.to.x, connectorPath.to.y)

                    CGContextStrokePath(ctx)
                }
        }

    }
}
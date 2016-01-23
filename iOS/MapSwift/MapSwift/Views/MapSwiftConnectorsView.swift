//
//  MapSwiftConnectorsView.swift
//  MapSwift
//
//  Created by David de Florinier on 05/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation


extension UIColor {
    static func mapswift_colorForPosition(position:MapSwiftTheme.RelativeNodePosition) -> UIColor {
        switch position {
        case .Above:
            return UIColor.redColor()
        case .Below:
            return UIColor.blueColor()
        default:
            return UIColor.greenColor()
        }
    }
}
class MapSwiftConnectorsView : UIView {
    typealias ConnectorPath = (from:CGPoint, to:CGPoint, controlPoint:CGPoint)
    struct NodeConnectorInfo {
        let nodeRect:CGRect
        let styles:[String]
        let connectionStyle:MapSwiftTheme.ConnectionStyle
    }
    private var connectors:[String: MapSwiftNodeConnector] = [:]
    private var nodeConnectorInfoMap:[String:NodeConnectorInfo] = [:]

    private var _theme:MapSwiftTheme?
    var theme:MapSwiftTheme {
        get {
            if let theme = _theme {
                return theme
            }
            let defaultTheme = MapSwiftTheme.Default()
            _theme = defaultTheme
            return defaultTheme
        }
        set (val) {
            _theme = val
            for (nodeId, connectorInfo) in nodeConnectorInfoMap {
                nodeConnectorInfoMap[nodeId] = NodeConnectorInfo(nodeRect: connectorInfo.nodeRect, styles: connectorInfo.styles, connectionStyle: self.theme.nodeConnectionStyle(connectorInfo.styles))
            }
            self.setNeedsDisplay()
        }
    }


    private func keyForConnector(connector:MapSwiftNodeConnector) -> String {
        return "\(connector.from)->\(connector.to)"
    }


    private func horizontalConnector(from:CGRect, to: CGRect) -> ConnectorPath {
        let inset = MapSwiftNodeView.BackgroundInset + 5.0
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
        let inset = MapSwiftNodeView.BackgroundInset + 5.0
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
    func nodeConnectorInfo(nodeId:String, nodeRect:CGRect?, styles:[String]) {
        if let nodeRect = nodeRect {
            let connectorInfo = NodeConnectorInfo(nodeRect: nodeRect, styles: styles, connectionStyle: self.theme.nodeConnectionStyle(styles))
            nodeConnectorInfoMap[nodeId] = connectorInfo
        } else {
            nodeConnectorInfoMap.removeValueForKey(nodeId)
        }
        self.setNeedsDisplay()

    }

    func animateNodeRectWithDuration(duration:NSTimeInterval, nodeId:String, nodeRect:CGRect) {
        if let info = nodeConnectorInfoMap[nodeId] {
            nodeConnectorInfoMap[nodeId] = NodeConnectorInfo(nodeRect: nodeRect, styles: info.styles, connectionStyle: self.theme.nodeConnectionStyle(info.styles))
            self.setNeedsDisplay()
        }
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
        CGContextSetLineWidth(ctx, 1)
        for (_, connector) in self.connectors {
                if let fromInfo = nodeConnectorInfoMap[connector.from], toInfo = nodeConnectorInfoMap[connector.to] {
                    let connectorPath = calculateConnector(fromInfo.nodeRect, to: toInfo.nodeRect)
                    let pos = fromInfo.nodeRect.mapswift_relativePositionOfPoint(connectorPath.to)
                    let color = UIColor.mapswift_colorForPosition(pos)
                    CGContextSetStrokeColorWithColor(ctx,color.CGColor)
                    CGContextMoveToPoint(ctx, connectorPath.from.x, connectorPath.from.y)
                    CGContextAddQuadCurveToPoint(ctx, connectorPath.controlPoint.x, connectorPath.controlPoint.y, connectorPath.to.x, connectorPath.to.y)

                    CGContextStrokePath(ctx)
                }
        }

    }
}
//
//  MapSwiftConnectorsView.swift
//  MapSwift
//
//  Created by David de Florinier on 05/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation


extension UIColor {
    static func mapswift_colorForPosition(position:MapSwift.RelativeNodePosition) -> UIColor {
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

extension CGRect {
    func mapswift_connectionPointForJoinPositions(positions:MapSwift.ConnectionJoinPositions, relativePoint:CGPoint, cornerRadius:CGFloat, lineWidth:CGFloat) -> CGPoint {
        let inset = MapSwiftNodeView.BackgroundInset
        let xinset = inset + cornerRadius
        let halfLineWidth:CGFloat = 0.5 * lineWidth

        func getY(pos:MapSwift.ConnectionJoinPosition) -> CGFloat {
            switch pos {
            case MapSwift.ConnectionJoinPosition.Center:
                return self.midY
            case MapSwift.ConnectionJoinPosition.Base:
                return self.maxY  - inset - halfLineWidth
            case MapSwift.ConnectionJoinPosition.Nearest:
                if relativePoint.y > self.midY {
                    return self.maxY - inset
                }
                if relativePoint.y < self.midY {
                    return self.minY + inset
                }
                return self.midY
            case MapSwift.ConnectionJoinPosition.NearestInset:
                if relativePoint.y > self.midY {
                    return self.maxY - xinset
                }
                if relativePoint.y < self.midY {
                    return self.minY + xinset
                }
                return self.midY
            }
        }
        func getX(pos:MapSwift.ConnectionJoinPosition) -> CGFloat {
            switch pos {
            case MapSwift.ConnectionJoinPosition.Center:
                return self.midX
            case MapSwift.ConnectionJoinPosition.Nearest, MapSwift.ConnectionJoinPosition.Base:
                if relativePoint.x > self.midX {
                    return self.maxX - inset
                }
                if relativePoint.x < self.midX {
                    return self.minX + inset
                }
                return self.midX
            case  MapSwift.ConnectionJoinPosition.NearestInset:
                if relativePoint.x > self.midX {
                    return self.maxX - xinset
                }
                if relativePoint.x < self.midX {
                    return self.minX + xinset
                }
                return self.midX
            }
        }
        let x = getX(positions.h)
        let y = getY(positions.v)
        return CGPointMake(x,y)

    }
}

struct NodeConnectorInfo {
    let nodeRect:CGRect
    let styles:[String]
    let connectionStyle:MapSwift.ConnectionStyle
    let nodeStyle:MapSwift.NodeStyle
    func connectToPointForRectFrom(rectFrom:CGRect, lineWidth:CGFloat) -> CGPoint {
        let inset = MapSwiftNodeView.BackgroundInset
        let xinset = inset + self.nodeStyle.cornerRadius
        let halfLineWidth:CGFloat = 0.5 * lineWidth
        func getY(pos:MapSwift.ConnectionJoinPosition) -> CGFloat {
            switch pos {
            case MapSwift.ConnectionJoinPosition.Center:
                return self.nodeRect.midY
            case MapSwift.ConnectionJoinPosition.Base:
                return self.nodeRect.maxY - inset - halfLineWidth
            case MapSwift.ConnectionJoinPosition.Nearest:
                if rectFrom.minY > self.nodeRect.maxY {
                    return self.nodeRect.maxY - inset - halfLineWidth
                }
                if rectFrom.maxY < self.nodeRect.minY {
                    return self.nodeRect.minY + inset - halfLineWidth
                }
                return self.nodeRect.midY
            case MapSwift.ConnectionJoinPosition.NearestInset:
                if rectFrom.minY > self.nodeRect.maxY {
                    return self.nodeRect.maxY - xinset
                }
                if rectFrom.maxY < self.nodeRect.minY {
                    return self.nodeRect.minY + xinset
                }
                return self.nodeRect.midY
            }
        }
        func getX(pos:MapSwift.ConnectionJoinPosition) -> CGFloat {
            switch pos {
            case MapSwift.ConnectionJoinPosition.Center:
                return self.nodeRect.midX
            case MapSwift.ConnectionJoinPosition.Nearest, MapSwift.ConnectionJoinPosition.Base:
                if rectFrom.minX > self.nodeRect.midX {
                    return self.nodeRect.maxX - inset
                }
                if rectFrom.maxX < self.nodeRect.midX {
                    return self.nodeRect.minX + inset
                }
                return self.nodeRect.midX
            case  MapSwift.ConnectionJoinPosition.NearestInset:
                if rectFrom.minX > self.nodeRect.midX {
                    return self.nodeRect.maxX - xinset
                }
                if rectFrom.maxX < self.nodeRect.midX {
                    return self.nodeRect.minX + xinset
                }
                return self.nodeRect.midX
            }
        }
        let x = getX(self.connectionStyle.to.h)
        let y = getY(self.connectionStyle.to.v)
        return CGPointMake(x,y)
    }
    func connectionStyleFromForPosition(pos:MapSwift.RelativeNodePosition) -> MapSwift.ConnectionJoinPositions {
        switch pos {
        case MapSwift.RelativeNodePosition.Above:
            return self.connectionStyle.from.above
        case MapSwift.RelativeNodePosition.Below:
            return self.connectionStyle.from.below
        case MapSwift.RelativeNodePosition.Horizontal:
            return self.connectionStyle.from.horizontal
        }
    }
    func connectFromPointForPointTo(to:CGPoint, cornerRadius:CGFloat, lineWidth:CGFloat) -> CGPoint {
        let pos = self.nodeRect.mapswift_relativePositionOfPoint(to)
        let style = self.connectionStyleFromForPosition(pos)
        return self.nodeRect.mapswift_connectionPointForJoinPositions(style, relativePoint:to, cornerRadius: cornerRadius, lineWidth: lineWidth)
    }
}

class MapSwiftConnectorsView : UIView {
    typealias ConnectorPath = (from:CGPoint, to:CGPoint, controlPoint:CGPoint)

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
                nodeConnectorInfoMap[nodeId] = NodeConnectorInfo(nodeRect: connectorInfo.nodeRect, styles: connectorInfo.styles, connectionStyle: self.theme.nodeConnectionStyle(connectorInfo.styles), nodeStyle: self.theme.nodeStyle(connectorInfo.styles))
            }
            self.setNeedsDisplay()
        }
    }


    private func keyForConnector(connector:MapSwiftNodeConnector) -> String {
        return "\(connector.from)->\(connector.to)"
    }


    private func calculateConnector(from:NodeConnectorInfo, to: NodeConnectorInfo) -> ConnectorPath {
        let tolerance:CGFloat = 10
        let connectorBounds = CGRectInset(from.nodeRect.union(to.nodeRect), -30, -30)

        var connectorStyles:[String] = []
        if let style = to.connectionStyle.style {
            connectorStyles.append(style)
        }
        connectorStyles.append("default");

        let toPoint = to.connectToPointForRectFrom(from.nodeRect, lineWidth:to.connectionStyle.lineStyle.width)
        let pos = from.nodeRect.mapswift_relativePositionOfPoint(toPoint, tolerance: tolerance)
        let toRelativePosition = from.connectionStyleFromForPosition(pos)
        let fromPoint = from.nodeRect.mapswift_connectionPointForJoinPositions(toRelativePosition, relativePoint: toPoint, cornerRadius: from.nodeStyle.cornerRadius, lineWidth:to.connectionStyle.lineStyle.width)
        let controlPointMultipliers = self.theme.controlPointsForStylesAndPosition(connectorStyles, position: pos)
        var controlPoints:[CGPoint] = []
        let dx = toPoint.x - fromPoint.x
        let dy = toPoint.y - fromPoint.y
        for controlPointMultiplier in controlPointMultipliers {
            let x = (dx * controlPointMultiplier.width) + fromPoint.x
            let y = (dy * controlPointMultiplier.height) + fromPoint.y
            let controlPoint = CGPointMake(min(max(x, connectorBounds.minX), connectorBounds.maxX), min(max(y, connectorBounds.minY), connectorBounds.maxY))
            controlPoints.append(controlPoint)
        }
        if controlPoints.count == 0 {
            controlPoints.append(CGPointMake(fromPoint.x, fromPoint.y))
        }
        return ConnectorPath(from: fromPoint, to:toPoint, controlPoint:controlPoints.first!)

    }
    func nodeConnectorInfo(nodeId:String, nodeRect:CGRect?, styles:[String]) {
        if let nodeRect = nodeRect {
            let connectorInfo = NodeConnectorInfo(nodeRect: nodeRect, styles: styles, connectionStyle: self.theme.nodeConnectionStyle(styles), nodeStyle: self.theme.nodeStyle(styles))
            nodeConnectorInfoMap[nodeId] = connectorInfo
        } else {
            nodeConnectorInfoMap.removeValueForKey(nodeId)
        }
        self.setNeedsDisplay()

    }

    func animateNodeRectWithDuration(duration:NSTimeInterval, nodeId:String, nodeRect:CGRect) {
        if let info = nodeConnectorInfoMap[nodeId] {
            nodeConnectorInfoMap[nodeId] = NodeConnectorInfo(nodeRect: nodeRect, styles: info.styles, connectionStyle: self.theme.nodeConnectionStyle(info.styles), nodeStyle: info.nodeStyle)
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
        for (_, connector) in self.connectors {

                if let fromInfo = nodeConnectorInfoMap[connector.from], toInfo = nodeConnectorInfoMap[connector.to] {
                    let connectorPath = calculateConnector(fromInfo, to: toInfo)
                    CGContextSetStrokeColorWithColor(ctx,toInfo.connectionStyle.lineStyle.color.CGColor)
                    CGContextSetLineWidth(ctx, toInfo.connectionStyle.lineStyle.width)
                    CGContextSetLineCap(ctx, CGLineCap.Round)
                    CGContextMoveToPoint(ctx, connectorPath.from.x, connectorPath.from.y)
                    CGContextAddQuadCurveToPoint(ctx, connectorPath.controlPoint.x, connectorPath.controlPoint.y, connectorPath.to.x, connectorPath.to.y)

                    CGContextStrokePath(ctx)
                }
        }

    }
}
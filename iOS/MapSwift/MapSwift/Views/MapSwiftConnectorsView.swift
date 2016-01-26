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

extension CGRect {
    func mapswift_connectionPointForJoinPositions(positions:MapSwiftTheme.ConnectionJoinPositions, relativePoint:CGPoint) -> CGPoint {
        let inset = MapSwiftNodeView.BackgroundInset

        func getY(pos:MapSwiftTheme.ConnectionJoinPosition) -> CGFloat {
            switch pos {
            case MapSwiftTheme.ConnectionJoinPosition.Center:
                return self.midY
            case MapSwiftTheme.ConnectionJoinPosition.Base:
                return self.maxY  - inset - 0.5
            case MapSwiftTheme.ConnectionJoinPosition.Nearest:
                if relativePoint.y > self.midY {
                    return self.maxY - inset
                }
                if relativePoint.y < self.midY {
                    return self.minY + inset
                }
                return self.midY
            case  MapSwiftTheme.ConnectionJoinPosition.NearestInset:
                if relativePoint.y > self.midY {
                    return self.maxY - inset - 12
                }
                if relativePoint.y < self.midY {
                    return self.minY + inset + 12
                }
                return self.midY
            }
        }
        func getX(pos:MapSwiftTheme.ConnectionJoinPosition) -> CGFloat {
            switch pos {
            case MapSwiftTheme.ConnectionJoinPosition.Center:
                return self.midX
            case MapSwiftTheme.ConnectionJoinPosition.Nearest, MapSwiftTheme.ConnectionJoinPosition.Base:
                if relativePoint.x > self.midX {
                    return self.maxX - inset
                }
                if relativePoint.x < self.midX {
                    return self.minX + inset
                }
                return self.midX
            case  MapSwiftTheme.ConnectionJoinPosition.NearestInset:
                if relativePoint.x > self.midX {
                    return self.maxX - inset - 10
                }
                if relativePoint.x < self.midX {
                    return self.minX + inset + 10
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
    let connectionStyle:MapSwiftTheme.ConnectionStyle
    func connectToPointForRectFrom(rectFrom:CGRect) -> CGPoint {
        let inset = MapSwiftNodeView.BackgroundInset

        func getY(pos:MapSwiftTheme.ConnectionJoinPosition) -> CGFloat {
            switch pos {
            case MapSwiftTheme.ConnectionJoinPosition.Center:
                return self.nodeRect.midY
            case MapSwiftTheme.ConnectionJoinPosition.Base:
                return self.nodeRect.maxY - inset - 0.5
            case MapSwiftTheme.ConnectionJoinPosition.Nearest:
                if rectFrom.minY > self.nodeRect.maxY {
                    return self.nodeRect.maxY - inset
                }
                if rectFrom.maxY < self.nodeRect.minY {
                    return self.nodeRect.minY + inset
                }
                return self.nodeRect.midY
            case  MapSwiftTheme.ConnectionJoinPosition.NearestInset:
                if rectFrom.minY > self.nodeRect.maxY {
                    return self.nodeRect.maxY - inset - 12
                }
                if rectFrom.maxY < self.nodeRect.minY {
                    return self.nodeRect.minY + inset + 12
                }
                return self.nodeRect.midY
            }
        }
        func getX(pos:MapSwiftTheme.ConnectionJoinPosition) -> CGFloat {
            switch pos {
            case MapSwiftTheme.ConnectionJoinPosition.Center:
                return self.nodeRect.midX
            case MapSwiftTheme.ConnectionJoinPosition.Nearest, MapSwiftTheme.ConnectionJoinPosition.Base:
                if rectFrom.minX > self.nodeRect.midX {
                    return self.nodeRect.maxX - inset
                }
                if rectFrom.maxX < self.nodeRect.midX {
                    return self.nodeRect.minX + inset
                }
                return self.nodeRect.midX
            case  MapSwiftTheme.ConnectionJoinPosition.NearestInset:
                if rectFrom.minX > self.nodeRect.midX {
                    return self.nodeRect.maxX - inset - 10
                }
                if rectFrom.maxX < self.nodeRect.midX {
                    return self.nodeRect.minX + inset + 10
                }
                return self.nodeRect.midX
            }
        }
        let x = getX(self.connectionStyle.to.h)
        let y = getY(self.connectionStyle.to.v)
        return CGPointMake(x,y)
    }
    func connectionStyleFromForPosition(pos:MapSwiftTheme.RelativeNodePosition) -> MapSwiftTheme.ConnectionJoinPositions {
        switch pos {
        case MapSwiftTheme.RelativeNodePosition.Above:
            return self.connectionStyle.from.above
        case MapSwiftTheme.RelativeNodePosition.Below:
            return self.connectionStyle.from.below
        case MapSwiftTheme.RelativeNodePosition.Horizontal:
            return self.connectionStyle.from.horizontal
        }
    }
    func connectFromPointForPointTo(to:CGPoint) -> CGPoint {
        let pos = self.nodeRect.mapswift_relativePositionOfPoint(to)
        let style = self.connectionStyleFromForPosition(pos)
        return self.nodeRect.mapswift_connectionPointForJoinPositions(style, relativePoint:to)
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
                nodeConnectorInfoMap[nodeId] = NodeConnectorInfo(nodeRect: connectorInfo.nodeRect, styles: connectorInfo.styles, connectionStyle: self.theme.nodeConnectionStyle(connectorInfo.styles))
            }
            self.setNeedsDisplay()
        }
    }


    private func keyForConnector(connector:MapSwiftNodeConnector) -> String {
        return "\(connector.from)->\(connector.to)"
    }


    private func calculateConnector(from:NodeConnectorInfo, to: NodeConnectorInfo) -> ConnectorPath {
        let tolerance:CGFloat = 10

        let toPoint = to.connectToPointForRectFrom(from.nodeRect)
        let pos = from.nodeRect.mapswift_relativePositionOfPoint(toPoint, tolerance: tolerance)
        let toRelativePosition = from.connectionStyleFromForPosition(pos)
        let fromPoint = from.nodeRect.mapswift_connectionPointForJoinPositions(toRelativePosition, relativePoint: toPoint)
        if pos == MapSwiftTheme.RelativeNodePosition.Horizontal {
            let x = toPoint.y < fromPoint.y ? toPoint.x : fromPoint.x
            let y = toPoint.y < fromPoint.y ? fromPoint.y : toPoint.y
            return ConnectorPath(from: fromPoint, to:toPoint, controlPoint:CGPointMake(x, y))
        }
        let initialOffset = 0.75 * (fromPoint.y - toPoint.y)
        let maxOffset = min(from.nodeRect.height, to.nodeRect.height) * 1.5
        let offset = max(-1 * maxOffset, min(maxOffset, initialOffset))

        return ConnectorPath(from: fromPoint, to:toPoint, controlPoint:CGPointMake(fromPoint.x, toPoint.y - offset))
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
                    let connectorPath = calculateConnector(fromInfo, to: toInfo)
                    let pos = fromInfo.nodeRect.mapswift_relativePositionOfPoint(connectorPath.to)
                    let color = UIColor.mapswift_colorForPosition(pos)
                    CGContextSetStrokeColorWithColor(ctx,color.CGColor)
                    CGContextSetLineCap(ctx, CGLineCap.Round)
                    CGContextMoveToPoint(ctx, connectorPath.from.x, connectorPath.from.y)
                    CGContextAddQuadCurveToPoint(ctx, connectorPath.controlPoint.x, connectorPath.controlPoint.y, connectorPath.to.x, connectorPath.to.y)

                    CGContextStrokePath(ctx)
                }
        }

    }
}
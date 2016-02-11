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
    private var connectorViews:[String: MapSwiftConnectorView] = [:]
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

    private func calculateViewConnectorInfo(connector:MapSwiftNodeConnector, from:NodeConnectorInfo, to: NodeConnectorInfo) -> (frame:CGRect, connector:MapSwiftConnectorView.Connector) {

        let tolerance:CGFloat = 10

        var connectorStyles:[String] = []
        if let style = to.connectionStyle.style {
            connectorStyles.append(style)
        }
        connectorStyles.append("default");
        let toPoint = to.connectToPointForRectFrom(from.nodeRect, lineWidth:to.connectionStyle.lineStyle.width)
        let pos = from.nodeRect.mapswift_relativePositionOfPoint(toPoint, tolerance: tolerance)
        let toRelativePosition = from.connectionStyleFromForPosition(pos)
        let fromPoint = from.nodeRect.mapswift_connectionPointForJoinPositions(toRelativePosition, relativePoint: toPoint, cornerRadius: from.nodeStyle.cornerRadius, lineWidth:to.connectionStyle.lineStyle.width)

        let connectorBounds = CGRect.mapswift_rectContainingPoints(fromPoint, to: toPoint, minSize: 1)

        let convertedToAndFrom = connectorBounds.mapswift_pointsforFromAndToCGPoints(fromPoint, to: toPoint)
        let controlPointMultipliers = self.theme.controlPointsForStylesAndPosition(connectorStyles, position: pos)
        let controlPoints = controlPointMultipliers.map { (cp) -> MapSwift.Position.Point in
            return MapSwift.Position.Point(type: MapSwift.Position.Measurement.Proportional, origin:convertedToAndFrom.from.origin, point: CGPointMake(cp.width, cp.height))
        }
        let frameConnector = MapSwiftConnectorView.Connector(nodes:connector, from:convertedToAndFrom.from, to: convertedToAndFrom.to, controlPoints:controlPoints);
        return (frame:connectorBounds, connector:frameConnector)
    }

    private func connectorsForNodeId(nodeId:String) -> [MapSwiftNodeConnector] {
        return self.connectors.values.filter({ (connector) -> Bool in
            return connector.from == nodeId || connector.to == nodeId
        })
    }
    private func connectorViewsForNodeId(nodeId:String) -> [MapSwiftConnectorView] {
        return self.connectorViews.values.filter({ (view) -> Bool in
            if let connector = view.connector {
                return connector.from == nodeId || connector.to == nodeId
            }
            return false
        })
    }
    private func removeConnectorViewsForNodeId(nodeId:String) {
        let views = connectorViewsForNodeId(nodeId)
        for view in views {
            view.removeFromSuperview()
            if let connector = view.connector {
                self.connectorViews.removeValueForKey(keyForConnector(connector))
            }
        }
    }
    private func showConnectors(connectors:[MapSwiftNodeConnector], animationDuration:NSTimeInterval) {
        for connector in connectors {
            let key = keyForConnector(connector)

            if let fromInfo = nodeConnectorInfoMap[connector.from], toInfo = nodeConnectorInfoMap[connector.to] {
                let connectorPath = calculateViewConnectorInfo(connector, from: fromInfo, to: toInfo)
                let inset:CGFloat = 30
                let viewFrame = CGRectInset(connectorPath.frame, -inset, -inset)
                if let view = connectorViews[key] {
                    if animationDuration > 0 {
                        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                            view.frame = connectorPath.frame
                            }, completion: { (completed) in
                                view.frame = viewFrame
                                view.showConnector(connectorPath.connector, line: toInfo.connectionStyle.lineStyle, inset: inset)
                        })
                    } else {
                        view.showConnector(connectorPath.connector, line: toInfo.connectionStyle.lineStyle, inset: inset)
                        view.frame = viewFrame
                    }
                } else {
                    let view = MapSwiftConnectorView(frame:viewFrame)
                    self.addSubview(view)
                    connectorViews[key] = view
                    view.showConnector(connectorPath.connector, line: toInfo.connectionStyle.lineStyle, inset: inset)
                }

            } else {
                if let view = connectorViews[key] {
                    view.removeFromSuperview()
                    connectorViews.removeValueForKey(key)
                }
            }
        }
    }

    func nodeConnectorInfo(nodeId:String, nodeRect:CGRect?, styles:[String]) {
        if let nodeRect = nodeRect {
            let connectorInfo = NodeConnectorInfo(nodeRect: nodeRect, styles: styles, connectionStyle: self.theme.nodeConnectionStyle(styles), nodeStyle: self.theme.nodeStyle(styles))
            nodeConnectorInfoMap[nodeId] = connectorInfo
            let connectors = self.connectorsForNodeId(nodeId)
            self.showConnectors(connectors, animationDuration: 0)
        } else {
            nodeConnectorInfoMap.removeValueForKey(nodeId)
            removeConnectorViewsForNodeId(nodeId)
        }
    }

    func animateNodeRectWithDuration(duration:NSTimeInterval, nodeId:String, nodeRect:CGRect) {
        if let info = nodeConnectorInfoMap[nodeId] {
            nodeConnectorInfoMap[nodeId] = NodeConnectorInfo(nodeRect: nodeRect, styles: info.styles, connectionStyle: self.theme.nodeConnectionStyle(info.styles), nodeStyle: info.nodeStyle)
            let connectors = self.connectorsForNodeId(nodeId)
            self.showConnectors(connectors, animationDuration: duration)
        }
    }
    func addConnector(connector:MapSwiftNodeConnector) {
        self.connectors[keyForConnector(connector)] = connector
        self.showConnectors([connector], animationDuration: 0)
    }

    func removeConnector(connector:MapSwiftNodeConnector) {
        let key = keyForConnector(connector)
        self.connectors.removeValueForKey(key)
        if let view = self.connectorViews[key] {
            view.removeFromSuperview()
        }
        self.connectorViews.removeValueForKey(key)
    }
}
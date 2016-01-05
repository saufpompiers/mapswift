//
//  MapSwiftConnectorsView.swift
//  MapSwift
//
//  Created by David de Florinier on 05/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation
class MapSwiftConnectorsView : UIView {
    private var connectors:[String: MapSwiftNodeConnector] = [:]
    private var nodeRects:[String:CGRect] = [:]

    private func keyForConnector(connector:MapSwiftNodeConnector) -> String {
        return "\(connector.from)->\(connector.to)"
    }
    private func drawPathForConnector(from:MapSwiftNode, to:MapSwiftNode)  {
    }

    func nodeRect(nodeId:String, nodeRect:CGRect?) {
        if let nodeRect = nodeRect {
            nodeRects[nodeId] = nodeRect
        } else {
            nodeRects.removeValueForKey(nodeId)
        }
        self.setNeedsDisplay()
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
        let ctx = UIGraphicsGetCurrentContext()
        for (_, connector) in self.connectors {
                if let fromRect = nodeRects[connector.from], toRect = nodeRects[connector.to] {
                    print("from:\(connector.from) rect:\(fromRect) to:\(connector.to) rect:\(toRect)")
                    CGContextMoveToPoint(ctx, fromRect.midX, fromRect.midY)
                    CGContextSetStrokeColorWithColor(ctx,UIColor.blackColor().CGColor)
                    CGContextSetLineWidth(ctx, 2.0)
                    CGContextAddLineToPoint(ctx, toRect.midX, toRect.midY)
                    CGContextStrokePath(ctx)
                }
        }

    }
}
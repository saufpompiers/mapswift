//
//  MapSwiftConnectorsView.swift
//  MapSwift
//
//  Created by David de Florinier on 05/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

class MapSwiftConnectorsView : UIView {
    private var connectors:[String: (from:MapSwiftNode, to:MapSwiftNode)] = [:]
    private func keyForConnector(from:MapSwiftNode, to:MapSwiftNode) -> String {
        return "\(from.id)->\(to.id)"
    }
    private func drawPathForConnector(from:MapSwiftNode, to:MapSwiftNode)  {
    }
    func showConnector(from:MapSwiftNode, to:MapSwiftNode) {
        self.connectors[keyForConnector(from, to: to)] = (from:from, to:to)
        self.setNeedsDisplay()
    }

    func removeConnector(from:MapSwiftNode, to:MapSwiftNode) {
        self.connectors.removeValueForKey(keyForConnector(from, to: to))
    }
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx,UIColor.blackColor().CGColor);
        CGContextSetLineWidth(ctx, 1.0);
        for (_, connector) in self.connectors {
            let path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, connector.from.rect.midX, connector.from.rect.midY)
            CGPathAddLineToPoint(path, nil, connector.to.rect.midX, connector.to.rect.midY);
        }
        CGContextStrokePath(ctx);
    }
}
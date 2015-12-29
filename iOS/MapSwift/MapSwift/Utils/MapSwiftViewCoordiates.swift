//
//  MapSwiftViewCoordiates.swift
//  MapSwift
//
//  Created by David de Florinier on 24/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

protocol MapSwiftViewCoordiatesDelegate:class {
    func mapSwiftViewCoordiatesChanged(mapSwiftViewCoordiates:MapSwiftViewCoordiates, rectConverter:((rect:CGRect)->(CGRect)))
}

class MapSwiftViewCoordiates {
    typealias CoordinateMap = (htmlRect:CGRect, localRect:CGRect)
    private var margin:CGFloat
    private var mapRect:CGRect
    private var offset:CGPoint {
        get {
            if let centerNode = self.centerNode {
                return CGPointMake(centerNode.localRect.midX, centerNode.localRect.midY)
            }
            return CGPointMake(mapRect.midX, mapRect.midY)
        }
    }
    private var centerNode:CoordinateMap?

    private var nodes:Dictionary<String, CoordinateMap> = [:]
    private var scale:CGFloat = 1
    weak var delegate:MapSwiftViewCoordiatesDelegate?

    init(margin:CGFloat) {
        self.margin = margin
        let side = margin * 2
        self.mapRect = CGRectMake(0, 0, side, side)
    }

    convenience init() {
        self.init(margin:10.0)
    }

    private func convertRect(rect:CGRect) -> CGRect {
        return rect
    }
    private func convertRectFromHtmlCoordinateSystem(rect:CGRect) -> CGRect {

        let x = rect.origin.x
        let y = rect.origin.y - rect.height
        return CGRectMake(x, y, rect.height, rect.width)
    }

    func nodeAdded(node:MapSwiftNode) -> CGRect {
        let convertedNodeRect = self.convertRectFromHtmlCoordinateSystem(node.rect)
        if node.level == 1 {
            self.centerNode = CoordinateMap(htmlRect:node.rect, localRect:convertedNodeRect)
        }
        if !mapRect.contains(convertedNodeRect) {
        } else {
        }
        return convertedNodeRect
    }
    func nodeMoved(node:MapSwiftNode) {

    }
    func nodeRemoved(node:MapSwiftNode) {

    }
}

//
//  MapSwiftViewCoordiates.swift
//  MapSwift
//
//  Created by David de Florinier on 24/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

protocol MapSwiftViewCoordinatesDelegate:class {
    func mapSwiftViewCoordinatesChanged(mapSwiftViewCoordiates:MapSwiftViewCoordinates, rectConverter:MapSwift.RectConverter)
    func mapSwiftViewSizeChanged(mapSwiftViewCoordiates:MapSwiftViewCoordinates, mapSize:CGSize)
}

class MapSwiftViewCoordinates {
    private var margin:CGFloat
    private let coordinateSystem:MapSwiftCoordinateSystem
    private var scale:CGFloat = 1
    weak var delegate:MapSwiftViewCoordinatesDelegate?

    init(margin:CGFloat, coordinateSystem:MapSwiftCoordinateSystem) {
        self.margin = margin
        self.coordinateSystem = coordinateSystem
    }

    convenience init() {
        self.init(margin:10.0, coordinateSystem:MapSwiftHTMLCoordinates())
    }

//MARK: - private helpers
    private var mapSize:CGSize {
        get {
            let size = coordinateSystem.mapSize,
            outdent = margin * 2
            return CGSizeMake(size.width + outdent, size.height + outdent)
        }
    }

    private func convertRectFromHtmlCoordinateSystem(rect:CGRect) -> CGRect {
        let offset = coordinateSystem.mapOriginOffset
        let x = rect.origin.x + offset.x + margin
        let y = rect.origin.y + offset.y + margin
        return CGRectMake(x, y, rect.width, rect.height)
    }

    private func reactToChangeFlags(flags:MapChangeFlags) {
        if let delegate = delegate {
            if flags.boundsChanged {
                delegate.mapSwiftViewSizeChanged(self, mapSize:self.mapSize)
            }
            if flags.offsetChanged {
                delegate.mapSwiftViewCoordinatesChanged(self, rectConverter: convertRectFromHtmlCoordinateSystem)
            }
        }
    }

//MARK: - public API
    func nodeAdded(node:MapSwiftNode) -> CGRect {
        let flags = coordinateSystem.addRect(node.id, rect: node.rect)
        let convertedNodeRect = self.convertRectFromHtmlCoordinateSystem(node.rect)
        reactToChangeFlags(flags)
        return convertedNodeRect
    }
    func nodeMoved(node:MapSwiftNode) -> CGRect {
        return self.nodeAdded(node)
    }
    func nodeRemoved(node:MapSwiftNode) {
        let flags = coordinateSystem.removeRect(node.id)
        reactToChangeFlags(flags)
    }
}

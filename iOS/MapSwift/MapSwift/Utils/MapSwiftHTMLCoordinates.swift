//
//  MapSwiftHTMLCoordinates.swift
//  MapSwift
//
//  Created by David de Florinier on 28/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

class MapSwiftHTMLCoordinates: NSObject {
    typealias MapBounds = (minX:CGFloat, maxX:CGFloat, minY:CGFloat, maxY:CGFloat)
    typealias MapChangeFlags = (boundsChanged:Bool, offsetChanged:Bool)

    var mapSize:CGSize {
        get {
            return CGSizeMake(_mapBounds.maxX - _mapBounds.minX, _mapBounds.maxY - _mapBounds.minY)
        }
    }

    private var mapRects:[String:CGRect] = [:]
    var _mapBounds:MapBounds =  (minX:0, maxX:0, minY:0, maxY:0)
    var mapBounds:MapBounds {
        get {
            return _mapBounds
        }
    }

    private var _mapOriginOffset = CGPointMake(0,0)
    var mapOriginOffset:CGPoint {
        get {
            return _mapOriginOffset
        }
    }

    private func setMapBounds(bounds:MapBounds) {
        _mapOriginOffset = CGPointMake(bounds.minX * -1, bounds.maxY)
        _mapBounds = bounds
    }
    private func setInitialBoundsFromRect(rect:CGRect) {
        var currentBounds = MapBounds(minX:0, maxX:0, minY:0, maxY:0)
        currentBounds.minX = rect.origin.x
        currentBounds.maxX = rect.origin.x + rect.width
        currentBounds.minY = rect.origin.y
        currentBounds.maxY = rect.origin.y + rect.height
        self.setMapBounds(currentBounds)
    }
    private func enlargeBoundsToFitRect(rect:CGRect) -> MapChangeFlags {
        var currentBounds = mapBounds
        var flags = MapChangeFlags(boundsChanged:false, offsetChanged:false)

        if currentBounds.minX > rect.origin.x {
            flags.boundsChanged = true
            flags.offsetChanged = true
            currentBounds.minX = rect.origin.x
        }
        let rectMaxX = rect.origin.x + rect.width
        if rectMaxX > currentBounds.maxX {
            currentBounds.maxX = rectMaxX
        }
        if currentBounds.minY > rect.origin.y {
            flags.boundsChanged = true
            currentBounds.minY = rect.origin.y
        }
        let rectMaxY = rect.origin.y + rect.height
        if rectMaxY > currentBounds.maxY {
            flags.boundsChanged = true
            flags.offsetChanged = true
            currentBounds.maxY = rectMaxY
        }
        if flags.boundsChanged {
            self.setMapBounds(currentBounds)
        }
        return flags
    }
    func addRect(id:String, rect:CGRect) -> MapChangeFlags {
        var flags:MapChangeFlags!
        if let existingRect = mapRects[id] {
            if rect == existingRect {
                return MapChangeFlags(boundsChanged:false, offsetChanged:false)
            }
            removeRect(id)
        }
        if mapRects.count == 0 {
            setInitialBoundsFromRect(rect)
            flags = MapChangeFlags(boundsChanged:true, offsetChanged:true)
        } else {
            flags = enlargeBoundsToFitRect(rect)
        }
        mapRects[id] = rect
        return flags
    }
    private func rectIsWithinBounds(rect:CGRect) -> Bool {
        let bounds = mapBounds
        if bounds.minX < rect.origin.x && bounds.maxX > (rect.origin.x + rect.width) && bounds.minY < rect.origin.y && bounds.maxY > rect.origin.y + rect.height {
            print("is in bounds bounds:\(bounds) rect:\(rect)")
            return true
        }
        return false
    }
    private func recalcBounds() -> MapChangeFlags {
        let rects = mapRects
        var flags:MapChangeFlags = MapChangeFlags(boundsChanged:false, offsetChanged:false)

        _mapBounds = (minX:0, maxX:0, minY:0, maxY:0)
        _mapOriginOffset = CGPointMake(0,0)
        for (_, rect) in rects {
            let thisFlags = enlargeBoundsToFitRect(rect);
            flags.boundsChanged = flags.boundsChanged || thisFlags.boundsChanged
            flags.offsetChanged = flags.offsetChanged || thisFlags.offsetChanged
        }
        return flags
    }

    func removeRect(id:String) -> MapChangeFlags {
        var flags:MapChangeFlags = MapChangeFlags(boundsChanged:false, offsetChanged:false)
        if let rect = mapRects[id] {
            mapRects.removeValueForKey(id)
            if mapRects.count == 0 {
                flags.boundsChanged = true
                flags.offsetChanged = true
                _mapBounds = (minX:0, maxX:0, minY:0, maxY:0)
                _mapOriginOffset = CGPointMake(0,0)
            } else if !rectIsWithinBounds(rect) {
                flags = recalcBounds()
            }
        }
        return flags
    }
}

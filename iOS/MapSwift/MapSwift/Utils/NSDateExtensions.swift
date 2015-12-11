//
//  NSDateExtensions.swift
//  MapSwift
//
//  Created by David de Florinier on 11/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation


public extension NSDate {
    var mapswift_jsTimestamp:Int {
        get {
            return self.timeIntervalSince1970.mapswift_JSTimeInterval
        }
    }

    static func MapSwift_fromJSTimestamp(jsTimeStamp:Int) -> NSDate {
        let ts = NSTimeInterval.MapSwift_fromJSTimeInterval(jsTimeStamp)
        return NSDate(timeIntervalSince1970: ts)
    }
}
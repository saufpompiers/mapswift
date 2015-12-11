//
//  NSTimeIntervalExtensions.swift
//  MapSwift
//
//  Created by David de Florinier on 11/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

public extension NSTimeInterval {
    var mapswift_JSTimeInterval:Int {
        get {
            return Int(floor(self * 1000))
        }
    }
    static func MapSwift_fromJSTimeInterval(jsInterval:Int) -> NSTimeInterval {
        let jsIntervalDouble = Double(jsInterval)
        return jsIntervalDouble / 1000
    }
}
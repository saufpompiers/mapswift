//
//  NSURLExtensions.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

public extension NSURL {
    var mapswift_fileContent:String? {
        get {
            if let data = NSData(contentsOfURL: self) {
                if let html = NSString(data: data, encoding: NSUTF8StringEncoding) as String? {
                    return html
                }
            }
            return nil
        }
    }
}
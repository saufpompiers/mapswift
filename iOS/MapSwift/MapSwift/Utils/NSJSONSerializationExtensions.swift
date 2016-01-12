//
//  NSJSONSerializationExtensions.swift
//  MapSwift
//
//  Created by David de Florinier on 12/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

extension NSJSONSerialization {
    static func mapswift_JSONDictionaryFromFileURL(fileURL:NSURL) -> NSDictionary? {
        do {
            if let data = NSData(contentsOfURL: fileURL) {
                if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
                    return json
                }
            }
        } catch let e as NSError {
            print("Unable to load JSON dictionary from file:\(fileURL) error:\(e)")
        }
        return nil
    }
}

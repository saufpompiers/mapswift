//
//  StringExtensions.swift
//  MapSwift
//
//  Created by David de Florinier on 16/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

extension String {
    static func mapswift_jsArgsString(args:[AnyObject]) -> String? {
        let EMPTY_ARGS_STRING = "[]"
        if args.count == 0 {
            return EMPTY_ARGS_STRING
        }
        do {
            let argsData = try NSJSONSerialization.dataWithJSONObject(args, options: NSJSONWritingOptions(rawValue: 0))
            if let argsString = NSString(data: argsData, encoding: NSUTF8StringEncoding) as? String {
                return argsString
            } else {
                return EMPTY_ARGS_STRING
            }
        } catch let err as NSError {
            print("Error \(err.localizedDescription) generating args string for \(args)")
        }
        return nil;
    }
    static func mapswift_fromAnyObject(object:AnyObject?) -> String? {
        return String.mapswift_fromAnyObject(object, fallback: nil)
    }
    static func mapswift_fromAnyObject(object:AnyObject?, fallback:String?) -> String? {
        if object == nil {
            return nil
        }
        if let stringVal = object as? String {
            return stringVal
        }
        if let intVal = object as? Int {
            return "\(intVal)"
        }
        return fallback
    }
}
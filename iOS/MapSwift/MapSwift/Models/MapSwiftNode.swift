//
//  MapSwiftNode.swift
//  MapSwift
//
//  Created by David de Florinier on 23/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

public struct MapSwiftNode {
    public var title:String
    public var level:Int
    public let id:String
    public var rect:CGRect
    public let attr:MapSwiftNodeAttributes

    public var styles:[String] {
        get {
            return ["level \(self.level)"]
        }
    }
    static func parseDictionary(dictionary:Dictionary<String, AnyObject>) -> MapSwiftNode? {
//        print("MapSwiftNode dictionary:\(dictionary)")
        if let id = String.mapswift_fromAnyObject(dictionary["id"], fallback:""), level = dictionary["level"] as? Int, width = dictionary["width"] as? CGFloat, height = dictionary["height"] as? CGFloat, x = dictionary["x"] as? CGFloat, y = dictionary["y"] as? CGFloat {
            let attrDictionary = dictionary["attr"] as? Dictionary<String, AnyObject>

            let attr = MapSwiftNodeAttributes.parseDictionary(attrDictionary)
            let rect = CGRectMake(x, y, width, height)
            if let title = dictionary["title"] as? String {
                return MapSwiftNode(title: title, level: level, id: id, rect: rect, attr: attr)
            } else {
                return MapSwiftNode(title: "", level: level, id: id, rect: rect, attr: attr)
            }
        }
        return nil
    }

}
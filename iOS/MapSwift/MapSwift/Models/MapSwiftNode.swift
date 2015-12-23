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
    public var attr:Dictionary<String, AnyObject>?

    public static func parseDictionary(dictionary:Dictionary<String, AnyObject>) -> MapSwiftNode? {
        var id = ""
        if let textId = dictionary["id"] as? String {
            id = textId
        } else if let intId = dictionary["id"] as? Int {
            id = "\(intId)"
        }
        if id == "" {
            return nil
        }
        if let level = dictionary["level"] as? Int, width = dictionary["width"] as? CGFloat, height = dictionary["height"] as? CGFloat, x = dictionary["x"] as? CGFloat, y = dictionary["y"] as? CGFloat {
            let attr = dictionary["attr"] as? Dictionary<String, AnyObject>
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
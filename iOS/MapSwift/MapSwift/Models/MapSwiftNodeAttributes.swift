//
//  MapSwiftNodeAttributes.swift
//  MapSwift
//
//  Created by David de Florinier on 29/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

public struct MapSwiftNodeAttributes {
    let backgroundColor:UIColor?
    let collapsed:Bool
    static func empty() -> MapSwiftNodeAttributes {
        return MapSwiftNodeAttributes(backgroundColor: nil, collapsed: false)
    }
    static func parseDictionary(attrDictionary:Dictionary<String, AnyObject>?) -> MapSwiftNodeAttributes {

        if let dictionary = attrDictionary {
            var backgroundColor:UIColor?
            var collapsed = false
            if let styleDictionary = dictionary["style"] as? [String: AnyObject] {
                if let backgroundColorHex = styleDictionary["background"] as? String {
                    backgroundColor = UIColor(hexString: backgroundColorHex)
                }
            }
            if let coll = dictionary["collapsed"] as? Bool {
                collapsed = coll
            }
            return MapSwiftNodeAttributes(backgroundColor: backgroundColor, collapsed: collapsed)
        }
        return MapSwiftNodeAttributes.empty()
    }
}

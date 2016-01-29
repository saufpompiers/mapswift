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
    static func empty() -> MapSwiftNodeAttributes {
        return MapSwiftNodeAttributes(backgroundColor: nil)
    }
    static func parseDictionary(attrDictionary:Dictionary<String, AnyObject>?) -> MapSwiftNodeAttributes {

        if let dictionary = attrDictionary {
            var backgroundColor:UIColor?
            if let styleDictionary = dictionary["style"] as? [String: AnyObject] {
                if let backgroundColorHex = styleDictionary["background"] as? String {
                    backgroundColor = UIColor(hexString: backgroundColorHex)
                }
            }
            return MapSwiftNodeAttributes(backgroundColor: backgroundColor)
        }
        return MapSwiftNodeAttributes.empty()
    }
}

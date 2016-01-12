//
//  MapSwiftTheme.swift
//  MapSwift
//
//  Created by David de Florinier on 12/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

public class MapSwiftTheme {
    typealias KeyConFiguration = (prefixes:[String], postFixes:[String]?)
    public enum NodeAttribute {
        case BackgroundColor
        var keyConFiguration:KeyConFiguration {
            get {
                switch self {
                case .BackgroundColor:
                    return KeyConFiguration(prefixes:["node"], postFixes:["backgroundColor"])
                }

            }
        }
    }
    let themeDictionary:MapSwiftDefaultedDictionary

    public init(dictionary:NSDictionary) {
        self.themeDictionary = MapSwiftDefaultedDictionary(dictionary: dictionary)
    }

    private func optionsFromStyle(style:String?) -> [String] {
        var options:[String] = []
        if let style = style {
            options.append(style)
        }
        options.append("default")
        return options
    }

    func nodeAttribute(attribute:NodeAttribute, style:String?) -> AnyObject? {
        let keyConFiguration = attribute.keyConFiguration
        return self.themeDictionary.valueForKeyWithOptions(keyConFiguration.prefixes, keyOptions: optionsFromStyle(style), keyPostFixes: keyConFiguration.postFixes)
    }

    func nodeAttribute<T>(attribute:NodeAttribute, style:String?, fallback:T) -> T {
        if let val =  self.nodeAttribute(attribute, style: style) as? T {
            return val
        }
        return fallback
    }
}
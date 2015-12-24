//
//  MapSwiftConnector.swift
//  MapSwift
//
//  Created by David de Florinier on 24/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

public struct MapSwiftNodeConnector {
    public let from:String
    public let to:String
    static func parseDictionary(dictionary:Dictionary<String, AnyObject>) -> MapSwiftNodeConnector? {
        if let from = String.mapswift_fromAnyObject(dictionary["from"]), to = String.mapswift_fromAnyObject(dictionary["to"]) {
            return MapSwiftNodeConnector(from: from, to: to)
        }
        return nil
    }
}


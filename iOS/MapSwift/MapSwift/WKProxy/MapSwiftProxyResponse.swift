//
//  MapSwiftProxyResponse.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

public struct MapSwiftProxyResponse {
    let id:String?
    let completed:Bool
    let componentId:String?
    let selector:String?
    let result:AnyObject?
    let errors:[String]?

    static func fromNSDictionary(dictionary:NSDictionary) -> MapSwiftProxyResponse {
        var completed = false;
        if let wasCompleted = dictionary["completed"] as? Bool {
            completed = wasCompleted
        }
        let componentId = dictionary["componentId"] as? String
        let selector = dictionary["selector"] as? String
        let id = dictionary["id"] as? String
        let result = dictionary["result"]
        let errors = dictionary["errors"] as? [String]
        return MapSwiftProxyResponse(id: id, completed: completed, componentId: componentId, selector: selector, result: result, errors: errors)
    }


}

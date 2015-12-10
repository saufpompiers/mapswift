//
//  MapSwiftProxyResponse.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

extension NSDictionary {
    func toMapSwiftProxyResponse(error:NSError?) -> MapSwiftProxyResponse {
        var completed = false;
        if let wasCompleted = self["completed"] as? Bool {
            completed = wasCompleted
        }
        let componentId = self["componentId"] as? String
        let selector = self["selector"] as? String
        let id = self["id"] as? String
        let result = self["result"]
        let errors = self["errors"] as? [String]
        return MapSwiftProxyResponse(id: id, completed: completed, componentId: componentId, selector: selector, result: result, errors: errors)
    }
}
public struct MapSwiftProxyResponse {
    let id:String?
    let completed:Bool
    let componentId:String?
    let selector:String?
    let result:AnyObject?
    let errors:[String]?

}

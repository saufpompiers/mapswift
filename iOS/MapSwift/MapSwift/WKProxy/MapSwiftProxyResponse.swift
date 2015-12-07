//
//  MapSwiftProxyResponse.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

public struct MapSwiftProxyResponse {
    let id:String
    let completed:Bool
    let componentId:String
    let selector:String
    let result:AnyObject?
    let error:NSError?
}

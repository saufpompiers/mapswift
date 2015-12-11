//
//  MapSwiftErrors.swift
//  MapSwift
//
//  Created by David de Florinier on 10/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

public class MapSwiftError {
    public class var ProtocolNotReady:NSError {
        get {
            return NSError(domain: "com.saufpompiers", code: 1, userInfo: [NSLocalizedDescriptionKey: "The protocol is not ready for use", NSLocalizedRecoverySuggestionErrorKey:"Use MapSwiftWKProxyProtocol.start to make ready"])
        }
    }
    public class var InvalidProtocolRequestArgs:NSError {
        get {
            return NSError(domain: "com.saufpompiers", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid arguments supplied to protocol", NSLocalizedRecoverySuggestionErrorKey:"Arguments must be transformable into JSON"])
        }
    }
    public class func InvalidResponseFromProxy(response:MapSwiftProxyResponse?) -> NSError {
            return NSError(domain: "com.saufpompiers", code: 3, userInfo: [NSLocalizedDescriptionKey: "An Invalid response was received from the protocol",
                NSLocalizedFailureReasonErrorKey: "\(response)"])
    }

}
//
//  MapSwiftProxyEchoResponse.swift
//  MapSwift
//
//  Created by David de Florinier on 11/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

public struct MapSwiftProxyEchoResponse {
    public let identifier:String
    public let sent:NSDate
    public let reply:NSDate
    public let received:NSDate
    public var description:String {
        get {

            let out =  reply.timeIntervalSinceDate(sent).mapswift_JSTimeInterval
            let back = received.timeIntervalSinceDate(reply).mapswift_JSTimeInterval
            return "\(identifier) [out:\(out)ms back:\(back)ms]"
        }
    }
    static func fromProxyResponse(response:MapSwiftProxyResponse, sent:NSDate, received:NSDate) -> MapSwiftProxyEchoResponse? {
        if let result = response.result as? NSDictionary, identifier = result["identifier"] as? String, receivedJSTS = result["received"] as? Int {
            return MapSwiftProxyEchoResponse(identifier: identifier, sent:sent, reply:NSDate.MapSwift_fromJSTimestamp(receivedJSTS), received: received)
        }
        return nil;
    }
}

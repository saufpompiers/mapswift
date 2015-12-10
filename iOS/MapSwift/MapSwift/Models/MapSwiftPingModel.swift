//
//  MapSwiftPingModel.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
extension MapSwiftProxyResponse {
    func mapSwiftEchoResponse(sent:NSDate, received:NSDate) -> MapSwiftPingModel.MapSwiftEchoResponse? {
        if let result = self.result as? NSDictionary, identifier = result["identifier"] as? String, receivedJSTS = result["received"] as? Double {
            let div:Double = 1000
            let receivedTI = (receivedJSTS / div) as NSTimeInterval
            let replyDate = NSDate(timeIntervalSince1970: receivedTI)
            return MapSwiftPingModel.MapSwiftEchoResponse(identifier: identifier, sent:sent, reply:replyDate, received: received)
        }
        return nil;
    }
}

public class MapSwiftPingModel {
    public struct MapSwiftEchoResponse {
        let identifier:String
        let sent:NSDate
        let reply:NSDate
        let received:NSDate
    }
    let COMPONENT_ID = "pingModel"
    let proxy:MapSwiftProxyProtocol

    init(proxy:MapSwiftProxyProtocol) {
        self.proxy = proxy
        self.proxy.addProxyListener(COMPONENT_ID) { (eventName, args) -> () in
            print("\(eventName), args:\(args)")
        }
    }

    public func echo(message:String, then:((response:MapSwiftEchoResponse?)->())) {
        print("echo:\(message)")
        proxy.sendCommand(COMPONENT_ID, selector: "echo", args: [message]) { (response, error) -> () in
            let sent = NSDate()
            if let error = error {
                print("echo error:\(error.localizedDescription)")
                return
            }
            if let response = response {
                then(response: response.mapSwiftEchoResponse(sent, received: NSDate()))
            } else {
                then(response: nil)
            }

        }
    }
}

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

public protocol MapSwiftPingModelDelegate:class {
    func ping(identifier:String, sent:NSDate)
}
public class MapSwiftPingModel {
    public struct MapSwiftEchoResponse {
        public let identifier:String
        public let sent:NSDate
        public let reply:NSDate
        public let received:NSDate
        public var description:String {
            get {
                let out = (reply.timeIntervalSinceReferenceDate - sent.timeIntervalSinceReferenceDate) * 1000
                let back = (received.timeIntervalSinceReferenceDate - reply.timeIntervalSinceReferenceDate) * 1000
                return "\(identifier) [out:\(out)ms back:\(back)ms]"
            }
        }
    }
    let COMPONENT_ID = "pingModel"
    let proxy:MapSwiftProxyProtocol
    public weak var delegate:MapSwiftPingModelDelegate?

    init(proxy:MapSwiftProxyProtocol) {
        self.proxy = proxy
        self.proxy.addProxyListener(COMPONENT_ID) { (eventName, args) -> () in
            if let delegate = self.delegate, identifer = args[0] as? String, timestamp = args[1] as? Double {
                let div:Double = 1000
                let receivedTI = (timestamp / div) as NSTimeInterval
                let timeSent = NSDate(timeIntervalSince1970: receivedTI)
                delegate.ping(identifer, sent: timeSent)
            }
        }
    }
    private func exec(selector:String, args:[AnyObject], then: (()->()), fail:((error:NSError)->())) {
        proxy.sendCommand(COMPONENT_ID, selector: selector, args: args) { (response, error) -> () in
            if let error = error {
                fail(error: error)
            } else {
                then()
            }
        }
    }
    public func start(identifier:String, interval:NSTimeInterval, then:(()->()), fail:((error:NSError)->())) {
        let intervalMilis = floor(interval*1000)
        self.exec("start", args:[identifier, intervalMilis], then:then, fail: fail);
    }
    public func stop(then:(()->()), fail:((error:NSError)->())) {
        self.exec("stop", args:[], then:then, fail: fail);
    }

    public func echo(message:String, then:((response:MapSwiftEchoResponse)->()), fail:((error:NSError)->())) {
        let sent = NSDate()
        proxy.sendCommand(COMPONENT_ID, selector: "echo", args: [message]) { (response, error) -> () in
            if let error = error {
                fail(error: error)
            } else if let response = response, echoResponse = response.mapSwiftEchoResponse(sent, received: NSDate()) {
                then(response: echoResponse)
            } else {
                fail(error: MapSwiftError.InvalidResponseFromProxy(response))
            }
        }
    }
}

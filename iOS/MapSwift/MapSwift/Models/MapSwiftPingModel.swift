//
//  MapSwiftPingModel.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

public protocol MapSwiftPingModelDelegate:class {
    func ping(identifier:String, sent:NSDate)
}


public class MapSwiftPingModel {
    let COMPONENT_ID = "pingModel"
    let proxy:MapSwiftProxyProtocol
    public weak var delegate:MapSwiftPingModelDelegate?

    init(proxy:MapSwiftProxyProtocol) throws {
        self.proxy = proxy
        try self.proxy.addProxyListener(COMPONENT_ID) { (eventName, args) -> () in
            if let delegate = self.delegate, identifer = args[0] as? String, timestamp = args[1] as? Int {
                delegate.ping(identifer, sent: NSDate.MapSwift_fromJSTimestamp(timestamp))
            }
        }
    }
    
    //MARK: - Prvate helpers methods
    private func exec(selector:String, args:[AnyObject], then: (()->()), fail:((error:NSError)->())) {
        proxy.sendCommand(COMPONENT_ID, selector: selector, args: args) { (response, error) -> () in
            if let error = error {
                fail(error: error)
            } else {
                then()
            }
        }
    }

    //MARK: - Prvate API
    public func start(identifier:String, interval:NSTimeInterval, then:(()->()), fail:((error:NSError)->())) {
        let intervalMilis = floor(interval*1000)
        self.exec("start", args:[identifier, intervalMilis], then:then, fail: fail);
    }
    public func stop(then:(()->()), fail:((error:NSError)->())) {
        self.exec("stop", args:[], then:then, fail: fail);
    }

    public func echo(message:String, then:((response:MapSwiftProxyEchoResponse)->()), fail:((error:NSError)->())) {
        let sent = NSDate()
        proxy.sendCommand(COMPONENT_ID, selector: "echo", args: [message]) { (response, error) -> () in
            if let error = error {
                fail(error: error)
            } else if let response = response, echoResponse = MapSwiftProxyEchoResponse.fromProxyResponse(response, sent: sent, received: NSDate()) {
                then(response: echoResponse)
            } else {
                fail(error: MapSwiftError.InvalidResponseFromProxy(response))
            }
        }
    }
}

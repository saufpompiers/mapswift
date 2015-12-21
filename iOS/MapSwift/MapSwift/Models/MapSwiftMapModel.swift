//
//  MapSwiftMapModel.swift
//  MapSwift
//
//  Created by David de Florinier on 21/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

public protocol MapSwiftMapModelDelegate {
    func mapModelLayoutChangeStarting(mapModel:MapSwiftMapModel)
    func mapModelLayoutChangeComplete(mapModel:MapSwiftMapModel)
}
public class MapSwiftMapModel {
    let COMPONENT_ID = "mapModel"
    let proxy:MapSwiftProxyProtocol
    public var delegate:MapSwiftMapModelDelegate?

    init(proxy:MapSwiftProxyProtocol) throws {
        self.proxy = proxy
        try self.proxy.addProxyListener(COMPONENT_ID) { (eventName, args) -> () in
            if let delegate = self.delegate {
                print("\(eventName) args:\(args)")
                switch eventName {
                    case "layoutChangeStarting":
                        delegate.mapModelLayoutChangeStarting(self)
                        break
                    case "layoutChangeComplete":
                        delegate.mapModelLayoutChangeStarting(self)
                        break
                    default:
                        print("\(eventName) unhandled");
                }
            }
        }
    }

    //MARK: - Prvate helpers methods
    private func exec(selector:String, args:[AnyObject], then:MapSwiftProxyProtocolThen, fail:MapSwiftProxyProtocolFail) {
        proxy.sendCommand(COMPONENT_ID, selector: selector, args: args, then:{ (response) -> () in
            print("exec selector:\(selector) args:\(args)")
        }, fail: fail)
    }

    //MARK: - public api
    public func setIdea(content:String, then:(()->()), fail:MapSwiftProxyProtocolFail) {
        proxy.execCommandArgString(COMPONENT_ID, selector: "setIdea", argString: "MAPJS.content(\(content))", then: { (response) -> () in
            print("response:\(response)");
            then()
        }, fail: fail)
    }
}

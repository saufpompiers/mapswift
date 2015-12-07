//
//  MapSwiftPingModel.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

public class MapSwiftPingModel {
    let COMPONENT_ID = "pingModel"
    let proxy:MapSwiftProxyProtocol

    init(proxy:MapSwiftProxyProtocol) {
        self.proxy = proxy
        self.proxy.addProxyListener(COMPONENT_ID) { (eventName, args) -> () in
            print("\(eventName), args:\(args)")
        }
    }

    public func echo(message:String) {
        print("echo:\(message)")
        proxy.sendCommand(COMPONENT_ID, selector: "echo", args: [message]) { (response) -> () in
            print("echo response:\(response)")
        }
    }
}

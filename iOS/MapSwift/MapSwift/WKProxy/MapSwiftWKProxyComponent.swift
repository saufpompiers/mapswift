//
//  MapSwiftWKProxyComponent.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import WebKit

public class MapSwiftWKProxyComponent {
    let componentId:String
    let proxyProtocol:MapSwiftProxyProtocol

    public init(componentId:String, proxyProtocol:MapSwiftProxyProtocol) {
        self.componentId = componentId
        self.proxyProtocol = proxyProtocol;
    }
    public func sendCommand(selector:String, args:[AnyObject], then:MapSwiftProxyProtocolSendCommandThen, fail:MapSwiftProxyProtocolFail) {
        self.proxyProtocol.sendCommand(componentId, selector: selector, args: args, then: then, fail: fail);
    }
}

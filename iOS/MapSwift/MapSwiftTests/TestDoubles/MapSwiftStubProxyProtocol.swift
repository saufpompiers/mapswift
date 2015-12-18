//
//  MapSwiftStubProxyProtocol.swift
//  MapSwift
//
//  Created by David de Florinier on 14/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import MapSwift

class MapSwiftStubProxyProtocol: NSObject, MapSwiftProxyProtocol {
    var delegate:MapSwiftProxyProtocolDelegate?
    var isReady:Bool = false

    typealias SendCommandCall = (componentId:String, selector:String, args:[AnyObject], then:MapSwiftProxyProtocolSendCommandThen, fail:MapSwiftProxyProtocolFail)
    var sendCommandCalls:[SendCommandCall] = []

    func sendCommand(componentId:String, selector:String, args:[AnyObject], then:MapSwiftProxyProtocolSendCommandThen, fail:MapSwiftProxyProtocolFail) {
        let thisCall = SendCommandCall(componentId:componentId, selector:selector, args:args, then:then, fail:fail)
        sendCommandCalls.append(thisCall)
    }

    typealias AddProxyListenerCall = (componentId:String, callBack:MapSwiftProxyEventHandler)
    var addProxyListenerCalls:[AddProxyListenerCall] = []

    func addProxyListener(componentId:String, callBack:MapSwiftProxyEventHandler) {
        let thisCall = AddProxyListenerCall(componentId:componentId, callBack:callBack)
        addProxyListenerCalls.append(thisCall)
    }

    var startCalls = 0
    func start() {
        startCalls++
    }

}

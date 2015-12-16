//
//  MapSwiftStubProxyProtocolDelegate.swift
//  MapSwift
//
//  Created by David de Florinier on 15/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import MapSwift

class MapSwiftStubProxyProtocolDelegate:NSObject, MapSwiftProxyProtocolDelegate {

    var proxyDidChangeStatusCalls:[MapSwiftProxyStatus] = []
    func proxyDidChangeStatus(status:MapSwiftProxyStatus) {
        proxyDidChangeStatusCalls.append(status)
    }

    typealias ProxyDidSendLogCall = [AnyObject]
    var proxyDidSendLogCalls:[ProxyDidSendLogCall] = []
    func proxyDidSendLog(args:[AnyObject]) {
        proxyDidSendLogCalls.append(args)
    }

    var proxyDidRecieveErrorCalls:[NSError] = []
    func proxyDidRecieveError(error:NSError) {
        proxyDidRecieveErrorCalls.append(error)
    }
}


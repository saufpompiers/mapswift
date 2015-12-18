//
//  MapSwiftProxyProtocolDelegateWrapper.swift
//  MapSwift
//
//  Created by David de Florinier on 18/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

class MapSwiftProxyProtocolDelegateWrapper: MapSwiftProxyProtocolDelegate {
    weak var passThroughDelegate:MapSwiftProxyProtocolDelegate?
    var readyCallback:MapSwiftProxyProtocolThen?

    deinit{
        readyCallback = nil
    }

    //MARK - MapSwiftProxyProtocolDelegate
    func proxyDidChangeStatus(status: MapSwiftProxyStatus) {

        if let delegate = passThroughDelegate {
            delegate.proxyDidChangeStatus(status);
        }
        if let readyCallback = readyCallback where status == MapSwiftProxyStatus.Ready {
            readyCallback();
            self.readyCallback = nil
        }
    }
    func proxyDidRecieveError(error: NSError) {
        if let delegate = passThroughDelegate {
            delegate.proxyDidRecieveError(error)
        }

    }

    func proxyDidSendLog(args: [AnyObject]) {
        if let delegate = passThroughDelegate {
            delegate.proxyDidSendLog(args)
        }
    }
}

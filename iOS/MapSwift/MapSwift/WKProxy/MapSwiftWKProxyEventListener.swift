//
//  MapSwiftWKProxyEventListener.swift
//  MapSwift
//
//  Created by David de Florinier on 11/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import WebKit

@objc class MapSwiftWKProxyEventListener: NSObject, WKScriptMessageHandler {
    let eventHandler:MapSwiftProxyEventHandler
    init(eventHandler:MapSwiftProxyEventHandler) {
        self.eventHandler = eventHandler
        super.init()
    }
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let bodyDictionary = message.body as? NSDictionary, eventName =  bodyDictionary["eventName"] as? String, args = bodyDictionary["args"] as? [AnyObject] {
            self.eventHandler(eventName: eventName, args: args)
        } else {
            print("MapSwiftWKProxyEventListener: unrecognised message:\(message.body)")
        }

    }
}

//
//  StubWKUserContentController.swift
//  MapSwift
//
//  Created by David de Florinier on 15/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import WebKit
@testable import MapSwift

class StubWKUserContentController: WKUserContentController {
    typealias AddScriptMessageHandlerCall = (scriptMessageHandler: WKScriptMessageHandler, name: String)
    var addScriptMessageHandlerCalls:[AddScriptMessageHandlerCall] = []
    override func addScriptMessageHandler(scriptMessageHandler: WKScriptMessageHandler, name: String) {
        addScriptMessageHandlerCalls.append(AddScriptMessageHandlerCall(scriptMessageHandler:scriptMessageHandler, name:name))
    }

    func sendEventToMapSwiftComponent(name:String, eventName:String, args:[AnyObject]) {
        let filtered = addScriptMessageHandlerCalls.filter { call -> Bool in
            return call.name == name
        }
        if let f = filtered.first, handler = f.scriptMessageHandler as? MapSwiftWKProxyEventListener {
            handler.eventHandler(eventName: eventName, args: args)
        }
    }
}

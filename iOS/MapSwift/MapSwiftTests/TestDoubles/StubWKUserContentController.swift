//
//  StubWKUserContentController.swift
//  MapSwift
//
//  Created by David de Florinier on 15/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import WebKit

class StubWKUserContentController: WKUserContentController {
    typealias AddScriptMessageHandlerCall = (scriptMessageHandler: WKScriptMessageHandler, name: String)
    var addScriptMessageHandlerCalls:[AddScriptMessageHandlerCall] = []
    override func addScriptMessageHandler(scriptMessageHandler: WKScriptMessageHandler, name: String) {
        addScriptMessageHandlerCalls.append(AddScriptMessageHandlerCall(scriptMessageHandler:scriptMessageHandler, name:name))
    }
}

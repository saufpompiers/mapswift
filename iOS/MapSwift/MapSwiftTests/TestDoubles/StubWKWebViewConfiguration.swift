//
//  StubWKWebViewConfiguration.swift
//  MapSwift
//
//  Created by David de Florinier on 17/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import WebKit

class StubWKWebViewConfiguration: WKWebViewConfiguration {
    var stub:WKUserContentController = StubWKUserContentController()
    override var userContentController:WKUserContentController {
        get {
            return stub
        }
        set(val) {
            stub = val
        }
    }

}

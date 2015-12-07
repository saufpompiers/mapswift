//
//  MapSwiftComponents.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import WebKit
public class MapSwiftCore {
    let container:WKWebView
    let containerProtocol:MapSwiftProxyProtocol
    var components:MapSwiftComponents?

    public init() {
        let config = WKWebViewConfiguration()
        self.container = WKWebView(frame: CGRectMake(0, 0, 500, 500), configuration: config)
        containerProtocol = MapSwiftWKProxyProtocol(container: container)
    }

    public func loadComponents(then:((components:MapSwiftComponents?, error:NSError?)->())) {
        if let components = self.components {
            then(components:components, error:nil)
            return
        }
        containerProtocol.loadResources(MapSwiftResources.sharedInstance) { (error) -> () in
            if error == nil {
                self.components = MapSwiftComponents(pingModel:MapSwiftPingModel(proxy: self.containerProtocol))
            }
            then(components:self.components, error:error)
        }
    }
}

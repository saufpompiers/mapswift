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
    var _components:MapSwiftComponents?

    public init(container:WKWebView, containerProtocol:MapSwiftProxyProtocol) {
        self.container = container
        self.containerProtocol = containerProtocol
    }

    public convenience init() {
        let config = WKWebViewConfiguration()
        let container = WKWebView(frame: CGRectMake(0, 0, 500, 500), configuration: config)
        let containerProtocol = MapSwiftWKProxyProtocol(container: container, resources: MapSwiftResources.sharedInstance)
        self.init(container:container, containerProtocol:containerProtocol)
    }

    public func start() {
        containerProtocol.start()
    }

    public var components:MapSwiftComponents? {
        get {
            if let components = _components {
                return components
            }
            if containerProtocol.isReady {
                _components = MapSwiftComponents(pingModel:MapSwiftPingModel(proxy: self.containerProtocol))
            }
            return _components
        }
    }

    public var delegate:MapSwiftProxyProtocolDelegate? {
        get {
            return containerProtocol.delegate
        }
        set(val) {
            containerProtocol.delegate = val
        }
    }
}

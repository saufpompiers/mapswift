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
    private let containerProtocol:MapSwiftProxyProtocol
    private var _components:MapSwiftComponents?

    public init(containerProtocol:MapSwiftProxyProtocol) {
        self.containerProtocol = containerProtocol
    }

    public convenience init() {
        let config = WKWebViewConfiguration()
        let container = WKWebView(frame: CGRectMake(0, 0, 500, 500), configuration: config)
        let containerProtocol = MapSwiftWKProxyProtocol(container: container, resources: MapSwiftResources.sharedInstance)
        self.init(containerProtocol:containerProtocol)
    }

    public func start() {
        containerProtocol.start()
    }

    public func components() throws  -> MapSwiftComponents? {
        if let components = _components {
            return components
        }
        if containerProtocol.isReady {
            do {
                let pingModel = try MapSwiftPingModel(proxy: self.containerProtocol)
                _components = MapSwiftComponents(pingModel:pingModel)
            } catch let error as NSError {
                print("unable to create components error:\(error.localizedDescription)")
            }
        }
        return _components
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

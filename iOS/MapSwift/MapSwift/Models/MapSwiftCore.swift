//
//  MapSwiftComponents.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import WebKit

public class MapSwiftCore  {
    public typealias StartThen = ((components:MapSwiftComponents)->())

    private let containerProtocol:MapSwiftProxyProtocol
    private var _components:MapSwiftComponents?
    private let proxyDelegateWrapper:MapSwiftProxyProtocolDelegateWrapper

    public init(containerProtocol:MapSwiftProxyProtocol) {
        self.proxyDelegateWrapper = MapSwiftProxyProtocolDelegateWrapper()
        self.containerProtocol = containerProtocol
        self.containerProtocol.delegate = self.proxyDelegateWrapper
    }

    public convenience init() {
        let config = WKWebViewConfiguration()
        let container = WKWebView(frame: CGRectMake(0, 0, 500, 500), configuration: config)
        let containerProtocol = MapSwiftWKProxyProtocol(container: container, resources: MapSwiftResources.sharedInstance)
        self.init(containerProtocol:containerProtocol)
    }

    private func buildMapSwiftComponents() throws -> MapSwiftComponents {
        let pingModel = try MapSwiftPingModel(proxy: self.containerProtocol)
        return MapSwiftComponents(pingModel:pingModel)
    }

    public func ready(then:StartThen, fail:MapSwiftProxyProtocolFail) {
        func thenBuildComponents()  {
            do {
                let components = try self.buildMapSwiftComponents()
                self._components = components
                then(components: components)
            } catch let error as NSError {
                fail(error: error);
            }
        }
        if let components = self._components {
            then(components: components)
        } else if containerProtocol.isReady {
            thenBuildComponents()
        } else if let _ = self.proxyDelegateWrapper.readyCallback {
            fail(error: MapSwiftError.ProtocolNotInRequiredState(MapSwiftProxyStatus.NotInitialised))
            return;
        } else {
            self.proxyDelegateWrapper.readyCallback = thenBuildComponents
            containerProtocol.start()
        }
    }

    public var delegate:MapSwiftProxyProtocolDelegate? {
        get {
            return proxyDelegateWrapper.passThroughDelegate
        }
        set(val) {
            proxyDelegateWrapper.passThroughDelegate = val
        }
    }

}

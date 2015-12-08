//
//  MapSwiftWKProxyProtocol.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import WebKit
public typealias MapSwiftProxyEventHandler = ((eventName:String, args:[AnyObject])->())

public protocol MapSwiftProxyProtocolDelegate:class {
    func proxyDidChangeStatus(status:MapSwiftProxyStatus)
    func proxyDidRecieveError(error:NSError)
}
public enum MapSwiftProxyStatus { case NotInitialised, LoadingPage, LoadingLibraries, ExecutingMain, LoadingError, Ready}
public protocol MapSwiftProxyProtocol:class {

    var delegate:MapSwiftProxyProtocolDelegate? {get set}
    var isReady:Bool {get}
    func sendCommand(componentId:String, selector:String, args:[AnyObject], then:((response:MapSwiftProxyResponse)->()))
    func addProxyListener(componentId:String, callBack:MapSwiftProxyEventHandler)
    func start()
}

class MapSwiftWKProxyProtocol:NSObject, MapSwiftProxyProtocol, WKScriptMessageHandler {
    let container:WKWebView;
    let resources:MapSwiftResources
    weak var delegate:MapSwiftProxyProtocolDelegate?


    var serialQueue = dispatch_queue_create("com.saufpompiers.MapSwiftWKProxyProtocol", DISPATCH_QUEUE_SERIAL)
    let notReadyError = NSError(domain: "com.saufpompiers", code: 1, userInfo: [NSLocalizedDescriptionKey: "notReady", NSLocalizedRecoverySuggestionErrorKey:"Use MapSwiftWKProxyProtocol.loadResources to make ready"]);

    @objc class MapSwiftWKProxyListener: NSObject, WKScriptMessageHandler {
        let eventHandler:MapSwiftProxyEventHandler
        let componentId:String
        init(componentId:String, eventHandler:MapSwiftProxyEventHandler) {
            self.componentId = componentId
            self.eventHandler = eventHandler
            super.init()
        }
        func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {

        }
    }

    var listeners:Dictionary<String, MapSwiftProxyEventHandler> = [:]
    private var _status = MapSwiftProxyStatus.NotInitialised
    var status:MapSwiftProxyStatus {
        get {
            return _status
        }
        set(val) {
            if (_status == val) {
                return
            }
            _status = val
            if let delegate = self.delegate {
                delegate.proxyDidChangeStatus(_status)
            }
        }
    }
    var isReady:Bool {
        get {
            return _status == MapSwiftProxyStatus.Ready
        }
    }

    init(container:WKWebView, resources:MapSwiftResources) {
        self.resources = resources
        self.container = container
    }

    private func getArgsString(args:[AnyObject]) -> String {
        do {
            let argsData = try NSJSONSerialization.dataWithJSONObject(args, options: NSJSONWritingOptions(rawValue: 0))
            if let s = NSString(data: argsData, encoding: NSUTF8StringEncoding) as? String {
                return s
            }
        } catch let err as NSError {
            print("Error \(err.localizedDescription) generating args string for \(args)")
        }
        return "[]";
    }
    func start() {
        dispatch_async(serialQueue, {
            if self.status != MapSwiftProxyStatus.NotInitialised {
                return
            }

            self.status = MapSwiftProxyStatus.LoadingLibraries
            let containerUrl = self.resources.containerHTMLURL()
            if let containerHtml = containerUrl.mapswift_fileContent {
                self.container.configuration.userContentController.addScriptMessageHandler(self, name: "map-swift-proxy");
                self.container.loadHTMLString(containerHtml, baseURL: containerUrl)
            } else {
                self.status = MapSwiftProxyStatus.LoadingError
            }

        })
    }
    private func loadingError(error:NSError) {
        self.status = MapSwiftProxyStatus.LoadingError
        if let delegate = self.delegate {
            delegate.proxyDidRecieveError(error)
        }
    }

    private func loadPageLibs() {
        self.status = MapSwiftProxyStatus.LoadingLibraries
        if let libJS = resources.containerLibrary {
            self.container.evaluateJavaScript(libJS) { (result, error) in }
        }
    }
    private func execPageMain() {
        self.status = MapSwiftProxyStatus.ExecutingMain
        let js = "MapSwift.editorMain({messageHandlerNames: ['pingModel']});"
        self.container.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                self.loadingError(error)
                return
            }
            self.status = MapSwiftProxyStatus.Ready
        }

    }
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        print("message:\(message.body)")
        if let body = message.body as? String where body == "map-swift-page-loaded" {
            self.loadPageLibs()
        } else if let body = message.body as? String where body == "map-swift-lib-loaded" {
            self.execPageMain();
        }
    }
    func sendCommand(componentId:String, selector:String, args:[AnyObject], then:((response:MapSwiftProxyResponse)->())) {
        dispatch_async(serialQueue, {
            if self.status != MapSwiftProxyStatus.Ready {
                let response = MapSwiftProxyResponse(id:"", completed:false, componentId:componentId, selector:selector, result: nil, error:self.notReadyError);
                then(response:response);
                return
            }

            let commandJS = "components.containerProxy.sendFromSwift({componentId: '\(componentId)', selector: '\(selector)', args: \(self.getArgsString(args))});"
            self.container.evaluateJavaScript(commandJS) { (result, error) in
                print("evaluateJavaScript:\(commandJS) result:\(result) error:\(error)")

                let completed = error == nil ? true : false

                let response = MapSwiftProxyResponse(id:"", completed:completed, componentId:componentId, selector:selector, result: nil, error:error);
                then(response:response);
            }
        })
    }
    func addProxyListener(componentId:String, callBack:MapSwiftProxyEventHandler) {
        let listener = MapSwiftWKProxyListener(componentId: componentId, eventHandler: callBack)
        container.configuration.userContentController.addScriptMessageHandler(listener, name: componentId);
    }
}

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
    func sendCommand(componentId:String, selector:String, args:[AnyObject], then:((response:MapSwiftProxyResponse?, error:NSError?)->()))
    func addProxyListener(componentId:String, callBack:MapSwiftProxyEventHandler)
    func start()
}

class MapSwiftWKProxyProtocol:NSObject, MapSwiftProxyProtocol {
    let container:WKWebView;
    let resources:MapSwiftResources
    weak var delegate:MapSwiftProxyProtocolDelegate?
    let serialQueue = dispatch_queue_create("com.saufpompiers.MapSwiftWKProxyProtocol", DISPATCH_QUEUE_SERIAL)


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
                print("unrecognised message:\(message.body)")
            }

        }
    }

    var listeners:Dictionary<String, MapSwiftProxyEventHandler> = [:]
    private var _status = MapSwiftProxyStatus.NotInitialised
    private var proxyEventListener:MapSwiftWKProxyEventListener?

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

    private let EMPTY_ARGS_STRING = "[]"
    private func getArgsString(args:[AnyObject]) -> String? {

        if args.count == 0 {
            return EMPTY_ARGS_STRING
        }
        do {
            let argsData = try NSJSONSerialization.dataWithJSONObject(args, options: NSJSONWritingOptions(rawValue: 0))
            if let argsString = NSString(data: argsData, encoding: NSUTF8StringEncoding) as? String {
                return argsString
            } else {
                return EMPTY_ARGS_STRING
            }
        } catch let err as NSError {
            print("Error \(err.localizedDescription) generating args string for \(args)")
        }
        return nil;
    }

    func start() {
        dispatch_async(serialQueue, {
            if self.status != MapSwiftProxyStatus.NotInitialised {
                return
            }

            self.status = MapSwiftProxyStatus.LoadingLibraries
            let containerUrl = self.resources.containerHTMLURL()
            if let containerHtml = containerUrl.mapswift_fileContent {
                let listener = MapSwiftWKProxyEventListener() { (eventName, args) -> () in
                    switch eventName {
                    case "error":
                        let error = NSError(domain: "com.saufpompiers", code: 1, userInfo: [NSLocalizedDescriptionKey: "\(args)"]);
                        self.loadingError(error)
                    case "status":
                        if let status = args[0] as? String {
                            if status == "map-swift-page-loaded" {
                                self.loadPageLibs()
                            } else if status == "map-swift-lib-loaded" {
                                self.execPageMain();
                            }
                        }
                    default:
                        print("unknown event:\(eventName) args:\(args)")
                    }
                }
                self.container.configuration.userContentController.addScriptMessageHandler(listener, name: "map-swift-proxy");
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
        let js = "MapSwift.editorMain();"
        self.container.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                self.loadingError(error)
                return
            }
            self.status = MapSwiftProxyStatus.Ready
        }

    }
    func sendCommand(componentId:String, selector:String, args:[AnyObject], then:((response:MapSwiftProxyResponse?, error:NSError?)->())) {
        dispatch_async(serialQueue, {
            if self.status != MapSwiftProxyStatus.Ready {
                then(response:nil, error: MapSwiftError.ProtocolNotReady);
            } else if let argsString = self.getArgsString(args) {
                let commandJS = "components.containerProxy.sendFromSwift({componentId: '\(componentId)', selector: '\(selector)', args: \(argsString)});"
                self.container.evaluateJavaScript(commandJS) { (result, error) in
                    if let resultDictionary = result as? NSDictionary {
                        let proxyResponse = resultDictionary.toMapSwiftProxyResponse(error)
                        then(response: proxyResponse, error: error)
                    } else {
                        then(response:nil, error: error);
                    }
                }
            } else {
                then(response:nil, error: MapSwiftError.InvalidProtocolRequestArgs);
            }
        })
    }
    func addProxyListener(componentId:String, callBack:MapSwiftProxyEventHandler) {
        let listener = MapSwiftWKProxyEventListener(eventHandler: callBack)
        container.configuration.userContentController.addScriptMessageHandler(listener, name: componentId);
    }
}

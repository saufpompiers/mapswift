//
//  MapSwiftWKProxyProtocol.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import WebKit

class MapSwiftWKProxyProtocol:NSObject, MapSwiftProxyProtocol {

    private let container:WKWebView;
    private let resources:MapSwiftResources
    private let serialQueue = dispatch_queue_create("com.saufpompiers.MapSwiftWKProxyProtocol", DISPATCH_QUEUE_SERIAL)
    private var listeners:Dictionary<String, MapSwiftProxyEventHandler> = [:]
    private var proxyEventListener:MapSwiftWKProxyEventListener?
    private var _status = MapSwiftProxyStatus.NotInitialised
    private var _listener:MapSwiftWKProxyEventListener?

    init(container:WKWebView, resources:MapSwiftResources) {
        self.resources = resources
        self.container = container
    }

    private var listener:MapSwiftWKProxyEventListener {
        get {
            if let listener = _listener {
                return listener
            } else {
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
                    case "log":
                        self.logReceived(args);
                    default:
                        print("unknown event:\(eventName) args:\(args)")
                    }
                }
                _listener = listener
                return listener
            }
        }
    }
    //MARK: - Private helper methods
    private func changeStatus(latest:MapSwiftProxyStatus) {
        if (_status == latest) {
            return
        }
        _status = latest
        if let delegate = self.delegate {
            delegate.proxyDidChangeStatus(_status)
        }
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

    private func loadPageLibs() {
        self.changeStatus(MapSwiftProxyStatus.LoadingLibraries)
        if let libJS = resources.containerLibrary {
            self.container.evaluateJavaScript(libJS) { (result, error) in }
        }
    }

    private func execPageMain() {
        self.changeStatus(MapSwiftProxyStatus.ExecutingMain)
        let js = "MapSwift.editorMain();"
        self.container.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                self.loadingError(error)
                return
            }
            self.changeStatus(MapSwiftProxyStatus.Ready)
        }

    }

//MARK: - Delegate callbacks
    private func logReceived(args:[AnyObject]) {
        if let delegate = delegate {
            delegate.proxyDidSendLog(args);
        }
    }

    private func loadingError(error:NSError) {
        self.changeStatus(MapSwiftProxyStatus.LoadingError)
        if let delegate = self.delegate {
            delegate.proxyDidRecieveError(error)
        }
    }

//MARK: - MapSwiftProxyProtocol
    weak var delegate:MapSwiftProxyProtocolDelegate?
    var isReady:Bool {
        get {
            return _status == MapSwiftProxyStatus.Ready
        }
    }

    func start() {
        dispatch_async(serialQueue, {
            if self._status != MapSwiftProxyStatus.NotInitialised {
                return
            }

            self.changeStatus(MapSwiftProxyStatus.LoadingLibraries)
            let containerUrl = self.resources.containerHTMLURL()
            if let containerHtml = containerUrl.mapswift_fileContent {
                self.container.configuration.userContentController.addScriptMessageHandler(self.listener, name: "map-swift-proxy");
                self.container.loadHTMLString(containerHtml, baseURL: containerUrl)
            } else {
                self.changeStatus(MapSwiftProxyStatus.LoadingError)
            }

        })
    }

    func sendCommand(componentId:String, selector:String, args:[AnyObject], then:((response:MapSwiftProxyResponse?, error:NSError?)->())) {
        dispatch_async(serialQueue, {
            if !self.isReady {
                then(response:nil, error: MapSwiftError.ProtocolNotReady);
            } else if let argsString = self.getArgsString(args) {
                let commandJS = "components.containerProxy.sendFromSwift({componentId: '\(componentId)', selector: '\(selector)', args: \(argsString)});"
                self.container.evaluateJavaScript(commandJS) { (result, error) in
                    if let error = error {
                        then(response:nil, error: error);
                    } else if let resultDictionary = result as? NSDictionary {
                        then(response: MapSwiftProxyResponse.fromNSDictionary(resultDictionary), error: error)
                    } else {
                        then(response:nil, error: nil);
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

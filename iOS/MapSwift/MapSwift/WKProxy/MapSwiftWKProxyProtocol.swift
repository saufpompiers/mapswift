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


    private func loadPageLibs() {
        self.changeStatus(MapSwiftProxyStatus.LoadingLibraries)
        if let libJS = resources.containerLibrary {
            self.container.evaluateJavaScript(libJS) { (result, error) in
                if let error = error {
                    self.loadingError(error)
                }
            }
        }
    }

    private func execPageMain() {
        self.changeStatus(MapSwiftProxyStatus.ExecutingMain)
        self.container.evaluateJavaScript("MapSwift.editorMain();") { (result, error) in
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
        self.start(true)
    }
    func start(async:Bool) {
        let doStart:(()->()) = {
            if self._status != MapSwiftProxyStatus.NotInitialised {
                self.loadingError(MapSwiftError.ProtocolNotInRequiredState(MapSwiftProxyStatus.NotInitialised))
                return
            }
            self.changeStatus(MapSwiftProxyStatus.LoadingPage)
            let containerUrl = self.resources.containerHTMLURL()
            self.container.configuration.userContentController.addScriptMessageHandler(self.listener, name: "map-swift-proxy");
            self.container.loadFileURL(containerUrl, allowingReadAccessToURL: containerUrl)
        }
        if (async) {
            dispatch_async(serialQueue, doStart)
        } else {
            dispatch_sync(serialQueue, doStart)
        }
    }
    func execCommandArgString(componentId:String, selector:String, argString:String, then:MapSwiftProxyProtocolExecCommandArgStringThen, fail:MapSwiftProxyProtocolFail) {
        dispatch_async(serialQueue, {
            if !self.isReady {
                fail(error: MapSwiftError.ProtocolNotInRequiredState(MapSwiftProxyStatus.Ready));
            } else {
                let commandJS = "components.\(componentId).\(selector)(\(argString));"
                print("commandJS:\(commandJS)")
                self.container.evaluateJavaScript(commandJS) { (result, error) in
                    if let error = error {
                        fail(error: error);
                    } else if let result = result {
                        then(response: "\(result)")
                    } else {
                        then(response: "")
                    }
                }
            }
        })

    }
    func sendCommand(componentId:String, selector:String, args:[AnyObject], then:MapSwiftProxyProtocolSendCommandThen, fail:MapSwiftProxyProtocolFail) {
        dispatch_async(serialQueue, {
            if !self.isReady {
                fail(error: MapSwiftError.ProtocolNotInRequiredState(MapSwiftProxyStatus.Ready));
            } else if let argsString = String.mapswift_jsArgsString(args) {
                let commandJS = "components.containerProxy.sendFromSwift({componentId: '\(componentId)', selector: '\(selector)', args: \(argsString)});"
                self.container.evaluateJavaScript(commandJS) { (result, error) in
                    if let error = error {
                        fail(error: error);
                    } else if let resultDictionary = result as? NSDictionary {
                        then(response: MapSwiftProxyResponse.fromNSDictionary(resultDictionary))
                    } else {
                        fail(error: MapSwiftError.UnrecognisedResponseFromWKContainer(result));
                    }
                }
            } else {
                fail(error: MapSwiftError.InvalidProtocolRequestArgs);
            }
        })
    }

    func addProxyListener(componentId:String, callBack:MapSwiftProxyEventHandler) throws {
        if !self.isReady {
            throw MapSwiftError.ProtocolNotInRequiredState(MapSwiftProxyStatus.Ready);
        }
        let listener = MapSwiftWKProxyEventListener(eventHandler: callBack)
        container.configuration.userContentController.addScriptMessageHandler(listener, name: componentId);
    }
}

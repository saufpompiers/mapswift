//
//  MapSwiftWKProxyProtocol.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import WebKit
public typealias MapSwiftProxyEventHandler = ((eventName:String, args:[AnyObject])->())

public protocol MapSwiftProxyProtocol:class {

    func sendCommand(componentId:String, selector:String, args:[AnyObject], then:((response:MapSwiftProxyResponse)->()))
    func addProxyListener(componentId:String, callBack:MapSwiftProxyEventHandler)
    func loadResources(resources:MapSwiftResources, then:((error:NSError?)->()))
}

class MapSwiftWKProxyProtocol:NSObject, MapSwiftProxyProtocol, WKScriptMessageHandler {
    let container:WKWebView;
    enum Status { case NotInitialised, LoadingLibraries, LoadingError, Ready}
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
    var status = Status.NotInitialised
    init(container:WKWebView) {
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
    var callback:((error:NSError?)->())?
    func loadResources(resources:MapSwiftResources, then:((error:NSError?)->())) {
        self.callback = then
        dispatch_async(serialQueue, {
            if self.status != Status.NotInitialised {
                then(error: nil)
                return
            }

            if self.status != Status.NotInitialised {
                then(error: self.notReadyError)
                return
            }
            self.status = Status.LoadingLibraries
            let containerUrl = resources.containerHTMLURL()
            if let containerHtml = containerUrl.mapswift_fileContent {
                if let libJS = resources.containerLibrary {
                    let containerHtmlFull = containerHtml.stringByReplacingOccurrencesOfString("/* ios_insert_here */", withString: libJS);
                self.container.configuration.userContentController.addScriptMessageHandler(self, name: "proxy");
                print("loading");
                self.container.loadHTMLString(containerHtmlFull, baseURL: containerUrl)
                }
            } else {
                self.status = Status.LoadingError
                then(error: self.notReadyError)
                return
            }

        })
    }
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        print("message:\(message.body)")

        if let body = message.body as? String where body == "lib-loaded" {
            if let callback = self.callback {
                self.status = Status.Ready
                callback(error:nil)
            }
        }
    }
    func sendCommand(componentId:String, selector:String, args:[AnyObject], then:((response:MapSwiftProxyResponse)->())) {
        dispatch_async(serialQueue, {
            if self.status != Status.Ready {
                let response = MapSwiftProxyResponse(id:"", completed:false, componentId:componentId, selector:selector, result: nil, error:self.notReadyError);
                then(response:response);
                return
            }

            let commandJS = "components.containerProxy.sendFromSwift({componentId: '\(componentId)', selector: '\(selector)', args: \(self.getArgsString(args))});"
            self.container.evaluateJavaScript(commandJS) { (result, error) in
                print("evaluateJavaScript:\(commandJS) result:\(result) error:\(error)")
                let completed = error == nil ? false : true

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

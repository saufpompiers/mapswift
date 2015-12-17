//
//  StubWKWebView.swift
//  MapSwift
//
//  Created by David de Florinier on 15/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import WebKit
class StubWKWebView: WKWebView {
    typealias EvaluateJavaScriptCall = (javaScriptString: String, completionHandler: ((AnyObject?, NSError?) -> Void)?)
    var evaluateJavaScriptCalls:[EvaluateJavaScriptCall] = []
    override func evaluateJavaScript(javaScriptString: String, completionHandler: ((AnyObject?, NSError?) -> Void)?) {
        evaluateJavaScriptCalls.append(EvaluateJavaScriptCall(javaScriptString:javaScriptString, completionHandler:completionHandler))
    }

    typealias LoadHTMLStringCall = (string: String, baseURL: NSURL?)
    var loadHTMLStringCalls:[LoadHTMLStringCall] = []
    override func loadHTMLString(string: String, baseURL: NSURL?) -> WKNavigation? {
        loadHTMLStringCalls.append(LoadHTMLStringCall(string:string, baseURL:baseURL))
        return nil
    }

    typealias LoadFileURLCall = (URL: NSURL, allowingReadAccessToURL: NSURL)
    var loadFileURLCalls:[LoadFileURLCall] = []
    override func loadFileURL(URL: NSURL, allowingReadAccessToURL readAccessURL: NSURL) -> WKNavigation? {
        loadFileURLCalls.append((URL:URL, allowingReadAccessToURL:readAccessURL))
        return nil
    }

    var _configuration:WKWebViewConfiguration = StubWKWebViewConfiguration()
    override var configuration:WKWebViewConfiguration {
        get {
            return _configuration
        }
    }
}

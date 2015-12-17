//
//  MapSwiftWKProxyProtocolTests.swift
//  MapSwift
//
//  Created by David de Florinier on 15/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift

class MapSwiftWKProxyProtocolTests: XCTestCase  {
    var underTest:MapSwiftWKProxyProtocol!
    var stubWebView:StubWKWebView!
    var stubUserContentController:StubWKUserContentController!
    var stubResources:MapSwiftStubResources!
    var stubDelegate:MapSwiftStubProxyProtocolDelegate!

    override func setUp() {
        super.setUp()
        stubDelegate = MapSwiftStubProxyProtocolDelegate();
        stubResources = MapSwiftStubResources()
        stubWebView = StubWKWebView(frame: CGRectMake(10, 10, 10, 10))
        stubUserContentController = StubWKUserContentController()
        stubWebView.configuration.userContentController = stubUserContentController
        underTest = MapSwiftWKProxyProtocol(container: stubWebView, resources: stubResources)
        underTest.delegate = stubDelegate
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //MARK: - start()
    func test_start_should_change_status_to_loading_page() {
        underTest.start(false)
        XCTAssertEqual(stubDelegate.proxyDidChangeStatusCalls.count, 1)
        XCTAssertEqual(stubDelegate.proxyDidChangeStatusCalls[0], MapSwiftProxyStatus.LoadingPage)
    }

    func test_start_should_add_script_message_handler() {
        underTest.start(false)
        XCTAssertEqual(stubUserContentController.addScriptMessageHandlerCalls.count, 1)
        let call = stubUserContentController.addScriptMessageHandlerCalls[0]
        XCTAssertEqual(call.name, "map-swift-proxy")
    }
    
    func test_start_should_load_page() {
        underTest.start(false)
        XCTAssertEqual(stubWebView.loadFileURLCalls.count, 1)
        let call = stubWebView.loadFileURLCalls[0]
        XCTAssertEqual(call.URL, stubResources.containerHTMLURL())
        XCTAssertEqual(call.allowingReadAccessToURL, stubResources.containerHTMLURL())
    }

    func test_should_change_status_to_loading_page_libraries_when_page_has_loaded() {
        underTest.start(false)
        stubUserContentController.sendEventToMapSwiftComponent("map-swift-proxy", eventName: "status", args: ["map-swift-page-loaded"])
        XCTAssertEqual(stubDelegate.proxyDidChangeStatusCalls.last, MapSwiftProxyStatus.LoadingLibraries)
    }


    func test_should_load_page_libraries_when_page_has_loaded() {
        underTest.start(false)
        stubUserContentController.sendEventToMapSwiftComponent("map-swift-proxy", eventName: "status", args: ["map-swift-page-loaded"])
        if let lastCall = stubWebView.evaluateJavaScriptCalls.last {
            XCTAssertEqual(lastCall.javaScriptString, stubResources.containerLibrary)
        } else {
            XCTFail("no evaluateJavaScriptCalls")
        }
    }

    func test_should_change_status_to_executing_main_when_page_libraries_have_loaded() {
        underTest.start(false)
        stubUserContentController.sendEventToMapSwiftComponent("map-swift-proxy", eventName: "status", args: ["map-swift-lib-loaded"])
        XCTAssertEqual(stubDelegate.proxyDidChangeStatusCalls.last, MapSwiftProxyStatus.ExecutingMain)
    }

    func test_should_exc_main_when_page_libraries_have_loaded() {
        underTest.start(false)
        stubUserContentController.sendEventToMapSwiftComponent("map-swift-proxy", eventName: "status", args: ["map-swift-lib-loaded"])
        if let lastCall = stubWebView.evaluateJavaScriptCalls.last {
            XCTAssertEqual(lastCall.javaScriptString, "MapSwift.editorMain();")
        } else {
            XCTFail("no evaluateJavaScriptCalls")
        }
    }
    func test_should_change_status_to_ready_when_main_has_executed_without_error() {
        underTest.start(false)
        stubUserContentController.sendEventToMapSwiftComponent("map-swift-proxy", eventName: "status", args: ["map-swift-lib-loaded"])
        if let lastCall = stubWebView.evaluateJavaScriptCalls.last {
            lastCall.completionHandler!(nil,nil);
            XCTAssertEqual(stubDelegate.proxyDidChangeStatusCalls.last, MapSwiftProxyStatus.Ready)
        } else {
            XCTFail("no evaluateJavaScriptCalls")
        }
    }
}

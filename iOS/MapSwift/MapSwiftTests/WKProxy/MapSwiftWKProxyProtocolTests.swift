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
    
    func test_start_should_change_status_t0_loading_page() {
        underTest.start(false)
        XCTAssertEqual(stubDelegate.proxyDidChangeStatusCalls.count, 1)
        XCTAssertEqual(stubDelegate.proxyDidChangeStatusCalls[0], MapSwiftProxyStatus.LoadingPage)
    }
    
    
}

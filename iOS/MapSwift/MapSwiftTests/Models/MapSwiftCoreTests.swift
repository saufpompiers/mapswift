//
//  MapSwiftCoreTests.swift
//  MapSwift
//
//  Created by David de Florinier on 15/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
import MapSwift

class MapSwiftCoreTests: XCTestCase {
    var underTest:MapSwiftCore!
    var stubProtocol:MapSwiftStubProxyProtocol!
    var stubDelegate:MapSwiftStubProxyProtocolDelegate!
    func failHandler(error:NSError?)  {
        if let error = error {
            XCTFail("unexpected error:\(error.localizedDescription)")
        }
    }
    override func setUp() {
        super.setUp()
        stubProtocol = MapSwiftStubProxyProtocol()
        stubDelegate = MapSwiftStubProxyProtocolDelegate();
        underTest = MapSwiftCore(containerProtocol: stubProtocol)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
//MARK: - Stubbed tests
    func test_start_should_start_protocol() {
        underTest.ready({ (components) -> () in }, fail:failHandler)
        XCTAssertEqual(stubProtocol.startCalls, 1)
    }


    func test_should_attach_delegate_to_protocol() {
        underTest.delegate = stubDelegate
        stubProtocol.delegate!.proxyDidChangeStatus(MapSwiftProxyStatus.Ready)
        if let call = stubDelegate.proxyDidChangeStatusCalls.last {
            XCTAssertEqual(call, MapSwiftProxyStatus.Ready)
        } else {
            XCTFail("proxy call not passed")
        }
    }

//MARK: - Integration Tests

    func test_integrated_should_return_components() {
        underTest = MapSwiftCore()
        let expectation = expectationWithDescription("should return components");

        underTest.ready({ (components) -> () in
            expectation.fulfill()
        }, fail: failHandler)

        waitForExpectationsWithTimeout(5.0, handler: failHandler)
    }


}

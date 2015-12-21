//
//  MapSwiftPingModelTests.swift
//  MapSwift
//
//  Created by David de Florinier on 21/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
import MapSwift

class MapSwiftPingModelTests: XCTestCase {
    var mapSwift:MapSwiftCore!
    var stubPingDelegate:StubPingDelegate!

    func failHandler(error:NSError?)  {
        if let error = error {
            XCTFail("unexpected error:\(error.localizedDescription)")
        }
    }

    override func setUp() {
        super.setUp()
        stubPingDelegate = StubPingDelegate()
        mapSwift = MapSwiftCore()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        mapSwift = nil
    }
    
    func test_should_echo() {
        let expectation = expectationWithDescription("should echo");

        mapSwift.ready({ (components) -> () in
            let underTest = components.pingModel
            underTest.echo("hello", then: { (response) -> () in
                expectation.fulfill()
                XCTAssertEqual(response.identifier, "hello");
            }, fail: self.failHandler)
        }, fail: failHandler)

        waitForExpectationsWithTimeout(5.0, handler: failHandler)
    }

    func test_should_ping() {
        let startExpectation = expectationWithDescription("should start");
        let pingExpectation = expectationWithDescription("should ping");
        let stopExpectation = expectationWithDescription("should stop");

        mapSwift.ready({ (components) -> () in
            let underTest = components.pingModel
            underTest.delegate = self.stubPingDelegate
            self.stubPingDelegate.listener = { (identifier, sent) in
                XCTAssertEqual("hello", identifier)
                underTest.stop({ () -> () in
                    stopExpectation.fulfill()
                }, fail: self.failHandler)
                pingExpectation.fulfill()
            }
            underTest.start("hello", interval: 0.1, then: { () -> () in
                startExpectation.fulfill()
            }, fail: self.failHandler)
        }, fail: failHandler)

        waitForExpectationsWithTimeout(5.0, handler: failHandler)
    }

}

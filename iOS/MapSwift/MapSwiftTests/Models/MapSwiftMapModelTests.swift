//
//  bMapSwiftMapModelTests.swift
//  MapSwift
//
//  Created by David de Florinier on 21/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
import MapSwift

class MapSwiftMapModelTests: XCTestCase {
    var mapSwift:MapSwiftCore!
    let EMPTY_MAP = "{\"id\": \"1\", \"title\": \"empty map\"}"
    var stubDelegate:StubMapSwiftMapModelDelegate!

    func failHandler(error:NSError?)  {
        if let error = error {
            XCTFail("unexpected error:\(error.localizedDescription)")
        }   
    }

    override func setUp() {
        super.setUp()
        stubDelegate = StubMapSwiftMapModelDelegate()
        mapSwift = MapSwiftCore()

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func test_should_setIdea() {
        let expectation = expectationWithDescription("should set idea");
        mapSwift.ready({ (components) -> () in
            components.mapModel.delegate = self.stubDelegate
            components.mapModel.setIdea(self.EMPTY_MAP, then: { () -> () in
                expectation.fulfill()
            }, fail: self.failHandler)
        }, fail: failHandler)

        waitForExpectationsWithTimeout(5.0, handler: failHandler)
    }

    func test_should_addSubIdea() {
        let expectAddSubIdea = expectationWithDescription("should add subidea");
        let expectNodeEvent = expectationWithDescription("should send node added event");
        mapSwift.ready({ (components) -> () in
            components.mapModel.delegate = self.stubDelegate
            components.mapModel.setIdea(self.EMPTY_MAP, then: {
                self.stubDelegate.mapModelNodeEventListener = { (event: MapSwiftMapModel.NodeEvent, node:MapSwiftNode) in
                    XCTAssertEqual(event, MapSwiftMapModel.NodeEvent.NodeCreated)
                    XCTAssertEqual(node.title, "hello")
                    expectNodeEvent.fulfill()
                }
                components.mapModel.addSubIdea("1", initialTitle: "hello", then: {
                        expectAddSubIdea.fulfill()
                    }, fail: self.failHandler)
                }, fail: self.failHandler)
            }, fail: failHandler)

        waitForExpectationsWithTimeout(5.0, handler: failHandler)
    }

}

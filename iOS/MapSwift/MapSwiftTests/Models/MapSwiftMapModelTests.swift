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
    let NODES_MAP = "{ \"id\": \"1\", \"title\": \"map center\",  \"ideas\": { \"-1\": {\"id\": \"2\", \"title\": \"left node\"},  \"1\": {\"id\": \"3\", \"title\": \"right node\"}}}"

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
    }

    func test_should_set_idea() {
        let expectation = expectationWithDescription("should set idea");
        mapSwift.ready({ (components) -> () in
            components.mapModel.delegate = self.stubDelegate
            components.mapModel.setIdea(self.EMPTY_MAP, then: { () -> () in
                expectation.fulfill()
                }, fail: self.failHandler)
            }, fail: failHandler)

        waitForExpectationsWithTimeout(5.0, handler: failHandler)
    }

    func test_should_send_node_and_connector_created_events_when_idea_set() {
        let expectation = expectationWithDescription("should set idea");
        let expectNodeEvent = expectationWithDescription("should send node added event");
        let expectConnectorEvent = expectationWithDescription("should send connector added event");

        mapSwift.ready({ (components) -> () in
            components.mapModel.delegate = self.stubDelegate
            self.stubDelegate.mapModelNodeEventListener = { (event: MapSwiftMapModel.NodeEvent, node:MapSwiftNode) in
                XCTAssertEqual(event, MapSwiftMapModel.NodeEvent.NodeCreated)

                if self.stubDelegate.mapModelNodeEventCalls == 3 {
                    expectNodeEvent.fulfill()
                }
            }
            self.stubDelegate.mapModelConnectorEventListener = { (event, connector) in
                if (self.stubDelegate.mapModelConnectorEventCalls == 2) {
                    expectConnectorEvent.fulfill()
                }
            }
            components.mapModel.setIdea(self.NODES_MAP, then: { () -> () in
                expectation.fulfill()
                }, fail: self.failHandler)
            }, fail: failHandler)

        waitForExpectationsWithTimeout(5.0, handler: failHandler)

    }
    func test_should_send_events_in_correct_order_when_idea_set() {
        let expectationForEvents = expectationWithDescription("should send events in correct order");
        let expectedOrder = ["layoutChangeStarting", "nodeCreated", "nodeCreated", "nodeCreated", "connectorCreated", "connectorCreated", "layoutChangeComplete"]
        mapSwift.ready({ (components) -> () in
            components.mapModel.delegate = self.stubDelegate
            self.stubDelegate.eventOccurredListener = {
                print("events:\(self.stubDelegate.eventOrder)")
                if self.stubDelegate.eventOrder == expectedOrder {
                    expectationForEvents.fulfill()
                }
            }
            components.mapModel.setIdea(self.NODES_MAP, then: { () -> () in
                }, fail: self.failHandler)
            }, fail: failHandler)

        waitForExpectationsWithTimeout(5.0, handler: failHandler)
    }

    func test_should_addSubIdea() {
        let expectAddSubIdea = expectationWithDescription("should add subidea");
        let expectNodeEvent = expectationWithDescription("should send node added event");
        let expectConnectorEvent = expectationWithDescription("should send connector added event");
        mapSwift.ready({ (components) -> () in
            components.mapModel.delegate = self.stubDelegate
            components.mapModel.setIdea(self.EMPTY_MAP, then: {
                self.stubDelegate.mapModelNodeEventListener = { (event: MapSwiftMapModel.NodeEvent, node:MapSwiftNode) in
                    XCTAssertEqual(event, MapSwiftMapModel.NodeEvent.NodeCreated)
                    XCTAssertEqual(node.title, "hello")
                    expectNodeEvent.fulfill()
                }
                self.stubDelegate.mapModelConnectorEventListener = { (event, connector) in
                    expectConnectorEvent.fulfill()
                }
                components.mapModel.addSubIdea("1", initialTitle: "hello", then: {
                    expectAddSubIdea.fulfill()
                }, fail: self.failHandler)
            }, fail: self.failHandler)
        }, fail: failHandler)

        waitForExpectationsWithTimeout(5.0, handler: failHandler)
    }

    func test_should_getCurrentLayout() {
        let expectGetCurrentLayout = expectationWithDescription("should add subidea");
        mapSwift.ready({ (components) -> () in
            components.mapModel.delegate = self.stubDelegate
            components.mapModel.setIdea(self.EMPTY_MAP, then: {
                components.mapModel.addSubIdea("1", initialTitle: "hello", then: { }, fail: self.failHandler)
                components.mapModel.getCurrentLayout({ (layout) -> () in
                    expectGetCurrentLayout.fulfill()
                }, fail: self.failHandler)
            }, fail: self.failHandler)
        }, fail: failHandler)

        waitForExpectationsWithTimeout(5.0, handler: failHandler)

    }
}

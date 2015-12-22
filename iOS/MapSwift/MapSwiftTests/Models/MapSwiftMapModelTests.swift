//
//  bMapSwiftMapModelTests.swift
//  MapSwift
//
//  Created by David de Florinier on 21/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
import MapSwift

class bMapSwiftMapModelTests: XCTestCase {
    var mapSwift:MapSwiftCore!
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
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()    
    }

    func test_should_setIdea() {
        let expectation = expectationWithDescription("should set idea");
        mapSwift.ready({ (components) -> () in
            components.mapModel.delegate = self.stubDelegate
            components.mapModel.setIdea("{\"title\":\"test map\"}", then: { () -> () in
                expectation.fulfill()
            }, fail: self.failHandler)
        }, fail: failHandler)

        waitForExpectationsWithTimeout(5.0, handler: failHandler)
    }


}

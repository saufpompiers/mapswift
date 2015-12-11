//
//  MapSwiftProxyResponseTests.swift
//  MapSwift
//
//  Created by David de Florinier on 11/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift

class MapSwiftProxyResponseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_should_be_created_from_NSDictionary() {
        let dict = [
            "completed": true,
            "componentId": "componentFoo",
            "selector": "doit",
            "id": "a",
            "result": ["A": "B", "C": "D"],
            "errors": ["err1", "err2"]
        ]

        let result = MapSwiftProxyResponse.fromNSDictionary(dict)
        XCTAssertEqual(result.completed, true)
        XCTAssertEqual(result.componentId, "componentFoo")
        XCTAssertEqual(result.selector, "doit")
        XCTAssertEqual(result.id, "a")
        if let result = result.result as? NSDictionary {
            XCTAssertEqual(result, ["A": "B", "C": "D"])
        } else {
            XCTFail("result dictionary expected")
        }
        if let errors = result.errors  {
            XCTAssertEqual(errors, ["err1", "err2"])
        } else {
            XCTFail("result errors expected")
        }
    }
    func test_should_be_created_from_an_empty_NSDictionary() {
        let result = MapSwiftProxyResponse.fromNSDictionary(NSDictionary())
        XCTAssertEqual(result.completed, false)
        XCTAssertNil(result.componentId)
        XCTAssertNil(result.selector)
        XCTAssertNil(result.id)
        XCTAssertNil(result.result)
        XCTAssertNil(result.errors)
    }

}

//
//  MapSwiftNodeConnectorTests.swift
//  MapSwift
//
//  Created by David de Florinier on 24/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift
class MapSwiftNodeConnectorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_should_parse_dictionary_with_string_from_and_to() {
        let dictionary = [
            "from": "1.test",
            "to": 2,
        ]
        if let result = MapSwiftNodeConnector.parseDictionary(dictionary) {
            XCTAssertEqual("1.test", result.from)
            XCTAssertEqual("2", result.to)
        } else {
            XCTFail("should parse dictionary")
        }
    }
    func test_should_not_parse_dictionary_Withour_from_and_to() {
        let dictionary = [
            "to": 2,
        ]
        XCTAssertNil(MapSwiftNodeConnector.parseDictionary(dictionary))
    }
}

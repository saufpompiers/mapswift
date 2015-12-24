//
//  MapSwiftNodeTests.swift
//  MapSwift
//
//  Created by David de Florinier on 23/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift

class MapSwiftNodeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_should_parse_dictionary_with_string_id() {
        let dictionary = [
            "id": "1.test",
            "title": "hello",
            "level": 2,
            "attr": ["style": false],
            "height": 22,
            "width": 2,
            "x": 23,
            "y": 45
        ]
        if let result = MapSwiftNode.parseDictionary(dictionary) {
            XCTAssertEqual("1.test", result.id)
            XCTAssertEqual("hello", result.title)
            XCTAssertEqual(2, result.level)
            let expectedRect = CGRectMake(23, 45, 2, 22)
            XCTAssertEqual(expectedRect, result.rect)
            XCTAssertNotNil(result.attr)
        } else {
            XCTFail("should parse dictionary")
        }
    }

    func test_should_parse_dictionary_with_int_id() {
        let dictionary = [
            "id": 1,
            "title": "hello",
            "level": 2,
            "attr": ["style": false],
            "height": 22,
            "width": 2,
            "x": 23,
            "y": 45
        ]
        if let result = MapSwiftNode.parseDictionary(dictionary) {
            XCTAssertEqual("1", result.id)
            XCTAssertEqual("hello", result.title)
            XCTAssertEqual(2, result.level)
            let expectedRect = CGRectMake(23, 45, 2, 22)
            XCTAssertEqual(expectedRect, result.rect)
            XCTAssertNotNil(result.attr)
        } else {
            XCTFail("should parse dictionary")
        }
    }

    func test_should_parse_dictionary_without_title() {
        let dictionary = [
            "id": "1.test",
            "level": 2,
            "attr": ["style": false],
            "height": 22,
            "width": 2,
            "x": 23,
            "y": 45
        ]
        if let result = MapSwiftNode.parseDictionary(dictionary) {
            XCTAssertEqual("1.test", result.id)
            XCTAssertEqual("", result.title)
            XCTAssertEqual(2, result.level)
            let expectedRect = CGRectMake(23, 45, 2, 22)
            XCTAssertEqual(expectedRect, result.rect)
            XCTAssertNotNil(result.attr)
        } else {
            XCTFail("should parse dictionary")
        }
    }

    func test_should_not_parse_dictionary_without_id() {
        let dictionary = [
            "level": 2,
            "attr": ["style": false],
            "height": 22,
            "width": 2,
            "x": 23,
            "y": 45
        ]
        XCTAssertNil(MapSwiftNode.parseDictionary(dictionary))
    }


}

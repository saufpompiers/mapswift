//
//  MapSwiftDefaultedDictionaryTests.swift
//  MapSwift
//
//  Created by David de Florinier on 12/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift

class MapSwiftDefaultedDictionaryTests: XCTestCase {
    var underTest:MapSwiftDefaultedDictionary!
    override func setUp() {
        super.setUp()
        let bundle = NSBundle(forClass: NSJSONSerializationExtensionsTests.self)
        let url = bundle.URLForResource("test-theme", withExtension: "json")!
        let dictionary = NSJSONSerialization.mapswift_JSONDictionaryFromFileURL(url)
        underTest = MapSwiftDefaultedDictionary(dictionary: dictionary!)

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

//MARK:- valueForKey
    func test_should_return_value_for_key() {
        if let result = underTest.valueForKey("name") as? String {
            XCTAssertEqual(result, "MindMup Test Theme")
        } else {
            XCTFail("no name found")
        }
    }
    
    func test_should_return_value_for_chain_of_keys() {
        if let result = underTest.valueForKey("node", "default", "cornerRadius") as? CGFloat {
            XCTAssertEqual(result, 10.0)
        } else {
            XCTFail("no cornerRadius found")
        }
    }

    func test_should_return_nil_for_invalid_chain_of_keys() {
        let result = underTest.valueForKey("nodey", "default", "cornerRadius")
        XCTAssertNil(result)
    }

//MARK:- valueForKeyWithOptions
    func test_should_return_value_for_a_single_option() {
    if let result = underTest.valueForKeyWithOptions(["node"], keyOptions:["default"], keyPostFixes:["backgroundColor"]) as? String {
            XCTAssertEqual(result, "#E0E0E0")
        } else {
            XCTFail("no backgroundColor found")
        }
    }

    func test_should_return_first_found_value_for_a_multiple_options() {
        if let result = underTest.valueForKeyWithOptions(["node"], keyOptions:["center", "default"], keyPostFixes:["backgroundColor"]) as? String {
            XCTAssertEqual(result, "#22AAE0")
        } else {
            XCTFail("no backgroundColor found")
        }
    }
    func test_should_return_first_found_value_for_a_multiple_options_without_postfixes() {
        if let result = underTest.valueForKeyWithOptions(["test"], keyOptions:["two", "one"], keyPostFixes:nil) as? Int {
            XCTAssertEqual(result, 2)
        } else {
            XCTFail("no value found")
        }

    }

}

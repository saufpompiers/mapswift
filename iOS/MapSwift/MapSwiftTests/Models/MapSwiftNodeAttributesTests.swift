//
//  MapSwiftNodeAttributesTests.swift
//  MapSwift
//
//  Created by David de Florinier on 29/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift
class MapSwiftNodeAttributesTests: XCTestCase {
    var underTest:MapSwiftNodeAttributes!
    var dictionary:[String:AnyObject]!
    override func setUp() {
        super.setUp()
        let style:[String:AnyObject] = [ "background": "#FF0000"]
        dictionary = [ "style": style]
        underTest = MapSwiftNodeAttributes.parseDictionary(dictionary)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_should_return_empty_attributes_for_nil_dictionary() {
        XCTAssertNotNil(MapSwiftNodeAttributes.parseDictionary(nil))
    }

    func test_should_parse_background_from_dictionary() {
        XCTAssertEqual(underTest.backgroundColor, UIColor(hexString: "#FF0000"))
    }

    func test_should_parse_dictionary_with_no_background() {
        let result = MapSwiftNodeAttributes.parseDictionary([:])
        XCTAssertNotNil(result)
        XCTAssertNil(result.backgroundColor)
    }


}

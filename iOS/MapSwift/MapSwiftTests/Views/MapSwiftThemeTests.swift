//
//  MapSwiftThemeTests.swift
//  MapSwift
//
//  Created by David de Florinier on 12/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift

class MapSwiftThemeTests: XCTestCase {
    var underTest:MapSwiftTheme!
    override func setUp() {
        super.setUp()
        let bundle = NSBundle(forClass: NSJSONSerializationExtensionsTests.self)
        let url = bundle.URLForResource("test-theme", withExtension: "json")!
        let dictionary = NSJSONSerialization.mapswift_JSONDictionaryFromFileURL(url)
        underTest = MapSwiftTheme(dictionary: dictionary!)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //MARK: - nodeAttribute

    func test_should_return_node_attribute() {
        if let result = underTest.nodeAttribute(.BackgroundColor, style: nil) as? String {
            XCTAssertEqual(result, "#E0E0E0")
        } else {
            XCTFail("background color not found")
        }
    }

    //MARK: - nodeAttribute<T>

    func test_should_return_node_attribute_with_type() {
        let result = underTest.nodeAttribute(.BackgroundColor, style: nil, fallback:"wrong")
        XCTAssertEqual(result, "#E0E0E0")
    }

}

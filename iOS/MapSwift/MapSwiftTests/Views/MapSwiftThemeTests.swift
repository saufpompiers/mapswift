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

    func test_should_return_node_attribute_with_no_style() {
        let result = underTest.nodeAttribute(.BackgroundColor, style: nil, fallback:"wrong")
        XCTAssertEqual(result, "#E0E0E0")
    }
    func test_should_return_node_attribute_with_style() {
        let result = underTest.nodeAttribute(.BackgroundColor, style: "center", fallback:"wrong")
        XCTAssertEqual(result, "#22AAE0")
    }

    //MARK: - nodeBorderStyle
    func test_should_return_node_border_style_with_name() {
        let result = underTest.nodeBorderStyle("center")
        XCTAssertEqual(result.width, 2.0)
        XCTAssertEqual(result.color, UIColor(hexString: "#707070"))
    }

    func test_should_return_node_border_style_with_no_name() {
        let result = underTest.nodeBorderStyle(nil)
        XCTAssertEqual(result.width, 1.0)
        XCTAssertEqual(result.color, UIColor(hexString: "#707070"))
    }
    //MARK: - nodeShadowStyle
    func test_should_return_node_shadow_style_with_name() {
        let result = underTest.nodeShadowStyle("center")
        XCTAssertEqual(result.color, UIColor(hexString: "#070707"))
        XCTAssertEqual(result.offset, CGSizeMake(2, 4))
        XCTAssertEqual(result.opacity, 0.6)
        XCTAssertEqual(result.radius, 2)
    }

    func test_should_return_node_shadow_style_with_no_name() {
        let result = underTest.nodeShadowStyle(nil)
        XCTAssertEqual(result.color, UIColor(hexString: "#070707"))
        XCTAssertEqual(result.offset, CGSizeMake(2, 2))
        XCTAssertEqual(result.opacity, 0.4)
        XCTAssertEqual(result.radius, 2)
    }
}

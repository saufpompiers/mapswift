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

    func test_should_return_name() {
        XCTAssertEqual(underTest.name, "MindMup Test Theme")
    }

    func test_should_return_default() {
        XCTAssertEqual(MapSwiftTheme.Default().name, "MindMup Default")
    }
    
    //MARK: - nodeAttribute

    func test_should_return_node_attribute() {
        if let result = underTest.nodeAttribute(.BackgroundColor, styles: []) as? String {
            XCTAssertEqual(result, "#E0E0E0")
        } else {
            XCTFail("background color not found")
        }
    }

    //MARK: - nodeAttribute<T>

    func test_should_return_node_attribute_with_no_style() {
        let result = underTest.nodeAttribute(.BackgroundColor, styles: [], fallback:"wrong")
        XCTAssertEqual(result, "#E0E0E0")
    }
    func test_should_return_node_attribute_with_style() {
        let result = underTest.nodeAttribute(.BackgroundColor, styles: ["center"], fallback:"wrong")
        XCTAssertEqual(result, "#22AAE0")
    }

    //MARK: - nodeFontStyle
    func test_should_return_node_font_style_with_no_name() {
        let result = underTest.nodeFontStyle([])
        XCTAssertEqual(result.size, 14.0)
        XCTAssertEqual(result.weight, UIFontWeightSemibold)
    }

    func test_should_return_node_font_style_with_name() {
        let result = underTest.nodeFontStyle(["center"])
        XCTAssertEqual(result.size, 15.0)
        XCTAssertEqual(result.weight, UIFontWeightSemibold)
    }

    //MARK: - nodeTextStyle
    func test_should_return_node_text_style_with_no_name() {
        let result = underTest.nodeTextStyle([])
        XCTAssertEqual(result.alignment, NSTextAlignment.Center)
        XCTAssertEqual(result.color, UIColor(hexString: "#4F4F4F"))
        XCTAssertEqual(result.font.size, 14.0)
    }

    func test_should_return_node_text_style_with_name() {
        let result = underTest.nodeTextStyle(["center"])
        XCTAssertEqual(result.alignment, NSTextAlignment.Left)
        XCTAssertEqual(result.color, UIColor(hexString: "#4F4F4F"))
        XCTAssertEqual(result.font.size, 15.0)
    }

    //MARK: - nodeBorderStyle
    func test_should_return_node_border_style_with_name() {
        let result = underTest.nodeBorderStyle(["center"])
        XCTAssertEqual(result.width, 2.0)
        XCTAssertEqual(result.color, UIColor(hexString: "#707070"))
    }

    func test_should_return_node_border_style_with_no_name() {
        let result = underTest.nodeBorderStyle([])
        XCTAssertEqual(result.width, 1.0)
        XCTAssertEqual(result.color, UIColor(hexString: "#707070"))
    }
    //MARK: - nodeShadowStyle
    func test_should_return_node_shadow_style_with_name() {
        let result = underTest.nodeShadowStyle(["center"])
        XCTAssertEqual(result.color, UIColor(hexString: "#070707"))
        XCTAssertEqual(result.offset, CGSizeMake(2, 4))
        XCTAssertEqual(result.opacity, 0.6)
        XCTAssertEqual(result.radius, 2)
    }

    func test_should_return_node_shadow_style_with_no_name() {
        let result = underTest.nodeShadowStyle([])
        XCTAssertEqual(result.color, UIColor(hexString: "#070707"))
        XCTAssertEqual(result.offset, CGSizeMake(2, 2))
        XCTAssertEqual(result.opacity, 0.4)
        XCTAssertEqual(result.radius, 2)
    }

    //MARK: - nodeStyle
    func test_should_return_node_style_with_name() {
        let result = underTest.nodeStyle(["center"])
        
        XCTAssertEqual(result.backgroundColor, UIColor(hexString: "#22AAE0"))
        XCTAssertEqual(result.activatedColor, UIColor(hexString: "#E0E0E0"))
        XCTAssertEqual(result.text.font.size, 15.0)
        XCTAssertEqual(result.cornerRadius, 10.0)
    }
}

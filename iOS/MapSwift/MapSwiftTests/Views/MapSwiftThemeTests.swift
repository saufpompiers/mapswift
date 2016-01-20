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
    func test_border_inset_is_0_if_type_is_none() {
        let result = underTest.nodeBorderStyle(["borderless"])
        XCTAssertEqual(result.type, MapSwiftTheme.BorderType.None)
        XCTAssertEqual(result.inset, 0.0)

    }
    func test_should_return_node_border_style_with_name() {
        let result = underTest.nodeBorderStyle(["center"])
        XCTAssertEqual(result.type, MapSwiftTheme.BorderType.Underline)
        XCTAssertEqual(result.line.width, 2.0)
        XCTAssertEqual(result.line.color, UIColor(hexString: "#707070"))
        XCTAssertEqual(result.inset, 2.0)
    }

    func test_should_return_node_border_style_with_no_name() {
        let result = underTest.nodeBorderStyle([])
        XCTAssertEqual(result.type, MapSwiftTheme.BorderType.Surround)
        XCTAssertEqual(result.line.width, 1.0)
        XCTAssertEqual(result.line.color, UIColor(hexString: "#707070"))
        XCTAssertEqual(result.inset, 1.0)
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

    //MARK: - controlPointsForStylesAndPosition
    func test_should_return_default_if_no_style_supplied() {
        let result = underTest.controlPointsForStylesAndPosition([], position: MapSwiftTheme.RelativeNodePosition.Above)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(CGSizeMake(0.75, 1.5), result.first)
    }

    func test_should_return_multiple_control_points_if_configured() {
        let result = underTest.controlPointsForStylesAndPosition([], position: MapSwiftTheme.RelativeNodePosition.Below)
        XCTAssertEqual(2, result.count)
        XCTAssertEqual(CGSizeMake(0.5, 1.8), result.first)
        XCTAssertEqual(CGSizeMake(0.3, 0.5), result.last)
    }

    func test_should_fallback_to_default_if_style_supplied() {
        let result = underTest.controlPointsForStylesAndPosition(["curve"], position: MapSwiftTheme.RelativeNodePosition.Horizontal)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(CGSizeMake(0, 1), result.first)
    }

    func test_should_return_empty_array_if_configrued_without() {
        let result = underTest.controlPointsForStylesAndPosition(["straightline"], position: MapSwiftTheme.RelativeNodePosition.Below)
        XCTAssertEqual(0, result.count)
    }

    //MARK: - nodeConnectionStyle
    func test_should_return_default_style() {
        let result = underTest.nodeConnectionStyle([]);
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Center, result.from.above.h)
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Center, result.from.below.h)
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Center, result.from.horizontal.h)

        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Center, result.from.above.v)
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Center, result.from.below.v)
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Nearest, result.from.horizontal.v)

        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Nearest, result.to.h)
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Center, result.to.v)
        XCTAssertEqual("", result.style)
    }

    func test_should_return_with_style_overrides() {
        let result = underTest.nodeConnectionStyle(["borderless"]);
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Nearest, result.from.above.h)
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Center, result.from.below.h)
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Center, result.from.horizontal.h)

        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Center, result.from.above.v)
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Center, result.from.below.v)
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Nearest, result.from.horizontal.v)

        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Nearest, result.to.h)
        XCTAssertEqual(MapSwiftTheme.ConnectionJoinPosition.Center, result.to.v)
        XCTAssertEqual("curve", result.style)
    }
}

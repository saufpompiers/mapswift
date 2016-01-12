//
//  NSJSONSerializationExtensionsTests.swift
//  MapSwift
//
//  Created by David de Florinier on 12/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift

class NSJSONSerializationExtensionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_should_open_default_theme_json_file_into_dictionary() {
        let result = NSJSONSerialization.mapswift_JSONDictionaryFromFileURL(MapSwiftResources.sharedInstance.defaultThemeURL)
        XCTAssertNotNil(result)
    }
    
    func test_should_open_test_theme_json_file_into_dictionary() {
        let bundle = NSBundle(forClass: NSJSONSerializationExtensionsTests.self)
        let url = bundle.URLForResource("test-theme", withExtension: "json")!
        let result = NSJSONSerialization.mapswift_JSONDictionaryFromFileURL(url)
        XCTAssertNotNil(result)
    }

}

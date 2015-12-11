//
//  NSDateExtensionsTests.swift
//  MapSwift
//
//  Created by David de Florinier on 11/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest

class NSDateExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_should_convert_to_javascript_timestamp() {
        XCTAssertEqual(NSDate(timeIntervalSince1970: 30.5).mapswift_jsTimestamp, 30500);
    }

    func test_should_convert_from_javascript_timestamp() {
        XCTAssertEqual(NSDate.MapSwift_fromJSTimestamp(30500), NSDate(timeIntervalSince1970: 30.5));
    }

}

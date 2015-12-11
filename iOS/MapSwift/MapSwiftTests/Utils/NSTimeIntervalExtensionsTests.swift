//
//  NSTimeIntervalExtensionsTests.swift
//  MapSwift
//
//  Created by David de Florinier on 11/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
import MapSwift

class NSTimeIntervalExtensionsTests: XCTestCase {
    
    func test_should_convert_to_js_time_interval() {
        let underTest:NSTimeInterval = 2.5
        XCTAssertEqual(underTest.mapswift_JSTimeInterval, 2500)
    }

    func test_should_convert_from_js_time_interval() {
        let expected:NSTimeInterval = 0.5
        XCTAssertEqual(NSTimeInterval.MapSwift_fromJSTimeInterval(500), expected)
    }
    
}

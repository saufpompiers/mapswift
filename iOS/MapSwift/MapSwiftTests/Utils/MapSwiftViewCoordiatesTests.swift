//
//  MapSwiftViewCoordiatesTests.swift
//  MapSwift
//
//  Created by David de Florinier on 24/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift

class MapSwiftViewCoordiatesTests: XCTestCase {
    var underTest:MapSwiftViewCoordiates!

    override func setUp() {
        super.setUp()
        underTest = MapSwiftViewCoordiates(margin:10.0)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_should_center_first_node_added() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let result = underTest.nodeAdded(MapSwiftNode(title: "hello", level: 1, id: "1", rect: CGRectMake(-35.5, -10, 71, 20), attr: [:]))
//        XCTAssertEqual(result, CGRectMake(10, 10, 71, 20))
    }

}

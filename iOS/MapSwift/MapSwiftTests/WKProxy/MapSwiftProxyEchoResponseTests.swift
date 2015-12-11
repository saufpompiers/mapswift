//
//  MapSwiftProxyEchoResponseTests.swift
//  MapSwift
//
//  Created by David de Florinier on 11/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift

class MapSwiftProxyEchoResponseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_should_be_created_from_proxy_response() {
        let response = MapSwiftProxyResponse(id: "one", completed: true, componentId: "comp", selector: "echo", result: ["identifier":"foo", "received":10000], errors: nil)
        if let result = MapSwiftProxyEchoResponse.fromProxyResponse(response, sent: NSDate(timeIntervalSince1970: 8), received: NSDate(timeIntervalSince1970: 13)) {
            XCTAssertEqual(result.identifier, "foo")
            XCTAssertEqual(result.received, NSDate(timeIntervalSince1970: 13))
            XCTAssertEqual(result.sent, NSDate(timeIntervalSince1970: 8))
            XCTAssertEqual(result.reply, NSDate(timeIntervalSince1970: 10))
            XCTAssertEqual(result.description, "foo [out:2000ms back:3000ms]")
        } else {
            XCTFail("nil result");
        }
    }
    

}

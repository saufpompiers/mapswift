//
//  MapSwiftViewCoordiatesTests.swift
//  MapSwift
//
//  Created by David de Florinier on 24/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift

class StubMapSwiftCoordinateSystem: MapSwiftCoordinateSystem {
    var mapBounds  = MapBounds(minX:0, maxX:100, minY:0, maxY:100)
    var mapOriginOffset = CGPointMake(10, 20)
    var mapSize = CGSizeMake(100, 100)
    var mapChangeFlags = MapChangeFlags(boundsChanged:false, offsetChanged:false)

    var addRectCalls:[(id:String, rect:CGRect)] = []
    func addRect(id:String, rect:CGRect) -> MapChangeFlags {
        addRectCalls.append((id: id, rect: rect))
        return mapChangeFlags
    }
    var removeRectCalls:[String] = []
    func removeRect(id:String) -> MapChangeFlags {
        removeRectCalls.append(id)
        return mapChangeFlags
    }

}
class StubMapSwiftViewCoordinatesDelegate: MapSwiftViewCoordinatesDelegate {
    var mapSwiftViewCoordinatesChangedCalls = 0
    func mapSwiftViewCoordinatesChanged(mapSwiftViewCoordiates:MapSwiftViewCoordinates, rectConverter:((rect:CGRect)->(CGRect))) {
        mapSwiftViewCoordinatesChangedCalls++
    }
    var mapSwiftViewSizeChangedCalls:[CGSize] = []
    func mapSwiftViewSizeChanged(mapSwiftViewCoordiates:MapSwiftViewCoordinates, mapSize:CGSize) {
        mapSwiftViewSizeChangedCalls.append(mapSize)
    }

}
class MapSwiftViewCoordiantesTests: XCTestCase {
    var underTest:MapSwiftViewCoordinates!
    var stubCoordinateSystem:StubMapSwiftCoordinateSystem!
    var stubMapSwiftViewCoordinatesDelegate:StubMapSwiftViewCoordinatesDelegate!
    var node:MapSwiftNode!
    override func setUp() {
        super.setUp()
        node = MapSwiftNode(title: "hello", level: 1, id: "1", rect: CGRectMake(-35.5, -10, 71, 20), attr: [:])
        stubCoordinateSystem = StubMapSwiftCoordinateSystem()
        stubMapSwiftViewCoordinatesDelegate = StubMapSwiftViewCoordinatesDelegate()
        underTest = MapSwiftViewCoordinates(margin:10.0, coordinateSystem: stubCoordinateSystem)
        underTest.delegate = stubMapSwiftViewCoordinatesDelegate
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

//Mark: - nodeAdded
    func test_should_convert_node_coordinates_using_coordinate_sytem() {
        stubCoordinateSystem.mapOriginOffset = CGPointMake(35.5, 10)

        let result = underTest.nodeAdded(node)

        XCTAssertEqual(result, CGRectMake(10, 10, 71, 20))
        XCTAssertEqual(stubCoordinateSystem.addRectCalls.count, 1)
        if let call = stubCoordinateSystem.addRectCalls.first {
            XCTAssertEqual(node.id, call.id)
            XCTAssertEqual(node.rect, call.rect)
        }
    }

    func test_should_call_delegate_if_map_size_changes() {
        stubCoordinateSystem.mapChangeFlags.boundsChanged = true

        underTest.nodeAdded(node)

        XCTAssertEqual(stubMapSwiftViewCoordinatesDelegate.mapSwiftViewSizeChangedCalls.first, CGSizeMake(120, 120))
    }

    func test_should_call_delegate_if_map_origin_changes() {
        stubCoordinateSystem.mapChangeFlags.offsetChanged = true

        underTest.nodeAdded(node)

        XCTAssertEqual(stubMapSwiftViewCoordinatesDelegate.mapSwiftViewCoordinatesChangedCalls, 1)
    }

//Mark: - nodeMoved
    func test_should_convert_moved_node_coordinates_using_coordinate_sytem() {
        stubCoordinateSystem.mapOriginOffset = CGPointMake(35.5, 10)

        let result = underTest.nodeMoved(node)

        XCTAssertEqual(result, CGRectMake(10, 10, 71, 20))
        XCTAssertEqual(stubCoordinateSystem.addRectCalls.count, 1)
        if let call = stubCoordinateSystem.addRectCalls.first {
            XCTAssertEqual(node.id, call.id)
            XCTAssertEqual(node.rect, call.rect)
        }
    }

//Mark: - Node Removed
    func test_should_remove_node_coordinates_using_coordinate_sytem() {
        stubCoordinateSystem.mapOriginOffset = CGPointMake(35.5, 10)

        underTest.nodeRemoved(node)

        XCTAssertEqual(stubCoordinateSystem.removeRectCalls.first, node.id)
    }


}

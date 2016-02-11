//
//  CGRectExtensionsTests.swift
//  MapSwift
//
//  Created by David de Florinier on 10/02/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift

class CGRectExtensionsTests: XCTestCase {
    var underTest:CGRect!

    let topLeft = MapSwift.Position.Origin(horizontal:MapSwift.Position.Horizontal.Left, vertical:MapSwift.Position.Vertical.Top)
    let topRight = MapSwift.Position.Origin(horizontal:MapSwift.Position.Horizontal.Right, vertical:MapSwift.Position.Vertical.Top)
    let bottomRight = MapSwift.Position.Origin(horizontal:MapSwift.Position.Horizontal.Right, vertical:MapSwift.Position.Vertical.Bottom)
    let bottomLeft = MapSwift.Position.Origin(horizontal:MapSwift.Position.Horizontal.Left, vertical:MapSwift.Position.Vertical.Bottom)
    let absolute = MapSwift.Position.Measurement.Absolute
    let proportional = MapSwift.Position.Measurement.Proportional
    override func setUp() {
        super.setUp()
        underTest = CGRectMake(10, 10, 100, 100)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//MARK: - mapswift_CGPointForPositionPoint
    func test_CGPointForPositionPoint_should_return_for_absolute_points() {
        //top left
        XCTAssertEqual(CGPointMake(10, 10), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:absolute, origin:topLeft, point:CGPointMake(0,0))))
        XCTAssertEqual(CGPointMake(20, 20), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:absolute, origin:topLeft, point:CGPointMake(10,10))))

        //top right
        XCTAssertEqual(CGPointMake(110, 10), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:absolute, origin:topRight, point:CGPointMake(0,0))))
        XCTAssertEqual(CGPointMake(100, 20), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:absolute, origin:topRight, point:CGPointMake(10,10))))

        //bottom left
        XCTAssertEqual(CGPointMake(10, 110), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:absolute, origin:bottomLeft, point:CGPointMake(0,0))))
        XCTAssertEqual(CGPointMake(20, 100), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:absolute, origin:bottomLeft, point:CGPointMake(10,10))))

        //bottom right
        XCTAssertEqual(CGPointMake(110, 110), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:absolute, origin:bottomRight, point:CGPointMake(0,0))))
        XCTAssertEqual(CGPointMake(100, 100), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:absolute, origin:bottomRight, point:CGPointMake(10,10))))

    }
    func test_CGPointForPositionPoint_should_return_for_proportional_points() {
        //top left
        XCTAssertEqual(CGPointMake(10, 10), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:proportional, origin:topLeft, point:CGPointMake(0,0))))
        XCTAssertEqual(CGPointMake(35, 35), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:proportional, origin:topLeft, point:CGPointMake(0.25,0.25))))

        //top right
        XCTAssertEqual(CGPointMake(110, 10), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:proportional, origin:topRight, point:CGPointMake(0,0))))
        XCTAssertEqual(CGPointMake(85, 35), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:proportional, origin:topRight, point:CGPointMake(0.25,0.25))))

        //bottom left
        XCTAssertEqual(CGPointMake(10, 110), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:proportional, origin:bottomLeft, point:CGPointMake(0,0))))
        XCTAssertEqual(CGPointMake(35, 85), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:proportional, origin:bottomLeft, point:CGPointMake(0.25,0.25))))

        //bottom right
        XCTAssertEqual(CGPointMake(110, 110), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:proportional, origin:bottomRight, point:CGPointMake(0,0))))
        XCTAssertEqual(CGPointMake(85, 85), underTest.mapswift_CGPointForPositionPoint(MapSwift.Position.Point(type:proportional, origin:bottomRight, point:CGPointMake(0.25,0.25))))
    }

//MARK: - mapswift_relativePositionOfPoint
    func test_relativePositionOfPoint_should_return_below_if_point_below_bottom_of_rect_with_default_tolerance_of_10() {
        XCTAssertEqual(MapSwift.RelativeNodePosition.Below, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 121)))
    }
    func test_relativePositionOfPoint_should_return_below_if_point_below_bottom_of_rect_with_specified_tolerance() {
        XCTAssertEqual(MapSwift.RelativeNodePosition.Below, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 111), tolerance: 0))
        XCTAssertEqual(MapSwift.RelativeNodePosition.Below, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 112), tolerance: 1))
        XCTAssertEqual(MapSwift.RelativeNodePosition.Below, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 110), tolerance: -1))
    }
    func test_relativePositionOfPoint_should_return_above_if_point_above_top_of_rect_with_default_tolerance_of_10() {
        XCTAssertEqual(MapSwift.RelativeNodePosition.Above, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, -1)))
    }
    func test_relativePositionOfPoint_should_return_above_if_point_above_top_of_rect_with_specified_tolerance() {
        XCTAssertEqual(MapSwift.RelativeNodePosition.Above, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 9), tolerance: 0))
        XCTAssertEqual(MapSwift.RelativeNodePosition.Above, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 8), tolerance: 1))
        XCTAssertEqual(MapSwift.RelativeNodePosition.Above, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 10), tolerance: -1))
    }
    func test_relativePositionOfPoint_should_return_horizontal_if_point_between_top_and_bottom_of_rect_with_default_tolerance_of_10() {
        XCTAssertEqual(MapSwift.RelativeNodePosition.Horizontal, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 120)))
        XCTAssertEqual(MapSwift.RelativeNodePosition.Horizontal, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 0)))
    }
    func test_relativePositionOfPoint_should_return_horizontal_if_point_between_top_and_bottom_of_rect_with_specified_tolerance() {
        XCTAssertEqual(MapSwift.RelativeNodePosition.Horizontal, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 10), tolerance: 0))
        XCTAssertEqual(MapSwift.RelativeNodePosition.Horizontal, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 9), tolerance: 1))
        XCTAssertEqual(MapSwift.RelativeNodePosition.Horizontal, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 11), tolerance: -1))

        XCTAssertEqual(MapSwift.RelativeNodePosition.Horizontal, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 110), tolerance: 0))
        XCTAssertEqual(MapSwift.RelativeNodePosition.Horizontal, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 111), tolerance: 1))
        XCTAssertEqual(MapSwift.RelativeNodePosition.Horizontal, underTest.mapswift_relativePositionOfPoint(CGPointMake(0, 109), tolerance: -1))

    }
//MARK: - mapswift_pointsforFromAndToCGPoints
    func test_pointsforFromAndToCGPoints_forTopToBottomLeftToRight() {
        let point1 = CGPointMake(10, 10)
        let point2 = CGPointMake(110, 110)
        let result = underTest.mapswift_pointsforFromAndToCGPoints(point1, to: point2)
        XCTAssertEqual(MapSwift.Position.Measurement.Absolute, result.from.type)
        XCTAssertEqual(MapSwift.Position.Horizontal.Left, result.from.origin.horizontal)
        XCTAssertEqual(MapSwift.Position.Vertical.Top, result.from.origin.vertical)
        XCTAssertEqual(CGPointMake(0, 0), result.from.point)

        XCTAssertEqual(MapSwift.Position.Measurement.Absolute, result.to.type)
        XCTAssertEqual(MapSwift.Position.Horizontal.Right, result.to.origin.horizontal)
        XCTAssertEqual(MapSwift.Position.Vertical.Bottom, result.to.origin.vertical)
        XCTAssertEqual(CGPointMake(0, 0), result.to.point)

    }
    func test_pointsforFromAndToCGPoints_forBottomToTopLeftToRight() {
        let point1 = CGPointMake(10, 110)
        let point2 = CGPointMake(110, 10)
        let result = underTest.mapswift_pointsforFromAndToCGPoints(point1, to: point2)
        XCTAssertEqual(MapSwift.Position.Measurement.Absolute, result.from.type)
        XCTAssertEqual(MapSwift.Position.Horizontal.Left, result.from.origin.horizontal)
        XCTAssertEqual(MapSwift.Position.Vertical.Bottom, result.from.origin.vertical)
        XCTAssertEqual(CGPointMake(0, 0), result.from.point)

        XCTAssertEqual(MapSwift.Position.Measurement.Absolute, result.to.type)
        XCTAssertEqual(MapSwift.Position.Horizontal.Right, result.to.origin.horizontal)
        XCTAssertEqual(MapSwift.Position.Vertical.Top, result.to.origin.vertical)
        XCTAssertEqual(CGPointMake(0, 0), result.to.point)
        
    }

    func test_pointsforFromAndToCGPoints_forTopToBottomRightToLeft() {
        let point1 = CGPointMake(110, 10)
        let point2 = CGPointMake(10, 110)
        let result = underTest.mapswift_pointsforFromAndToCGPoints(point1, to: point2)
        XCTAssertEqual(MapSwift.Position.Measurement.Absolute, result.from.type)
        XCTAssertEqual(MapSwift.Position.Horizontal.Right, result.from.origin.horizontal)
        XCTAssertEqual(MapSwift.Position.Vertical.Top, result.from.origin.vertical)
        XCTAssertEqual(CGPointMake(0, 0), result.from.point)

        XCTAssertEqual(MapSwift.Position.Measurement.Absolute, result.to.type)
        XCTAssertEqual(MapSwift.Position.Horizontal.Left, result.to.origin.horizontal)
        XCTAssertEqual(MapSwift.Position.Vertical.Bottom, result.to.origin.vertical)
        XCTAssertEqual(CGPointMake(0, 0), result.to.point)
        
    }

    func test_pointsforFromAndToCGPoints_forBottomToTopRightToLeft() {
        let point1 = CGPointMake(110, 110)
        let point2 = CGPointMake(10, 10)
        let result = underTest.mapswift_pointsforFromAndToCGPoints(point1, to: point2)
        XCTAssertEqual(MapSwift.Position.Measurement.Absolute, result.from.type)
        XCTAssertEqual(MapSwift.Position.Horizontal.Right, result.from.origin.horizontal)
        XCTAssertEqual(MapSwift.Position.Vertical.Bottom, result.from.origin.vertical)
        XCTAssertEqual(CGPointMake(0, 0), result.from.point)

        XCTAssertEqual(MapSwift.Position.Measurement.Absolute, result.to.type)
        XCTAssertEqual(MapSwift.Position.Horizontal.Left, result.to.origin.horizontal)
        XCTAssertEqual(MapSwift.Position.Vertical.Top, result.to.origin.vertical)
        XCTAssertEqual(CGPointMake(0, 0), result.to.point)

    }

}

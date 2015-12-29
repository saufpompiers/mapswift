//
//  MapSwiftHTMLCoordinatesTests.swift
//  MapSwift
//
//  Created by David de Florinier on 28/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import XCTest
@testable import MapSwift

class MapSwiftHTMLCoordinatesTests: XCTestCase {
    var underTest:MapSwiftHTMLCoordinates!

    override func setUp() {
        super.setUp()
        underTest = MapSwiftHTMLCoordinates()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
//MARK: - addRect
    func test_adding_a_central_rect_should_enlarge_the_map_while_maintaining_center_position() {
        underTest.addRect("1", rect:CGRectMake(-35.5, -10, 71, 20))
        XCTAssertEqual(underTest.mapSize, CGSizeMake(71, 20))
    }

    func test_adding_first_rect_should_flag_bounds_and_offset_As_changed() {
        let result = underTest.addRect("1", rect:CGRectMake(-35.5, -10, 71, 20))
        XCTAssertTrue(result.boundsChanged)
        XCTAssertTrue(result.offsetChanged)
    }

    func test_adding_an_off_center_rect_should_not_enlarge_the_map() {
        underTest.addRect("1", rect:CGRectMake(30, 10, 70, 20))
        XCTAssertEqual(underTest.mapSize, CGSizeMake(70, 20))
    }

    func test_adding_an_multiple_rects_rect_should_enlarge_the_map() {
        underTest.addRect("1", rect:CGRectMake(30, 70, 70, 30))
        underTest.addRect("2", rect:CGRectMake(-100, -200, 70, 30))
        XCTAssertEqual(underTest.mapSize, CGSizeMake(200, 300))
    }

    func test_adding_a_rect_that_is_within_existing_boulds_should_not_change_mapSize() {
        underTest.addRect("1", rect:CGRectMake(30, 10, 70, 20))
        let mapSize = underTest.mapSize
        let result = underTest.addRect("2", rect:CGRectMake(30, 10, 70, 20))
        XCTAssertEqual(underTest.mapSize, mapSize)
        XCTAssertFalse(result.boundsChanged)
        XCTAssertFalse(result.offsetChanged)
    }

    func test_adding_a_single_centered_rect_should_set_offset_to_bottom_left_of_the_rect() {
        underTest.addRect("1", rect:CGRectMake(-35.5, -10, 71, 20))
        XCTAssertEqual(underTest.mapOriginOffset, CGPointMake(35.5, 10))
    }

    func test_adding_subsequent_off_centered_rect_should_set_offset_to_bottom_left_of_the_rect() {
        underTest.addRect("1", rect:CGRectMake(-35.5, -10, 71, 20))
        let result = underTest.addRect("2", rect:CGRectMake(30, -30, 70, 20))
        XCTAssertEqual(underTest.mapOriginOffset, CGPointMake(35.5, 10))
        XCTAssertTrue(result.boundsChanged)
        XCTAssertFalse(result.offsetChanged)
    }

    func test_adding_subsequent_off_centered_rect_to_left_should_set_offset_to_bottom_left_of_the_rect() {
        underTest.addRect("1", rect:CGRectMake(-35.5, -10, 71, 20))
        let result = underTest.addRect("2", rect:CGRectMake(-100, -10, 71, 20))
        XCTAssertEqual(underTest.mapOriginOffset, CGPointMake(100, 10))
        XCTAssertTrue(result.boundsChanged)
        XCTAssertTrue(result.offsetChanged)
    }

    func test_adding_subsequent_off_centered_rect_to_bottom_should_set_offset_to_bottom_left_of_the_rect() {
        underTest.addRect("1", rect:CGRectMake(-35.5, -10, 71, 20))
        let result = underTest.addRect("2", rect:CGRectMake(-100, 150, 70, 20))
        XCTAssertEqual(underTest.mapOriginOffset, CGPointMake(100, 170))
        XCTAssertTrue(result.boundsChanged)
        XCTAssertTrue(result.offsetChanged)
    }

    func test_the_origin_offset_can_be_negative() {
        underTest.addRect("1", rect:CGRectMake(30, -30, 70, 20))
        XCTAssertEqual(underTest.mapOriginOffset, CGPointMake(-30, -10))
    }

    func test_the_origin_offset_can_be_positive() {
        underTest.addRect("1", rect:CGRectMake(-40, 10, 70, 20))
        XCTAssertEqual(underTest.mapOriginOffset, CGPointMake(40, 30))
    }

    func test_the_origin_offset_can_be_mixed() {
        underTest.addRect("1", rect:CGRectMake(30, 10, 70, 20))
        XCTAssertEqual(underTest.mapOriginOffset, CGPointMake(-30, 30))
    }

    func test_adding_the_rect_twice_is_ignored() {
        underTest.addRect("1", rect:CGRectMake(30, 10, 70, 20))
        let result = underTest.addRect("1", rect:CGRectMake(30, 10, 70, 20))
        XCTAssertFalse(result.offsetChanged)
        XCTAssertFalse(result.boundsChanged)
    }

    func test_offset_can_be_moved() {
        underTest.addRect("1", rect:CGRectMake(-40, 10, 70, 20))
        let result = underTest.addRect("1", rect:CGRectMake(30, 10, 70, 20))
        XCTAssertTrue(result.offsetChanged)
        XCTAssertEqual(underTest.mapOriginOffset, CGPointMake(-30, 30))
    }

    func test_moving_rect_changes_bounds() {
        underTest.addRect("1", rect:CGRectMake(-40, 10, 70, 20))
        let result = underTest.addRect("1", rect:CGRectMake(30, 10, 70, 20))
        XCTAssertTrue(result.boundsChanged)
        XCTAssertEqual(underTest.mapSize, CGSizeMake(70,20))
    }

//MARK: - removeRect
    func test_should_set_size_to_zero_when_last_rect_removed() {
        underTest.addRect("1", rect:CGRectMake(30, 10, 70, 20))
        let result = underTest.removeRect("1")
        XCTAssertTrue(result.boundsChanged)
        XCTAssertEqual(underTest.mapSize, CGSizeMake(0, 0))
    }

    func test_should_set_offset_to_zero_when_last_rect_removed() {
        underTest.addRect("1", rect:CGRectMake(30, 10, 70, 20))
        let result = underTest.removeRect("1")
        XCTAssertTrue(result.offsetChanged)
        XCTAssertEqual(underTest.mapOriginOffset, CGPointMake(0, 0))
    }

    func test_should_set_size_to_remaining_rects_when_rect_removed() {
        underTest.addRect("1", rect:CGRectMake(30, 70, 70, 30))
        underTest.addRect("2", rect:CGRectMake(-100, -200, 70, 30))
        underTest.addRect("3", rect:CGRectMake(100, 200, 70, 30))
        let result = underTest.removeRect("3")
        XCTAssertTrue(result.boundsChanged)
        XCTAssertEqual(underTest.mapSize, CGSizeMake(200, 300))
    }

    func test_should_not_change_size_to_remaining_rects_when_rect_removed_is_within_bounds() {
        underTest.addRect("1", rect:CGRectMake(30, 70, 70, 30))
        underTest.addRect("2", rect:CGRectMake(-100, -200, 70, 30))
        underTest.addRect("3", rect:CGRectMake(100, 200, 70, 30))
        let result = underTest.removeRect("1")
        XCTAssertFalse(result.boundsChanged)
        XCTAssertEqual(underTest.mapSize, CGSizeMake(270, 430))
    }

    func test_should_not_set_offset_to_zero_when_last_rect_removed() {
        underTest.addRect("1", rect:CGRectMake(30, 70, 70, 30))
        underTest.addRect("2", rect:CGRectMake(-100, -200, 70, 30))
        underTest.addRect("3", rect:CGRectMake(100, 200, 70, 30))
        let result = underTest.removeRect("1")
        XCTAssertFalse(result.offsetChanged)
        XCTAssertEqual(underTest.mapOriginOffset, CGPointMake(100, 230))
    }

    func test_should_set_offset_to_remaining_rects_when_rect_removed() {
        underTest.addRect("1", rect:CGRectMake(30, 70, 70, 30))
        underTest.addRect("2", rect:CGRectMake(-100, -200, 70, 30))
        underTest.addRect("3", rect:CGRectMake(100, 200, 70, 30))
        let result = underTest.removeRect("3")
        XCTAssertTrue(result.offsetChanged)
        XCTAssertEqual(underTest.mapOriginOffset, CGPointMake(100, 100))
    }

}

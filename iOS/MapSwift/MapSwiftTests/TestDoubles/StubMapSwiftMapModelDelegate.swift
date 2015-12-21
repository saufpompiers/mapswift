//
//  StubMapSwiftMapModelDelegate.swift
//  MapSwift
//
//  Created by David de Florinier on 21/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation
import MapSwift

class StubMapSwiftMapModelDelegate: MapSwiftMapModelDelegate {
    var mapModelLayoutChangeCompleteCalls = 0
    func mapModelLayoutChangeComplete(mapModel: MapSwiftMapModel) {
        print("mapModelLayoutChangeComplete");
        mapModelLayoutChangeCompleteCalls++
    }
    var mapModelLayoutChangeStartingCalls = 0
    func mapModelLayoutChangeStarting(mapModel: MapSwiftMapModel) {
        print("mapModelLayoutChangeStarting");
        mapModelLayoutChangeStartingCalls++
    }
}
//
//  MapSwiftMapViewListener.swift
//  MapSwift
//
//  Created by David de Florinier on 07/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

public class MapSwiftMapViewListener : MapSwiftMapViewDelegate {
    public let components:MapSwiftComponents
    public init(components:MapSwiftComponents) {
        self.components = components
    }

    //MARK: - MapSwiftMapViewDelegate
    public func mapViewDidSelectNode(mapView: MapSwiftMapView, nodeSelected: MapSwiftNode) {
        components.mapModel.selectNode(nodeSelected.id, force: true, appendToActive: false, then: { () -> () in
            }) { (error) -> () in
                print("mapViewDidSelectNode error:\(error.localizedDescription)")
        }
    }
}
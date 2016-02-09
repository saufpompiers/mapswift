//
//  MapSwiftLayoutChange.swift
//  MapSwift
//
//  Created by David de Florinier on 09/02/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

extension MapSwift {
    class LayoutChange {
        var nodeEvents:[NodeEventArgs] = []
        var connectorEvents:[ConnectorEventArgs] = []
        var nodeIdEvents:[NodeIdEventArgs] = []
        var rectConverter:MapSwift.RectConverter?
        var mapSize:CGSize?
    }
}
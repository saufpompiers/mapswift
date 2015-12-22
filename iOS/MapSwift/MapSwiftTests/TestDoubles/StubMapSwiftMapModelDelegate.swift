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
    typealias MapModelMapEventCall = String
    var mapModelMapEventCalls:[MapModelMapEventCall] = []
    func mapModelMapEvent(mapModel: MapSwiftMapModel, event: String) {
        print("mapModelMapEvent \(event)")
        mapModelMapEventCalls.append(event)
    }

    typealias MapModelNodeEventCall = (event: String, node: Dictionary<String, AnyObject>)
    var mapModelNodeEventCalls:[MapModelNodeEventCall] = []
    func mapModelNodeEvent(mapModel: MapSwiftMapModel, event: String, node: Dictionary<String, AnyObject>) {
        print("mapModelNodeEvent \(event) \(node)")
        mapModelNodeEventCalls.append((event:event, node:node))
    }

    func mapModelActivatedNodesChanged(mapModel: MapSwiftMapModel, activatedNodes: AnyObject, deactivatedNodes: AnyObject) {
        print("mapModelActivatedNodesChanged activatedNodes:\(activatedNodes) deactivatedNodes:\(deactivatedNodes)")
    }
    func mapModelConnectorEvent(mapModel: MapSwiftMapModel, event: String, connector: Dictionary<String, AnyObject>) {
        print("mapModelConnectorEvent \(event) \(connector)")
    }
    func mapModelLinkEvent(mapModel: MapSwiftMapModel, event: String, link: Dictionary<String, AnyObject>) {
        print("mapModelLinkEvent \(event) \(link)")
    }
    func mapModelMapScaleChanged(mapModel: MapSwiftMapModel, scale: Double) {
        print("mapModelMapScaleChanged \(scale)")
    }
    func mapModelNodeEditRequested(mapModel: MapSwiftMapModel, nodeId: String, shouldSelectAll: Bool, editingNew: Bool) {
        print("mapModelNodeEditRequested nodeId:\(nodeId) shouldSelectAll:\(shouldSelectAll) editingNew:\(editingNew)")
    }
    func mapModelNodeIdEvent(mapModel: MapSwiftMapModel, event: String, nodeId: String, toggle: Bool) {
        print("mapModelNodeIdEvent \(event) nodeId:\(nodeId) toggle:\(toggle)")
    }
    func mapModelToggleEvent(mapModel: MapSwiftMapModel, event: String, toggle: Bool) {
        print("mapModelToggleEvent \(event) toggle:\(toggle)")
    }
}
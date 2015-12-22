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
    func mapModelMapEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.MapEvent) {
        print("mapModelMapEvent \(event)")
    }

    func mapModelNodeEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.NodeEvent, node: Dictionary<String, AnyObject>) {
        print("mapModelNodeEvent \(event) \(node)")
    }
    func mapModelConnectorEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.ConnectorEvent, connector: Dictionary<String, AnyObject>) {
        print("mapModelConnectorEvent \(event) \(connector)")
    }
    func mapModelLinkEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.LinkEvent, link: Dictionary<String, AnyObject>) {
        print("mapModelLinkEvent \(event) \(link)")
    }
    func mapModelNodeIdEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.NodeRequestEvent, nodeId: String, toggle: Bool) {
        print("mapModelNodeIdEvent \(event) nodeId:\(nodeId) toggle:\(toggle)")
    }

    func mapModelToggleEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.ToggleRequestEvent, toggle: Bool) {
        print("mapModelToggleEvent \(event) toggle:\(toggle)")
    }

    func mapModelActivatedNodesChanged(mapModel: MapSwiftMapModel, activatedNodes: AnyObject, deactivatedNodes: AnyObject) {
        print("mapModelActivatedNodesChanged activatedNodes:\(activatedNodes) deactivatedNodes:\(deactivatedNodes)")
    }
    func mapModelMapScaleChanged(mapModel: MapSwiftMapModel, scale: Double) {
        print("mapModelMapScaleChanged \(scale)")
    }
    func mapModelNodeEditRequested(mapModel: MapSwiftMapModel, nodeId: String, shouldSelectAll: Bool, editingNew: Bool) {
        print("mapModelNodeEditRequested nodeId:\(nodeId) shouldSelectAll:\(shouldSelectAll) editingNew:\(editingNew)")
    }
}
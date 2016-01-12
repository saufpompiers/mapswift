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
    var eventOrder:[String] = []
    var eventOccurredListener:(()->())?
    func eventOccurred(event:String) {
        eventOrder.append(event)
        if let listener = eventOccurredListener {
            listener();
        }
    }

    func mapModelMapEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.MapEvent) {
        print("mapModelMapEvent \(event)")
        eventOccurred(event.rawValue)
    }

    var mapModelNodeEventCalls = 0
    var mapModelNodeEventListener:((event: MapSwiftMapModel.NodeEvent, node:MapSwiftNode)->())?
    func mapModelNodeEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.NodeEvent, node:MapSwiftNode) {
        print("mapModelNodeEvent \(event) \(node)")
        eventOccurred(event.rawValue)
        mapModelNodeEventCalls++
        if let listener = mapModelNodeEventListener {
            listener(event: event, node: node)
        }
    }

    var mapModelConnectorEventCalls = 0
    var mapModelConnectorEventListener:((event: MapSwiftMapModel.ConnectorEvent, connector: Dictionary<String, AnyObject>)->())?
    func mapModelConnectorEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.ConnectorEvent, connector: Dictionary<String, AnyObject>) {
        print("mapModelConnectorEvent \(event) \(connector)")
        eventOccurred(event.rawValue)

        mapModelConnectorEventCalls++
        if let listener = mapModelConnectorEventListener {
            listener(event:event, connector:connector)
        }
    }
    func mapModelLinkEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.LinkEvent, link: Dictionary<String, AnyObject>) {
        print("mapModelLinkEvent \(event) \(link)")
        eventOccurred(event.rawValue)
    }
    func mapModelNodeIdEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.NodeRequestEvent, nodeId: String, toggle: Bool) {
        print("mapModelNodeIdEvent \(event) nodeId:\(nodeId) toggle:\(toggle)")
        eventOccurred(event.rawValue)
    }

    func mapModelToggleEvent(mapModel: MapSwiftMapModel, event: MapSwiftMapModel.ToggleRequestEvent, toggle: Bool) {
        print("mapModelToggleEvent \(event) toggle:\(toggle)")
        eventOccurred(event.rawValue)
    }

    func mapModelActivatedNodesChanged(mapModel: MapSwiftMapModel, activatedNodes: [AnyObject], deactivatedNodes: [AnyObject]) {
        print("mapModelActivatedNodesChanged activatedNodes:\(activatedNodes) deactivatedNodes:\(deactivatedNodes)")
        eventOccurred("mapModelActivatedNodesChanged")
    }
    func mapModelMapScaleChanged(mapModel: MapSwiftMapModel, scale: Double) {
        print("mapModelMapScaleChanged \(scale)")
        eventOccurred("mapModelMapScaleChanged")
    }
    func mapModelNodeEditRequested(mapModel: MapSwiftMapModel, nodeId: String, shouldSelectAll: Bool, editingNew: Bool) {
        print("mapModelNodeEditRequested nodeId:\(nodeId) shouldSelectAll:\(shouldSelectAll) editingNew:\(editingNew)")
        eventOccurred("mapModelNodeEditRequested")
    }
}
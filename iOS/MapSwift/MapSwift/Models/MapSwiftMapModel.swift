//
//  MapSwiftMapModel.swift
//  MapSwift
//
//  Created by David de Florinier on 21/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

public protocol MapSwiftMapModelDelegate {
    func mapModelMapEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.MapEvent)
    func mapModelNodeEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.NodeEvent, node:MapSwiftNode)
    func mapModelLinkEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.LinkEvent, link:Dictionary<String, AnyObject>)
    func mapModelConnectorEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.ConnectorEvent, connector:Dictionary<String, AnyObject>)
    func mapModelNodeIdEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.NodeRequestEvent, nodeId:String, toggle:Bool)
    func mapModelToggleEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.ToggleRequestEvent, toggle:Bool)

    func mapModelMapScaleChanged(mapModel:MapSwiftMapModel, scale:Double)
    func mapModelNodeEditRequested(mapModel:MapSwiftMapModel, nodeId:String, shouldSelectAll:Bool, editingNew:Bool)
    func mapModelActivatedNodesChanged(mapModel:MapSwiftMapModel, activatedNodes:AnyObject, deactivatedNodes:AnyObject)
}


public class MapSwiftMapModel {

    public enum MapEvent:String {
        case LayoutChangeStarting = "layoutChangeStarting", LayoutChangeComplete = "layoutChangeComplete", MapViewResetRequested = "mapViewResetRequested"
        static func parse(event:String) -> MapEvent? {
            switch event {
                case "layoutChangeStarting":
                    return LayoutChangeStarting
                case "layoutChangeComplete":
                    return LayoutChangeComplete
                case "mapViewResetRequested":
                    return MapViewResetRequested
                default:
                    return nil
            }
        }
    }
    public enum NodeEvent:String {
        case NodeCreated = "nodeCreated", NodeRemoved = "nodeRemoved", NodeMoved = "nodeMoved", NodeTitleChanged = "nodeTitleChanged", NodeAttrChanged = "nodeAttrChanged", NodeLabelChanged = "nodeLabelChanged"
        static func parse(event:String) -> NodeEvent? {
            switch event {
                case "nodeCreated":
                    return NodeCreated
                case "nodeRemoved":
                    return NodeRemoved
                case "nodeMoved":
                    return NodeMoved
                case "nodeTitleChanged":
                    return NodeTitleChanged
                case "nodeAttrChanged":
                    return NodeAttrChanged
                case "nodeLabelChanged":
                    return NodeLabelChanged
                default:
                    return nil
            }
        }

        func parseArgs(args:[AnyObject]) -> MapSwiftNode? {
            if let first = args.first, parsed = first as? Dictionary<String, AnyObject> {
                return MapSwiftNode.parseDictionary(parsed)
            }
            return nil
        }
    }
    public enum LinkEvent:String {
        case LinkAttrChanged = "linkAttrChanged", LinkCreated = "linkCreated", LinkRemoved = "linkRemoved"
        static func parse(event:String) -> LinkEvent? {
            switch event {
                case "linkAttrChanged":
                    return LinkAttrChanged
                case "linkCreated":
                    return LinkCreated
                case "linkRemoved":
                    return LinkRemoved
                default:
                    return nil
            }
        }
        func parseArgs(args:[AnyObject]) -> Dictionary<String, AnyObject>? {
            if let first = args.first, parsed = first as? Dictionary<String, AnyObject> {
                return  parsed
            }
            return nil
        }
    }
    public enum ConnectorEvent:String {
        case ConnectorCreated = "connectorCreated", ConnectorRemoved = "connectorRemoved"
        static func parse(event:String) -> ConnectorEvent? {
            switch event {
                case "connectorCreated":
                    return ConnectorCreated
                case "connectorRemoved":
                    return ConnectorRemoved
                default:
                    return nil
            }
        }
        func parseArgs(args:[AnyObject]) -> Dictionary<String, AnyObject>? {
            if let first = args.first, parsed = first as? Dictionary<String, AnyObject> {
                return parsed
            }
            return nil
        }

    }
    public enum NodeRequestEvent:String {
        case NodeVisibilityRequested = "nodeVisibilityRequested", NodeFocusRequested = "nodeFocusRequested", NodeSelectionChanged = "nodeSelectionChanged"
        static func parse(event:String) -> NodeRequestEvent? {
            switch event {
            case "nodeVisibilityRequested":
                return NodeVisibilityRequested
            case "nodeFocusRequested":
                return NodeFocusRequested
            case "nodeSelectionChanged":
                return NodeSelectionChanged
            default:
                return nil
            }
        }
        func parseArgs(args:[AnyObject]) -> (nodeId:String, toggle:Bool)? {
            if let nodeId = args[0] as? String {
                var toggle = false
                if args.count > 1 {
                    if let toggleArg  = args[1] as? Bool {
                        toggle = toggleArg
                    }
                }
                return (nodeId:nodeId, toggle:toggle)
            }
            return nil
        }

    }
    public enum ToggleRequestEvent:String {
        case AddLinkModeToggled = "addLinkModeToggled"
        static func parse(event:String) -> ToggleRequestEvent? {
            switch event {
            case "addLinkModeToggled":
                return AddLinkModeToggled
            default:
                return nil
            }
        }
        func parseArgs(args:[AnyObject]) -> Bool? {
            if let first = args.first, parsed = first as? Bool {
                return parsed
            }
            return nil
        }

    }
    public struct NodeEditRequest {
        let nodeId:String, shouldSelectAll:Bool, editingNew:Bool
        public static func parse(event:String, args:[AnyObject]) -> NodeEditRequest? {
            if (event == "nodeEditRequested" && args.count > 2) {
                if let nodeId = args[0] as? String, shouldSelectAll = args[1] as? Bool, editingNew = args[2] as? Bool {
                    return NodeEditRequest(nodeId: nodeId, shouldSelectAll: shouldSelectAll, editingNew: editingNew)
                }
            }
            return nil
        }
    }
    public struct ActivatedNodesChangedEvent {
        let activatedNodes:AnyObject
        let deactivatedNodes:AnyObject
        public static func parse(event:String, args:[AnyObject]) -> ActivatedNodesChangedEvent? {
            if (event == "activatedNodesChanged" && args.count > 1) {
                return ActivatedNodesChangedEvent(activatedNodes: args[0], deactivatedNodes: args[1])
            }
            return nil
        }
    }

    public struct MapScaleChangedEvent {
        let scaleMultiplier:Double
        public static func parse(event:String, args:[AnyObject]) -> MapScaleChangedEvent? {
            if let scale = args.first as? Double where event == "mapScaleChanged" {
                return MapScaleChangedEvent(scaleMultiplier: scale)
            }
            return nil
        }
    }

    let COMPONENT_ID = "mapModel"
    let proxy:MapSwiftProxyProtocol
    public var delegate:MapSwiftMapModelDelegate?

    init(proxy:MapSwiftProxyProtocol) throws {
        self.proxy = proxy
        try self.proxy.addProxyListener(COMPONENT_ID) { (eventName, args) -> () in
            if let delegate = self.delegate {
                if let mapEvent = MapEvent.parse(eventName) {
                    delegate.mapModelMapEvent(self, event: mapEvent)
                } else if let nodeEvent = NodeEvent.parse(eventName), node = nodeEvent.parseArgs(args) {
                    delegate.mapModelNodeEvent(self, event: nodeEvent, node: node)
                } else if let linkEvent = LinkEvent.parse(eventName), link = linkEvent.parseArgs(args) {
                    delegate.mapModelLinkEvent(self, event: linkEvent, link: link)
                } else if let connectorEvent = ConnectorEvent.parse(eventName), connector = connectorEvent.parseArgs(args) {
                    delegate.mapModelConnectorEvent(self, event: connectorEvent, connector: connector)
                } else if let nodeRequestEvent = NodeRequestEvent.parse(eventName), eventArgs = nodeRequestEvent.parseArgs(args) {
                    delegate.mapModelNodeIdEvent(self, event: nodeRequestEvent, nodeId: eventArgs.nodeId, toggle: eventArgs.toggle)
                } else if let toggleRequestEvent = ToggleRequestEvent.parse(eventName), toggle = toggleRequestEvent.parseArgs(args) {
                    delegate.mapModelToggleEvent(self, event: toggleRequestEvent, toggle: toggle)
                } else if let nodeEditRequest = NodeEditRequest.parse(eventName, args: args) {
                    delegate.mapModelNodeEditRequested(self, nodeId: nodeEditRequest.nodeId, shouldSelectAll: nodeEditRequest.shouldSelectAll, editingNew: nodeEditRequest.editingNew)
                } else if let eventArgs = ActivatedNodesChangedEvent.parse(eventName, args: args) {
                    delegate.mapModelActivatedNodesChanged(self, activatedNodes: eventArgs.activatedNodes, deactivatedNodes: eventArgs.deactivatedNodes)
                } else if let eventArgs = MapScaleChangedEvent.parse(eventName, args: args) {
                    delegate.mapModelMapScaleChanged(self, scale: eventArgs.scaleMultiplier)
                } else {
                    print("unhandled \(eventName) args:\(args)")
                }
            }
        }
    }

    //MARK: - Prvate helpers methods
    private func exec(selector:String, args:[AnyObject], then:MapSwiftProxyProtocolThen, fail:MapSwiftProxyProtocolFail) {
        proxy.sendCommand(COMPONENT_ID, selector: selector, args: args, then:{ (response) -> () in
            print("exec selector:\(selector) args:\(args) response:\(response)")
            then()
        }, fail: fail)
    }
    //MARK: - public api
    public func setIdea(content:String, then:(()->()), fail:MapSwiftProxyProtocolFail) {
        proxy.execCommandArgString(COMPONENT_ID, selector: "setIdea", argString: "MAPJS.content(\(content))", then: { (response) -> () in
            print("response:\(response)");
            then()
        }, fail: fail)
    }

    public func addSubIdea(parentId:String, initialTitle:String, then:MapSwiftProxyProtocolThen, fail:MapSwiftProxyProtocolFail) {
        self.exec("addSubIdea", args: ["iOS", parentId, initialTitle], then: then, fail: fail)
    }
}

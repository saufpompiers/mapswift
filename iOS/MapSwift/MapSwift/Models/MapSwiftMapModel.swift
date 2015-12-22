//
//  MapSwiftMapModel.swift
//  MapSwift
//
//  Created by David de Florinier on 21/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

public protocol MapSwiftMapModelDelegate {
    func mapModelMapEvent(mapModel:MapSwiftMapModel, event:String)
    func mapModelMapScaleChanged(mapModel:MapSwiftMapModel, scale:Double)
    func mapModelNodeEvent(mapModel:MapSwiftMapModel, event:String, node:Dictionary<String, AnyObject>)
    func mapModelLinkEvent(mapModel:MapSwiftMapModel, event:String, link:Dictionary<String, AnyObject>)
    func mapModelConnectorEvent(mapModel:MapSwiftMapModel, event:String, connector:Dictionary<String, AnyObject>)
    func mapModelNodeIdEvent(mapModel:MapSwiftMapModel, event:String, nodeId:String, toggle:Bool)
    func mapModelNodeEditRequested(mapModel:MapSwiftMapModel, nodeId:String, shouldSelectAll:Bool, editingNew:Bool)
    func mapModelToggleEvent(mapModel:MapSwiftMapModel, event:String, toggle:Bool)
    func mapModelActivatedNodesChanged(mapModel:MapSwiftMapModel, activatedNodes:AnyObject, deactivatedNodes:AnyObject)
}
public class MapSwiftMapModel {
    let COMPONENT_ID = "mapModel"
    let proxy:MapSwiftProxyProtocol
    public var delegate:MapSwiftMapModelDelegate?

    init(proxy:MapSwiftProxyProtocol) throws {
        self.proxy = proxy
        try self.proxy.addProxyListener(COMPONENT_ID) { (eventName, args) -> () in
            if let delegate = self.delegate {
                switch eventName {
                    case "layoutChangeStarting", "layoutChangeComplete", "mapViewResetRequested":
                        delegate.mapModelMapEvent(self, event: eventName)
                        break
                    case "nodeCreated", "nodeRemoved", "nodeMoved", "nodeTitleChanged", "nodeAttrChanged", "nodeLabelChanged":
                        if let node = args[0] as? Dictionary<String, AnyObject> {
                            delegate.mapModelNodeEvent(self, event: eventName, node: node)
                        } else {
                            print("could not parse argument:\(args[0])")
                        }
                        break
                    case "linkAttrChanged", "linkCreated", "linkRemoved":
                        if let link = args[0] as? Dictionary<String, AnyObject> {
                            delegate.mapModelLinkEvent(self, event: eventName, link: link)
                        } else {
                            print("could not parse argument:\(args[0])")
                        }
                        break
                    case "connectorCreated", "connectorRemoved":
                        if let connector = args[0] as? Dictionary<String, AnyObject> {
                            delegate.mapModelConnectorEvent(self, event: eventName, connector: connector)
                        } else {
                            print("could not parse argument:\(args[0])")
                        }
                        break
                    case "nodeVisibilityRequested", "nodeFocusRequested", "nodeSelectionChanged":
                        if let nodeId = args[0] as? String {
                            var toggle = false
                            if args.count > 1 {
                                if let toggleArg  = args[1] as? Bool {
                                    toggle = toggleArg
                                }
                            }
                            delegate.mapModelNodeIdEvent(self, event: eventName, nodeId: nodeId, toggle: toggle)
                        } else {
                            print("could not parse argument:\(args[0])")
                        }
                        break
                    case "nodeEditRequested":
                        if let nodeId = args[0] as? String, shouldSelectAll = args[1] as? Bool, editingNew = args[2] as? Bool {
                            delegate.mapModelNodeEditRequested(self, nodeId: nodeId, shouldSelectAll: shouldSelectAll, editingNew: editingNew)
                        } else {
                            print("could not parse arguments:\(args)")
                        }
                        break
                    case "addLinkModeToggled":
                        if let toggle = args[0] as? Bool {
                            delegate.mapModelToggleEvent(self, event: eventName, toggle: toggle)
                        } else {
                            print("could not parse argument:\(args[0])")
                        }
                        break
                    case "activatedNodesChanged":
                        if args.count > 1 {
                            let activatedNodes = args[0]
                            let deactivatedNodes = args[1]
                            delegate.mapModelActivatedNodesChanged(self, activatedNodes: activatedNodes, deactivatedNodes: deactivatedNodes)
                        } else {
                            print("could not parse argument:\(args)")
                        }
                        break
                    case "mapScaleChanged":
                        if let scaleMultiplier = args[0] as? Double {
                            delegate.mapModelMapScaleChanged(self, scale: scaleMultiplier)
                        } else {
                            print("could not parse argument:\(args[0])")
                        }
                        break
                    default:
                        print("unhandled \(eventName) args:\(args)")
                }
            }
        }
    }

    //MARK: - Prvate helpers methods
    private func exec(selector:String, args:[AnyObject], then:MapSwiftProxyProtocolThen, fail:MapSwiftProxyProtocolFail) {
        proxy.sendCommand(COMPONENT_ID, selector: selector, args: args, then:{ (response) -> () in
            print("exec selector:\(selector) args:\(args)")
        }, fail: fail)
    }

    //MARK: - public api
    public func setIdea(content:String, then:(()->()), fail:MapSwiftProxyProtocolFail) {
        proxy.execCommandArgString(COMPONENT_ID, selector: "setIdea", argString: "MAPJS.content(\(content))", then: { (response) -> () in
            print("response:\(response)");
            then()
        }, fail: fail)
    }
}

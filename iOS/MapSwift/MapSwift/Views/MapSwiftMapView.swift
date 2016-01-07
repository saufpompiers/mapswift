//
//  MapSwiftMapView.swift
//  MapSwift
//
//  Created by David de Florinier on 30/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
public protocol MapSwiftMapViewDelegate : class {
    func mapViewDidSelectNode(mapView:MapSwiftMapView, nodeSelected:MapSwiftNode)
}
public class MapSwiftMapView: UIView, MapSwiftMapModelDelegate, MapSwiftViewCoordinatesDelegate, MapSwiftNodeViewDelegate {
    typealias NodeEventArgs = (event:MapSwiftMapModel.NodeEvent, node:MapSwiftNode)
    weak public var delegate:MapSwiftMapViewDelegate?

    private var selectedNodeId:String?

    private var nodeViews:[String:MapSwiftNodeView] = [:]
    private var layoutChanging = false
    private var queuedNodeEvents:[NodeEventArgs] = []
    private var coordinateSystem = MapSwiftViewCoordinates()
    private let scrollView:UIScrollView
    private let mapContentView = UIView(frame: CGRectMake(0,0,10, 10))
    private let nodeLayerView = UIView(frame: CGRectMake(0,0,10, 10))
    private let connectorLayerView = MapSwiftConnectorsView(frame: CGRectMake(0,0,10, 10))
    public override init(frame: CGRect) {
        self.scrollView = UIScrollView(frame: CGRectMake(0,0,frame.width, frame.height))
        super.init(frame: frame)
        self.firstLayout()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.scrollView = UIScrollView(frame: CGRectMake(0,0,10, 10))
        super.init(coder: aDecoder)
        self.firstLayout()
    }

    func firstLayout() {
        scrollView.backgroundColor = UIColor.clearColor()
        mapContentView.backgroundColor = UIColor.clearColor()
        self.addSubview(scrollView)
        self.scrollView.addSubview(mapContentView)
        connectorLayerView.backgroundColor = UIColor.clearColor()
        nodeLayerView.backgroundColor = UIColor.clearColor()
        self.mapContentView.addSubview(connectorLayerView)
        self.mapContentView.insertSubview(nodeLayerView, aboveSubview: connectorLayerView)
        self.scrollView.scrollEnabled = true
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.bounces = true
        self.coordinateSystem.delegate = self
    }
    public override func layoutSubviews() {
        self.scrollView.frame = self.bounds
        let contentSize = self.mapContentView.frame.size
        self.scrollView.contentSize = contentSize
        let hoffset = (self.bounds.size.width - contentSize.width)/2
        let hinset:CGFloat = max(0, hoffset)
        let voffset = (self.bounds.size.height - contentSize.height)/2
        let vinset:CGFloat = max(0, voffset)
        let insets = UIEdgeInsetsMake(vinset, hinset, vinset, hinset)
        self.scrollView.contentInset = insets
        self.centerOnSelectedNode();
    }

    private func queueViewTask(block:(() -> ())) {
        dispatch_async(dispatch_get_main_queue(), block)
    }

    private func applyQueuedChanges() {
        for nodeEvent in queuedNodeEvents {
            self.applyNodeEvent(nodeEvent.event, node: nodeEvent.node)
        }
    }
    private func applyNodeEvent(event:MapSwiftMapModel.NodeEvent, node:MapSwiftNode) {
        if event == MapSwiftMapModel.NodeEvent.NodeRemoved {
            if let nodeView = nodeViews[node.id] {
                nodeView.removeFromSuperview()
                nodeViews.removeValueForKey(node.id)
                coordinateSystem.nodeRemoved(node)
                connectorLayerView.nodeRect(node.id, nodeRect:nil)
                return
            }
        }
        let frame = coordinateSystem.nodeAdded(node)
        var nodeView:MapSwiftNodeView! = nodeViews[node.id]
        let nodeFrame = MapSwiftNodeView.NodeRect(frame)
        if nodeView == nil {
            nodeView = MapSwiftNodeView(frame:nodeFrame)
            nodeView.delegate = self
            if let selectedNodeId = self.selectedNodeId where selectedNodeId == node.id {
                nodeView.isSelected = true
            }

            self.nodeLayerView.addSubview(nodeView)
            nodeViews[node.id] = nodeView
        }
        nodeView.node = node
        connectorLayerView.nodeRect(node.id, nodeRect: nodeFrame)
        UIView.animateWithDuration(0.2, animations: {
            nodeView.frame = nodeFrame
        })
        self.setNeedsLayout()
    }

    private func resetScrollView() {
    }
    private func centerOnSelectedNode() {
        if let selectedNodeId = self.selectedNodeId {
            if let nodeView = self.nodeViews[selectedNodeId] {
                self.scrollView.scrollRectToVisible(nodeView.frame, animated: true)
            }
        }
    }

//Mark: - MapSwiftMapModelDelegate
    public func mapModelMapEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.MapEvent) {
        queueViewTask({
            switch event {
            case MapSwiftMapModel.MapEvent.LayoutChangeStarting:
                self.layoutChanging = true
                break
            case MapSwiftMapModel.MapEvent.LayoutChangeComplete:
                self.applyQueuedChanges()
                self.layoutChanging = false
                break
            case MapSwiftMapModel.MapEvent.MapViewResetRequested:
                self.resetScrollView()
                break
            }
        })
    }

    public func mapModelNodeEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.NodeEvent, node:MapSwiftNode) {
        queueViewTask({
            if self.layoutChanging {
                self.queuedNodeEvents.append((event:event, node:node))
            } else {
                self.applyNodeEvent(event, node: node)
            }
        })
    }

    public func mapModelLinkEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.LinkEvent, link:Dictionary<String, AnyObject>) {

    }
    public func mapModelConnectorEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.ConnectorEvent, connector:Dictionary<String, AnyObject>) {
        queueViewTask({
            if let connector = MapSwiftNodeConnector.parseDictionary(connector) {
                switch event {
                case .ConnectorCreated:
                    self.connectorLayerView.addConnector(connector)
                case .ConnectorRemoved:
                    self.connectorLayerView.removeConnector(connector)
                }
            }
        })

    }
    public func mapModelNodeIdEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.NodeRequestEvent, nodeId:String, toggle:Bool) {
        if event == MapSwiftMapModel.NodeRequestEvent.NodeSelectionChanged {
            if toggle {
                selectedNodeId = nodeId
            } else {
                selectedNodeId = nil
            }
            if let nodeView = self.nodeViews[nodeId] {
                nodeView.isSelected = toggle
            }
            if toggle {
                queueViewTask({
                    self.centerOnSelectedNode();
                })
            }

        }
    }
    public func mapModelToggleEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.ToggleRequestEvent, toggle:Bool) {

    }

    public func mapModelMapScaleChanged(mapModel:MapSwiftMapModel, scale:Double) {

    }

    public func mapModelNodeEditRequested(mapModel:MapSwiftMapModel, nodeId:String, shouldSelectAll:Bool, editingNew:Bool) {

    }

    public func mapModelActivatedNodesChanged(mapModel:MapSwiftMapModel, activatedNodes:AnyObject, deactivatedNodes:AnyObject) {

    }
//MARK: - MapSwiftViewCoordinatesDelegate
    func mapSwiftViewCoordinatesChanged(mapSwiftViewCoordiates:MapSwiftViewCoordinates, rectConverter:((rect:CGRect)->(CGRect))) {
        for (_, nodeView) in nodeViews {
            if let node = nodeView.node {
                let nodeFrame = MapSwiftNodeView.NodeRect(rectConverter(rect: node.rect))
                nodeView.frame = nodeFrame
                connectorLayerView.nodeRect(node.id, nodeRect: nodeFrame)
                nodeView.setNeedsLayout()
            }
        }
    }
    func mapSwiftViewSizeChanged(mapSwiftViewCoordiates:MapSwiftViewCoordinates, mapSize:CGSize) {
        self.mapContentView.frame = CGRectMake(0, 0, mapSize.width, mapSize.height)
        self.nodeLayerView.frame = self.mapContentView.bounds
        self.connectorLayerView.frame = self.mapContentView.bounds
        self.centerOnSelectedNode();
        self.setNeedsLayout()
    }
//MARK: - MapSwiftNodeViewDelegate 
    func nodeViewWasTapped(nodeView: MapSwiftNodeView) {
        if let node = nodeView.node, delegate = self.delegate {
            delegate.mapViewDidSelectNode(self, nodeSelected: node)
        }
    }
}

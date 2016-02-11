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
    func mapViewDidCollapse(mapView:MapSwiftMapView, collapse:Bool)
}
extension MapSwift {
    typealias NodeEventArgs = (event:MapSwiftMapModel.NodeEvent, node:MapSwiftNode)
    typealias ConnectorEventArgs = (event:MapSwiftMapModel.ConnectorEvent, connector:Dictionary<String, AnyObject>)
    typealias NodeIdEventArgs = (event:MapSwiftMapModel.NodeRequestEvent, nodeId:String, toggle:Bool)
    typealias RectConverter = ((rect:CGRect)->(CGRect))
}
public class MapSwiftMapView: UIView, MapSwiftMapModelDelegate, MapSwiftViewCoordinatesDelegate, MapSwiftNodeViewDelegate {

    weak public var delegate:MapSwiftMapViewDelegate?

    private var selectedNodeId:String?

    private var nodeViews:[String:MapSwiftNodeView] = [:]

    var layoutChange:MapSwift.LayoutChange? = nil

    private var coordinateSystem = MapSwiftViewCoordinates()
    private let scrollView:UIScrollView
    private let mapContentView = UIView(frame: CGRectMake(0,0,10, 10))
    private let nodeLayerView = UIView(frame: CGRectMake(0,0,10, 10))
    private let connectorLayerView = MapSwiftConnectorsView(frame: CGRectMake(0,0,10, 10))
    private var draggedNode:MapSwiftNodeView?

    private var _theme:MapSwiftTheme?
    public var theme:MapSwiftTheme {
        get {
            if let theme = _theme {
                return theme
            }
            let defaultTheme = MapSwiftTheme.Default()
            _theme = defaultTheme
            return defaultTheme
        }
        set (val) {
            _theme = val
            queueViewTask({
                for (_, nodeView) in self.nodeViews {
                    nodeView.theme = val
                    self.connectorLayerView.theme = val
                }
            })
        }
    }

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
        connectorLayerView.theme = self.theme
        nodeLayerView.backgroundColor = UIColor.clearColor()
        self.mapContentView.addSubview(connectorLayerView)
        self.mapContentView.insertSubview(nodeLayerView, aboveSubview: connectorLayerView)
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: "onContentPanGesture:")
        panGestureRecogniser.requireGestureRecognizerToFail(self.scrollView.panGestureRecognizer)
        panGestureRecogniser.cancelsTouchesInView = false
        mapContentView.addGestureRecognizer(panGestureRecogniser)
        self.scrollView.scrollEnabled = true
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.bounces = true
        self.coordinateSystem.delegate = self
        self.setNeedsLayout()
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
        self.scrollView.contentOffset = CGPointMake(0, 0)
        self.centerOnSelectedNode();
    }
    func onContentPanGesture(pan:UIPanGestureRecognizer) {
        if let draggedNode = draggedNode, node = draggedNode.node {
            let translation = pan.translationInView(mapContentView)
            if pan.state == UIGestureRecognizerState.Began || pan.state == UIGestureRecognizerState.Changed {
                let frame = coordinateSystem.nodeAdded(node)
                var nodeFrame = MapSwiftNodeView.NodeRect(frame)
                nodeFrame = CGRectMake(nodeFrame.origin.x + translation.x, nodeFrame.origin.y + translation.y, nodeFrame.width, nodeFrame.height)
                draggedNode.frame = nodeFrame
                connectorLayerView.nodeConnectorInfo(node.id, nodeRect: nodeFrame, styles: node.styles);
            } else {
                endDragging()
                let frame = coordinateSystem.nodeAdded(node)
                let nodeFrame = MapSwiftNodeView.NodeRect(frame)
                let returnNode = draggedNode
                let duration:NSTimeInterval = 0.1
                self.connectorLayerView.animateNodeRectWithDuration(duration, nodeId: node.id, nodeRect: nodeFrame)
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    returnNode.frame = nodeFrame
                }, completion: nil)
            }
        }
    }
    private func queueViewTask(block:(() -> ())) {
        dispatch_async(dispatch_get_main_queue(), block)
    }

    private func applyLayoutChange() {
        print(">>applyLayoutChange")
        if let layoutChange = self.layoutChange {
            for evt in layoutChange.nodeEvents {
                self.applyNodeEvent(evt.event, node: evt.node)
            }
            if let mapSize = layoutChange.mapSize {
                self.applyMapSizeChange(mapSize)
            }
            if let rectConverter = layoutChange.rectConverter {
                self.applyRectConverter(rectConverter, applyToConnectors: false)
            }
            for evt in layoutChange.connectorEvents {
                self.applyConnectorEvent(evt.event, connector: evt.connector)
            }
            if let _ = layoutChange.rectConverter {
                self.applyNodeRectsToConnectors()
            }
            for evt in layoutChange.nodeIdEvents {
                self.applyNodeIdEvent(evt.event, nodeId: evt.nodeId, toggle: evt.toggle)
            }
        }
        self.layoutChange = nil
        print("<<applyLayoutChange")
    }
    private func applyNodeEvent(event:MapSwiftMapModel.NodeEvent, node:MapSwiftNode) {
        if event == MapSwiftMapModel.NodeEvent.NodeRemoved {
            if let nodeView = nodeViews[node.id] {
                nodeView.removeFromSuperview()
                nodeViews.removeValueForKey(node.id)
                coordinateSystem.nodeRemoved(node)
                connectorLayerView.nodeConnectorInfo(node.id, nodeRect: nil, styles: node.styles);
                return
            }
        }
        let frame = coordinateSystem.nodeAdded(node)
        var nodeView:MapSwiftNodeView! = nodeViews[node.id]
        let nodeFrame = MapSwiftNodeView.NodeRect(frame)
        if nodeView == nil {
            nodeView = MapSwiftNodeView(frame:nodeFrame, theme: self.theme)
            nodeView.delegate = self
            if let selectedNodeId = self.selectedNodeId where selectedNodeId == node.id {
                nodeView.isSelected = true
            }

            self.nodeLayerView.addSubview(nodeView)
            nodeViews[node.id] = nodeView
        }
        nodeView.node = node
        connectorLayerView.nodeConnectorInfo(node.id, nodeRect: nodeFrame, styles: node.styles)
        nodeView.frame = nodeFrame
    }

    private func applyConnectorEvent(event:MapSwiftMapModel.ConnectorEvent, connector:Dictionary<String, AnyObject>) {
        if let connector = MapSwiftNodeConnector.parseDictionary(connector) {
            switch event {
            case .ConnectorCreated:
                self.connectorLayerView.addConnector(connector)
            case .ConnectorRemoved:
                self.connectorLayerView.removeConnector(connector)
            }
        }
    }

    private func applyNodeIdEvent(event:MapSwiftMapModel.NodeRequestEvent, nodeId:String, toggle:Bool) {
        if event == MapSwiftMapModel.NodeRequestEvent.NodeSelectionChanged {
            self.selectedNodeId = nil
            if let nodeView = self.nodeViews[nodeId] {
                nodeView.isSelected = toggle
                if toggle {
                    self.selectedNodeId = nodeId
                }
            }
            if toggle {
                self.centerOnSelectedNode();
            }
        }
    }

    private func applyRectConverter(rectConverter:MapSwift.RectConverter, applyToConnectors:Bool) {
        print("applyRectConverter \(self.layoutChange)")
        for (_, nodeView) in self.nodeViews {
            if let node = nodeView.node {
                let nodeFrame = MapSwiftNodeView.NodeRect(rectConverter(rect: node.rect))
                nodeView.frame = nodeFrame
                if (applyToConnectors) {
                    self.connectorLayerView.nodeConnectorInfo(node.id, nodeRect: nodeView.frame, styles: node.styles);
                }
                nodeView.setNeedsLayout()
            }
        }
    }
    private func applyNodeRectsToConnectors() {
        for (_, nodeView) in self.nodeViews {
            if let node = nodeView.node {
                self.connectorLayerView.nodeConnectorInfo(node.id, nodeRect: nodeView.frame, styles: node.styles);
            }
        }

    }
    private func resetScrollView() {
    }
    private func centerOnSelectedNode() {
        if let selectedNodeId = self.selectedNodeId {
            if let nodeView = self.nodeViews[selectedNodeId] {
                self.scrollView.scrollRectToVisible(CGRectInset(nodeView.frame, -10, -10), animated: true)
            }
        }
    }

//Mark: - MapSwiftMapModelDelegate
    public func mapModelMapEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.MapEvent) {
        queueViewTask({
            switch event {
            case MapSwiftMapModel.MapEvent.LayoutChangeStarting:
                if self.layoutChange == nil {
                    self.layoutChange = MapSwift.LayoutChange();
                }
                break
            case MapSwiftMapModel.MapEvent.LayoutChangeComplete:
                self.applyLayoutChange()
                self.setNeedsLayout()
                break
            case MapSwiftMapModel.MapEvent.MapViewResetRequested:
                self.resetScrollView()
                break
            }
        })
    }

    public func mapModelNodeEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.NodeEvent, node:MapSwiftNode) {
        queueViewTask({
            if let layoutChange = self.layoutChange {
                layoutChange.nodeEvents.append((event:event, node:node))
            } else {
                self.applyNodeEvent(event, node: node)
                self.setNeedsLayout()
            }
        })
    }

    public func mapModelLinkEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.LinkEvent, link:Dictionary<String, AnyObject>) {

    }
    public func mapModelConnectorEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.ConnectorEvent, connector:Dictionary<String, AnyObject>) {
        queueViewTask({
            if let layoutChange = self.layoutChange {
                layoutChange.connectorEvents.append((event:event, connector: connector))
            } else {
                    self.applyConnectorEvent(event, connector: connector)
                    self.setNeedsLayout()
            }
        })
    }
    public func toggleCollapsed() {
        if let delegate = self.delegate, nodeId = self.selectedNodeId, nodeView = self.nodeViews[nodeId], node = nodeView.node {
            let collapsed = node.attr.collapsed
            delegate.mapViewDidCollapse(self, collapse:!collapsed)
        }
    }
    public func mapModelNodeIdEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.NodeRequestEvent, nodeId:String, toggle:Bool) {
        queueViewTask({
            if let layoutChange = self.layoutChange {
                layoutChange.nodeIdEvents.append((event:event, nodeId: nodeId, toggle: toggle))
            } else {
                self.applyNodeIdEvent(event, nodeId: nodeId, toggle: toggle);
                self.setNeedsLayout()
            }
        });

    }
    public func mapModelToggleEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.ToggleRequestEvent, toggle:Bool) {

    }

    public func mapModelMapScaleChanged(mapModel:MapSwiftMapModel, scale:Double) {

    }

    public func mapModelNodeEditRequested(mapModel:MapSwiftMapModel, nodeId:String, shouldSelectAll:Bool, editingNew:Bool) {

    }

    public func mapModelActivatedNodesChanged(mapModel:MapSwiftMapModel, activatedNodes:[AnyObject], deactivatedNodes:[AnyObject]) {
        queueViewTask({
            for activated in activatedNodes {
                if let activatedNodeId = String.mapswift_fromAnyObject(activated), activatedNodeView = self.nodeViews[activatedNodeId] {
                    activatedNodeView.isActivated = true

                }
            }
            for deactivated in deactivatedNodes {
                if let deactivatedNodeId = String.mapswift_fromAnyObject(deactivated),
                    deactivatedNodeView = self.nodeViews[deactivatedNodeId] {
                    deactivatedNodeView.isActivated = false

                }
            }
        })
    }
//MARK: - MapSwiftViewCoordinatesDelegate
    func mapSwiftViewCoordinatesChanged(mapSwiftViewCoordiates:MapSwiftViewCoordinates, rectConverter:MapSwift.RectConverter) {
        print("mapSwiftViewCoordinatesChanged \(self.layoutChange)")
        if let layoutChange = self.layoutChange {
            print("delay rectConverter")
            layoutChange.rectConverter = rectConverter
        } else {
            queueViewTask({
                self.applyRectConverter(rectConverter, applyToConnectors: true);
                self.setNeedsLayout()
            })
        }

    }
    private func applyMapSizeChange(mapSize:CGSize) {
        print("applyMapSizeChange")
        self.mapContentView.frame = CGRectMake(0, 0, mapSize.width, mapSize.height)
        self.nodeLayerView.frame = self.mapContentView.bounds
        self.connectorLayerView.frame = self.mapContentView.bounds
        self.centerOnSelectedNode();
    }
    func mapSwiftViewSizeChanged(mapSwiftViewCoordiates:MapSwiftViewCoordinates, mapSize:CGSize) {
        if let layoutChange = self.layoutChange {
            print("delay mapSwiftViewSizeChanged")
            layoutChange.mapSize = mapSize
        } else {
            queueViewTask({
                self.applyMapSizeChange(mapSize)
                self.setNeedsLayout()
            })
        }
    }


//MARK: - MapSwiftNodeViewDelegate 
    func nodeViewWasTapped(nodeView: MapSwiftNodeView) {
        queueViewTask({
            if let node = nodeView.node, delegate = self.delegate {
                delegate.mapViewDidSelectNode(self, nodeSelected: node)
            }
        })
    }
    func nodeViewWasTouched(nodeView: MapSwiftNodeView) {
        queueViewTask({
            if let node = nodeView.node where node.level > 1 {
                self.draggedNode = nodeView
                self.nodeLayerView.bringSubviewToFront(nodeView)
                self.scrollView.scrollEnabled = false
            }
        })
    }
    func endDragging() {
        queueViewTask({
            if let _ = self.delegate {
                self.draggedNode = nil
                self.scrollView.scrollEnabled = true
            }
        });

    }
    func nodeViewTouchEnded(nodeView: MapSwiftNodeView) {
        queueViewTask({
            self.endDragging()
        });
    }
}

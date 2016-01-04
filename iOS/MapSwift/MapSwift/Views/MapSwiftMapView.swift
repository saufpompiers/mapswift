//
//  MapSwiftMapView.swift
//  MapSwift
//
//  Created by David de Florinier on 30/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

public class MapSwiftMapView: UIView, MapSwiftMapModelDelegate, MapSwiftViewCoordinatesDelegate {
    typealias NodeEventArgs = (event:MapSwiftMapModel.NodeEvent, node:MapSwiftNode)

    private var nodeViews:[String:MapSwiftNodeView] = [:]
    private var layoutChanging = false
    private var queuedNodeEvents:[NodeEventArgs] = []
    private var coordinateSystem = MapSwiftViewCoordinates()
    private let scrollView:UIScrollView
    private let mapContentView = UIView(frame: CGRectMake(0,0,10, 10))

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
        scrollView.backgroundColor = UIColor.lightGrayColor()
        mapContentView.backgroundColor = UIColor.whiteColor()
        self.addSubview(scrollView)
        self.scrollView.addSubview(mapContentView)
        self.scrollView.scrollEnabled = true
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
                return
            }
        }
        let frame = coordinateSystem.nodeAdded(node)
        print("node:\(node.title) frame:\(frame) nodeRect:\(node.rect)")
        var nodeView:MapSwiftNodeView! = nodeViews[node.id]
        if nodeView == nil {
            nodeView = MapSwiftNodeView(frame:frame)
            self.mapContentView.addSubview(nodeView)
            nodeViews[node.id] = nodeView
        } else {
            nodeView.frame = frame
        }
        nodeView.node = node
        UIView.animateWithDuration(0.2, animations: {
            nodeView.frame = frame
        })
        self.setNeedsLayout()
    }

    private func resetScrollView() {

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

    }
    public func mapModelNodeIdEvent(mapModel:MapSwiftMapModel, event:MapSwiftMapModel.NodeRequestEvent, nodeId:String, toggle:Bool) {

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
                nodeView.frame = rectConverter(rect: node.rect)
            }
        }
    }
    func mapSwiftViewSizeChanged(mapSwiftViewCoordiates:MapSwiftViewCoordinates, mapSize:CGSize) {
        self.mapContentView.frame = CGRectMake(0, 0, mapSize.width, mapSize.height)
        self.setNeedsLayout()
    }

}

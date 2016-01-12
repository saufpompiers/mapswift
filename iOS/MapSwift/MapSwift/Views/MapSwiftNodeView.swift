//
//  MapSwiftNodeView.swift
//  MapSwift
//
//  Created by David de Florinier on 30/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

protocol MapSwiftNodeViewDelegate:class {
    func nodeViewWasTapped(nodeView:MapSwiftNodeView)
    func nodeViewWasTouched(nodeView:MapSwiftNodeView)
    func nodeViewTouchEnded(nodeView:MapSwiftNodeView)
}
class MapSwiftNodeView: UIView {
    static let BackgroundInset:CGFloat = 10
    static let LabelInset:CGFloat = 15
    class func NodeRect(rect:CGRect) -> CGRect {
        let outset = -1 * MapSwiftNodeView.BackgroundInset
        return CGRectInset(rect, outset , outset)
    }

    weak var delegate:MapSwiftNodeViewDelegate?

    private var _node:MapSwiftNode?
    var node:MapSwiftNode? {
        get {
            return _node
        }
        set (n) {
            _node = n
            if let node = _node {
                self.nodeTextlabel.text = node.title
                self.nodeTextlabel.textColor = UIColor(hexString: "#4F4F4F")
                if node.level == 1 {
                    self.nodeBackgroundView.backgroundColor = UIColor(hexString: "#22AAE0")
                    self.nodeDecorationView.activatedColor = UIColor(hexString: "#E0E0E0")
                } else {
                    self.nodeBackgroundView.backgroundColor = UIColor(hexString: "#E0E0E0")
                    self.nodeDecorationView.activatedColor = UIColor(hexString: "#22AAE0")
                }
            }
            self.setNeedsLayout()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.defaultColors()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.userInteractionEnabled = true
        self.defaultColors()

    }

    var isSelected:Bool {
        get {
            return nodeBackgroundView.selected
        }
        set (s) {
            nodeBackgroundView.selected = s
        }
    }
    var isActivated:Bool {
        get {
            return nodeDecorationView.activated
        }
        set (val) {
            nodeDecorationView.activated = val
        }
    }
    private var labelFrame:CGRect {
        get {
            return CGRectInset(self.bounds, MapSwiftNodeView.LabelInset, MapSwiftNodeView.LabelInset)
        }
    }

    private var _label:UILabel?
    private var nodeTextlabel:UILabel {
        get {
            if let label = _label {
                return label
            }
            let label = UILabel(frame:self.labelFrame)
            self._label = label
            label.numberOfLines = 0
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont.systemFontOfSize(16, weight: UIFontWeightSemibold)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.2
            self.insertSubview(label, aboveSubview: nodeDecorationView)
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapGesture"))
            label.userInteractionEnabled = true
            return label
        }
    }

    private var backgroundFrame:CGRect {
        get {
            return CGRectInset(self.bounds, MapSwiftNodeView.BackgroundInset, MapSwiftNodeView.BackgroundInset)
        }
    }

    private var _nodeBackgroundView:MapSwiftNodeBackgroundView?
    var nodeBackgroundView:MapSwiftNodeBackgroundView {
        get {
            if let bg = _nodeBackgroundView {
                return bg
            }
            let bg = MapSwiftNodeBackgroundView(frame: self.backgroundFrame)
            _nodeBackgroundView = bg
            self.addSubview(bg)
            return bg
        }
    }

    private var _nodeDecorationView:MapSwiftNodeDecorationView?
    var nodeDecorationView:MapSwiftNodeDecorationView {
        get {
            if let ndec = _nodeDecorationView {
                return ndec
            }
            let ndec = MapSwiftNodeDecorationView(frame:self.bounds)
            _nodeDecorationView = ndec
            self.insertSubview(ndec, aboveSubview: nodeBackgroundView)
            return ndec
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let delegate = self.delegate {
            delegate.nodeViewWasTouched(self)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let delegate = self.delegate {
            delegate.nodeViewTouchEnded(self)
        }

    }
    override func layoutSubviews() {
        nodeTextlabel.frame = self.labelFrame
        nodeBackgroundView.frame = self.backgroundFrame
    }

    func onTapGesture() {
        if let delegate = self.delegate {
            delegate.nodeViewWasTapped(self)
        }
    }
    private func defaultColors() {
        self.backgroundColor = UIColor.clearColor()
    }

}

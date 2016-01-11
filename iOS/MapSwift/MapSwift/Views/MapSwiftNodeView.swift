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
            if let label = self.label, node = _node {
                label.text = node.title

                if node.level == 1 {
                    self.nodeBackgroundView?.backgroundColor = UIColor(hexString: "#22AAE0")
                } else {
                    self.nodeBackgroundView?.backgroundColor = UIColor(hexString: "#E0E0E0")
                }
            }
            self.setNeedsLayout()
        }
    }

    private var _isSelected = false
    var isSelected:Bool {
        get {
            return _isSelected
        }
        set (s) {
            _isSelected = s
            if let nodeBackgroundView = self.nodeBackgroundView {
                if _isSelected {
                    nodeBackgroundView.layer.shadowColor = UIColor.blackColor().CGColor;
                    nodeBackgroundView.layer.shadowOffset = CGSizeMake(2,2)
                    nodeBackgroundView.layer.shadowOpacity = 0.9
                    nodeBackgroundView.layer.shadowRadius = 2
                } else {
                    nodeBackgroundView.layer.shadowColor = UIColor(hexString: "#070707").CGColor;
                    nodeBackgroundView.layer.shadowOffset = CGSizeMake(1,1)
                    nodeBackgroundView.layer.shadowOpacity = 0.4
                    nodeBackgroundView.layer.shadowRadius = 2
                }
            }

        }
    }
    private var label:UILabel?
    var nodeBackgroundView:UIView?

    private var backgroundFrame:CGRect {
        get {
            return CGRectInset(self.bounds, MapSwiftNodeView.BackgroundInset, MapSwiftNodeView.BackgroundInset)
        }
    }
    private var labelFrame:CGRect {
        get {
            return CGRectInset(self.bounds, MapSwiftNodeView.LabelInset, MapSwiftNodeView.LabelInset)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nodeBackgroundView = UIView(frame: self.backgroundFrame)
        nodeBackgroundView.userInteractionEnabled = true
        self.addSubview(nodeBackgroundView)
        self.nodeBackgroundView = nodeBackgroundView
        self.userInteractionEnabled = true
        let label = UILabel(frame:self.labelFrame)
        label.textColor = UIColor(hexString: "#4F4F4F")
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(16, weight: UIFontWeightSemibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        self.label = label
        self.insertSubview(label, aboveSubview: nodeBackgroundView)
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapGesture"))
        label.userInteractionEnabled = true
        self.defaultColors()

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
        if let label = self.label {
            label.frame = self.labelFrame
        }
        if let nodeBackgroundView = self.nodeBackgroundView {
            nodeBackgroundView.frame = self.backgroundFrame
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.defaultColors()
    }
    func onTapGesture() {
        if let delegate = self.delegate {
            delegate.nodeViewWasTapped(self)
        }
    }
    private func defaultColors() {
        self.backgroundColor = UIColor.clearColor()
        if let nodeBackgroundView = self.nodeBackgroundView {
            nodeBackgroundView.backgroundColor = UIColor(hexString: "#E0E0E0")
            nodeBackgroundView.layer.borderColor = UIColor(hexString: "#707070").CGColor
            nodeBackgroundView.layer.borderWidth = 1
            nodeBackgroundView.layer.cornerRadius = 10
            nodeBackgroundView.layer.shadowColor = UIColor(hexString: "#070707").CGColor;
            nodeBackgroundView.layer.shadowOffset = CGSizeMake(1,1)
            nodeBackgroundView.layer.shadowOpacity = 0.4
            nodeBackgroundView.layer.shadowRadius = 2
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

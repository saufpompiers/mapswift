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
    var labelInset = MapSwiftNodeView.BackgroundInset
//    static let LabelInset:CGFloat = 15
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
            self.setNeedsLayout()
        }
    }

    func showTextForNodeStyle(node:MapSwiftNode, nodeStyle:MapSwiftTheme.NodeStyle) {
        let label = self.nodeTextlabel
        label.font = UIFont.systemFontOfSize(nodeStyle.text.font.size, weight: nodeStyle.text.font.weight)
        label.textColor = nodeStyle.text.color

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.0
        paragraphStyle.alignment = nodeStyle.text.alignment
        let attrString = NSMutableAttributedString(string: node.title)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        label.attributedText = attrString
    }

    func calcNodeStyles() -> [String] {
        var styles:[String] = []
        if _isSelected {
            styles.append("selected")
        }
        if let node = _node {
            styles.append("level \(node.level)")
        }
        return styles
    }
    func  calcNodeStyle() -> MapSwiftTheme.NodeStyle {
        return self.theme.nodeStyle(calcNodeStyles())
    }
    private var _theme:MapSwiftTheme?
    var theme:MapSwiftTheme {
        get {
            if let theme = _theme {
                return theme
            }
            let def = MapSwiftTheme.Default()
            _theme = def
            return def
        }
        set (val){
            _theme = val
            self.setNeedsLayout()
        }
    }

    convenience init?(coder aDecoder: NSCoder, theme:MapSwiftTheme) {
        self.init(coder: aDecoder)
        self._theme = theme
        self.defaultColors()
    }

    init(frame: CGRect, theme:MapSwiftTheme) {
        self._theme = theme
        super.init(frame: frame)
        self.userInteractionEnabled = true
        self.defaultColors()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private var _isSelected = false
    var isSelected:Bool {
        get {
            return _isSelected
        }
        set (s) {
            _isSelected = s
            self.setNeedsLayout()
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
            return CGRectInset(self.bounds, labelInset, labelInset)
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
            self.setNeedsLayout()
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
        if let node = _node {
            let nodeStyle = self.calcNodeStyle()
            self.nodeBackgroundView.setNodeStyle(nodeStyle)
            self.labelInset = MapSwiftNodeView.BackgroundInset + nodeStyle.text.margin
            self.nodeBackgroundView.setNodeStyle(nodeStyle)
            self.nodeDecorationView.setNodeStyle(nodeStyle)
            self.showTextForNodeStyle(node, nodeStyle: nodeStyle)
        }
        self.nodeTextlabel.frame = self.labelFrame
        self.nodeBackgroundView.frame = self.backgroundFrame
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

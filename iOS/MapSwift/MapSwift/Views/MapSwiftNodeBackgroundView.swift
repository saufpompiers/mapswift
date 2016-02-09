//
//  MapSwiftNodeBackgroundView.swift
//  MapSwift
//
//  Created by David de Florinier on 11/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

class MapSwiftNodeBackgroundView: UIView {
    enum ShowShadowOn {
        case Collapsed, Never, UnCollapsed
    }
    var shadowOn:ShowShadowOn = ShowShadowOn.UnCollapsed

    var _nodeBorderView:MapSwiftNodeBorderView?
    var nodeBorderView:MapSwiftNodeBorderView {
        get {
            if let nodeBorderView = _nodeBorderView {
                return nodeBorderView
            }
            let nbv  = MapSwiftNodeBorderView(frame:self.bounds)
            _nodeBorderView = nbv
            self.addSubview(nbv)
            return nbv
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    override func layoutSubviews() {
        self.nodeBorderView.frame = self.bounds
    }
    func showShadow(nodeAttributes:MapSwiftNodeAttributes) -> Bool {
        if shadowOn == .Never {
            return false
        }
        if nodeAttributes.collapsed && shadowOn == .UnCollapsed {
            return false
        }
        if !nodeAttributes.collapsed && shadowOn == .Collapsed {
            return false
        }
        return true
    }
    func setNodeStyle(nodeStyle:MapSwift.NodeStyle, nodeAttributes:MapSwiftNodeAttributes) {
        self.nodeBorderView.setNodeStyle(nodeStyle, nodeAttributes:nodeAttributes)
        if showShadow(nodeAttributes) {
            self.layer.shadowColor = nodeStyle.shadow.color.CGColor
            self.layer.shadowOffset = nodeStyle.shadow.offset
            self.layer.shadowOpacity = nodeStyle.shadow.opacity
        } else {
            self.layer.shadowColor = UIColor.clearColor().CGColor
            self.layer.shadowOffset = CGSizeMake(0,0)
            self.layer.shadowOpacity = 0
        }
    }


}

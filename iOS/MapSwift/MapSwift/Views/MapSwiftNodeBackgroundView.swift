//
//  MapSwiftNodeBackgroundView.swift
//  MapSwift
//
//  Created by David de Florinier on 11/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

class MapSwiftNodeBackgroundView: UIView {
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
    func setNodeStyle(nodeStyle:MapSwiftTheme.NodeStyle) {
        self.nodeBorderView.setNodeStyle(nodeStyle)
        self.layer.shadowColor = nodeStyle.shadow.color.CGColor
        self.layer.shadowOffset = nodeStyle.shadow.offset
        self.layer.shadowOpacity = nodeStyle.shadow.opacity
    }


}

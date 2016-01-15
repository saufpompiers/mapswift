//
//  MapSwiftNodeDecorationView.swift
//  MapSwift
//
//  Created by David de Florinier on 11/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import Foundation
class MapSwiftNodeDecorationView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.defaultColors();
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.defaultColors();
    }

    func defaultColors() {
        self.backgroundColor = UIColor.clearColor();
    }
    private var borderInset:CGFloat = 0
    private var activatedColor = UIColor.blueColor()
    private var cornerRadius:CGFloat = 0
    private var inset:CGFloat = MapSwiftNodeView.BackgroundInset

    func setNodeStyle(nodeStyle:MapSwiftTheme.NodeStyle) {
        self.borderInset = nodeStyle.borderStyle.inset * 2
        self.activatedColor = nodeStyle.activatedColor
        self.cornerRadius = max(0, nodeStyle.cornerRadius - self.borderInset)
        self.inset = MapSwiftNodeView.BackgroundInset + borderInset
        self.setNeedsDisplay()
    }
    private var _activated:Bool = false
    var activated:Bool {
        get {
            return _activated
        }
        set (val){
            _activated = val
            setVisibility()
            if _activated {
                self.setNeedsDisplay()
            }
        }
    }
    func setVisibility() {
        self.hidden = !_activated
    }
    override func drawRect(rect: CGRect) {
        if _activated {
            let ctx = UIGraphicsGetCurrentContext()
            let outlineRect = CGRectInset(self.bounds, self.inset, self.inset)
            let path = UIBezierPath(roundedRect: outlineRect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSizeMake(cornerRadius, cornerRadius))
            let phase:CGFloat = 2 //perim % 2
            let dashLengths:[CGFloat] = [2, 2];
            path.setLineDash(dashLengths, count: 2, phase: phase)
            CGContextSetStrokeColorWithColor(ctx,activatedColor.CGColor)

            path.lineWidth = self.borderInset
            path.stroke()
        }
    }

}

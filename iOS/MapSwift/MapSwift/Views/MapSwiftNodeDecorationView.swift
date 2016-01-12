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
    var activatedColor = UIColor.blueColor()
    static let BorderInset:CGFloat = (MapSwiftNodeBackgroundView.BorderWidth * 2)
    var inset:CGFloat = MapSwiftNodeView.BackgroundInset + MapSwiftNodeDecorationView.BorderInset
    var cornerRadius = MapSwiftNodeBackgroundView.CornerRadius - MapSwiftNodeDecorationView.BorderInset

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

            path.lineWidth = MapSwiftNodeBackgroundView.BorderWidth * 2
            path.stroke()
        }
    }

}

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

    func setNodeStyle(nodeStyle:MapSwift.NodeStyle) {
        self.borderInset = nodeStyle.borderStyle.inset * 2
        self.activatedColor = nodeStyle.activatedColor
        self.cornerRadius = max(0, nodeStyle.cornerRadius - nodeStyle.borderStyle.inset)
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
            let x0 = outlineRect.origin.x
            let x1 = outlineRect.origin.x + cornerRadius
            let x2 = outlineRect.origin.x + outlineRect.width - cornerRadius
            let x3 = outlineRect.origin.x + outlineRect.width

            let y0 = outlineRect.origin.y
            let y1 = outlineRect.origin.y + cornerRadius
            let y2 = outlineRect.origin.y + outlineRect.height - cornerRadius
            let y3 = outlineRect.origin.y + outlineRect.height

            CGContextSetStrokeColorWithColor(ctx,activatedColor.CGColor)
            CGContextSetLineWidth(ctx, self.borderInset)
            let phase:CGFloat = 1 //perim % 2
            let dashLengths:[CGFloat] = [2, 2];
            CGContextSetLineDash(ctx, phase, dashLengths, 2)
            CGContextMoveToPoint(ctx, x1, y0);
            CGContextAddLineToPoint(ctx, x2, y0)
            CGContextAddQuadCurveToPoint(ctx, x3, y0, x3, y1)
            CGContextAddLineToPoint(ctx, x3, y2)
            CGContextAddQuadCurveToPoint(ctx, x3, y3, x2, y3)
            CGContextAddLineToPoint(ctx, x1, y3)
            CGContextAddQuadCurveToPoint(ctx, x0, y3, x0, y2)
            CGContextAddLineToPoint(ctx, x0, y1)
            CGContextAddQuadCurveToPoint(ctx, x0, y0, x1, y0)
            CGContextStrokePath(ctx);
        }
    }

}

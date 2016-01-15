//
//  MapSwiftNodeBackgroundView.swift
//  MapSwift
//
//  Created by David de Florinier on 11/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

class MapSwiftNodeBackgroundView: UIView {
    static let CornerRadius:CGFloat = 10
    static let BorderWidth:CGFloat = 1
    private var nodeStyle:MapSwiftTheme.NodeStyle?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    func setNodeStyle(nodeStyle:MapSwiftTheme.NodeStyle) {
        self.nodeStyle = nodeStyle
    }

    override func drawRect(rect: CGRect) {
        if let nodeStyle = nodeStyle  {
            switch nodeStyle.borderStyle.type {
            case .Surround:
                let ctx = UIGraphicsGetCurrentContext()
                let outlineRect = CGRectInset(self.bounds, nodeStyle.borderStyle.inset, nodeStyle.borderStyle.inset)
                let path = UIBezierPath(roundedRect: outlineRect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSizeMake(nodeStyle.cornerRadius, nodeStyle.cornerRadius))
                CGContextSetFillColorWithColor(ctx, nodeStyle.backgroundColor.CGColor)
                CGContextSetStrokeColorWithColor(ctx,nodeStyle.borderStyle.line.color.CGColor)
                path.lineWidth = nodeStyle.borderStyle.line.width
                path.stroke()
                path.fill()
                break;
            case .Underline:
                let ctx = UIGraphicsGetCurrentContext()
                CGContextSetStrokeColorWithColor(ctx,nodeStyle.borderStyle.line.color.CGColor)
                CGContextSetLineWidth(ctx, nodeStyle.borderStyle.line.width)
                CGContextMoveToPoint(ctx, nodeStyle.cornerRadius, self.bounds.height)
                CGContextAddLineToPoint(ctx, self.bounds.width - nodeStyle.cornerRadius, self.bounds.height)
                CGContextStrokePath(ctx)
                break;
            default:
                break
            }
            if nodeStyle.borderStyle.type == MapSwiftTheme.BorderType.Underline {
            }
        }
    }
}

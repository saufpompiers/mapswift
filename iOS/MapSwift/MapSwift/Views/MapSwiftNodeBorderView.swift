//
//  MapSwiftNodeBorderView.swift
//  MapSwift
//
//  Created by David de Florinier on 15/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

class MapSwiftNodeBorderView: UIView {
    private var nodeStyle:MapSwift.NodeStyle?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
    }

    func setNodeStyle(nodeStyle:MapSwift.NodeStyle, nodeAttributes:MapSwiftNodeAttributes) {
        self.nodeStyle = nodeStyle
        self.layer.cornerRadius = nodeStyle.cornerRadius
        if let color = nodeAttributes.backgroundColor {
            self.backgroundColor = color
        } else {
            self.backgroundColor = nodeStyle.backgroundColor
        }
    }

    override func drawRect(rect: CGRect) {
        if let nodeStyle = nodeStyle  {
            switch nodeStyle.borderStyle.type {
            case .Surround:
                self.layer.borderColor = nodeStyle.borderStyle.line.color.CGColor
                self.layer.borderWidth = nodeStyle.borderStyle.line.width
                break;
            case .Underline:
                self.layer.borderColor = UIColor.clearColor().CGColor
                self.layer.borderWidth = 0
                let ctx = UIGraphicsGetCurrentContext()
                CGContextSetStrokeColorWithColor(ctx,nodeStyle.borderStyle.line.color.CGColor)
                CGContextSetLineWidth(ctx, nodeStyle.borderStyle.line.width * 2)
                CGContextMoveToPoint(ctx, nodeStyle.cornerRadius, self.bounds.height)
                CGContextAddLineToPoint(ctx, self.bounds.width - nodeStyle.cornerRadius, self.bounds.height)
                CGContextStrokePath(ctx)
                break;
            default:
                break
            }
        }
    }

}

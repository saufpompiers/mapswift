//
//  MapSwiftNodeView.swift
//  MapSwift
//
//  Created by David de Florinier on 30/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

class MapSwiftNodeView: UIView {
    var _node:MapSwiftNode?
    var node:MapSwiftNode? {
        get {
            return _node
        }
        set (n) {
            _node = n
            if let label = self.label, node = _node {
                label.text = node.title
                if node.level == 1 {
                    self.backgroundColor = UIColor(hexString: "#22AAE0")
                } else {
                    self.backgroundColor = UIColor(hexString: "#E0E0E0")
                }
            }
            self.setNeedsLayout()
        }
    }
    var label:UILabel?
    override init(frame: CGRect) {
        super.init(frame: frame)
        let label = UILabel(frame:CGRectMake(0,0, frame.width, frame.height))
        label.textColor = UIColor(hexString: "#4F4F4F")
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(16, weight: UIFontWeightSemibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        self.label = label
        self.addSubview(label)
        self.defaultColors()

    }
    override func layoutSubviews() {
        if let label = self.label {
            label.frame = CGRectInset(self.bounds, 5, 5)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.defaultColors()
    }

    private func defaultColors() {
        self.backgroundColor = UIColor.lightTextColor();
        self.layer.borderColor = UIColor(hexString: "#707070").CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor(hexString: "#070707").CGColor;
        self.layer.shadowOffset = CGSizeMake(1,1)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 2
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

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
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    func setNodeStyle(nodeStyle:MapSwiftTheme.NodeStyle) {
        self.layer.borderColor = nodeStyle.borderStyle.color.CGColor
        self.layer.borderWidth = nodeStyle.borderStyle.width
        self.layer.cornerRadius = nodeStyle.cornerRadius
        self.backgroundColor = nodeStyle.backgroundColor
        self.layer.shadowColor = nodeStyle.shadow.color.CGColor;
        self.layer.shadowOffset = nodeStyle.shadow.offset
        self.layer.shadowOpacity = nodeStyle.shadow.opacity
        self.layer.shadowRadius = nodeStyle.shadow.radius

    }
}

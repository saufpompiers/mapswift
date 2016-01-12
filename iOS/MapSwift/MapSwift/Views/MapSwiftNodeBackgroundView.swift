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
        self.defaultColors();
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.defaultColors();
    }

    private func defaultColors() {
        self.layer.borderColor = UIColor(hexString: "#707070").CGColor
        self.layer.borderWidth = MapSwiftNodeBackgroundView.BorderWidth
        self.layer.cornerRadius = MapSwiftNodeBackgroundView.CornerRadius
        self.selected = false
    }
    private var _selected:Bool = false
    var selected:Bool {
        get {
            return _selected
        }
        set (val){
            _selected = val
            if _selected {
                self.layer.shadowColor = UIColor.blackColor().CGColor;
                self.layer.shadowOffset = CGSizeMake(2,2)
                self.layer.shadowOpacity = 0.9
                self.layer.shadowRadius = 2
            } else {
                self.layer.shadowColor = UIColor(hexString: "#070707").CGColor;
                self.layer.shadowOffset = CGSizeMake(1,1)
                self.layer.shadowOpacity = 0.4
                self.layer.shadowRadius = 2
            }
            self.setNeedsDisplay()

        }
    }
}

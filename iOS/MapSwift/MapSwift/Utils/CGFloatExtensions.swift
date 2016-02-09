//
//  CGFloatExtensions.swift
//  MapSwift
//
//  Created by David de Florinier on 09/02/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

extension CGFloat {
    static func mapswift_parseFontWeight(weight:String) -> CGFloat {
        switch weight {
        case "bold":
            return UIFontWeightBold
        case "semibold":
            return UIFontWeightSemibold
        case "light":
            return UIFontWeightLight
        default:
            return UIFontWeightRegular
        }
    }
}

//
//  NSTextAlignmentExtensions.swift
//  MapSwift
//
//  Created by David de Florinier on 09/02/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

extension NSTextAlignment {
    static func mapswift_parseThemeAlignment(alignment:String) -> NSTextAlignment {
        switch alignment {
        case "left":
            return NSTextAlignment.Left
        case "right":
            return NSTextAlignment.Right
        default:
            return NSTextAlignment.Center
        }
    }
}

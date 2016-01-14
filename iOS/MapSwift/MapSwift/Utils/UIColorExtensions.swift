//
//  UIColorExtensions.swift
//  MapSwift
//
//  Created by David de Florinier on 04/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

//node background #E0E0E0
//border #777
//center node background #22AAE0
//corner radius 10

func mm_int2rgb(rgbValue: CUnsignedInt) -> (CGFloat, CGFloat, CGFloat) {
    let div:CGFloat = 255.0
    return (
        CGFloat(UInt((rgbValue & 0xff0000) >> 16))/div,
        CGFloat(UInt((rgbValue & 0xFF00) >> 8))/div,
        CGFloat(UInt(rgbValue & 0xFF))/div
    )
}

extension UIColor {
    class  func fromMapSwiftTheme(string:NSString) -> UIColor {
        if string == "transparent" {
            return UIColor.clearColor()
        }
        return UIColor(hexString: string);
    }
    convenience init(hexValue: CUnsignedInt) {
        let (r,g,b) = mm_int2rgb(hexValue)
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    convenience init(hexString: NSString) {
        var hex = hexString as String
        if hexString.hasPrefix("#") {
            hex = hexString.substringWithRange(NSMakeRange(1, hexString.length - 1))
        }
        var rgbValue : CUnsignedInt = 0
        NSScanner(string: hex).scanHexInt(&rgbValue)
        let (r,g,b) = mm_int2rgb(rgbValue)
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }

}

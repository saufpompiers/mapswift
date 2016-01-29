//
//  UIColorExtensions.swift
//  MapSwift
//
//  Created by David de Florinier on 04/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

func mm_int2rgb(rgbValue: CUnsignedInt) -> (CGFloat, CGFloat, CGFloat) {
    let div:CGFloat = 255.0
    return (
        CGFloat(UInt((rgbValue & 0xff0000) >> 16))/div,
        CGFloat(UInt((rgbValue & 0xFF00) >> 8))/div,
        CGFloat(UInt(rgbValue & 0xFF))/div
    )
}

typealias MapSwiftRGBA = (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat)
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

    func mapswift_blend(color: UIColor, weight:CGFloat = 0.5 ) -> UIColor {
        func blend(w1:CGFloat, c1:CGFloat, w2:CGFloat, c2:CGFloat) -> CGFloat {
            return (w1 * c1) + (w2 * c2)
        }
        if let r1 = self.mapswift_rgba,  r2 = color.mapswift_rgba {
            let p = weight;
            let w = 2 * p - 1;
            let a = r1.a - r2.a
            let w1 = (((w * a == -1) ? w : (w + a) / (1 + w * a)) + 1) / 2.0;
            let w2 = 1 - w1;
            return UIColor(red: blend(w1, c1:r1.r, w2:w2, c2:r2.r), green: blend(w1, c1:r1.g, w2:w2, c2:r2.g), blue: blend(w1, c1:r1.b, w2:w2, c2:r2.b), alpha: blend(w1, c1:r1.a, w2:w2, c2:r2.a))
        }
        return self
    }
    var mapswift_rgba:MapSwiftRGBA? {
        get {
            var r:CGFloat = 0.0
            var g:CGFloat = 0.0
            var b:CGFloat = 0.0
            var a:CGFloat = 0.0

            if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
                return MapSwiftRGBA(r:r, g:g, b:b, a:a)
            }
            return nil
        }
    }
    var mapswift_rgbLuminosity:CGFloat {
        get {
            func lum(chan:CGFloat) -> CGFloat {
                return (chan <= 0.03928) ? chan / 12.92 : pow(((chan + 0.055) / 1.055), 2.4);
            }
            if let rgba = self.mapswift_rgba {
                return (0.2126 * lum(rgba.r) + 0.7152 * lum(rgba.g) + 0.0722 * lum(rgba.b));
            }
            return 0.6
        }
    }
}

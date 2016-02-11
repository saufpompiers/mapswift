//
//  MapSwiftThemeDescriptors.swift
//  MapSwift
//
//  Created by David de Florinier on 09/02/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

extension MapSwift {
    public typealias LineStyle = (color:UIColor, width:CGFloat)
    public enum BorderType: String {
        case Surround = "surround", Underline = "underline", None = "none"
        static func parse(string:String) -> BorderType {
            switch string {
            case "underline":
                return .Underline
            case "none":
                return .None
            default:
                return .Surround
            }
        }
    }

    class BorderStyle {
        let type:BorderType, line:LineStyle, inset:CGFloat
        init(type:BorderType, line:LineStyle, inset:CGFloat) {
            self.inset = inset
            self.type = type
            self.line = line
        }
    }
    class ShadowStyle {
        let color:UIColor, opacity:Float, offset:CGSize, radius:CGFloat
        init (color:UIColor, opacity:Float, offset:CGSize, radius:CGFloat) {
            self.color = color
            self.opacity = opacity
            self.offset = offset
            self.radius = radius
        }
    }

    class TextStyle {
        let font:FontStyle, alignment:NSTextAlignment, color:UIColor, lightColor:UIColor, darkColor:UIColor, lineSpacing:CGFloat, margin:CGFloat
        init(font:FontStyle, alignment:NSTextAlignment, color:UIColor, lightColor:UIColor, darkColor:UIColor, lineSpacing:CGFloat, margin:CGFloat) {
            self.font = font
            self.alignment = alignment
            self.color = color
            self.lightColor = lightColor
            self.darkColor = darkColor
            self.lineSpacing = lineSpacing
            self.margin = margin
        }
    }

    class FontStyle {
        let size:CGFloat
        let weight:CGFloat
        init(size:CGFloat, weight:CGFloat) {
            self.size = size
            self.weight = weight
        }
    }
    typealias ConnectionJoinPositions = (h:ConnectionJoinPosition, v:ConnectionJoinPosition)
    typealias ConnectionJoinsFrom = (above:ConnectionJoinPositions, below:ConnectionJoinPositions, horizontal:ConnectionJoinPositions)
    class ConnectionStyle {
        let from:ConnectionJoinsFrom, to:ConnectionJoinPositions, style:String?, lineStyle:LineStyle
        init(from:ConnectionJoinsFrom, to:ConnectionJoinPositions, style:String?, lineStyle:LineStyle) {
            self.from = from
            self.to = to
            self.style = style
            self.lineStyle = lineStyle
        }
    }

    public enum ConnectionJoinPosition : String {
        case Center = "center", Nearest = "nearest", NearestInset = "nearest-inset", Base = "base"
        static func parse(string:String) -> ConnectionJoinPosition {
            switch string {
            case Center.rawValue:
                return .Center
            case Base.rawValue:
                return .Base
            case NearestInset.rawValue:
                return .NearestInset
            default:
                return .Nearest
            }
        }
    }
    public class NodeStyle {
        let cornerRadius:CGFloat, backgroundColor:UIColor, activatedColor:UIColor, borderStyle:BorderStyle, shadow:ShadowStyle, text:TextStyle
        init(cornerRadius:CGFloat, backgroundColor:UIColor, activatedColor:UIColor, borderStyle:BorderStyle, shadow:ShadowStyle, text:TextStyle) {
            self.cornerRadius = cornerRadius
            self.backgroundColor = backgroundColor
            self.activatedColor = activatedColor
            self.borderStyle = borderStyle
            self.shadow = shadow
            self.text = text
        }
    }
    class ControlPoints {
        let points:[CGSize]
        init(points:[CGSize]) {
            self.points = points
        }
    }
}


//
//  MapSwiftTheme.swift
//  MapSwift
//
//  Created by David de Florinier on 12/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

public class MapSwiftTheme {

    let themeDictionary:MapSwiftDefaultedDictionary

    public init(dictionary:NSDictionary) {
        self.themeDictionary = MapSwiftDefaultedDictionary(dictionary: dictionary)
    }

//MARK: - private helper functions
    private func optionsFromStyle(style:String?) -> [String] {
        var options:[String] = []
        if let style = style {
            options.append(style)
        }
        options.append("default")
        return options
    }

//MARK: - general styling tuples
    public typealias LineStyle = (color:UIColor, width:CGFloat)

    public typealias ShadowStyle = (color:UIColor, opacity:CGFloat, offset:CGSize, radius:CGFloat)

//MARK: - node styling
    public struct NodeStyle {
        let cornerRadius:CGFloat
        let backgroundColor:UIColor
        let activatedColor:UIColor
        let borderStyle:LineStyle
        let shadow:ShadowStyle
    }

    public enum NodeAttribute:String {
        case
        CornerRadius = "cornerRadius",
        BackgroundColor = "backgroundColor",
        ActivatedColor = "activatedColor",
        BorderColor = "border:color",
        BorderWidth = "border:width",
        ShadowColor = "shadow:color",
        ShadowOpacity = "shadow:opacity",
        ShadowOffsetWidth = "shadow:offset:width",
        ShadowOffsetHeight = "shadow:offset:height",
        ShadowRadius = "shadow:radius"

        static let Prefixes = ["node"]
        var postFixes:[String] {
            get {
                return self.rawValue.componentsSeparatedByString(":")
            }
        }
    }

    func nodeAttribute(attribute:NodeAttribute, style:String?) -> AnyObject? {
        return self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: optionsFromStyle(style), keyPostFixes: attribute.postFixes)
    }

    func nodeAttribute<T>(attribute:NodeAttribute, style:String?, fallback:T) -> T {
        if let val =  self.nodeAttribute(attribute, style: style) as? T {
            return val
        }
        return fallback
    }

    func nodeBorderStyle(style:String?) -> LineStyle {
        let colorHex:String = nodeAttribute(.BorderColor, style: style, fallback: "#707070")
        let width:CGFloat = nodeAttribute(.BorderWidth, style: style, fallback: 1.0)
        return LineStyle(color: UIColor(hexString: colorHex), width:width)
    }

    func nodeShadowStyle(style:String?) -> ShadowStyle {
        let colorHex:String = nodeAttribute(.ShadowColor, style: style, fallback: "#070707")
        let opacity:CGFloat = nodeAttribute(.ShadowOpacity, style: style, fallback: 0.4)
        let offsetWidth:CGFloat = nodeAttribute(.ShadowOffsetWidth, style: style, fallback: 2)
        let offsetHeight:CGFloat = nodeAttribute(.ShadowOffsetHeight, style: style, fallback: 2)
        let offset = CGSizeMake(offsetWidth, offsetHeight)
        let radius:CGFloat = nodeAttribute(.ShadowRadius, style: style, fallback: 2)
        return ShadowStyle(color:UIColor(hexString: colorHex), opacity:opacity, offset:offset, radius:radius)
    }

    func nodeStyle(style:String?) -> NodeStyle? {
        let cornerRadius:CGFloat = nodeAttribute(.CornerRadius, style: style, fallback: 10.0)
        let backgroundColorHex:String = nodeAttribute(.BackgroundColor, style: style, fallback: "#E0E0E0")
        let activatedColorHex:String = nodeAttribute(.ActivatedColor, style: style, fallback: "#22AAE0")

        return NodeStyle(cornerRadius: cornerRadius, backgroundColor: UIColor(hexString: backgroundColorHex), activatedColor: UIColor(hexString: activatedColorHex), borderStyle: nodeBorderStyle(style), shadow: nodeShadowStyle(style))
    }
}
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
    public class func Default() -> MapSwiftTheme {
        let url = MapSwiftResources.sharedInstance.defaultThemeURL
        if let dictionary = NSJSONSerialization.mapswift_JSONDictionaryFromFileURL(url) {
            return MapSwiftTheme(dictionary: dictionary)
        }
        return MapSwiftTheme(dictionary: NSDictionary())
    }
//MARK: - private helper functions
    private func optionsFromStyle(styles:[String]) -> [String] {
        var options = styles
        options.append("default")
        return options
    }

//MARK: - general styling tuples
    public typealias LineStyle = (color:UIColor, width:CGFloat)

    public typealias ShadowStyle = (color:UIColor, opacity:CGFloat, offset:CGSize, radius:CGFloat)

    var name:String {
        get {
            if let name = themeDictionary.valueForKey("name") as? String {
                return name
            }
            return "unknown theme"
        }
    }
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

    func nodeAttribute(attribute:NodeAttribute, styles:[String]) -> AnyObject? {
        return self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: optionsFromStyle(styles), keyPostFixes: attribute.postFixes)
    }

    func nodeAttribute<T>(attribute:NodeAttribute, styles:[String], fallback:T) -> T {
        if let val =  self.nodeAttribute(attribute, styles: styles) as? T {
            return val
        }
        return fallback
    }

    func nodeBorderStyle(styles:[String]) -> LineStyle {
        let colorHex:String = nodeAttribute(.BorderColor, styles:styles, fallback: "#707070")
        let width:CGFloat = nodeAttribute(.BorderWidth, styles: styles, fallback: 1.0)
        return LineStyle(color: UIColor(hexString: colorHex), width:width)
    }

    func nodeShadowStyle(styles:[String]) -> ShadowStyle {
        let colorHex:String = nodeAttribute(.ShadowColor, styles: styles, fallback: "#070707")
        let opacity:CGFloat = nodeAttribute(.ShadowOpacity, styles: styles, fallback: 0.4)
        let offsetWidth:CGFloat = nodeAttribute(.ShadowOffsetWidth, styles: styles, fallback: 2)
        let offsetHeight:CGFloat = nodeAttribute(.ShadowOffsetHeight, styles: styles, fallback: 2)
        let offset = CGSizeMake(offsetWidth, offsetHeight)
        let radius:CGFloat = nodeAttribute(.ShadowRadius, styles: styles, fallback: 2)
        return ShadowStyle(color:UIColor(hexString: colorHex), opacity:opacity, offset:offset, radius:radius)
    }

    func nodeStyle(styles:String...) -> NodeStyle {
        let cornerRadius:CGFloat = nodeAttribute(.CornerRadius, styles: styles, fallback: 10.0)
        let backgroundColorHex:String = nodeAttribute(.BackgroundColor, styles: styles, fallback: "#E0E0E0")
        let activatedColorHex:String = nodeAttribute(.ActivatedColor, styles: styles, fallback: "#22AAE0")

        return NodeStyle(cornerRadius: cornerRadius, backgroundColor: UIColor(hexString: backgroundColorHex), activatedColor: UIColor(hexString: activatedColorHex), borderStyle: nodeBorderStyle(styles), shadow: nodeShadowStyle(styles))
    }
}
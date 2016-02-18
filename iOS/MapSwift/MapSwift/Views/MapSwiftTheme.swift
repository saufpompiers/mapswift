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
    var name:String {
        get {
            if let name = themeDictionary.valueForKey("name") as? String {
                return name
            }
            return "unknown theme"
        }
    }
    private var _cacheName:String?
    private var cache:MapSwiftCache {
        get {
            if let cacheName = _cacheName {
                return MapSwiftCaches.forName(cacheName)
            }
            let cacheName = "MapSwiftTheme:\(self.name)"
            _cacheName = cacheName
            return MapSwiftCaches.forName(cacheName)
        }
    }
//MARK: - node styling

    public enum NodeAttribute:String {
        case
        CornerRadius = "cornerRadius",
        BackgroundColor = "backgroundColor",
        ActivatedColor = "activatedColor",
        BorderType = "border:type",
        BorderColor = "border:line:color",
        BorderWidth = "border:line:width",
        ShadowColor = "shadow:color",
        ShadowOpacity = "shadow:opacity",
        ShadowOffsetWidth = "shadow:offset:width",
        ShadowOffsetHeight = "shadow:offset:height",
        ShadowRadius = "shadow:radius",
        TextAlignment = "text:alignment",
        TextColor = "text:color",
        LightTextColor = "text:lightColor",
        DarkTextColor = "text:darkColor",
        TextLineSpacing = "text:lineSpacing",
        TextMargin = "text:margin",
        FontSize = "text:font:size",
        FontWeight = "text:font:weight",
        ConnectionsDefaultH = "connections:default:h",
        ConnectionsDefaultV = "connections:default:v",
        ConnectionsFrom = "connections:from",
        ConnectionsToH = "connections:to:h",
        ConnectionsToV = "connections:to:v",
        ConnectionsStyle = "connections:style"
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
    func cacheKeyForStyles(prefix:String, styles:[String]) -> String {
        return "\(prefix)[\(styles.joinWithSeparator(":"))]"
    }
    func nodeFontStyle(styles:[String]) -> MapSwift.FontStyle {
        let cacheKey = cacheKeyForStyles("nodeFontStyle", styles: styles)
        if let cached:MapSwift.FontStyle = cache.itemForKey(cacheKey) {
            return cached
        }
        let size:CGFloat = nodeAttribute(.FontSize, styles: styles, fallback: 12)
        let weightDescription = nodeAttribute(.FontWeight, styles: styles, fallback: "regular")
        let weight = CGFloat.mapswift_parseFontWeight(weightDescription)
        let style =  MapSwift.FontStyle(size:size, weight:weight)
        cache.cacheItemForKey(style, key: cacheKey)
        return style
    }

    func nodeBorderStyle(styles:[String]) -> MapSwift.BorderStyle {
        let cacheKey = cacheKeyForStyles("nodeBorderStyle", styles: styles)
        if let cached:MapSwift.BorderStyle = cache.itemForKey(cacheKey) {
            return cached
        }

        let color:String = nodeAttribute(.BorderColor, styles:styles, fallback: "#707070")
        let width:CGFloat = nodeAttribute(.BorderWidth, styles: styles, fallback: 1.0)
        let typeName = nodeAttribute(.BorderType, styles: styles, fallback: "")
        var inset = width
        let type = MapSwift.BorderType.parse(typeName)
        if type == MapSwift.BorderType.None {
            inset = 0
        }
        let style = MapSwift.BorderStyle(type: type, line:MapSwift.LineStyle(color:UIColor.fromMapSwiftTheme(color), width:width), inset:inset)
        cache.cacheItemForKey(style, key: cacheKey)
        return style
    }

    func nodeTextStyle(styles:[String]) -> MapSwift.TextStyle {
        let cacheKey = cacheKeyForStyles("nodeTextStyle", styles: styles)
        if let cached:MapSwift.TextStyle = cache.itemForKey(cacheKey) {
            return cached
        }

        let font = self.nodeFontStyle(styles)
        let defaultTextColorHex = "#4F4F4F"
        let color = nodeAttribute(.TextColor, styles: styles, fallback: defaultTextColorHex)
        let lightColor = nodeAttribute(.LightTextColor, styles: styles, fallback: defaultTextColorHex)
        let darkColor = nodeAttribute(.DarkTextColor, styles: styles, fallback: defaultTextColorHex)
        let alignmentDescription = nodeAttribute(.TextAlignment, styles: styles, fallback: "center")
        let lineSpacing:CGFloat = nodeAttribute(.TextLineSpacing, styles: styles, fallback: 3.0)
        let margin:CGFloat = nodeAttribute(.TextMargin, styles: styles, fallback: 10.0)
        let style = MapSwift.TextStyle(font:font, alignment:NSTextAlignment.mapswift_parseThemeAlignment(alignmentDescription), color:UIColor.fromMapSwiftTheme(color), lightColor:UIColor.fromMapSwiftTheme(lightColor), darkColor:UIColor.fromMapSwiftTheme(darkColor), lineSpacing:lineSpacing, margin: margin)
        cache.cacheItemForKey(style, key: cacheKey)
        return style

    }

    func nodeConnectionStyle(styles:[String]) -> MapSwift.ConnectionStyle {
        let cacheKey = cacheKeyForStyles("nodeConnectionStyle", styles: styles)
        if let cached:MapSwift.ConnectionStyle = cache.itemForKey(cacheKey) {
            return cached
        }
        func calcConnectionJoinPositions(styles:[String], postFixes:[String], pos:MapSwift.RelativeNodePosition) -> MapSwift.ConnectionJoinPositions {
            let postFixesH = postFixes + [pos.rawValue, "h"] 
            let postFixesV = postFixes + [pos.rawValue, "v"]
            let defaultPostFixesH = NodeAttribute.ConnectionsDefaultH.postFixes
            let defaultPostFixesV = NodeAttribute.ConnectionsDefaultV.postFixes
            var hString = ""
            var vString = ""

            for (style) in optionsFromStyle(styles) {
                if hString == "" {
                    if let val = self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: [style], keyPostFixes: postFixesH) as? String {
                        hString = val
                    } else if let val = self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: [style],
                        keyPostFixes: defaultPostFixesH) as? String {
                        hString = val
                    }
                }
                if vString == "" {
                    if let val = self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: [style], keyPostFixes: postFixesV) as? String {
                        vString = val
                    } else if let val = self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: [style], keyPostFixes: defaultPostFixesV) as? String {
                        vString = val
                    }
                }
            }

            return MapSwift.ConnectionJoinPositions(h: MapSwift.ConnectionJoinPosition.parse(hString), v: MapSwift.ConnectionJoinPosition.parse(vString))
        }
        func calcConnectionToJoinPosition(styles:[String]) -> MapSwift.ConnectionJoinPositions {
            let fallback = "center"
            let defaultPostFixesH = NodeAttribute.ConnectionsDefaultH.postFixes
            let defaultPostFixesV = NodeAttribute.ConnectionsDefaultV.postFixes
            let postFixesH = NodeAttribute.ConnectionsToH.postFixes
            let postFixesV = NodeAttribute.ConnectionsToV.postFixes
            var hString = ""
            var vString = ""
            for (style) in optionsFromStyle(styles) {
                if hString == "" {
                    if let val = self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: [style], keyPostFixes: postFixesH) as? String {
                        hString = val
                    } else if let val = self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: [style],
                        keyPostFixes: defaultPostFixesH) as? String {
                            hString = val
                    }

                }
                if vString == "" {
                    if let val = self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: [style], keyPostFixes: postFixesV) as? String {
                        vString = val
                    } else if let val = self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: [style], keyPostFixes: defaultPostFixesV) as? String {
                        vString = val
                    }
                }
            }
            if hString == "" {
                hString = fallback
            }
            if vString == "" {
                vString = fallback
            }
            return MapSwift.ConnectionJoinPositions(h: MapSwift.ConnectionJoinPosition.parse(hString), v: MapSwift.ConnectionJoinPosition.parse(vString))

        }
        let options = optionsFromStyle(styles)
        let postFixesFrom = NodeAttribute.ConnectionsFrom.postFixes
        let fromAbove = calcConnectionJoinPositions(options, postFixes:postFixesFrom, pos: .Above);
        let fromBelow = calcConnectionJoinPositions(options, postFixes:postFixesFrom, pos: .Below);
        let fromHorizontal = calcConnectionJoinPositions(options, postFixes:postFixesFrom, pos: .Horizontal);
        let from = MapSwift.ConnectionJoinsFrom(above:fromAbove, below:fromBelow, horizontal:fromHorizontal)
        let to = calcConnectionToJoinPosition(styles)

        let style = self.nodeAttribute(.ConnectionsStyle, styles: styles, fallback: "")
        let lineWidth:CGFloat = connectAttribute(.LineWidth, styles: [style], fallback: 1.0)
        let lineColorHex:String = connectAttribute(.LineColor, styles: [style], fallback: "#4F4F4F")
        let lineColor = UIColor(hexString: lineColorHex)
        let lineStyle = MapSwift.LineStyle(color:lineColor, width:lineWidth)
        let connectionStyle = MapSwift.ConnectionStyle(from:from, to:to, style:style, lineStyle: lineStyle)
        cache.cacheItemForKey(connectionStyle, key: cacheKey)
        return connectionStyle

    }
    func nodeShadowStyle(styles:[String]) -> MapSwift.ShadowStyle {
        let cacheKey = cacheKeyForStyles("nodeShadowStyle", styles: styles)
        if let cached:MapSwift.ShadowStyle = cache.itemForKey(cacheKey) {
            return cached
        }
        let color:String = nodeAttribute(.ShadowColor, styles: styles, fallback: "#070707")
        let opacity:Float = nodeAttribute(.ShadowOpacity, styles: styles, fallback: 0.4)
        let offsetWidth:CGFloat = nodeAttribute(.ShadowOffsetWidth, styles: styles, fallback: 2)
        let offsetHeight:CGFloat = nodeAttribute(.ShadowOffsetHeight, styles: styles, fallback: 2)
        let offset = CGSizeMake(offsetWidth, offsetHeight)
        let radius:CGFloat = nodeAttribute(.ShadowRadius, styles: styles, fallback: 2)
        let style = MapSwift.ShadowStyle(color:UIColor.fromMapSwiftTheme(color), opacity:opacity, offset:offset, radius:radius)
        cache.cacheItemForKey(style, key: cacheKey)
        return style

    }

    func nodeStyle(styles:[String]) -> MapSwift.NodeStyle {
        let cacheKey = cacheKeyForStyles("nodeStyle", styles: styles)
        if let cached:MapSwift.NodeStyle = cache.itemForKey(cacheKey) {
            return cached
        }
        let cornerRadius:CGFloat = nodeAttribute(.CornerRadius, styles: styles, fallback: 10.0)
        let backgroundColorHex:String = nodeAttribute(.BackgroundColor, styles: styles, fallback: "#E0E0E0")
        let activatedColorHex:String = nodeAttribute(.ActivatedColor, styles: styles, fallback: "#22AAE0")

        let style = MapSwift.NodeStyle(cornerRadius: cornerRadius, backgroundColor: UIColor.fromMapSwiftTheme( backgroundColorHex), activatedColor: UIColor.fromMapSwiftTheme(activatedColorHex), borderStyle: nodeBorderStyle(styles), shadow: nodeShadowStyle(styles), text: nodeTextStyle(styles))
        cache.cacheItemForKey(style, key: cacheKey)
        return style
    }

//MARK: - Connector styling
    public enum ConnectorAttribute:String {
        case
        CurveType = "type",
        LineColor = "line:color",
        LineWidth = "line:width",
        ControlPoint = "controlPoint"

        static let Prefixes = ["connector"]

        var postFixes:[String] {
            get {
                return self.rawValue.componentsSeparatedByString(":")
            }
        }
    }


    private func connectorAttribute(attribute:ConnectorAttribute, styles:[String]) -> AnyObject? {
        return self.themeDictionary.valueForKeyWithOptions(ConnectorAttribute.Prefixes, keyOptions: optionsFromStyle(styles), keyPostFixes: attribute.postFixes)
    }

    private func connectAttribute<T>(attribute:ConnectorAttribute, styles:[String], fallback:T) -> T {
        if let val =  self.connectorAttribute(attribute, styles: styles) as? T {
            return val
        }
        return fallback
    }

    public func connectorCurveTypeForStyles(styles:[String]) -> String {
        let cacheKey = cacheKeyForStyles("connectorCurveTypeForStyles", styles: styles)
        if let cached:String = cache.itemForKey(cacheKey) {
            return cached
        }
        let curveType:String = connectAttribute(.CurveType, styles: styles, fallback: "quadratic")
        cache.cacheItemForKey(curveType, key: cacheKey)
        return curveType
    }

    public func controlPointForStylesAndPosition(styles:[String], position:MapSwift.RelativeNodePosition) -> CGSize {
        let cacheKey = cacheKeyForStyles("controlPointsForStylesAndPosition:\(position.rawValue)", styles: styles)
        if let cached:MapSwift.ControlPoint = cache.itemForKey(cacheKey) {
            return cached.point
        }

        var postFixes = ConnectorAttribute.ControlPoint.postFixes
        postFixes.append(position.rawValue)

        var parsedPoint = CGSizeMake(0, 1)
        if let controlPoint = self.themeDictionary.valueForKeyWithOptions(ConnectorAttribute.Prefixes, keyOptions: optionsFromStyle(styles), keyPostFixes: postFixes) as? NSDictionary {
            if let width = controlPoint["width"] as? CGFloat, height = controlPoint["height"] as? CGFloat {
                parsedPoint = CGSizeMake(width, height)
            }

        }
        cache.cacheItemForKey(MapSwift.ControlPoint(point:parsedPoint), key: cacheKey)
        return parsedPoint
    }
}
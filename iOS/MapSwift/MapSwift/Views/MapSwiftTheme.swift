//
//  MapSwiftTheme.swift
//  MapSwift
//
//  Created by David de Florinier on 12/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation
extension CGRect {
    func mapswift_relativePositionOfPoint(to:CGPoint, tolerance:CGFloat = 10) -> MapSwiftTheme.RelativeNodePosition {
        if to.y > self.maxY + tolerance {
            return MapSwiftTheme.RelativeNodePosition.Below
        }
        if to.y < self.minY - tolerance {
            return MapSwiftTheme.RelativeNodePosition.Above
        }
        return MapSwiftTheme.RelativeNodePosition.Horizontal
    }
}


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
//MARK: - general styling tuples
    public typealias LineStyle = (color:UIColor, width:CGFloat)
    public typealias BorderStyle = (type:BorderType, line:LineStyle, inset:CGFloat)
    public typealias ShadowStyle = (color:UIColor, opacity:Float, offset:CGSize, radius:CGFloat)
    public typealias FontStyle = (size:CGFloat, weight:CGFloat)
    public typealias TextStyle = (font:FontStyle, alignment:NSTextAlignment, color:UIColor, lineSpacing:CGFloat, margin:CGFloat)
    public typealias ConnectionJoinPositions = (h:ConnectionJoinPosition, v:ConnectionJoinPosition)
    public typealias ConnectionJoinsFrom = (above:ConnectionJoinPositions, below:ConnectionJoinPositions, horizontal:ConnectionJoinPositions)
    public typealias ConnectionStyle = (from:ConnectionJoinsFrom, to:ConnectionJoinPositions, style:String?)
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
        let borderStyle:BorderStyle
        let shadow:ShadowStyle
        let text:TextStyle
    }

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
        TextLineSpacing = "text:lineSpacing",
        TextMargin = "text:margin",
        FontSize = "text:font:size",
        FontWeight = "text:font:weight",
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
    
    func nodeFontStyle(styles:[String]) -> FontStyle {
        let size:CGFloat = nodeAttribute(.FontSize, styles: styles, fallback: 12)
        let weightDescription = nodeAttribute(.FontWeight, styles: styles, fallback: "regular")
        let weight = CGFloat.mapswift_parseFontWeight(weightDescription)
        return FontStyle(size:size, weight:weight)
    }

    func nodeBorderStyle(styles:[String]) -> BorderStyle {
        let color:String = nodeAttribute(.BorderColor, styles:styles, fallback: "#707070")
        let width:CGFloat = nodeAttribute(.BorderWidth, styles: styles, fallback: 1.0)
        let typeName = nodeAttribute(.BorderType, styles: styles, fallback: "")
        var inset = width
        let type = BorderType.parse(typeName)
        if type == BorderType.None {
            inset = 0
        }
        return BorderStyle(type: type, line:LineStyle(color:UIColor.fromMapSwiftTheme(color), width:width), inset:inset)
    }

    func nodeTextStyle(styles:[String]) -> TextStyle {
        let font = self.nodeFontStyle(styles)
        let color = nodeAttribute(.TextColor, styles: styles, fallback: "#4F4F4F")
        let alignmentDescription = nodeAttribute(.TextAlignment, styles: styles, fallback: "center")
        let lineSpacing:CGFloat = nodeAttribute(.TextLineSpacing, styles: styles, fallback: 3.0)
        let margin:CGFloat = nodeAttribute(.TextMargin, styles: styles, fallback: 10.0)
        return TextStyle(font:font, alignment:NSTextAlignment.mapswift_parseThemeAlignment(alignmentDescription), color:UIColor.fromMapSwiftTheme(color), lineSpacing:lineSpacing, margin: margin)
    }

    func nodeConnectionStyle(styles:[String]) -> ConnectionStyle {
        func calcConnectionJoinPositions(styles:[String], postFixes:[String], pos:RelativeNodePosition) -> ConnectionJoinPositions {
            let postFixesH = postFixes + [pos.rawValue, "h"]
            let postFixesV = postFixes + [pos.rawValue, "v"]
            var hString = ""
            var vString = ""
            if let val = self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: styles, keyPostFixes: postFixesH) as? String {
                hString = val
            }
            if let val = self.themeDictionary.valueForKeyWithOptions(NodeAttribute.Prefixes, keyOptions: styles, keyPostFixes: postFixesV) as? String {
                vString = val
            }
            return ConnectionJoinPositions(h: ConnectionJoinPosition.parse(hString), v: ConnectionJoinPosition.parse(vString))
        }
        let options = optionsFromStyle(styles)
        let postFixesFrom = NodeAttribute.ConnectionsFrom.postFixes
        let fromAbove = calcConnectionJoinPositions(options, postFixes:postFixesFrom, pos: .Above);
        let fromBelow = calcConnectionJoinPositions(options, postFixes:postFixesFrom, pos: .Below);
        let fromHorizontal = calcConnectionJoinPositions(options, postFixes:postFixesFrom, pos: .Horizontal);
        let from = ConnectionJoinsFrom(above:fromAbove, below:fromBelow, horizontal:fromHorizontal)
        let toH = self.nodeAttribute(.ConnectionsToH, styles: styles, fallback: "center");
        let toV = self.nodeAttribute(.ConnectionsToV, styles: styles, fallback: "center");
        let to = ConnectionJoinPositions(h: ConnectionJoinPosition.parse(toH), v: ConnectionJoinPosition.parse(toV))
        let style = self.nodeAttribute(.ConnectionsStyle, styles: styles, fallback: "")
        return ConnectionStyle(from:from, to:to, style:style)
    }
    func nodeShadowStyle(styles:[String]) -> ShadowStyle {
        let color:String = nodeAttribute(.ShadowColor, styles: styles, fallback: "#070707")
        let opacity:Float = nodeAttribute(.ShadowOpacity, styles: styles, fallback: 0.4)
        let offsetWidth:CGFloat = nodeAttribute(.ShadowOffsetWidth, styles: styles, fallback: 2)
        let offsetHeight:CGFloat = nodeAttribute(.ShadowOffsetHeight, styles: styles, fallback: 2)
        let offset = CGSizeMake(offsetWidth, offsetHeight)
        let radius:CGFloat = nodeAttribute(.ShadowRadius, styles: styles, fallback: 2)
        return ShadowStyle(color:UIColor.fromMapSwiftTheme(color), opacity:opacity, offset:offset, radius:radius)
    }

    func nodeStyle(styles:[String]) -> NodeStyle {
        let cornerRadius:CGFloat = nodeAttribute(.CornerRadius, styles: styles, fallback: 10.0)
        let backgroundColorHex:String = nodeAttribute(.BackgroundColor, styles: styles, fallback: "#E0E0E0")
        let activatedColorHex:String = nodeAttribute(.ActivatedColor, styles: styles, fallback: "#22AAE0")

        return NodeStyle(cornerRadius: cornerRadius, backgroundColor: UIColor.fromMapSwiftTheme( backgroundColorHex), activatedColor: UIColor.fromMapSwiftTheme(activatedColorHex), borderStyle: nodeBorderStyle(styles), shadow: nodeShadowStyle(styles), text: nodeTextStyle(styles))
    }

//MARK: - Connector styling
    public enum ConnectorAttribute:String {
        case
        LineColor = "line:color",
        LineWidth = "line:width",
        ControlPoints = "controlPoints"

        static let Prefixes = ["connector"]

        var postFixes:[String] {
            get {
                return self.rawValue.componentsSeparatedByString(":")
            }
        }
    }

    public enum RelativeNodePosition:String {
        case Above = "above", Below = "below", Horizontal = "horizontal"
        static var allValues:[RelativeNodePosition] {
            return [.Above, .Below, .Horizontal]
        }
    }

    func connectorAttribute(attribute:ConnectorAttribute, styles:[String]) -> AnyObject? {
        return self.themeDictionary.valueForKeyWithOptions(ConnectorAttribute.Prefixes, keyOptions: optionsFromStyle(styles), keyPostFixes: attribute.postFixes)
    }

    func connectAttribute<T>(attribute:ConnectorAttribute, styles:[String], fallback:T) -> T {
        if let val =  self.connectorAttribute(attribute, styles: styles) as? T {
            return val
        }
        return fallback
    }

    public func controlPointsForStylesAndPosition(styles:[String], position:RelativeNodePosition) -> [CGSize] {
        var postFixes = ConnectorAttribute.ControlPoints.postFixes
        postFixes.append(position.rawValue)
        var parsedPoints:[CGSize] = []
        if let controlPoints = self.themeDictionary.valueForKeyWithOptions(ConnectorAttribute.Prefixes, keyOptions: optionsFromStyle(styles), keyPostFixes: postFixes) as? NSArray {
            for item in controlPoints {
                if let controlPoint = item as? NSDictionary, width = controlPoint["width"] as? CGFloat, height = controlPoint["height"] as? CGFloat {
                    parsedPoints.append(CGSizeMake(width, height))
                }
            }
        }
        return parsedPoints
    }
}
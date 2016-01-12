//
//  MapSwiftResources.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

public class MapSwiftResources {
    let JavascriptTrueFuncCall = "\n(function () {return true;})();\n"
    class var sharedInstance : MapSwiftResources {
        struct Static {
            static let instance:MapSwiftResources = MapSwiftResources()
        }
        return Static.instance
    }

    private var bundle:NSBundle {
        get {
            return NSBundle(forClass: MapSwiftResources.self)
        }
    }
    public func containerHTMLURL() -> NSURL {
        let url = bundle.URLForResource("mapswift-ios", withExtension: "html")!
        return url
    }

    public var containerLibrary:String? {
        get {
            let url = bundle.URLForResource("map-swift-editor", withExtension: "js")!
            if let content = url.mapswift_fileContent {
                return content + JavascriptTrueFuncCall
            }
            return nil
        }
    }

    public var defaultThemeURL:NSURL {
        let url = bundle.URLForResource("default-theme", withExtension: "json")!
        return url

    }
}

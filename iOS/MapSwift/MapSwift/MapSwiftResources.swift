//
//  MapSwiftResources.swift
//  MapSwift
//
//  Created by David de Florinier on 07/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

public class MapSwiftResources {
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
            return url.mapswift_fileContent
        }
    }
}

//
//  MapSwiftStubResources.swift
//  MapSwift
//
//  Created by David de Florinier on 15/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
@testable import MapSwift
class MapSwiftStubResources: MapSwiftResources {
    var stubContainerHTMLURL = NSURL(string: "https://www.mindmup.com")
    override func containerHTMLURL() -> NSURL {
        return stubContainerHTMLURL!
    }

    var stubContainerLibrary = "hello lib"
    override var containerLibrary:String? {
        get {
            return "hello lib"
        }
    }
}

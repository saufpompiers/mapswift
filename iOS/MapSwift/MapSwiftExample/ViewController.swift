//
//  ViewController.swift
//  MapSwiftExample
//
//  Created by David de Florinier on 02/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import MapSwift

class ViewController: UIViewController, MapSwiftProxyProtocolDelegate {
    var mapSwift:MapSwiftCore?
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapSwift = MapSwiftCore()
        mapSwift.delegate = self
        self.mapSwift = mapSwift
        mapSwift.start()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - MapSwiftProxyProtocolDelegate
    func proxyDidChangeStatus(status: MapSwiftProxyStatus) {
        print("proxyDidChangeStatus:\(status)")
        if status == MapSwiftProxyStatus.Ready {
            if let mapSwift = self.mapSwift  {
                if let components = mapSwift.components {
                    components.pingModel.echo("hello")
                }
            }
        }
    }
    func proxyDidRecieveError(error: NSError) {
        print("proxyDidRecieveError:\(error.localizedDescription)")
    }
}


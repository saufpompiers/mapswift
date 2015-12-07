//
//  ViewController.swift
//  MapSwiftExample
//
//  Created by David de Florinier on 02/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import MapSwift

class ViewController: UIViewController {
    var mapSwift:MapSwiftCore?
    var mapSwiftComponents:MapSwiftComponents?
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapSwift = MapSwiftCore()
        self.mapSwift = mapSwift
        mapSwift.loadComponents { (components, error) -> () in
            self.mapSwiftComponents = components;
            if let error = error {
                print("mapSwift.loadComponents error:\(error.localizedDescription)")
            }
            if let components = self.mapSwiftComponents {
                components.pingModel.echo("hello")
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


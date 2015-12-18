//
//  ViewController.swift
//  MapSwiftExample
//
//  Created by David de Florinier on 02/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit
import MapSwift

class ViewController: UIViewController, MapSwiftProxyProtocolDelegate, MapSwiftPingModelDelegate {
    var mapSwift:MapSwiftCore?
    var pingCount = 0
    var components:MapSwiftComponents?

    let errorPrinter = { (error:NSError) in
        print("error:\(error)")
    }
    func donePrinter(selector:String) -> (()->()) {
        return {
            print("\(selector) done");
        }
    }
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
    private func sendEcho() {
        if let components = components {
            components.pingModel.delegate = self;
            components.pingModel.echo("echo", then: { response  in
                print("\(response.description)")
                components.pingModel.start("pingTest", interval:5, then:self.donePrinter("pingModel.start"), fail:self.errorPrinter)
                }, fail: errorPrinter)
        }

    }
    //MARK: - MapSwiftProxyProtocolDelegate
    func proxyDidChangeStatus(status: MapSwiftProxyStatus) {
        print("proxyDidChangeStatus:\(status)")
        if status == MapSwiftProxyStatus.Ready {
            if let mapSwift = self.mapSwift {
                do {
                components = try mapSwift.components()
                } catch let error as NSError {
                    print("error generating components:\(error.localizedDescription)")
                }
            }

            self.sendEcho()
        }
    }
    func proxyDidRecieveError(error: NSError) {
        print("proxyDidRecieveError:\(error.localizedDescription)")
    }

    func proxyDidSendLog(args: [AnyObject]) {
        print("proxyDidSendLog:\(args)")
    }

    //MARK: - MapSwiftPingModelDelegate 
    func ping(identifier: String, sent: NSDate) {
        let latency = (sent.timeIntervalSinceNow * -1).mapswift_JSTimeInterval
        print("\(identifier) latency:\(latency)ms");
        pingCount++
        if pingCount > 4 {
            if let components = components {
                components.pingModel.stop(self.donePrinter("pingModel.stop"), fail: self.errorPrinter);
            }
        }
    }
}


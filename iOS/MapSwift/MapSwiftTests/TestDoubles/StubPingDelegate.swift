//
//  StubPingDelegate.swift
//  MapSwift
//
//  Created by David de Florinier on 21/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation
import MapSwift

class StubPingDelegate : MapSwiftPingModelDelegate {
    typealias PingCall = (identifier:String, sent:NSDate)
    var pingCalls:[PingCall] = []
    var listener:(PingCall -> ())?
    func ping(identifier:String, sent:NSDate) {
        pingCalls.append((identifier: identifier, sent: sent))
        if let listener = listener {
            listener(identifier:identifier, sent:sent)
        }
    }
}
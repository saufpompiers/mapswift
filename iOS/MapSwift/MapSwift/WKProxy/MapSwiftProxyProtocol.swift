//
//  MapSwiftProxyProtocol.swift
//  MapSwift
//
//  Created by David de Florinier on 11/12/2015.
//  Copyright © 2015 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

public typealias MapSwiftProxyEventHandler = ((eventName:String, args:[AnyObject])->())

public protocol MapSwiftProxyProtocolDelegate:class {
    func proxyDidChangeStatus(status:MapSwiftProxyStatus)
    func proxyDidSendLog(args:[AnyObject])
    func proxyDidRecieveError(error:NSError)
}

public enum MapSwiftProxyStatus { case NotInitialised, LoadingPage, LoadingLibraries, ExecutingMain, LoadingError, Ready}

public protocol MapSwiftProxyProtocol:class {
    var delegate:MapSwiftProxyProtocolDelegate? {get set}
    var isReady:Bool {get}
    func sendCommand(componentId:String, selector:String, args:[AnyObject], then:((response:MapSwiftProxyResponse?, error:NSError?)->()))
    func addProxyListener(componentId:String, callBack:MapSwiftProxyEventHandler) throws
    func start()
}

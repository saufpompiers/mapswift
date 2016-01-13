//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var data:NSData?
var args:[AnyObject] = ["hello",  NSNull(), 1, true]
do {
    data  = try NSJSONSerialization.dataWithJSONObject(args, options: NSJSONWritingOptions(rawValue: 0))
}

if let data = data {
    let s = NSString(data: data, encoding: NSUTF8StringEncoding);
    let command = "containerProxies.pingModel.sentFromSwift()"
}


let s = "cornerRadius,back"

s.componentsSeparatedByString(",")





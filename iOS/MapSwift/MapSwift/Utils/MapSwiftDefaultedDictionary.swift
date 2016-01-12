//
//  MapSwiftJSONFile.swift
//  MapSwift
//
//  Created by David de Florinier on 12/01/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation


extension NSDictionary {
    func mapswift_valueForKeys(keys:[String]) -> AnyObject? {
        if let key = keys.first {
            var remainingKeys = keys
            remainingKeys.removeFirst()
            let val = self.valueForKey(key)
            if let valDictionary = val as? NSDictionary where remainingKeys.count > 0 {
                return valDictionary.mapswift_valueForKeys(remainingKeys)
            } else {
                return val
            }
        }
        return nil
    }
}
class MapSwiftDefaultedDictionary {
    let dictionary:NSDictionary
    init(dictionary:NSDictionary)  {
        self.dictionary = dictionary
    }
    func valueForKey(keys:String...) -> AnyObject? {
        return self.dictionary.mapswift_valueForKeys(keys)
    }
    func valueForKeyWithOptions(keyPrefixes:[String], keyOptions:[String], keyPostFixes:[String]?) -> AnyObject? {

        for keyOption in keyOptions {
            var keys = keyPrefixes
            keys.append(keyOption)
            if let post = keyPostFixes {
                keys.appendContentsOf(post)
            }
            if let keyVal = self.dictionary.mapswift_valueForKeys(keys) {
                return keyVal
            }
        }
        return nil
    }
}
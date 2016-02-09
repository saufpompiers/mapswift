//
//  MapSwiftCache.swift
//  MapSwift
//
//  Created by David de Florinier on 09/02/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

class MapSwiftCaches {

    class var sharedInstance : MapSwiftCaches {
        struct Static {
            static let instance:MapSwiftCaches = MapSwiftCaches()
        }
        return Static.instance
    }
    private var caches:[String:MapSwiftCache] = [:]
    class func forName(name:String) -> MapSwiftCache {
        return MapSwiftCaches.sharedInstance.forName(name);
    }

    func forName(name:String) -> MapSwiftCache {
        if let cache = caches[name] {
            return cache
        }
        let cache = MapSwiftCache()
        caches[name] = cache
        return cache
    }

    func clean() {
        caches.forEach { (key:String, cache:MapSwiftCache) -> () in
            cache.clean()
        }
        caches.removeAll()
    }
}


class MapSwiftCache {
    private var cache:[String:AnyObject] = [:]
    func cacheItemForKey(item:AnyObject?, key:String) {
        if let item = item {
            cache[key] = item
        } else {
            cache.removeValueForKey(key);
        }
    }

    func itemForKey<T>(key:String) -> T? {
        return cache[key] as? T
    }

    func clean() {
        cache.removeAll()
    }
}
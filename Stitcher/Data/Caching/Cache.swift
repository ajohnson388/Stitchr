//
//  Cache.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

class Cache {
    
    static let shared = Cache()
    
    var isUserAuthorized: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Key.isUserAuthorized.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.isUserAuthorized.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    var userId: String? {
        get {
            return UserDefaults.standard.string(forKey: Key.userId.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.userId.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    private init() {}
    
    enum Key: String {
        case isUserAuthorized
        case userId
    }
}

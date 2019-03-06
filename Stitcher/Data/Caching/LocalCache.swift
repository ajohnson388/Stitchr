//
//  LocalCache.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/29/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

/**
    An implementation of the Cache module that uses the PList.
 */
final class LocalCache: Cache {
    
    // MARK: - Properties
    
    weak var delegate: CacheDelegate?
    
    var userCredentials: TokenStore?  {
        get {
            let data = UserDefaults.standard.data(forKey: Key.userCredentials.rawValue)
            return TokenStore.decode(data: data)
        }
        set {
            UserDefaults.standard.set(newValue.encode(), forKey: Key.userCredentials.rawValue)
            UserDefaults.standard.synchronize()
            delegate?.userCredentialsDidChange(newValue)
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
    
    func clear() {
        for key in Key.allCases {
            UserDefaults.standard.set(nil, forKey: key.rawValue)
        }
        UserDefaults.standard.synchronize()
    }
    
    
    // MARK: - Lifecycle
    
    init(delegate: CacheDelegate? = nil) {
        self.delegate = delegate
    }
    
    
    // MARK: - Associated Types
    
    enum Key: String, CaseIterable {
        case userId
        case userCredentials
    }
}

//
//  LocalCache.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/29/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import OAuthSwift

/**
    An implementation of the Cache module that uses the PList.
 */
final class LocalCache: Cache {
    
    // MARK: - Properties
    
    weak var delegate: CacheDelegate?
    
    var isUserAuthorized: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Key.isUserAuthorized.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.isUserAuthorized.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    var userCredentials: OAuthSwiftCredential?  {
        get {
            let data = UserDefaults.standard.data(forKey: Key.userCredentials.rawValue)
            return OAuthSwiftCredential.decode(data: data)
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
    
    
    // MARK: - Lifecycle
    
    init(delegate: CacheDelegate? = nil) {
        self.delegate = delegate
    }
    
    
    // MARK: - Associated Types
    
    enum Key: String {
        case isUserAuthorized
        case userId
        case userCredentials
    }
}

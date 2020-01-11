//
//  MockCache.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/2/20.
//  Copyright © 2020 Meaningless. All rights reserved.
//

import Foundation

class MockCache: Cache {
    
    var delegate: CacheDelegate?
    
    var userCredentials: TokenStore? {
        didSet {
            delegate?.userCredentialsDidChange(userCredentials)
        }
    }
    
    var userId: String? = MockFactory.shared.userProfile.id
    
    
    
    func clear() {
        
    }
}

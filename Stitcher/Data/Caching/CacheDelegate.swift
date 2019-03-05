//
//  CacheDelegate.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/29/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

/**
    A listener for observing changes in the cache.
 */
protocol CacheDelegate: class {
    func userCredentialsDidChange(_ credentials: TokenStore?)
}

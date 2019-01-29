//
//  Cache.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import OAuthSwift

/**
    A service for caching data locally.
 */
protocol Cache: class {
    
    /**
        A listener for observing changes in the cached data.
     */
    var delegate: CacheDelegate? { get set }
    
    /**
        True, if the user has authorized the app for Spotify.
     */
    var isUserAuthorized: Bool { get set }
    
    /**
        The credentials used for OAuth.
     */
    var userCredentials: OAuthSwiftCredential? { get set }
    
    /**
        The user's Spotify id.
     */
    var userId: String? { get set }
}

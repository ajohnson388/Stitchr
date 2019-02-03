//
//  BuildConfig.swift
//  Stitcher
//
//  Created by Andrew Johnson on 2/3/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

struct BuildConfig {
    
    static var spotifyClientId = getString(.clientId)
    static var spotifyClientSecret = getString(.clientSecret)
    
    private static func getString(_ key: Key) -> String {
        guard let string = Bundle.main.infoDictionary?[key.rawValue] as? String else {
            Logger.log("Failed to get value for config key: \(key.rawValue)")
            return ""
        }
        return string.replacingOccurrences(of: "\\", with: "")
    }
    
    private enum Key: String {
        case clientId = "Spotify Client Id"
        case clientSecret = "Spotify Consumer Secret"
    }
}

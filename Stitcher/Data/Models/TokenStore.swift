//
//  TokenStore.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

struct TokenStore: Codable {
    
    var accessToken: String?
    var refreshToken: String?
    var expirationDate: Date?
    
    init() {}
    
    var isExpired: Bool {
        guard let expirationDate = expirationDate else {
            return false
        }
        return expirationDate > Date()
    }
}

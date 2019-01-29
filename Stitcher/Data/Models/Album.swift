//
//  Album.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/25/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

struct Album: Codable, Equatable {
    let albumType: String
    let artists: [AddedBy]
    let availableMarkets: [String]
    let externalUrls: ExternalUrls
    let href: String
    let id: String
    let images: [Image]
    let name: String
    let type: String
    let uri: String
}

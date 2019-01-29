//
//  Track.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/25/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

struct Track: Codable, Equatable {
    let album: Album
    let artists: [AddedBy]
    let availableMarkets: [String]
    let discNumber: Int
    let durationMs: Int
    let explicit: Bool
    let externalIds: ExternalIDS
    let externalUrls: ExternalUrls
    let href: String
    let id: String
    let name: String
    let popularity: Int
    let previewUrl: String?
    let trackNumber: Int
    let type: String
    let uri: String
}

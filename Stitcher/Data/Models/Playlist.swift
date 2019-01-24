//
//  Playlist.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

struct Playlist: Codable {
    let collaborative: Bool
    let externalUrls: ExternalUrls
    let href: String
    let id: String
    let images: [Image]
    let name: String
    let owner: Owner
    let itemPublic: Bool
    let snapshotID: String
    let tracks: Tracks
    let type, uri: String
}

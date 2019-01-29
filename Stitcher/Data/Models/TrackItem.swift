//
//  TrackItem.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/25/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

struct TrackItem: Codable, Equatable {
    let addedAt: Date
    let addedBy: AddedBy
    let isLocal: Bool
    let track: Track?
}

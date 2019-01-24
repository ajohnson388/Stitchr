//
//  PagingResponse.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

struct PagingResponse: Codable {
    let href: String
    let items: [Playlist]
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
}

//
//  SearchResponse.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/25/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

struct SearchResponse: Codable {
    let tracks: PagingResponse<Track>
}

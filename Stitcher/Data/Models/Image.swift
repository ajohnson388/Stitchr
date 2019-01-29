//
//  Image.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

struct Image: Codable, Equatable {
    let height: Int?
    let width: Int?
    let url: String
}

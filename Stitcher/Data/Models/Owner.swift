//
//  Owner.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

struct Owner: Codable {
    let externalUrls: ExternalUrls
    let href: String?
    let id: String
    let type: String
    let uri: String
}

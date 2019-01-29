//
//  Collection+Count.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/28/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

extension Collection {
    
    func count(`where`: (Element) -> Bool) -> Int {
        var count = 0
        for item in self {
            if `where`(item) {
                count += 1
            }
        }
        return count
    }
}

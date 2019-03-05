//
//  Collection+Count.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/28/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

extension Collection {
    
    /// Computes the count of a collection under a condition.
    ///
    /// - Parameter `where`: A callback to check the condition of the element in a collection.
    ///                      Returns true if the element meets the criteria.
    /// - Returns: The count of the collection under the given condition.
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

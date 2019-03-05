//
//  String+Attributed.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/29/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

extension String {
    
    /// Converts a `String` into an `NSAttributedString`.
    var attributed: NSAttributedString {
        return NSAttributedString(string: self)
    }
}

//
//  Logger.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation   

struct Logger {
    
    
    /// A wrapper around the print statement that only emits for DEBUG builds.
    ///
    /// - Parameter items: The items to log to the console.
    static func log(_ items: Any...) {
        #if DEBUG
            print(items)
        #endif
    }
}

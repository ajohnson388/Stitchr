//
//  Logger.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation   

struct Logger {
    
    static func log(_ items: Any...) {
        #if DEBUG
            print(items)
        #endif
    }
}

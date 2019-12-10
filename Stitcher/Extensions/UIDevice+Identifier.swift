//
//  UIDevice+Identifier.swift
//  Stitcher
//
//  Created by Andrew Johnson on 6/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

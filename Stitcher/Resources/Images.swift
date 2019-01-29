//
//  Images.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/29/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

enum Images: String {
    case add = "AddIcon"
    case delete = "DeleteIcon"
    case imagePlaceholder = "PlaceholderPhoto"
    case stitcherLogo = "StitcherLogo"
    
    func make() -> UIImage {
        return UIImage(named: rawValue)!
    }
}

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
    case spotifyLogo = "SpotifyLogo"
    case editIcon = "EditIcon"
    
    func make() -> UIImage {
        return UIImage(named: rawValue)!
    }
    
    static var loadingImage: UIImage {
        let indices = [1, 2, 3, 2]
        let images = indices.compactMap { UIImage(named: "LoadingIcon\($0)") }
        return UIImage.animatedImage(with: images, duration: 0.5)!
    }
}

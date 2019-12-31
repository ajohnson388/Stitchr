//
//  UITableViewCell+Convenience.swift
//  Stitcher
//
//  Created by Andrew Johnson on 12/26/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import Nuke
import SkeletonView

extension UITableViewCell {
    
    func setImage(urlString: String?) {
        guard let imageView = (self as? FixedImageTableViewCell)?.fixedImageView else {
            return
        }
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            imageView.image = Images.imagePlaceholder.make()
            return
        }
        
        imageView.isSkeletonable = true
        imageView.showAnimatedSkeleton()
        let options = ImageLoadingOptions(placeholder: Images.imagePlaceholder.make(),
                                          transition: .none,
                                          failureImage: Images.imagePlaceholder.make(),
                                          failureImageTransition: .none)
        Nuke.loadImage(with: url, options: options, into: imageView, progress: nil) { _ in
            imageView.hideSkeleton()
        }
     }
}

//
//  UITableViewCell+Convenience.swift
//  Stitcher
//
//  Created by Andrew Johnson on 12/26/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UITableViewCell {
    
    func loadImage(_ imageUrlString: String?) {
        let imageUrl = imageUrlString == nil ? nil : try? imageUrlString!.asURL()
        imageView?.sd_setImage(with: imageUrl,
                               placeholderImage: Images.imagePlaceholder.make(),
                               options: [.progressiveDownload, .continueInBackground])
    }
}

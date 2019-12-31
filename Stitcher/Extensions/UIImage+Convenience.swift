//
//  File.swift
//  Stitcher
//
//  Created by Andrew Johnson on 12/30/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func imageWith(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size,false,1.0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        if let resizedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return resizedImage
        }
        UIGraphicsEndImageContext()
        return self
    }
}

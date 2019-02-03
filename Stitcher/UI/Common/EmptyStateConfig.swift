//
//  EmptyStateConfig.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/31/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

struct EmptyStateConfig {
    var state: State?
    var title: NSAttributedString?
    var description: NSAttributedString?
    var image: UIImage?
    var buttonTitle: NSAttributedString?
    
    enum State {
        case loading, error, authenticationChallenge, empty
    }
}

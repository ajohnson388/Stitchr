//
//  UITableView+Convenience.swift
//  Stitcher
//
//  Created by Andrew Johnson on 7/14/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func singleSelect(at indexPath: IndexPath) {
        for path in indexPathsForSelectedRows ?? [] where indexPath != path {
            deselectRow(at: indexPath, animated: false)
        }
    }
}

//
//  SearchTableViewCell.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/28/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import Anchorage

final class SearchTableViewCell: FixedImageTableViewCell {
    
    // MARK: - Properties
    
    private let holderView = UIView(frame: CGRect.null)
    private let countLabel = UILabel(frame: CGRect.null)
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    // MARK: - Initializers
    
    init(reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup
    
    private func setupView() {
        let rect = CGRect(x: 0, y: 0, width: 24, height: 24)
        holderView.frame = rect
        holderView.layer.borderColor = Theme.buttonTextColor.color.cgColor
        holderView.layer.borderWidth = 1
        holderView.layer.cornerRadius = 8
        holderView.layer.backgroundColor = Theme.buttonTextColor.color.cgColor
        accessoryView = holderView
        
        let padding = 1 as CGFloat
        holderView.addSubview(countLabel)
        countLabel.textColor = UIColor.white
        countLabel.leftAnchor == holderView.leftAnchor + padding
        countLabel.rightAnchor == holderView.rightAnchor - padding
        countLabel.topAnchor == holderView.topAnchor - padding
        countLabel.bottomAnchor == holderView.bottomAnchor + padding
        countLabel.textAlignment = .center
    }
    
    func setOccurrences(_ occurrences: Int) {
        countLabel.text = occurrences > 0 ? "\(occurrences)" : nil
        holderView.isHidden = occurrences == 0
    }
    
    func setLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        accessoryView = isLoading ? activityIndicator : holderView
    }
}

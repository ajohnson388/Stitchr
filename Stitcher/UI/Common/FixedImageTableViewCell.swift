//
//  FixedImageTableViewCell.swift
//  Stitcher
//
//  Created by Andrew Johnson on 12/31/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import Anchorage

class FixedImageTableViewCell: UITableViewCell {
    
    private let labelStack = UIStackView(arrangedSubviews: [])
    
    let fixedImageView = UIImageView(image: nil)
    let titleLabel = UILabel(frame: .null)
    let detailLabel = UILabel(frame: .null)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.addSubview(fixedImageView)
        fixedImageView.leadingAnchor == contentView.leadingAnchor + 16
        fixedImageView.centerYAnchor == contentView.centerYAnchor
        fixedImageView.heightAnchor == 40
        fixedImageView.widthAnchor == 40
        fixedImageView.image = Images.imagePlaceholder.make()
        fixedImageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(labelStack)
        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(detailLabel)
        labelStack.axis = .vertical
        labelStack.spacing = 4
        labelStack.centerYAnchor == contentView.centerYAnchor
        labelStack.trailingAnchor <= contentView.trailingAnchor - 8
        labelStack.leadingAnchor == fixedImageView.trailingAnchor + 16
        
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        detailLabel.font = UIFont.systemFont(ofSize: 12)
    }
}

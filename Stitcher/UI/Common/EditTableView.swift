//
//  EditTableView.swift
//  Stitcher
//
//  Created by Andrew Johnson on 2/12/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import Anchorage

protocol EditTableViewDelegate: class {
    func onEditButtonTapped(button: UIButton)
}

final class EditTableView: UIView {
    
    let editButtonView = UIButton(frame: CGRect.null)
    
    weak var delegate: EditTableViewDelegate?
    
    init(width: CGFloat) {
        let rect = CGRect(x: 0, y: 0, width: width, height: 44)
        super.init(frame: rect)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(editButtonView)
        
        let padding = 4 as CGFloat
        editButtonView.topAnchor == topAnchor - padding
        editButtonView.bottomAnchor == bottomAnchor + padding
        editButtonView.leadingAnchor == leadingAnchor + padding
        editButtonView.trailingAnchor == trailingAnchor - padding
        
        editButtonView.setTitle(Strings.playlistReorderButtonTitle.localized, for: .normal)
        editButtonView.setTitleColor(Themes.current.accentColor, for: .normal)
        editButtonView.setTitleColor(Themes.current.accentColor.withAlphaComponent(0.2), for: .highlighted)
        editButtonView.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
    }
    
    @objc
    func onButtonTapped() {
        delegate?.onEditButtonTapped(button: editButtonView)
    }
}

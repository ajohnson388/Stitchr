//
//  EmptyView.swift
//  Stitcher
//
//  Created by Andrew Johnson on 12/16/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import Anchorage

final class EmptyView: UIView {
    
    var title: String? {
        get {
            return titleView.text
        }
        set {
            titleView.text = newValue
            titleView.isHidden = newValue == nil
        }
    }
    
    var subtitle: String? {
        get {
            return subtitleView.text
        }
        set {
            subtitleView.text = newValue
            subtitleView.isHidden = newValue == nil
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.isHidden = newValue == nil
        }
    }
    
    var buttonTitle: String? {
        get {
            return buttonView.title(for: .normal)
        }
        set {
            buttonView.setTitle(newValue, for: .normal)
            buttonView.isHidden = newValue == nil
        }
    }
    
    func setButtonListener(onButtonTapped: @escaping () -> Void) {
        self.buttonListener = onButtonTapped
        let selector = #selector(onButtonTapped(_:))
        if buttonView.target(forAction: selector, withSender: buttonView) != nil {
            buttonView.removeTarget(self, action: selector, for: .touchUpInside)
        }
        buttonView.addTarget(self, action: selector, for: .touchUpInside)
    }
    
    @objc
    func onButtonTapped(_ sender: UIButton) {
        buttonListener?()
    }
    
    private var buttonListener: Optional<() -> Void> = nil
    private let imageView = UIImageView(image: nil)
    private let titleView = UILabel(frame: .null)
    private let subtitleView = UILabel(frame: .null)
    private let buttonView = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        
        titleView.font = UIFont.systemFont(ofSize: 27)
        titleView.textColor = UIColor(white: 0.6, alpha: 1)
        titleView.textAlignment = .center
        titleView.lineBreakMode = .byWordWrapping
        titleView.numberOfLines = 0
        
        subtitleView.font = UIFont.systemFont(ofSize: 17)
        subtitleView.textColor = UIColor(white: 0.6, alpha: 1)
        subtitleView.textAlignment = .center
        subtitleView.lineBreakMode = .byWordWrapping
        subtitleView.numberOfLines = 0
        
        buttonView.contentHorizontalAlignment = .center
        buttonView.contentVerticalAlignment = .center
        buttonView.setTitleColor(Theme.buttonTextColor.color, for: .normal)
        buttonView.setTitleColor(Theme.buttonTextColor.color.withAlphaComponent(0.2), for: .highlighted)
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleView, subtitleView, buttonView])
        addSubview(stackView)
        stackView.centerXAnchor == centerXAnchor
        stackView.centerYAnchor == centerYAnchor
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.widthAnchor == 304
        stackView.spacing = 8
    }
}

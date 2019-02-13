//
//  BaseTableViewController.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/31/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet
import OAuthSwift

class BaseTableViewController<T>: UITableViewController, DZNEmptyDataSetSource,
    DZNEmptyDataSetDelegate, BasePresenterDelegate where T: BasePresenter {
    
    // MARK: - Properties
    
    let presenter: T
    
    init(presenter: T) {
        self.presenter = presenter
        super.init(style: .grouped)
        presenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getEmptyStateConfig() -> EmptyStateConfig? {
        var config = EmptyStateConfig()
        if !presenter.isAuthenticated {
            config.state = .authenticationChallenge
            config.title = Strings.loginRequiredTitle.localized.attributed
            config.description = Strings.loginRequiredDescription.localized.attributed
            config.image = Images.spotifyLogo.make()
            config.buttonTitle = Strings.loginRequiredButtonTitle.localized.attributed
        } else if presenter.isLoading {
            config.state = .loading
            config.image = Images.loadingImage
        } else if let error = presenter.error {
            config.state = .error
            config.title = Strings.errorTitle.localized.attributed
            config.description = error.attributed
            config.buttonTitle = Strings.errorButtonTitle.localized.attributed
        } else {
            return nil
        }
        return config
    }
    
    
    func isUserAuthenticatedDidChange(_ isAuthenticated: Bool) {}
    func isLoadingChanged(_ isLoading: Bool) {}
    
    func errorDidChange(_ error: String?) {
        if error != nil {
            tableView.reloadEmptyDataSet()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delaysContentTouches = false
    }
    
    
    // MARK: - Empty Delegate
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return presenter.isAuthenticated
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        
    }
    
    
    // MARK: - Empty Data Source
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return getEmptyStateConfig()?.title
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return getEmptyStateConfig()?.description
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UITableView.appearance().backgroundColor
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return getEmptyStateConfig()?.image
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        guard let title = getEmptyStateConfig()?.buttonTitle?.string else {
            return nil
        }
        let color = Themes.current.accentColor
        let textColor = [NSAttributedString.Key.foregroundColor: state == .highlighted ? color.withAlphaComponent(0.2) : color]
        return NSAttributedString(string: title, attributes: textColor)
    }
}

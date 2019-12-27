//
//  Theme.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/25/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

enum Theme: String {
    case navigationBarColor = "NavigationBarColor"
    case navigationBarTextColor = "NavigationBarTextColor"
    case navigationBarButtonColor = "NavigationBarButtonColor"
    case tableViewBackgroundColor = "TableViewBackgroundColor"
    case tableViewCellColor = "TableViewCellColor"
    case tableViewTextColor = "TableViewTextColor"
    case buttonTextColor = "ButtonTextColor"
}

extension Theme {
    
    var color: UIColor {
        return UIColor(named: self.rawValue)!
    }
    
    static func apply(navigationItem: UINavigationItem? = nil) {
        Theme.applyButtonAppearance()
        Theme.applyNavigationBarAppearance(navigationItem: navigationItem)
        Theme.applySearchBarAppearance()
        Theme.applyTableViewAppearance()
    }
    
    private static func applyButtonAppearance() {
        UILabel.appearance(whenContainedInInstancesOf: [UIButton.self]).textColor = Theme.buttonTextColor.color
        UIBarButtonItem.appearance().tintColor = Theme.navigationBarButtonColor.color
    }
    
    private static func applySearchBarAppearance() {
        UISearchBar.appearance().barStyle = .black
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes =
            [.foregroundColor: Theme.navigationBarTextColor.color]
    }
    
    private static func applyTableViewAppearance() {
        UITableView.appearance().backgroundColor = Theme.tableViewBackgroundColor.color
        UITableViewCell.appearance().backgroundColor = Theme.tableViewCellColor.color
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor =
            Theme.tableViewTextColor.color
    }
    
    private static func applyNavigationBarAppearance(navigationItem: UINavigationItem? = nil) {
        let appearance = UINavigationBar.appearance()
        let textAttributes = [NSAttributedString.Key.foregroundColor: Theme.navigationBarTextColor.color]
        
        if #available(iOS 13.0, *) {
            let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
            buttonAppearance.normal.titleTextAttributes = [.foregroundColor: Theme.navigationBarButtonColor.color]
            
            let navigationAppearance = UINavigationBarAppearance()
            navigationAppearance.buttonAppearance = buttonAppearance
            navigationAppearance.titleTextAttributes = textAttributes
            navigationAppearance.largeTitleTextAttributes = textAttributes
            navigationAppearance.backgroundColor = Theme.navigationBarColor.color
            
            navigationItem?.standardAppearance = navigationAppearance
            navigationItem?.scrollEdgeAppearance = navigationAppearance
            navigationItem?.compactAppearance = navigationAppearance
            appearance.prefersLargeTitles = true
            
        } else {
            appearance.titleTextAttributes = textAttributes
            appearance.largeTitleTextAttributes = textAttributes
            appearance.prefersLargeTitles = true
            appearance.barTintColor = Theme.navigationBarColor.color
            appearance.tintColor = Theme.navigationBarTextColor.color
            appearance.isTranslucent = false
        }
    }
    
    static func apply(safariViewController: SFSafariViewController) {
        safariViewController.preferredControlTintColor = Theme.navigationBarTextColor.color
        safariViewController.preferredBarTintColor = Theme.navigationBarColor.color
    }
}

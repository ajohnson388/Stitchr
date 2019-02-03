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

protocol Theme {
    var primaryColor: UIColor { get }
    var primaryLightColor: UIColor { get }
    var primaryDarkColor: UIColor { get }
    
    var secondaryColor: UIColor { get }
    var secondaryLightColor: UIColor { get }
    var secondaryDarkColor: UIColor { get }
    
    var ternaryColor: UIColor { get }
    var ternaryLightColor: UIColor { get }
    var ternaryDarkColor: UIColor { get }
    
    var accentColor: UIColor { get }
}

extension Theme {
    
    func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
    func apply() {
        UIBarButtonItem.appearance().tintColor = ternaryLightColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : ternaryLightColor]
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ternaryLightColor]
        UINavigationBar.appearance().prefersLargeTitles = true
        UILabel.appearance().textColor = ternaryLightColor
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = color(109, 109, 114)
        UINavigationBar.appearance().barTintColor = primaryDarkColor
        UINavigationBar.appearance().tintColor = ternaryLightColor
        UITableView.appearance().backgroundColor = ternaryColor
        UITableViewCell.appearance().backgroundColor = ternaryLightColor
        UISearchBar.appearance().barStyle = .black
        UITextField.appearance().defaultTextAttributes = [NSAttributedString.Key.foregroundColor: ternaryLightColor]
        UILabel.appearance(whenContainedInInstancesOf: [UIButton.self]).textColor = accentColor
        UIButton.appearance().layer.cornerRadius = 3
        UIButton.appearance().layer.borderColor = accentColor.cgColor
        UIButton.appearance().layer.borderWidth = 1
    }
    
    func apply(safariViewController: SFSafariViewController) {
        safariViewController.preferredControlTintColor = ternaryLightColor
        safariViewController.preferredBarTintColor = primaryDarkColor
    }
}

struct Themes {
    
    static var current: Theme = DarkTheme()
    
    struct DarkTheme: Theme {
        var primaryColor: UIColor {
            return color(41, 42, 47)
        }
        var primaryLightColor: UIColor {
            return color(81, 82, 88)
        }
        var primaryDarkColor: UIColor {
            return color(0, 0, 5)
        }
        var secondaryColor: UIColor {
            return color(64, 65, 69)
        }
        var secondaryLightColor: UIColor {
            return color(107, 108, 112)
        }
        var secondaryDarkColor: UIColor {
            return color(26, 27, 30)
        }
        var ternaryColor: UIColor {
            return color(245, 245, 246)
        }
        var ternaryLightColor: UIColor {
            return color(255, 255, 255)
        }
        var ternaryDarkColor: UIColor {
            return color(225, 226, 225)
        }
        var accentColor: UIColor {
            return color(132, 74, 168)
        }
    }
}

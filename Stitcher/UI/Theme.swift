//
//  Theme.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/25/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

protocol Theme {
    var primaryColor: UIColor { get }
    var primaryLightColor: UIColor { get }
    var primaryDarkColor: UIColor { get }
    var primaryTextColor: UIColor { get }
    
    var secondaryColor: UIColor { get }
    var secondaryLightColor: UIColor { get }
    var secondaryDarkColor: UIColor { get }
    var secondaryTextColor: UIColor { get }
}

extension Theme {
    
    func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
    func apply() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : primaryTextColor]
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : primaryTextColor]
        UINavigationBar.appearance().prefersLargeTitles = true
        UILabel.appearance().textColor = primaryTextColor
        UINavigationBar.appearance().barTintColor = primaryDarkColor
        UINavigationBar.appearance().tintColor = primaryTextColor
        UITableView.appearance().backgroundColor = secondaryColor
        UITableViewCell.appearance().backgroundColor = secondaryColor
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
        var primaryTextColor: UIColor {
            return color(255, 255, 255)
        }
        var secondaryTextColor: UIColor {
            return color(255, 255, 255)
        }
    }
}

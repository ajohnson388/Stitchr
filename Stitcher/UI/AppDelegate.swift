//
//  AppDelegate.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            return true
        } else {
            initApp()
            addShortcutsIfNeeded(to: application)
            return true
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard LocalCache().userCredentials != nil else {
            completionHandler(false)
            return
        }
        initApp()
        // TODO: Open new playlist
    }
    
    private func initApp() {
        window = UIWindow.make()
        window?.initApp()
    }
    
    private func addShortcutsIfNeeded(to application: UIApplication) {
        if LocalCache().userCredentials != nil {
            addShortcuts(application: application)
        }
    }

    private func addShortcuts(application: UIApplication) {
        let createPlaylistShortcut = UIMutableApplicationShortcutItem(
            type: "CreatePlaylist",
            localizedTitle: Strings.createPlaylistShortcutTitle.localized,
            localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add),
            userInfo: nil
        )
        application.shortcutItems = [createPlaylistShortcut]
    }
}


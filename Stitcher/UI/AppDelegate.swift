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
        initApp()
        addShortcutsIfNeeded(to: application)
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard LocalCache().userCredentials != nil else {
            completionHandler(false)
            return
        }
        initApp()
        // TODO: Open new playlist
    }
    
    private func addShortcutsIfNeeded(to application: UIApplication) {
        if LocalCache().userCredentials != nil {
            addShortcuts(application: application)
        }
    }
    
    private func initApp() {
        let deviceType = UIDevice.current.userInterfaceIdiom
        switch deviceType {
        case .pad:
            let controller = makeContainerViewController()
            initApp(withViewController: controller)
        case .phone:
            let controller = PlaylistsViewController.make()
            let navController = UINavigationController(rootViewController: controller)
            initApp(withViewController: navController)
        default:
            fatalError("\(deviceType) is not supported.")
        }
    }
    
    private func initApp(withViewController viewController: UIViewController) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = viewController
        Themes.current.apply()
    }
    
    private func makeContainerViewController() -> ContainerViewController {
        let splitViewController = ContainerViewController()
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.viewControllers = [
            UINavigationController(rootViewController: PlaylistsViewController.make()),
            UINavigationController(rootViewController: PlaylistViewController.make())
        ]
        return splitViewController
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


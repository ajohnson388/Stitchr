//
//  AppDelegate.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let controller = makePlaylistsViewController()
        let navController = UINavigationController(rootViewController: controller)
        initApp(withViewController: navController)
        
        if LocalCache().isUserAuthorized {
            addShortcuts(application: application)
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        OAuth2Swift.handle(url: url)
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard LocalCache().isUserAuthorized else {
            completionHandler(false)
            return
        }
        let playlistsViewController = makePlaylistsViewController()
        let navController = UINavigationController(rootViewController: playlistsViewController)
        playlistsViewController.openPlaylist(playlist: nil, animated: false)
        initApp(withViewController: navController)
    }
    
    private func initApp(withViewController viewController: UIViewController) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = viewController
        Themes.current.apply()
    }
    
    private func makePlaylistsViewController() -> PlaylistsViewController {
        let cache = LocalCache()
        let spotifyApi = SpotifyApi(cache: cache)
        let presenter = PlaylistsPresenter(cache: cache, spotifyApi: spotifyApi)
        cache.delegate = presenter
        return PlaylistsViewController(presenter: presenter)
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


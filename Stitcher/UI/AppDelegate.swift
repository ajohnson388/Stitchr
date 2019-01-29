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
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let cache = LocalCache()
        let spotifyApi = SpotifyApi(cache: cache)
        let presenter = PlaylistsPresenter(cache: cache, spotifyApi: spotifyApi)
        cache.delegate = presenter
        let controller = PlaylistsViewController(presenter: presenter)
        let navController = UINavigationController(rootViewController: controller)
        window?.rootViewController = navController
        
        Themes.current.apply()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        OAuth2Swift.handle(url: url)
        return true
    }
}


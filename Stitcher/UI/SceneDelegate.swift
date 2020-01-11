//
//  SceneDelegate.swift
//  Stitcher
//
//  Created by Andrew Johnson on 12/21/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        connectionOptions
        guard let windowscene = scene as? UIWindowScene else {
            return
        }
        initApp(withScene: windowscene)
    }
    
    private func addShortcutsIfNeeded(to application: UIApplication) {
        if LocalCache().userCredentials != nil {
            addShortcuts(application: application)
        }
    }
    
    private func initApp(withScene scene: UIWindowScene) {
        window = UIWindow.make()
        window?.windowScene = scene
        window?.initApp()
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

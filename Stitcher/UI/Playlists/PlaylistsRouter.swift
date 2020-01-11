//
//  PlaylistsRouter.swift
//  Stitcher
//
//  Created by Andrew Johnson on 6/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

protocol PlaylistsViewControllerRouter: class {
    func openPlaylist(_ playlist: Playlist?)
}

final class PlaylistsRouter: PlaylistsViewControllerRouter {
    
    unowned var viewController: PlaylistsViewController
    
    init(viewController: PlaylistsViewController) {
        self.viewController = viewController
    }
    
    func openPlaylist(_ playlist: Playlist?) {
        guard let containerController = viewController.splitViewController as? ContainerViewController else {
            return
        }
        
        let playlistViewController = PlaylistViewController.make(withPlaylist: playlist,
                                                                 cache: viewController.presenter.cache,
                                                                 api: viewController.presenter.api)
        switch containerController.viewControllers.count {
        case 1:
            openSingleView(playlistViewController: playlistViewController)
        case 2:
            openSplitView(playlistViewController: playlistViewController)
        default:
            return
        }
    }
    
    private func openSplitView(playlistViewController: PlaylistViewController) {
        guard let containerController = viewController.splitViewController as? ContainerViewController,
        let navController = containerController.detailViewController else {
            return
        }
        navController.setViewControllers([playlistViewController], animated: false)
    }
    
    private func openSingleView(playlistViewController: PlaylistViewController) {
        guard let navController = viewController.navigationController else {
            return
        }
        navController.pushViewController(playlistViewController, animated: true)
    }
}

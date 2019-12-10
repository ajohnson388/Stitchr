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
    
    unowned var viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func openPlaylist(_ playlist: Playlist?) {
        // Prep the playlist controller
        let playlistViewController = PlaylistViewController.make(withPlaylist: playlist)
        
        // If iPad search for container view controller
        if UIDevice.isPad {
            guard
            let containerController = viewController.splitViewController as? ContainerViewController,
            let navController = containerController.detailViewController else {
                return
            }
            navController.setViewControllers([playlistViewController], animated: false)
        } else {
            guard let navController = viewController.navigationController else {
                return
            }
            navController.pushViewController(playlistViewController, animated: true)
        }
    }
}

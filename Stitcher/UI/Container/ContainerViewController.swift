//
//  ContainerViewController.swift
//  Stitcher
//
//  Created by Andrew Johnson on 6/18/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

protocol PlaylistsViewControllerDelegate: class {
    func didSelectPlaylist(withId id: String)
    func didCreateNewPlaylist()
    func didDeletePlaylist()
}

/// The base view controller used in iPad and macOS
final class ContainerViewController: UISplitViewController {
    
    var detailViewController: UINavigationController? {
        guard self.viewControllers.count > 1 else {
            return nil
        }
        return self.viewControllers[1] as? UINavigationController
    }
    
    var masterViewController: UINavigationController? {
        return self.viewControllers.first as? UINavigationController
    }
}


extension ContainerViewController: PlaylistsViewControllerObserver {
    
    func didSelectPlaylist(_ playlist: Playlist?) {
        let playlistViewController = makePlaylistViewController(playlist: playlist)
        if UIDevice.isPad {
            detailViewController?.pushViewController(playlistViewController, animated: true)
        } else {
            masterViewController?.pushViewController(playlistViewController, animated: true)
        }
    }
    
    private func makePlaylistViewController(playlist: Playlist?) -> PlaylistViewController {
        let cache = LocalCache()
        let spotifyApi = SpotifyApi(cache: cache)
        let playlistPresenter = PlaylistPresenter(cache: cache, spotifyApi: spotifyApi)
        cache.delegate = playlistPresenter
        playlistPresenter.setPlaylist(playlist: playlist)
        return PlaylistViewController(presenter: playlistPresenter)
    }
    
    func didCreateNewPlaylist() {
        // TODO
    }
    
    func didDeletePlaylist() {
        // TODO
    }
}

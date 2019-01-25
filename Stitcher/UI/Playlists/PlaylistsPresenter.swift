//
//  PlaylistsPresenter.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

protocol PlaylistsPresenterDelegate: class {
    func playlistsDidChange(_ playlists: [Playlist])
    func isUserAuthenticatedDidChangfe(_ isAuthenticated: Bool)
}

class PlaylistsPresenter {
    
    weak var delegate: PlaylistsPresenterDelegate?
    private(set) var playlists = [Playlist]() {
        didSet {
            delegate?.playlistsDidChange(playlists)
        }
    }
    private(set) var isAuthenticated: Bool = false {
        didSet {
            delegate?.isUserAuthenticatedDidChangfe(isAuthenticated)
        }
    }
    
    func login(viewController: UIViewController) {
        SpotifyApi.shared.authorize(viewController: viewController) { isAuthenticated in
            guard isAuthenticated else {
                self.isAuthenticated = false
                return
            }
            
            // Get the user profile now
            SpotifyApi.shared.getUserProfile { profile in
                Cache.shared.userId = profile?.id
                self.isAuthenticated = true
            }
        }
    }
    
    func fetchPlaylists(offset: Int = 0, limit: Int = 20) {
        SpotifyApi.shared.getPlaylists(offset: offset, limit: limit) { pagingResponse in
            self.playlists = pagingResponse?.items ?? []
        }
    }
    
    func selectPlaylist(at index: Int) {
        
    }
}

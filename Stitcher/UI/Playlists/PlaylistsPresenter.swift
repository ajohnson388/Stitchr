//
//  PlaylistsPresenter.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift

protocol PlaylistsPresenterDelegate: class {
    func playlistsDidChange(_ playlists: [Playlist])
    func isUserAuthenticatedDidChange(_ isAuthenticated: Bool)
    func errorDidChange(_ error: String?)
    func isLoadingChanged(_ isLoading: Bool)
}

class PlaylistsPresenter {
    
    weak var delegate: PlaylistsPresenterDelegate?
    
    private let cache: Cache
    private let spotifyApi: SpotifyApi
    
    private(set) var playlists = [Playlist]() {
        didSet {
            delegate?.playlistsDidChange(playlists)
        }
    }
    private(set) var isAuthenticated: Bool {
        didSet {
            delegate?.isUserAuthenticatedDidChange(isAuthenticated)
        }
    }
    private(set) var error: String? {
        didSet {
            delegate?.errorDidChange(error)
        }
    }
    private(set) var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingChanged(isLoading)
        }
    }
    
    init(cache: Cache, spotifyApi: SpotifyApi = SpotifyApi()) {
        self.cache = cache
        self.spotifyApi = spotifyApi
        isAuthenticated = cache.userCredentials != nil
    }
    
    func login(viewController: UIViewController) {
        spotifyApi.authorize(viewController: viewController) { isAuthenticated in
            guard isAuthenticated else {
                self.isAuthenticated = false
                return
            }
            
            // Get the user profile now
            self.spotifyApi.getUserProfile { profile in
                self.cache.userId = profile?.id
                self.isAuthenticated = true
            }
        }
    }
    
    func fetchPlaylists(offset: Int = 0, limit: Int = 20) {
        isLoading = true
        spotifyApi.getPlaylists(offset: offset, limit: limit) { pagingResponse in
            self.playlists = pagingResponse?.items ?? []
            self.isLoading = false
        }
    }
}


extension PlaylistsPresenter: CacheDelegate {
    
    func userCredentialsDidChange(_ credentials: OAuthSwiftCredential?) {
        isAuthenticated = credentials != nil
    }
}

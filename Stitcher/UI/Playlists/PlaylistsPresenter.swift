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

protocol PlaylistsPresenterDelegate: BasePresenterDelegate {
    func playlistsDidChange(_ playlists: [Playlist])
}

class PlaylistsPresenter: BasePresenter {
    
    weak var playlistsDelegate: PlaylistsPresenterDelegate? {
        didSet {
            self.delegate = playlistsDelegate
        }
    }
    
    private(set) var playlists = [Playlist]() {
        didSet {
            error = nil
            playlistsDelegate?.playlistsDidChange(playlists)
        }
    }
    
    override init(cache: Cache, spotifyApi: SpotifyApi) {
        super.init(cache: cache, spotifyApi: spotifyApi)
    }
    
    func fetchPlaylists(offset: Int = 0, limit: Int = 20) {
        isLoading = true
        error = nil
        spotifyApi.getPlaylists(offset: offset, limit: limit) { pagingResponse in
            self.isLoading = false
            
            // If the response is missing show an error
            guard let pagingResponse = pagingResponse else {
                self.error = "Failed to fetch playlists."
                return
            }
            
            // Update the playlists
            self.playlists = self.filterPlaylists(pagingResponse.items)
        }
    }
    
    private func filterPlaylists(_ playlists: [Playlist]) -> [Playlist] {
        let userId = cache.userId
        return playlists.filter {
            return $0.owner.id == userId || $0.collaborative
        }
    }
}

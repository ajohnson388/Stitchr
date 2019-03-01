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
    
    let playlistsDataSource = PlaylistsDataSource()
    private let playlistsBatchSize = 30
    private var nextStartIndex = 0
    
    override init(cache: Cache, spotifyApi: SpotifyApi) {
        super.init(cache: cache, spotifyApi: spotifyApi)
        playlistsDataSource.delegate = self
    }
}


extension PlaylistsPresenter: PlaylistsDataSourceDelegate {
    
    func fetchItems(startIndex: Int, amount: Int, completion: @escaping (PagerResult<Playlist>) -> ()) {
        isLoading = startIndex == 0  // Only show empty loading screen if not doing a paging fetch
        error = nil
        spotifyApi.getPlaylists(offset: startIndex, limit: amount) { pagingResponse in
            self.isLoading = false
            
            // If the response is missing show an error
            guard let pagingResponse = pagingResponse else {
                self.error = "Failed to fetch playlists."
                completion(.error)
                return
            }
            
            // Update the playlists
            let result = PagerResult.success(items: pagingResponse.items)
            completion(result)
        }
    }
    
    func itemsDidUpdate(_ items: [Playlist]) {
        playlistsDelegate?.playlistsDidChange(items)
    }
    
    func filterItems(_ items: [Playlist]) -> [Playlist] {
        let userId = cache.userId
        return items.filter {
            return $0.owner.id == userId || $0.collaborative
        }
    }
}

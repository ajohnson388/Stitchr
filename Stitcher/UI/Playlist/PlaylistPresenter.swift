//
//  PlaylistPresenter.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/25/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

protocol PlaylistPresenterDelegate: class {
    func tracksDidChange(_ tracks: [TrackItem])
    func searchResultsDidChange(_ tracks: [Track])
}

final class PlaylistPresenter {
    
    weak var delegate: PlaylistPresenterDelegate?
    
    var playlist: Playlist?
    private let cache: Cache
    private let spotifyApi: SpotifyApi
    
    private(set) var tracks: [TrackItem] = [] {
        didSet { delegate?.tracksDidChange(tracks) }
    }
    private(set) var searchResults: [Track] = [] {
        didSet { delegate?.searchResultsDidChange(searchResults) }
    }
    
    init(cache: Cache, spotifyApi: SpotifyApi = SpotifyApi()) {
        self.cache = cache
        self.spotifyApi = spotifyApi
    }
    
    func setPlaylist(playlist: Playlist?) {
        self.playlist = playlist
    }
    
    func loadTracks() {
        guard let playlist = playlist else { return }
        spotifyApi.getPlaylistTracks(playlistId: playlist.id) { pagingResponse in
            let items = pagingResponse?.items ?? []
            self.tracks = items
        }
     }
    
    func search(text: String) {
        guard !text.isEmpty else {
            self.searchResults = []
            return
        }
        
        spotifyApi.searchTracks(searchTerm: text) { searchResponse in
            self.searchResults = searchResponse?.tracks.items ?? []
        }
    }
    
    func addTrack(at index: Int, completion: @escaping (Bool) -> ()) {
        guard let playlist = playlist else {
            if let userId = cache.userId {
                spotifyApi.createPlaylist(name: Strings.newPlaylistTitle.localized, userId: userId) { playlist in
                    self.playlist = playlist
                    self.addTrack(at: index, completion: completion)
                    return
                }
            }
            completion(false)
            return
        }
        
        
        let trackUri = searchResults[index].uri
        spotifyApi.addTracksToPlaylist(withId: playlist.id, uris: [trackUri]) { snapshot in
            guard snapshot != nil else {
                completion(false)
                return
            }
            self.loadTracks()
            completion(true)
        }
    }
    
    func removeTrack(at index: Int, completion: @escaping (Bool) -> ()) {
        guard let playlist = playlist, let trackUri = tracks[index].track?.uri else {
            completion(false)
            return
        }
        
        spotifyApi.removeTracksFromPlaylist(withId: playlist.id, uris: [trackUri]) { snapshot in
            guard snapshot != nil else {
                completion(false)
                return
            }
            
            guard let index = self.tracks.firstIndex(where: { $0.track?.uri == trackUri }) else {
                completion(false)
                return
            }
            completion(true)
            self.tracks.remove(at: index)
        }
    }
}

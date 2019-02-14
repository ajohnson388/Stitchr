//
//  PlaylistPresenter.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/25/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import OAuthSwift

protocol PlaylistPresenterDelegate: BasePresenterDelegate {
    func tracksDidChange(_ tracks: [TrackItem])
    func searchResultsDidChange(_ tracks: [Track])
}

final class PlaylistPresenter: BasePresenter {
    
    weak var playlistDelegate: PlaylistPresenterDelegate? {
        didSet {
            self.delegate = playlistDelegate
        }
    }
    
    private var currentSearchRequest: Cancellable?
    var playlist: Playlist?
    
    
    private(set) var tracks: [TrackItem] = [] {
        didSet {
            error = nil
            playlistDelegate?.tracksDidChange(tracks)
        }
    }
    private(set) var searchResults: [Track] = [] {
        didSet { playlistDelegate?.searchResultsDidChange(searchResults) }
    }
    
    override init(cache: Cache, spotifyApi: SpotifyApi = SpotifyApi()) {
        super.init(cache: cache, spotifyApi: spotifyApi)
    }
    
    func setPlaylist(playlist: Playlist?) {
        self.playlist = playlist
    }
    
    func loadTracks() {
        // Get the playlist or clear the list if creating one
        guard let playlist = playlist else {
            self.tracks = []
            return
        }
        
        // Set the loading state and get the tracks
        isLoading = true
        spotifyApi.getPlaylistTracks(playlistId: playlist.id) { pagingResponse in
            self.isLoading = false
            
            // Show an error if the response is missing
            guard let tracks = pagingResponse?.items else {
                self.error = "Failed to load the tracks."
                return
            }
            self.tracks = tracks
        }
    }
    
    func loadPlaylistTitle() {
        spotifyApi
    }
    
    func search(text: String) {
        // Skip search if there is no text
        guard !text.isEmpty else {
            self.searchResults = []
            return
        }
        
        // Cancel any previous search requests and begin loading
        currentSearchRequest?.cancel()
        isLoading = true
        let request = spotifyApi.searchTracks(searchTerm: text) { searchResponse in
            self.isLoading = false
            
            // Skip if the search was cancelled
            guard let searchResults = searchResponse?.tracks.items else {
                // TODO: self.error = "Failed to load the tracks." or cancelled
                return
            }
            
            // Remove the request from pending and store the results
            self.searchResults = searchResults
            self.currentSearchRequest = nil
        }
        currentSearchRequest = request
    }
    
    func addTrack(at index: Int, completion: @escaping (Bool) -> ()) {
        // Get the playlist or create it
        guard let playlist = playlist else {
            createPlaylist(withTrackAt: index, completion: completion)
            return
        }
        
        // Add the track to the playlist
        let track = searchResults[index]
        spotifyApi.addTracksToPlaylist(withId: playlist.id, uris: [track.uri]) { snapshot in
            // Show an error if the response is missing
            guard snapshot != nil else {
                completion(false)
                // TODO: self.error = "Failed to add \(track.name) to the playlist."
                return
            }
            
            // Reload the tracks to display it in the list
            self.loadTracks()
            completion(true)
        }
    }
    
    func createPlaylist(withTrackAt index: Int, completion: @escaping (Bool) -> ()) {
        guard let userId = cache.userId else {
            completion(false)  // TODO: Fetch profile?
            return
        }
        spotifyApi.createPlaylist(name: Strings.newPlaylistTitle.localized, userId: userId) { playlist in
            // Show an error if the response is missing
            guard let playlist = playlist else {
                completion(false)
                // TODO: self.error = "Failed to create the playlist."
                return
            }
            // Store the new playlist and add the track
            self.playlist = playlist
            self.addTrack(at: index, completion: completion)
            return
        }
    }
    
    func removeTrack(at index: Int, completion: @escaping (Bool) -> ()) {
        // Assert the playlist and track exist
        guard let playlist = playlist, let track = tracks[index].track else {
            completion(false)
            return
        }
        
        // Remove the track from the playlist
        spotifyApi.removeTracksFromPlaylist(withId: playlist.id, uris: [track.uri]) { snapshot in
            
            // Show an error if the response is missing
            guard snapshot != nil else {
                // TODO: self.error = "Failed to remove \(track.name) from the playlist."
                completion(false)
                return
            }
            
            // Assert the track still exists in the table data
            guard let index = self.tracks.firstIndex(where: { $0.track?.uri == track.uri }) else {
                completion(false)
                return
            }
            
            // End the remove action and update the data source
            completion(true)
            self.tracks.remove(at: index)
        }
    }
    
    func reorderTrack(fromIndex: Int, toIndex: Int, completion: @escaping (Bool) -> ()) {
        // Assert the playlist and track exist
        guard let playlist = playlist, fromIndex != toIndex else {
            completion(false)
            return
        }
        
        // Remove the track from the playlist
        let spotifyToIndex = toIndex > fromIndex ? toIndex + 1 : toIndex
        spotifyApi.reorderTracksInPlaylist(withId: playlist.id, fromIndex: fromIndex, toIndex: spotifyToIndex) { snapshot in
            
            // Show an error if the response is missing
            guard snapshot != nil else {
                // TODO: self.error = "Failed to remove \(track.name) from the playlist."
                completion(false)
                return
            }
            
            // Update the model
            let track = self.tracks.remove(at: fromIndex)
            self.tracks.insert(track, at: toIndex)
            completion(true)
        }
    }
}

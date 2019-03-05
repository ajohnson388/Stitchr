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

    let tracksDataSource = TracksDataSource()
    let searchDataSource = SearchDataSource()
    var playlist: Playlist?
    weak var playlistDelegate: PlaylistPresenterDelegate? {
        didSet {
            self.delegate = playlistDelegate
        }
    }
    
    private var currentSearchRequest: Cancellable?
    private var searchText: String?
    
    override init(cache: Cache, spotifyApi: SpotifyApi = SpotifyApi()) {
        super.init(cache: cache, spotifyApi: spotifyApi)
        tracksDataSource.batchSize = 30
        tracksDataSource.delegate = self
        searchDataSource.delegate = self
    }
    
    func setPlaylist(playlist: Playlist?) {
        self.playlist = playlist
    }
    
    func search(_ text: String?) {
        searchText = text
        searchDataSource.refresh()
    }
    
    func addTrack(at index: Int, completion: @escaping (Bool) -> ()) {
        // Get the playlist or create it
        guard let playlist = playlist else {
            createPlaylist(withTrackAt: index, completion: completion)
            return
        }
        
        // Add the track to the playlist
        let track = searchDataSource.items[index]
        spotifyApi.addTracksToPlaylist(withId: playlist.id, uris: [track.uri]) { snapshot in
            // Show an error if the response is missing
            guard snapshot != nil else {
                completion(false)
                // TODO: self.error = "Failed to add \(track.name) to the playlist."
                return
            }
            
            // Reload the tracks to display it in the list
            self.tracksDataSource.refresh()
            completion(true)
        }
    }
    
    func createPlaylist(withTrackAt index: Int, completion: @escaping (Bool) -> ()) {
        spotifyApi.createPlaylist(name: Strings.newPlaylistTitle.localized) { playlist in
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
        guard let playlist = playlist, let track = tracksDataSource.items[index].track else {
            Logger.log(#function, "Cannot remove track due to mising playlist or track.")
            completion(false)
            return
        }
        
        // Remove the track from the playlist
        spotifyApi.removeTracksFromPlaylist(withId: playlist.id, uris: [track.uri]) { snapshot in
            
            // Show an error if the response is missing
            guard snapshot != nil else {
                completion(false)
                return
            }
            
            // Assert the track still exists in the table data
            guard let index = self.tracksDataSource.items.firstIndex(where: { $0.track?.uri == track.uri }) else {
                completion(false)
                return
            }
            
            // End the remove action and update the data source
            completion(true)
            self.tracksDataSource.removeItem(at: index)
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
            self.tracksDataSource.moveItem(from: fromIndex, to: toIndex)
            completion(true)
        }
    }
}


// MARK: - Tracks Source Delegate

extension PlaylistPresenter: TracksDataSourceDelegate {
    
    func fetchItems(startIndex: Int, amount: Int, completion: @escaping (PagerResult<TrackItem>) -> ()) {
        // Get the playlist or clear the list if creating one
        guard let playlist = playlist else {
            completion(.success(items: []))
            return
        }
        
        // Set the loading state and get the tracks
        isLoading = startIndex == 0
        spotifyApi.getPlaylistTracks(playlistId: playlist.id, offset: startIndex, limit: amount) { pagingResponse in
            self.isLoading = false
            
            // Show an error if the response is missing
            guard let tracks = pagingResponse?.items else {
                self.error = "Failed to load the tracks."
                completion(.error)
                return
            }
            completion(.success(items: tracks))
        }
    }
    
    func itemsDidUpdate(_ items: [TrackItem]) {
        playlistDelegate?.tracksDidChange(items)
    }
    
    func filterItems(_ items: [TrackItem]) -> [TrackItem] {
        return items
    }
}


// MARK: - Search Source Delegate

extension PlaylistPresenter: SearchDataSourceDelegate {
    
    func fetchItems(startIndex: Int, amount: Int, completion: @escaping (PagerResult<Track>) -> ()) {
        guard let searchText = searchText, !searchText.isEmpty else {
            completion(PagerResult.success(items: []))
            return
        }
        // Cancel any previous search requests and begin loading
        currentSearchRequest?.cancel()
        isLoading = true
        let request = spotifyApi.searchTracks(searchTerm: searchText, offset: startIndex, limit: amount) { searchResponse in
            self.isLoading = false
            
            // Skip if the search was cancelled
            guard let searchResults = searchResponse?.tracks.items else {
                // TODO: self.error = "Failed to load the tracks." or cancelled
                completion(PagerResult.error)
                return
            }
            
            // Remove the request from pending and store the results
            completion(.success(items: searchResults))
            self.currentSearchRequest = nil
        }
        currentSearchRequest = request
    }
    
    func itemsDidUpdate(_ items: [Track]) {
        playlistDelegate?.searchResultsDidChange(items)
    }
    
    func filterItems(_ items: [Track]) -> [Track] {
        return items
    }
}

//
//  SpotifyApi.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import Alamofire
import SafariServices


/// An implmentation of the Spotify API used for making authenticated requests.
final class SpotifyApi {
    
    // MARK: - Properties
    
    /// The base url for the Spotify user api.
    static let apiBaseUrl = "https://api.spotify.com/v1/"
    
    private let spotifyOAuth: SpotifyOAuth
    private let cache: Cache
    
    
    // MARK: - Lifecycle
    
    /// Instantiates the Spotify API wrapper with dependencies.
    ///
    /// - Parameter cache: The local cache for accessing authorization data.
    init(cache: Cache = LocalCache()) {
        self.cache = cache
        spotifyOAuth = SpotifyOAuth(cache: cache)
        spotifyOAuth.delegate = self
    }
    
    
    // MARK: - API
    
    /// Makes a request to authorize Spotify via system level authentication.
    func authorize() {
        spotifyOAuth.authorizeSpotify()
    }
    
    /// Fetches the profile of the current user.
    ///
    /// - Parameter completion: A callback that returns the user's profile, or nil, if an error occurred.
    func getUserProfile(completion: @escaping (UserProfile?) -> ()) {
        let url = makeUrl(withEndpoint: "me")
        _ = spotifyOAuth.makeJsonRequest(url: url, method: .get, completion: completion)
    }
    
    /// Fetches a playlist for the given id.
    ///
    /// - Parameters:
    ///   - id: The id of the playlist.
    ///   - fields: The fields to return for the playlist.
    ///   - completion: A callback that returns the playlist, or nil, if an error occurred.
    func getPlaylist(withId id: String, fields: [String]? = nil, completion: @escaping (Playlist?) -> ()) {
        let url = makeUrl(withEndpoint: "playlists/\(id)")
        var parameters = [String: Any]()
        if let fields = fields {
            parameters["fields"] = fields.joined(separator: ",")
        }
        _ = spotifyOAuth.makeJsonRequest(url: url, method: .get, parameters: parameters,
                                         encoding: URLEncoding(), completion: completion)
    }
    
    /// Fetches the current user's playlists.
    ///
    /// - Parameters:
    ///   - offset: The index to start at in the search cursor.
    ///   - limit: The maximum amount of tracks to return.
    ///   - completion: A callback that returns the user's playlists, or nil, if an error occurred.
    func getPlaylists(offset: Int = 0, limit: Int = 20, completion: @escaping (PagingResponse<Playlist>?) -> ()) {
        let url = makeUrl(withEndpoint: "me/playlists")
        let parameters = ["offset": offset, "limit": limit]
        _ = spotifyOAuth.makeJsonRequest(url: url, method: .get, parameters: parameters,
                                         encoding: URLEncoding(), completion: completion)
    }
    
    /// Fetches the tracks in a playlist using a pager.
    ///
    /// - Parameters:
    ///   - playlistId: The id of the playlist.
    ///   - offset: The index to start at in the search cursor.
    ///   - limit: The maximum amount of tracks to return.
    ///   - completion: A callback that returns the tracks in the playlist, or nil, if an error occurrred.
    func getPlaylistTracks(playlistId: String, offset: Int = 0, limit: Int = 20,
                           completion: @escaping (PagingResponse<TrackItem>?) -> ()) {
        let url = makeUrl(withEndpoint: "playlists/\(playlistId)/tracks")
        let parameters = ["offset": offset, "limit": limit]
        _ = spotifyOAuth.makeJsonRequest(url: url, method: .get, parameters: parameters,
                                         encoding: URLEncoding(), completion: completion)
    }
    
    /// Makes a paginated search request for tracks that match a search term.
    ///
    /// - Parameters:
    ///   - searchTerm: The search query.
    ///   - offset: The index to start at in the search cursor.
    ///   - limit: The maximum amount of tracks to return.
    ///   - completion: A callback that returns search results, or nil, if an error occurred.
    /// - Returns: A cancellable search request, or nil, if the request could not be constructed.
    func searchTracks(searchTerm: String, offset: Int = 0, limit: Int = 20,
                      completion: @escaping (SearchResponse?) -> ()) -> Cancellable? {
        let url = makeUrl(withEndpoint: "search")
        let parameters = ["q": searchTerm, "limit": "\(limit)", "offset": "\(offset)", "type": "track"]
        return spotifyOAuth.makeJsonRequest(url: url, method: .get, parameters: parameters,
                                            encoding: URLEncoding(), completion: completion)
    }
    
    /// Creates a new playlist with the given name.
    ///
    /// - Parameters:
    ///   - name: The name of the playlist.
    ///   - completion: A callback that returns the new playlist, or nil, if an error occurred.
    func createPlaylist(name: String, completion: @escaping (Playlist?) -> ()) {
        // Fetch the user id, if needed
        guard let userId = cache.userId else {
            completion(nil)
            return
        }
        
        // Create and start the request to create the playlist
        let url = makeUrl(withEndpoint: "users/\(userId)/playlists")
        let parameters: [String: Any] = ["name": name, "public": false]
        _ = spotifyOAuth.makeJsonRequest(url: url, method: .post, parameters: parameters, completion: completion)
    }
    
    /// Adds a set of tracks to a playlist.
    ///
    /// - Parameters:
    ///   - id: The id of the playlist.
    ///   - uris: The uri's of the tracks to add.
    ///   - completion: A callback that returns the new snapshot, or nil, if an error occurs.
    func addTracksToPlaylist(withId id: String, uris: [String], completion: @escaping (SnapshotResponse?) -> ()) {
        let url = makeUrl(withEndpoint: "playlists/\(id)/tracks")
        let parameters = ["uris": uris]
        _ = spotifyOAuth.makeJsonRequest(url: url, method: .post, parameters: parameters, encoding: JSONEncoding(), completion: completion)
    }
    
    /// Removes a set of tracks from a plylist.
    ///
    /// - Parameters:
    ///   - id: The id of the playlist.
    ///   - uris: The uri's of the tracks to remove.
    ///   - completion: A callback that returns the new snapshot of the playlist, or nil, if an error occurs.
    func removeTracksFromPlaylist(withId id: String, uris: [String], completion: @escaping (SnapshotResponse?) -> ()) {
        let url = makeUrl(withEndpoint: "playlists/\(id)/tracks")
        let tracks = uris.map { ["uri": $0] }
        let parameters = ["tracks": tracks]
        _ = spotifyOAuth.makeJsonRequest(url: url, method: .delete, parameters: parameters, completion: completion)
    }

    /// Repositions a track in a playlist to the specified index.
    ///
    /// - Parameters:
    ///   - id: The id of the playlist.
    ///   - fromIndex: The index of the track to reposition.
    ///   - toIndex: The index to move the track to.
    ///   - completion: A callback that returns the new snapshot of the playlist, or nil, if an error occurs.
    func reorderTracksInPlaylist(withId id: String, fromIndex: Int, toIndex: Int, completion: @escaping (SnapshotResponse?) -> ()) {
        let url = makeUrl(withEndpoint: "playlists/\(id)/tracks")
        let parameters = ["range_start": fromIndex, "insert_before": toIndex]
        _ = spotifyOAuth.makeJsonRequest(url: url, method: .put, parameters: parameters, completion: completion)
    }
    
    /// Updates the name of the playlist for the given id.
    ///
    /// - Parameters:
    ///   - id: The id of the playlist.
    ///   - name: The new name of the playlist
    ///   - completion: A callback that returns true if the playlist name was updated.
    func updatePlaylistName(withId id: String, name: String, completion: @escaping (Bool) -> ()) {
        let url = makeUrl(withEndpoint: "playlists/\(id)")
        let parameters = ["name": name]
        _ = spotifyOAuth.makeVoidRequest(url: url, method: .put, parameters: parameters, completion: completion)
    }
    
    private func makeUrl(withEndpoint endpoint: String) -> URL {
        return URL(string: SpotifyApi.apiBaseUrl + endpoint)!
    }
}


// MARK: - OAuth Delegate

extension SpotifyApi: SpotifyOAuthDelegate {
    
    func didAuthorizeSpoitfy(_ isAuthorized: Bool) {
        getUserProfile { userProfile in
            self.cache.userId = userProfile?.id
        }
    }
}

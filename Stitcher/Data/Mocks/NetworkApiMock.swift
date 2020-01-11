//
//  NetworkApiMock.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/2/20.
//  Copyright © 2020 Meaningless. All rights reserved.
//

import Foundation
import UIKit

final class NetworkApiMock: NetworkApi {
    
    private let userProfile = MockFactory.shared.userProfile
    private var playlists = MockFactory.shared.playlists(amount: 20)
    private var tracksLookup = [String: [TrackItem]]()
    private let cache: Cache
    
    init(cache: Cache) {
        self.cache = cache
    }
    
    func authorize(_ viewController: UIViewController) {
        let tokenResponse = TokenResponse(accessToken: "12", tokenType: "test", scope: "test", expiresIn: 2, refreshToken: nil)
        cache.userCredentials = TokenStore(tokenResponse: tokenResponse)
        cache.userId = userProfile.id ?? "Test User"
    }
    
    func getUserProfile(completion: @escaping (UserProfile?) -> ()) {
        completion(userProfile)
    }
    
    func getPlaylist(withId id: String, fields: [String]?, completion: @escaping (Playlist?) -> ()) {
        // Currently unused in code
    }
    
    func getPlaylists(offset: Int, limit: Int, completion: @escaping (PagingResponse<Playlist>?) -> ()) {
        guard offset < playlists.count else {
            completion(nil)
            return
        }
        let requestedEndIndex = offset + limit
        let actualEndIndex = playlists.count - 1;
        let endIndex = requestedEndIndex > actualEndIndex ? actualEndIndex : requestedEndIndex
        let playlistsPage = Array(playlists[offset...endIndex])
        let response = PagingResponse<Playlist>(href: nil, items: playlistsPage, limit: limit,
                                                next: nil, offset: offset, previous: nil,
                                                total: playlistsPage.count)
        completion(response)
    }
    
    func getPlaylistTracks(playlistId: String, offset: Int, limit: Int, completion: @escaping (PagingResponse<TrackItem>?) -> ()) {
        guard let playlist = playlists.first(where: { $0.id == playlistId }) else {
            completion(nil)
            return
        }
        
        if tracksLookup[playlistId] == nil {
            tracksLookup[playlistId] = MockFactory.shared.trackItems(amount: playlist.tracks.total)
        }
        
        let trackItems = tracksLookup[playlistId] ?? []
        let requestedEndIndex = offset + limit
        let actualEndIndex = trackItems.count - 1;
        let endIndex = requestedEndIndex > actualEndIndex ? actualEndIndex : requestedEndIndex
        let tracksPage = Array(trackItems[offset...endIndex])
        let response = PagingResponse<TrackItem>(href: nil, items: tracksPage, limit: limit,
                                                 next: nil, offset: offset, previous: nil,
                                                 total: tracksPage.count)
        completion(response)
    }
    
    func searchTracks(searchTerm: String, offset: Int, limit: Int, completion: @escaping (SearchResponse?) -> ()) -> Cancellable? {
        return nil
    }
    
    func createPlaylist(name: String, completion: @escaping (Playlist?) -> ()) {
        let externalUrls = ExternalUrls(spotify: "")
        let owner = Owner(externalUrls: externalUrls, href: nil, id: "", type: "", uri: "")
        let tracks = Tracks(href: nil, total: 0)
        let playlist = Playlist(collaborative: false, externalUrls: externalUrls, href: nil,
                                id: "New Playlist", images: [], name: name, owner: owner,
                                itemPublic: nil, snapshotID: nil, tracks: tracks, type: "",
                                uri: "")
        self.playlists = [playlist] + self.playlists
        completion(playlist)
    }
    
    func addTracksToPlaylist(withId id: String, uris: [String], completion: @escaping (SnapshotResponse?) -> ()) {
        
    }
    
    func removeTracksFromPlaylist(withId id: String, uris: [String], completion: @escaping (SnapshotResponse?) -> ()) {
        guard var tracks = tracksLookup[id] else {
            completion(nil)
            return
        }
    }
    
    func reorderTracksInPlaylist(withId id: String, fromIndex: Int, toIndex: Int, completion: @escaping (SnapshotResponse?) -> ()) {
        guard var tracks = tracksLookup[id] else {
            completion(nil)
            return
        }
        
        tracks.swapAt(fromIndex, toIndex)
        tracksLookup[id] = tracks
        
        let response = SnapshotResponse(snapshotId: "moved")
        completion(response)
    }
    
    func updatePlaylistName(withId id: String, name: String, completion: @escaping (Bool) -> ()) {
        guard let index = playlists.firstIndex(where: { $0.id == id }) else {
            completion(false)
            return
        }
        var playlist = playlists[index]
        playlist.name = name
        playlists[index] = playlist
        completion(true)
    }
}

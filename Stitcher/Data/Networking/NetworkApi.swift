//
//  NetworkApi.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/2/20.
//  Copyright © 2020 Meaningless. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkApi {
    func authorize(_ viewController: UIViewController)
    func getUserProfile(completion: @escaping (UserProfile?) -> ())
    func getPlaylist(withId id: String, fields: [String]?, completion: @escaping (Playlist?) -> ())
    func getPlaylists(offset: Int, limit: Int, completion: @escaping (PagingResponse<Playlist>?) -> ())
    func getPlaylistTracks(playlistId: String, offset: Int, limit: Int, completion: @escaping (PagingResponse<TrackItem>?) -> ())
    func searchTracks(searchTerm: String, offset: Int, limit: Int, completion: @escaping (SearchResponse?) -> ()) -> Cancellable?
    func createPlaylist(name: String, completion: @escaping (Playlist?) -> ())
    func addTracksToPlaylist(withId id: String, uris: [String], completion: @escaping (SnapshotResponse?) -> ())
    func removeTracksFromPlaylist(withId id: String, uris: [String], completion: @escaping (SnapshotResponse?) -> ())
    func reorderTracksInPlaylist(withId id: String, fromIndex: Int, toIndex: Int, completion: @escaping (SnapshotResponse?) -> ())
    func updatePlaylistName(withId id: String, name: String, completion: @escaping (Bool) -> ())
}

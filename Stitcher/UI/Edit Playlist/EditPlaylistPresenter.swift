//
//  EditPlaylistPresenter.swift
//  Stitcher
//
//  Created by Andrew Johnson on 2/11/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

protocol EditPlaylistPresenterDelegate: BasePresenterDelegate {
    func playlistTitleDidSave(_ isSaved: Bool)
}

class EditPlaylistPresenter: BasePresenter {
    
    weak var editPlaylistDelegate: EditPlaylistPresenterDelegate? {
        didSet {
            self.delegate = editPlaylistDelegate
        }
    }
    
    var playlist: Playlist?
    
    override init(cache: Cache, spotifyApi: SpotifyApi) {
        super.init(cache: cache, spotifyApi: spotifyApi)
    }
    
    func isValidTitle(_ title: String?) -> Bool {
        guard let title = title else {
            return false
        }
        return !title.isEmpty
    }
    
    func savePlaylistTitle(_ title: String?) {
        guard let title = title, isValidTitle(title) else {
            editPlaylistDelegate?.playlistTitleDidSave(true)
            return
        }
        
        guard let playlistId = playlist?.id else {
            createPlaylist(withTitle: title) { isSaved in
                self.editPlaylistDelegate?.playlistTitleDidSave(isSaved)
            }
            return
        }
        
        spotifyApi.updatePlaylistName(withId: playlistId, name: title) { success in
            self.editPlaylistDelegate?.playlistTitleDidSave(success)
        }
    }
    
    func createPlaylist(withTitle title: String, completion: @escaping (Bool) -> ()) {
        spotifyApi.createPlaylist(name: title) { playlist in
            self.playlist = playlist
            completion(playlist != nil)
        }
    }
}

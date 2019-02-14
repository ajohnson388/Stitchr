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
    
    func savePlaylistTitle(_ title: String?) {
        guard let title = title else {
            editPlaylistDelegate?.playlistTitleDidSave(false)
            return
        }
        
        guard title != playlist?.name else {
            editPlaylistDelegate?.playlistTitleDidSave(true)
            return
        }
        
        playlist?.name = title
        guard let playlistId = playlist?.id else {
            createPlaylist(withTitle: title) { isSaved in
                guard isSaved else {
                    self.editPlaylistDelegate?.playlistTitleDidSave(false)
                    return
                }
                self.savePlaylistTitle(title)
            }
            return
        }
        
        spotifyApi.updatePlaylistName(withId: playlistId, name: title) { success in
            self.editPlaylistDelegate?.playlistTitleDidSave(true)
        }
    }
    
    func createPlaylist(withTitle title: String, completion: @escaping (Bool) -> ()) {
        guard let userId = cache.userId else {
            completion(false)
            return
        }
        spotifyApi.createPlaylist(name: title, userId: userId) { playlist in
            self.playlist = playlist
            completion(playlist != nil)
        }
    }
}

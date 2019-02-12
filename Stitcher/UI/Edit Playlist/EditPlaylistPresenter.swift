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
        guard let title = title, let playlistId = playlist?.id else {
            editPlaylistDelegate?.playlistTitleDidSave(false)
            return
        }
        
        spotifyApi.updatePlaylistName(withId: playlistId, name: title) { success in
            self.editPlaylistDelegate?.playlistTitleDidSave(true)
        }
    }
}
